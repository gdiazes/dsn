
### **Guía de Laboratorio: Contenerización de una Aplicación Node.js y MongoDB con Docker Compose**

#### **Objetivos del Laboratorio**

Al finalizar este laboratorio, se habrán adquirido las competencias para:
*   Configurar un entorno de desarrollo con Docker y Docker Compose en un servidor Linux.
*   Visualizar y comprender una arquitectura de aplicación contenerizada en un entorno virtualizado.
*   Adaptar una aplicación existente para que funcione eficientemente dentro de contenedores.
*   Externalizar la configuración y los secretos de la aplicación.
*   Crear un archivo `docker-compose.yml` para orquestar una aplicación multi-servicio.
*   Implementar volúmenes de Docker para persistencia de datos y desarrollo ágil.
*   Gestionar dependencias de arranque entre servicios para un inicio robusto.

#### **Topología Lógica del Despliegue (Flujo Horizontal)**

El siguiente diagrama ilustra el flujo completo de una petición del usuario a través de las distintas capas de la arquitectura, desde el anfitrión físico hasta la base de datos dentro del contenedor.

```
+--------------------------------+       +--------------------------------------------------------------------------------------------------------------+
|      CAPA 1: HOST FÍSICO       |       |                                 CAPA 2 & 3: MÁQUINA VIRTUAL (Ubuntu Server en VMware)                        |
|      (PC con VMware)           |       |                                 IP: 192.168.1.100 (Accesible en la red local)                                |
|      IP: 192.168.1.50          |       |                                                                                                              |
|                                |       |                                                                                                              |
|     +-------------------+      |       |  +--------------+        +--------------------------------------------------------------------------------+  |
|     |  Navegador Web    |      |       |  | Puerto 3000  |        |                        CAPA 4: ENTORNO DOCKER                                  |  |
|     +-------------------+      |       |  +--------------+        | +--------------------------------------------------------------------------+   |  |
|                                |<----->|        ^                 | |                       RED DOCKER: app-network                            |   |  |
+--------------------------------+ Petición      | Mapeo            | |                     (Subred Aislada: 172.20.0.0/16)                      |   |  |
           a http://192.168.1.100:3000   |       | de Puerto        | |                                                                          |   |  |
                                         |       |                  | | +--------------------+  Conexión a BD  +--------------------+            |   |  |
                                         |       |                  | | | CONTENEDOR:        | -------------> | CONTENEDOR:        |             |   |  |
                                         |       +------------------| | | nodejs_app         | (Host: 'db')   | mongodb_db         |             |   |  |
                                         |                          | | | IP: 172.20.0.2     | Puerto: 27017  | IP: 172.20.0.3     |             |   |  |
                                         |                          | | | Puerto Int: 8080   |                | Puerto Int: 6379   |             |   |  |
                                         |                          | | +--------------------+                +---------+----------+             |   |  |
                                         |                          | |                                                 | Persistencia           |   |  |
                                         |                          |  +-------------------------------------------------|----------------------+    |  |
										 |                          |                                                    |  v                        |  |
                                         |                          |                                         +---------------------+                |  |
										 |    					    |                                         |   VOLUMEN: dbdata   |                |  |
                                         |                          |                                         +---------------------+                |  |
                                         |                          +--------------------------------------------------------------------------------+  |
                                         |                                                                                                              |
                                         |                                                                                                              |
                                         +--------------------------------------------------------------------------------------------------------------+
```
### **Estructura de Archivos del Proyecto**

```
app_node/
├── .git/
├── models/
│   └── pedido.js
├── public/
│   └── ... (archivos estáticos de la app)
├── routes/
│   └── index.js
├── .dockerignore         <- Archivo de exclusión para Docker
├── .env                  <- Archivo de configuración y secretos
├── app.js                <- Lógica principal de la aplicación Node.js
├── db.js                 <- Lógica de conexión a la base de datos
├── docker-compose.yml    <- Orquestador de la aplicación multi-contenedor
├── Dockerfile            <- Receta para construir la imagen de la aplicación
├── package.json          <- Manifiesto del proyecto y dependencias
├── package-lock.json
└── wait-for.sh           <- Script de utilidad para sincronización de servicios
```
#### **Prerrequisitos**
*   VMware Workstation (u otro hipervisor) con una Máquina Virtual de Ubuntu Server 24.04.3 LTS instalada y configurada con red en modo puente (Bridged Mode).
*   Acceso a la terminal de la VM con privilegios `sudo`.

