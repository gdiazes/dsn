### **Laboratory Guide: Containerizing a Node.js and MongoDB Application with Docker Compose**

#### **Laboratory Objectives**

Upon completion of this lab, the following competencies will have been acquired:
*   To set up a development environment with Docker and Docker Compose on a Linux server.
*   To visualize and understand a containerized application architecture in a virtualized environment.
*   To adapt an existing application to run efficiently inside containers.
*   To externalize application configuration and secrets, following best practices.
*   To create a `docker-compose.yml` file to orchestrate a multi-service application.
*   To implement Docker volumes for data persistence and agile development.
*   To manage startup dependencies between services for a robust launch.

#### **Logical Deployment Topology (Horizontal Flow)**

The following diagram illustrates the complete flow of a user request through the various architectural layers, from the physical host to the database inside the container.

```
+--------------------------------+       +-------------------------------------------------------------------------------------------------------------+
|       LAYER 1: PHYSICAL HOST   |       |                      LAYER 2 & 3: VIRTUAL MACHINE (Ubuntu Server on VMware)                                 |
|       (PC with VMware)         |       |                      IP: 192.168.1.100 (Accessible on the local network)                                    |
|       IP: 192.168.1.50         |       |                                                                                                             |
|                                |       |                                                                                                             |
|     +-------------------+      |       |  +--------------+        +-------------------------------------------------------------------------------+  |
|     |    Web Browser    |      |       |  |   Port 3000  |        |                           LAYER 4: DOCKER ENVIRONMENT                         |  |
|     +-------------------+      |       |  +--------------+        | +-------------------------------------------------------------------------+   |  |
|                                |------>|       ^                  | |                       DOCKER NETWORK: app-network                        |  |  |
+--------------------------------+ Request       | Port             | |                     (Isolated Subnet: 172.20.0.0/16)                     |  |  |
         to http://192.168.1.100:3000    |       | Mapping          | |                                                                          |  |  |
                                         |       |                  | | +--------------------+  DB Connection   +--------------------+         |  |  |
                                         |       +----------------->| | | CONTAINER:         | <--------------> | CONTAINER:         |         |  |  |
                                         |                          | | | nodejs_app         | (Host: 'db')     | mongodb_db         |           |  |  |
                                         |                          | | | IP: 172.20.0.2     | Port: 27017      | IP: 172.20.0.3     |           |  |  |
                                         |                          | | | Int. Port: 8080    |                  | Int. Port: 6379    |           |  |  |
                                         |                          | | +--------------------+                  +---------+----------+           |  |  |
                                         |                          | |                                                   | Persistence          |  |  |
                                         |                          | +---------------------------------------------------|----------------------+  |  |
                                         |                          |                                                     |  v                      |  |
                                         |                          |                                           +---------------------+             |  |
                                         |                          |                                           |   VOLUME: dbdata    |             |  |
                                         |                          |                                           +---------------------+             |  |
                                         |                          +-------------------------------------------------------------------------------+  |
                                         |                                                                                                             |
                                         +-------------------------------------------------------------------------------------------------------------+
```

#### **Prerequisites**
*   VMware Workstation (or another hypervisor) with an Ubuntu Server 24.04.3 LTS Virtual Machine installed and configured with a Bridged Mode network.
*   Terminal access to the VM with `sudo` privileges.

---

### **Procedure**

#### **Step 0: Environment Installation and Setup**

Before handling the application, the Virtual Machine must be prepared with all the necessary tools.

1.  **System Update.** The package list is updated, and existing packages are upgraded to their latest versions to ensure a stable and secure system.
    ```bash
    sudo apt update && sudo apt upgrade -y
    ```

2.  **Install Docker Engine.** Docker is installed using the official repository to ensure the latest and most supported version is obtained.
    ```bash
    # Install packages to allow apt to use a repository over HTTPS
    sudo apt install apt-transport-https ca-certificates curl gnupg -y

    # Add Docker’s official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Set up the Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine
    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    ```

3.  **Configure Docker Permissions (Post-installation).** To avoid the need for `sudo` with every Docker command, the current user is added to the `docker` group.
    ```bash
    sudo usermod -aG docker $USER
    ```
    **IMPORTANT!** For this group change to take effect, it is necessary to log out and log back in, or run the following command:
    ```bash
    newgrp docker
    ```

4.  **Verify Installation.** It is verified that Docker Engine and the Compose plugin have been installed correctly by running version commands.
    ```bash
    docker --version
    docker compose version
    ```

#### **Step 1: Source Code Preparation**

1.  **Clone the project.** The base repository is cloned to obtain the initial application source code.
    ```bash
    git clone https://github.com/jfarfantecsup/delivery-node-mongodb.git app_node
    ```

2.  **Access the project directory.** The newly created directory is entered to execute subsequent commands within its context.
    ```bash
    cd app_node
    ```

3.  **Add a development dependency.** The `package.json` file is modified with `vi` to include `nodemon`, a tool that will automatically restart the application upon code changes, facilitating development.
    ```bash
    vi package.json
    ```
    The `devDependencies` section is added:
    ```json
    "devDependencies": {
        "nodemon": "^1.18.10"
    }
    ```

#### **Step 2: Adapting the Application for Containerization**

