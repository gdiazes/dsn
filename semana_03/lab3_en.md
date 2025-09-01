# An Introductory Guide to Docker on a Ubuntu Environment

## Introduction

Docker is a software platform designed to facilitate the creation, deployment, and execution of applications using containers. Containers allow an application to be packaged with all of its dependencies (libraries, tools, etc.) into a single executable unit.

The objective of this guide is to provide a new student with a fundamental understanding of the Docker lifecycle, from installation to the distribution of a custom image.

### Fundamental Concepts

For effective understanding, it is crucial to differentiate the following terms:

*   **Docker Image**: This is considered an immutable template, similar to a recipe or a blueprint. It contains the base operating system, the application code, and all necessary dependencies.
*   **Docker Container**: This is a running instance of an image. It is an isolated and ephemeral environment where the application lives. Multiple containers can be run from the same image.
*   **Docker Hub**: A public, cloud-based registry where Docker images are stored and distributed. It functions as a central repository for official and community-built images.

---

### Step 1 — Installing the Docker Engine

The installation of Docker is performed from its official repository to ensure the authenticity and the latest version of the software.

**1.1. Updating the Package List**

Before any new installation, the system's package list must be updated.

```bash
sudo apt update
```

**1.2. Installing Prerequisite Packages**

Packages are installed to allow `apt` to manage repositories over HTTPS.

```bash
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```

**1.3. Adding Docker's Official GPG Key**

Docker's GPG key is added to the system to verify the integrity of the downloaded packages.

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

**1.4. Setting Up the Docker Repository**

The official Docker repository is added to the system's software sources. The command is designed to automatically detect the Ubuntu version.

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

**1.5. Installing the Docker Engine**

With the repository configured, the package list is updated again, and the installation of Docker components proceeds.

```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
```

**1.6. Verifying the Docker Service**

To confirm that the installation was successful and the service is running, its status is checked.

```bash
sudo systemctl status docker
```
An output indicating an `active (running)` status is expected.

---

### Step 2 — Permission Configuration (Running without `sudo`)

By default, Docker commands require superuser privileges. To improve usability, the current user can be added to the `docker` group.

**2.1. Adding the User to the `docker` Group**

The `${USER}` environment variable is used to reference the current user.

```bash
sudo usermod -aG docker ${USER}
```

**2.2. Applying the New Permissions**

Group membership changes are not applied to the active terminal session. A new session must be started. This can be achieved by closing and reopening the terminal or by using the following command:

```bash
su - ${USER}
```

**2.3. Verifying Membership**

It should be confirmed that the `docker` group is now part of the user's groups.

```bash
id -nG
```
From this point forward, the `sudo` prefix will no longer be necessary for `docker` commands.

---

### Step 3 — Basic Docker Commands

**3.1. Listing Available Commands**

Executing the `docker` command without arguments displays a complete list of its subcommands and functionalities.

```bash
docker
```

**3.2. Obtaining System Information**

This command provides a detailed summary of the Docker installation, including the number of existing images and containers.

```bash
docker info
```

---

### Step 4 — Managing Docker Images

**4.1. Running the First Image: `hello-world`**

The `docker run` command is the primary method for running containers. If the specified image (`hello-world`) is not found locally, Docker will download (`pull`) it from Docker Hub before creating and running a container from it.

```bash
docker run hello-world
```

**4.2. Searching for Images on Docker Hub**

Public images can be searched for directly from the terminal.

```bash
docker search ubuntu
```

**4.3. Downloading an Image**

To download an image without running it immediately, `docker pull` is used.

```bash
docker pull ubuntu
```

**4.4. Listing Local Images**

The `docker images` command displays all images that have been downloaded to the local system.

```bash
docker images
```

---

### Step 5 — Running an Interactive Container

Next, a container will be run with which one can interact via a shell.

**5.1. Starting an Ubuntu Container with an Interactive Terminal**

The command `docker run -it ubuntu` starts a container and provides access to its terminal.
*   `-i` (interactive): Keeps standard input (STDIN) open.
*   `-t` (TTY): Allocates a pseudo-terminal.
*   `ubuntu`: The base image for the container.

```bash
docker run -it ubuntu
```

The terminal prompt will change, indicating that the current session is inside the container.

**5.2. Operations Inside the Container**

The actions performed below affect only the container's filesystem. Here, Node.js will be installed as an example.

```bash
# Update the package list inside the container
apt update

# Install nodejs
apt install nodejs
```

**5.3. Verifying the Installation**

```bash
node -v
```

**5.4. Exiting the Container**

The `exit` command terminates the main shell process, which in turn stops the container and returns the user to the host system's terminal.

```bash
exit
```

---

### Step 6 — Administering Containers

Containers persist on the system even after they are stopped.

**6.1. Viewing Running Containers**

```bash
docker ps
```

**6.2. Viewing All Containers**

The `-a` flag allows all containers to be listed, including those that are stopped.

```bash
docker ps -a
```

**6.3. Container Lifecycle**

A container can be started, stopped, and removed using its `CONTAINER ID` or its randomly assigned `NAME`.

```bash
# Start a stopped container
docker start CONTAINER_ID_OR_NAME

# Stop a running container
docker stop CONTAINER_ID_OR_NAME

# Remove a stopped container (irreversible action)
docker rm CONTAINER_ID_OR_NAME
```

---

### Step 7 — Creating a New Image from a Container

Changes made within a container (such as the installation of Node.js) can be saved as a new image.

**7.1. The `docker commit` Command**

This command captures the state of a container and packages it into a new image. It is recommended for quick experimentation. The standard practice in production environments is the use of a `Dockerfile`.

```bash
# Replace the values as appropriate
docker commit -m "Added NodeJS" -a "Author" CONTAINER_ID yourusername/ubuntu-nodejs
```

**7.2. Verifying the New Image**

When listing images, the new custom image should appear.

```bash
docker images
```

---

### Step 8 — Distributing Images via Docker Hub

Custom images can be uploaded to Docker Hub for distribution.

**8.1. Authenticating with Docker Hub**

An account on [hub.docker.com](https://hub.docker.com) is required.

```bash
docker login -u yourusername
```

**8.2. Pushing the Image**

The `docker push` command uploads the image to the registry. The image name must follow the `yourusername/image-name` format.

```bash
docker push yourusername/ubuntu-nodejs
```