---

### **Procedimiento**

#### **Paso 0: Instalación y Configuración del Entorno**

Antes de manipular la aplicación, se debe preparar la Máquina Virtual con todas las herramientas necesarias.

1.  **Actualización del Sistema.** Se actualiza la lista de paquetes y se actualizan los paquetes existentes a sus últimas versiones para asegurar un sistema estable y seguro.
    ```bash
    sudo apt update && sudo apt upgrade -y
    ```

2.  **Instalación de Docker Engine.** Se instala Docker utilizando el repositorio oficial para garantizar que se obtiene la versión más reciente y soportada.
    ```bash
    # Instalar paquetes necesarios para permitir a apt usar un repositorio sobre HTTPS
    sudo apt install apt-transport-https ca-certificates curl gnupg -y

    # Agregar la clave GPG oficial de Docker
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Configurar el repositorio de Docker
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Instalar Docker Engine
    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    ```

3.  **Configuración de Permisos para Docker (Post-instalación).** Para evitar la necesidad de usar `sudo` con cada comando de Docker, el usuario actual es agregado al grupo `docker`.
    ```bash
    sudo usermod -aG docker $USER
    ```
    **¡IMPORTANTE!** Para que este cambio de grupo tenga efecto, es necesario cerrar la sesión actual y volver a iniciarla, o ejecutar el siguiente comando:
    ```bash
    newgrp docker
    ```

4.  **Verificación de la Instalación.** Se verifica que Docker Engine y el plugin de Compose se han instalado correctamente ejecutando comandos de versión.
    ```bash
    docker --version
    docker compose version
    ```

#### **Paso 1: Preparación del Código Fuente**

1.  **Clonación del proyecto.** Se clona el repositorio base para obtener el código fuente inicial de la aplicación.
    ```bash
    git clone https://github.com/jfarfantecsup/delivery-node-mongodb.git app_node
    ```

2.  **Acceso al directorio del proyecto.** Se accede al directorio recién creado para ejecutar los siguientes comandos en su contexto.
    ```bash
    cd app_node
    ```

3.  **Adición de dependencia de desarrollo.** Se modifica el archivo `package.json` con `vi` para incluir `nodemon`, una herramienta que reiniciará automáticamente la aplicación ante cambios en el código, facilitando el desarrollo.
    ```bash
    vi package.json
    ```
    Se agrega la sección `devDependencies`:
    ```json
    "devDependencies": {
        "nodemon": "^1.18.10"
    }
    ```

#### **Paso 2: Adaptación de la Aplicación para Contenerización**

1.  **Externalización de la configuración del puerto.** Se edita el archivo `app.js` para que el puerto de la aplicación sea configurable a través de variables de entorno.
    ```bash
    vi app.js
    ```
    La constante `port` es modificada:
    ```javascript
    const port = process.env.PORT || 8080;
    ```

