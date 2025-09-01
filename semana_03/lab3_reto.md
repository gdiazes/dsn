### Reto Práctico: Despliegue de una Aplicación Laravel

Este reto consolida todo lo aprendido y lo lleva un paso más allá, introduciendo la necesidad de orquestar un entorno de aplicación completo.

**Objetivo:** Crear una imagen Docker que contenga una aplicación Laravel funcional con un CRUD básico, utilizando un stack de Apache, PHP y MySQL.

Este es un desafío avanzado que requiere conceptos no cubiertos en esta guía de iniciación, como **`Dockerfile`** (para la construcción automatizada de imágenes) y **`Docker Compose`** (para gestionar múltiples servicios interconectados).

**Pasos Conceptuales para Abordar el Reto:**

1.  **Estructura del Proyecto:** Se debe organizar el código fuente de Laravel en un directorio de proyecto.
2.  **Creación del `Dockerfile`:** En lugar de `docker commit`, se debe crear un archivo llamado `Dockerfile`. Este archivo contendrá las instrucciones para:
    *   Partir de una imagen base oficial (ej. `php:8.1-apache`).
    *   Instalar las dependencias de PHP necesarias para Laravel.
    *   Copiar el código de la aplicación Laravel dentro de la imagen.
    *   Configurar los permisos correctos para Apache.
3.  **Uso de `Docker Compose`:** Se creará un archivo `docker-compose.yml` para definir y ejecutar la aplicación multi-contenedor:
    *   Un servicio `app` que construirá la imagen de Laravel/Apache a partir del `Dockerfile`.
    *   Un servicio `db` que usará la imagen oficial de `mysql`.
    *   Se configurará una red para que ambos contenedores puedan comunicarse.
    *   Se utilizarán volúmenes para persistir los datos de la base de datos.
4.  **Construcción y Ejecución:** Con el comando `docker-compose up`, se levantará todo el entorno.
5.  **Creación de la Imagen Final:** Una vez que la aplicación funcione, se puede crear una imagen unificada (aunque la práctica común es mantener los servicios separados) y subirla a Docker Hub.
6.  **Ciclo de Verificación:**
    *   Subir la imagen final a Docker Hub (`docker push`).
    *   Eliminar la imagen del sistema local para simular un nuevo entorno (`docker rmi`).
    *   Descargar la imagen de nuevo desde Docker Hub (`docker pull`).
    *   Ejecutar un contenedor desde la imagen descargada y verificar que la aplicación es accesible.
7.  **Resultado Final:** Al finalizar, se debe poder acceder a la aplicación Laravel a través de una URL local (ej. `http://localhost:8080`) y demostrar el funcionamiento del CRUD.

Este reto sirve como el siguiente paso natural en el aprendizaje de Docker, moviéndose de la gestión manual a la automatización y orquestación de aplicaciones complejas.
