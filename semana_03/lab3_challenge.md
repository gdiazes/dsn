### Practical Challenge: Deploying a Laravel Application

This challenge consolidates all that has been learned and takes it a step further by introducing the need to orchestrate a complete application environment.

**Objective:** To create a Docker image containing a functional Laravel application with a basic CRUD, using an Apache, PHP, and MySQL stack.

This is an advanced challenge that requires concepts not covered in this introductory guide, such as **`Dockerfile`** (for automated image building) and **`Docker Compose`** (for managing multiple interconnected services).

**Conceptual Steps to Address the Challenge:**

1.  **Project Structure:** The Laravel source code should be organized in a project directory.
2.  **`Dockerfile` Creation:** Instead of `docker commit`, a file named `Dockerfile` must be created. This file will contain instructions to:
    *   Start from an official base image (e.g., `php:8.1-apache`).
    *   Install the PHP dependencies required by Laravel.
    *   Copy the Laravel application code into the image.
    *   Configure the correct permissions for Apache.
3.  **Use of `Docker Compose`:** A `docker-compose.yml` file will be created to define and run the multi-container application:
    *   An `app` service that will build the Laravel/Apache image from the `Dockerfile`.
    *   A `db` service that will use the official `mysql` image.
    *   A network will be configured so both containers can communicate.
    *   Volumes will be used to persist the database data.
4.  **Build and Run:** With the `docker-compose up` command, the entire environment will be brought up.
5.  **Final Image Creation:** Once the application is working, a unified image can be created (though common practice is to keep services separate) and pushed to Docker Hub.
6.  **Verification Cycle:**
    *   Push the final image to Docker Hub (`docker push`).
    *   Remove the image from the local system to simulate a new environment (`docker rmi`).
    *   Pull the image again from Docker Hub (`docker pull`).
    *   Run a container from the downloaded image and verify that the application is accessible.
7.  **Final Result:** Upon completion, the Laravel application should be accessible via a local URL (e.g., `http://localhost:8080`), and the CRUD functionality should be demonstrable.