2.  **Externalización de las credenciales de la base de datos.** Se modifica `db.js` para eliminar las credenciales fijas del código, una práctica de seguridad fundamental.
    ```bash
    vi db.js
    ```
    El contenido del archivo es reemplazado para leer la configuración desde el entorno:
    ```javascript
    const mongoose = require('mongoose');
    const { MONGO_USERNAME, MONGO_PASSWORD, MONGO_HOSTNAME, MONGO_PORT, MONGO_DB } = process.env;
    const options = { useNewUrlParser: true, reconnectTries: Number.MAX_VALUE, reconnectInterval: 500, connectTimeoutMS: 10000 };
    const url = `mongodb://${MONGO_USERNAME}:${MONGO_PASSWORD}@${MONGO_HOSTNAME}:${MONGO_PORT}/${MONGO_DB}?authSource=admin`;
    mongoose.connect(url, options).then(() => console.log('MongoDB is connected')).catch((err) => console.log(err));
    ```

3.  **Creación del archivo de entorno.** Se crea el archivo `.env` para almacenar las variables de configuración. Este archivo nunca debe ser versionado en Git.
    ```bash
    vi .env
    ```
    Se agrega el siguiente contenido:
    ```env
    MONGO_USERNAME=userdemo
    MONGO_PASSWORD=Tecsup
    MONGO_PORT=27017
    MONGO_DB=deliverydb
    ```

4.  **Creación del archivo `.dockerignore`.** Este archivo instruye a Docker para que ignore archivos específicos durante la construcción de la imagen, optimizando su tamaño y seguridad.
    ```bash
    vi .dockerignore
    ```
    Se agregan las siguientes líneas:
    ```
    .env
    node_modules
    .git
    ```

5.  **Implementación de un Script de Espera.** Se descarga el script `wait-for.sh`, que pausa la ejecución del contenedor de la aplicación hasta que la base de datos esté lista para aceptar conexiones.
    ```bash
    curl -o wait-for.sh https://raw.githubusercontent.com/eficode/wait-for/master/wait-for
    ```
    Se le otorgan permisos de ejecución al script.
    ```bash
    chmod +x wait-for.sh
    ```

#### **Paso 3: Definición de la Orquestación con `docker-compose.yml`**

1.  **Creación del archivo de orquestación.** Se crea el archivo `docker-compose.yml`, que actúa como el "plano" de la aplicación multi-contenedor, definiendo servicios, redes y volúmenes.
    ```bash
    vi docker-compose.yml
    ```
    Se introduce la siguiente configuración:
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

2.  **Creación del `Dockerfile`.** Este archivo contiene la 'receta' para construir la imagen Docker personalizada de la aplicación Node.js.
    ```bash
    vi Dockerfile
    ```
    Se especifica el siguiente contenido:
    ```Dockerfile
    FROM node:14
    WORKDIR /home/node/app
    COPY package*.json ./
    RUN npm install
    COPY . .
    CMD [ "node", "app.js" ]
    ```

#### **Paso 4: Levantamiento y Gestión del Entorno**

1.  **Construcción e inicio del entorno.** Se utiliza un único comando para leer el `docker-compose.yml`, construir la imagen personalizada e iniciar todos los servicios en segundo plano (`-d`).
    ```bash
    docker compose up -d --build
    ```

2.  **Verificación del estado.** Se comprueba el estado de los contenedores para confirmar que ambos servicios se han iniciado correctamente.
    ```bash
    docker compose ps
    ```

#### **Paso 5: Verificación Funcional**

1.  **Conexión a la base de datos.** Se accede a una shell interactiva dentro del contenedor de la base de datos para verificar que se ha inicializado correctamente.
    ```bash
    docker exec -it mongodb_db mongo -u userdemo -p Tecsup --authenticationDatabase admin
    ```
    Dentro del cliente Mongo, se ejecutan comandos de inspección:
    ```
    show dbs
    use deliverydb
    db.pedidos.find()
    exit
    ```

2.  **Prueba de la aplicación.** Se realiza la prueba final abriendo un navegador en el Host Físico y accediendo a `http://<IP_DE_LA_VM>:3000`.

#### **Paso 6: Limpieza del Entorno**

1.  **Desmontaje del entorno.** Se detienen y eliminan todos los recursos (contenedores, redes) creados por Docker Compose.
    ```bash
    docker compose down
    ```

#### **Conclusión**

Mediante la ejecución de esta guía, se ha configurado un servidor, se ha construido y se ha desplegado una aplicación de dos niveles completamente contenerizada, estableciendo un entorno de desarrollo robusto, reproducible y aislado.



