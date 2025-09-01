# Guía de Introducción a Docker en un Entorno Ubuntu

## Introducción

Docker es una plataforma de software diseñada para facilitar la creación, el despliegue y la ejecución de aplicaciones utilizando contenedores. Los contenedores permiten empaquetar una aplicación con todas sus dependencias (librerías, herramientas, etc.) en una sola unidad ejecutable.

El objetivo de esta guía es proporcionar a un estudiante nuevo una comprensión fundamental del ciclo de vida de Docker, desde la instalación hasta la distribución de una imagen personalizada.

### Conceptos Fundamentales

Para una comprensión efectiva, es crucial diferenciar los siguientes términos:

*   **Imagen Docker**: Se considera una plantilla inmutable, similar a una receta o un plano. Contiene el sistema operativo base, el código de la aplicación y todas las dependencias necesarias.
*   **Contenedor Docker**: Es una instancia en ejecución de una imagen. Es un entorno aislado y efímero donde la aplicación vive. Múltiples contenedores pueden ser ejecutados desde la misma imagen.
*   **Docker Hub**: Un registro público en la nube donde se almacenan y distribuyen imágenes de Docker. Funciona como un repositorio central para imágenes oficiales y de la comunidad.

---

### Paso 1 — Instalación de Docker Engine

La instalación de Docker se realiza desde su repositorio oficial para garantizar la autenticidad y la versión más reciente del software.

**1.1. Actualización de la lista de paquetes**

Antes de cualquier instalación, la lista de paquetes del sistema debe ser actualizada.

```bash
sudo apt update
```

**1.2. Instalación de paquetes de prerrequisitos**

Se instalan paquetes que permiten a `apt` gestionar repositorios sobre HTTPS.

```bash
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```

**1.3. Adición de la clave GPG oficial de Docker**

La clave GPG de Docker se agrega al sistema para verificar la integridad de los paquetes descargados.

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

**1.4. Configuración del repositorio de Docker**

Se añade el repositorio oficial de Docker a las fuentes de software del sistema. El comando está diseñado para detectar automáticamente la versión de Ubuntu.

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

**1.5. Instalación de Docker Engine**

Con el repositorio ya configurado, se actualiza la lista de paquetes nuevamente y se procede con la instalación de los componentes de Docker.

```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
```

**1.6. Verificación del servicio de Docker**

Para confirmar que la instalación fue exitosa y el servicio está en ejecución, se consulta su estado.

```bash
sudo systemctl status docker
```
Se espera una salida que indique un estado `active (running)`.

---

### Paso 2 — Configuración de Permisos (Ejecución sin `sudo`)

Por defecto, los comandos de Docker requieren privilegios de superusuario. Para mejorar la usabilidad, se puede agregar el usuario actual al grupo `docker`.

**2.1. Adición del usuario al grupo `docker`**

La variable de entorno `${USER}` se utiliza para referenciar al usuario actual.

```bash
sudo usermod -aG docker ${USER}
```

**2.2. Aplicación de los nuevos permisos**

Los cambios de membresía de grupo no se aplican a la sesión de terminal activa. Se requiere iniciar una nueva sesión. Esto puede lograrse cerrando y abriendo la terminal o utilizando el siguiente comando:

```bash
su - ${USER}
```

**2.3. Verificación de la membresía**

Se debe confirmar que el grupo `docker` ahora forma parte de los grupos del usuario.

```bash
id -nG
```
A partir de este punto, el prefijo `sudo` ya no será necesario para los comandos `docker`.

---

### Paso 3 — Comandos Básicos de Docker

**3.1. Listado de comandos disponibles**

La ejecución del comando `docker` sin argumentos muestra una lista completa de sus subcomandos y funcionalidades.

```bash
docker
```

**3.2. Obtención de información del sistema**

Este comando provee un resumen detallado sobre la instalación de Docker, incluyendo el número de imágenes y contenedores existentes.

```bash
docker info
```

---

### Paso 4 — Gestión de Imágenes de Docker

**4.1. Ejecución de la primera imagen: `hello-world`**

El comando `docker run` es el principal medio para ejecutar contenedores. Si la imagen especificada (`hello-world`) no se encuentra localmente, Docker la descargará (`pull`) de Docker Hub antes de crear y ejecutar un contenedor a partir de ella.