1.  **Externalize the port configuration.** The `app.js` file is edited so that the application port is configurable via environment variables.
    ```bash
    vi app.js
    ```
    The `port` constant is modified:
    ```javascript
    const port = process.env.PORT || 8080;
    ```

2.  **Externalize the database credentials.** The `db.js` file is modified to remove hardcoded credentials from the code, a fundamental security practice.
    ```bash
    vi db.js
    ```
    The file's content is replaced to read the configuration from the environment:
    ```javascript
    const mongoose = require('mongoose');
    const { MONGO_USERNAME, MONGO_PASSWORD, MONGO_HOSTNAME, MONGO_PORT, MONGO_DB } = process.env;
    const options = { useNewUrlParser: true, reconnectTries: Number.MAX_VALUE, reconnectInterval: 500, connectTimeoutMS: 10000 };
    const url = `mongodb://${MONGO_USERNAME}:${MONGO_PASSWORD}@${MONGO_HOSTNAME}:${MONGO_PORT}/${MONGO_DB}?authSource=admin`;
    mongoose.connect(url, options).then(() => console.log('MongoDB is connected')).catch((err) => console.log(err));
    ```

3.  **Create the environment file.** An `.env` file is created to store configuration variables. This file should never be versioned in Git.
    ```bash
    vi .env
    ```
    The following content is added:
    ```env
    MONGO_USERNAME=userdemo
    MONGO_PASSWORD=Tecsup
    MONGO_PORT=27017
    MONGO_DB=deliverydb
    ```

4.  **Create the `.dockerignore` file.** This file instructs Docker to ignore specific files during the image build, optimizing size and security.
    ```bash
    vi .dockerignore
    ```
    The following lines are added:
    ```
    .env
    node_modules
    .git
    ```

5.  **Implement a Wait Script.** The `wait-for.sh` script is downloaded. It pauses the application container's execution until the database is ready to accept connections.
    ```bash
    curl -o wait-for.sh https://raw.githubusercontent.com/eficode/wait-for/master/wait-for
    ```
    Execution permissions are then granted to the script.
    ```bash
    chmod +x wait-for.sh
    ```

#### **Step 3: Defining the Orchestration with `docker-compose.yml`**

1.  **Create the orchestration file.** The `docker-compose.yml` file is created, which acts as the "blueprint" for the multi-container application, defining services, networks, and volumes.
    ```bash
    vi docker-compose.yml
    ```
    The following configuration is introduced:
    ```yaml
    version: '3.7'
    services:
      nodejsavilcatoma:
        build: { context: ., dockerfile: Dockerfile }
        image: nodejs-app-lab
        container_name: nodejs_app
        restart: unless-stopped
        env_file: .env
        environment:
          - MONGO_HOSTNAME=db
          - PORT=8080
        ports: ["3000:8080"]
        volumes:
          - .:/home/node/app
          - node_modules:/home/node/app/node_modules
        networks: [app-network]
        command: ./wait-for.sh db:27017 -- /home/node/app/node_modules/.bin/nodemon app.js
      db:
        image: mongo:4.1.8-xenial
        container_name: mongodb_db
        restart: unless-stopped
        env_file: .env
        environment:
          - MONGO_INITDB_ROOT_USERNAME=$MONGO_USERNAME
          - MONGO_INITDB_ROOT_PASSWORD=$MONGO_PASSWORD
        volumes: ["dbdata:/data/db"]
        networks: [app-network]
    networks:
      app-network: { driver: bridge }
    volumes:
      dbdata:
      node_modules:
    ```

2.  **Create the `Dockerfile`.** This file contains the 'recipe' for building the custom Docker image for the Node.js application.
    ```bash
    vi Dockerfile
    ```
    The following content is specified:
    ```Dockerfile
    FROM node:14
    WORKDIR /home/node/app
    COPY package*.json ./
    RUN npm install
    COPY . .
    CMD [ "node", "app.js" ]
    ```

#### **Step 4: Launching and Managing the Environment**

1.  **Build and start the environment.** A single command is used to read the `docker-compose.yml`, build the custom image, and start all services in the background (`-d`).
    ```bash
    docker compose up -d --build
    ```

2.  **Verify the status.** The state of the containers is checked to confirm that both services have started correctly.
    ```bash
    docker compose ps
    ```

#### **Step 5: Functional Verification**

1.  **Connect to the database.** An interactive shell is accessed inside the database container to verify that it has initialized correctly.
    ```bash
    docker exec -it mongodb_db mongo -u userdemo -p Tecsup --authenticationDatabase admin
    ```
    Inside the Mongo client, inspection commands are executed:
    ```
    show dbs
    use deliverydb
    db.pedidos.find()
    exit
    ```

2.  **Test the application.** The final test is performed by opening a browser on the Physical Host and navigating to `http://<YOUR_VM_IP>:3000`.

#### **Step 6: Environment Cleanup**

1.  **Tear down the environment.** All resources (containers, networks) created by Docker Compose are stopped and removed.
    ```bash
    docker compose down
    ```

#### **Conclusion**

By executing this guide, a server has been configured, and a fully containerized two-tier application has been built and deployed, establishing a robust, reproducible, and isolated development environment.