```bash
docker run hello-world
```

**4.2. Búsqueda de imágenes en Docker Hub**

Se pueden buscar imágenes públicas directamente desde la terminal.

```bash
docker search ubuntu
```

**4.3. Descarga de una imagen**

Para descargar una imagen sin ejecutarla inmediatamente, se utiliza `docker pull`.

```bash
docker pull ubuntu
```

**4.4. Listado de imágenes locales**

El comando `docker images` muestra todas las imágenes que han sido descargadas al sistema local.

```bash
docker images
```

---

### Paso 5 — Ejecución de un Contenedor Interactivo

Ahora se procederá a ejecutar un contenedor con el cual se pueda interactuar a través de un shell.

**5.1. Inicio de un contenedor Ubuntu con terminal interactiva**

El comando `docker run -it ubuntu` inicia un contenedor y proporciona acceso a su terminal.
*   `-i` (interactivo): Mantiene la entrada estándar (STDIN) abierta.
*   `-t` (TTY): Asigna una pseudo-terminal.
*   `ubuntu`: Es la imagen base para el contenedor.

```bash
docker run -it ubuntu
```

El prompt de la terminal cambiará, indicando que la sesión actual se encuentra dentro del contenedor.

**5.2. Operaciones dentro del contenedor**

Las acciones realizadas a continuación afectan exclusivamente al sistema de archivos del contenedor. Aquí se instalará Node.js como ejemplo.

```bash
# Actualización de la lista de paquetes dentro del contenedor
apt update

# Instalación de nodejs
apt install nodejs
```

**5.3. Verificación de la instalación**

```bash
node -v
```

**5.4. Salida del contenedor**

El comando `exit` finaliza el proceso principal del shell, lo que a su vez detiene el contenedor y devuelve al usuario a la terminal del sistema anfitrión.

```bash
exit
```

---

### Paso 6 — Administración de Contenedores

Los contenedores persisten en el sistema incluso después de ser detenidos.

**6.1. Visualización de contenedores en ejecución**

```bash
docker ps
```

**6.2. Visualización de todos los contenedores**

La opción `-a` permite listar todos los contenedores, incluyendo los que están detenidos.

```bash
docker ps -a
```

**6.3. Ciclo de vida de un contenedor**

Se puede iniciar, detener y eliminar un contenedor usando su `CONTAINER ID` o su `NAME` (asignado aleatoriamente).

```bash
# Iniciar un contenedor detenido
docker start ID_O_NOMBRE_DEL_CONTENEDOR

# Detener un contenedor en ejecución
docker stop ID_O_NOMBRE_DEL_CONTENEDOR

# Eliminar un contenedor detenido (acción irreversible)
docker rm ID_O_NOMBRE_DEL_CONTENEDOR
```

---

### Paso 7 — Creación de una Nueva Imagen desde un Contenedor

Los cambios realizados en un contenedor (como la instalación de Node.js) pueden ser guardados como una nueva imagen.

**7.1. El comando `docker commit`**

Este comando captura el estado de un contenedor y lo empaqueta en una nueva imagen. Se recomienda para experimentación rápida. La práctica estándar en entornos de producción es el uso de `Dockerfile`.

```bash
# Reemplazar los valores según corresponda
docker commit -m "Añadido NodeJS" -a "Autor" ID_DEL_CONTENEDOR nombredeusuario/ubuntu-nodejs
```

**7.2. Verificación de la nueva imagen**

Al listar las imágenes, la nueva imagen personalizada deberá aparecer.

```bash
docker images
```

---

### Paso 8 — Distribución de Imágenes a través de Docker Hub

Las imágenes personalizadas pueden ser subidas a Docker Hub para su distribución.

**8.1. Autenticación con Docker Hub**

Se requiere una cuenta en [hub.docker.com](https://hub.docker.com).

```bash
docker login -u nombredeusuario
```

**8.2. Subida de la imagen**

El comando `docker push` sube la imagen al registro. El nombre de la imagen debe seguir el formato `nombredeusuario/nombre-imagen`.

```bash
docker push nombredeusuario/ubuntu-nodejs
```
