# Complete and Detailed Guide: From Zero to Laravel with Git & SSH on Ubuntu

This guide contains all the necessary commands to set up a complete Laravel development environment on a clean Ubuntu virtual machine. It includes the installation of all dependencies, the initial database setup, and a secure connection to GitHub using an SSH key.

## Phase 0: Initial System Preparation

First, we update our Ubuntu VM's packages to ensure everything is up-to-date and secure.

```bash
sudo apt update
```
- **`sudo`**: Executes the command with administrator (superuser) privileges, which are required to manage system software.
- **`apt update`**: Synchronizes the list of available packages from the repositories configured on your system. It doesn't install or upgrade any software, it just refreshes the "catalog" of what's available.

```bash
sudo apt upgrade -y
```
- **`apt upgrade`**: Compares the versions of installed software with the updated catalog and then downloads and installs the newest versions.
- **`-y`**: Automatically answers "yes" to any confirmation prompts, making the process non-interactive.

## Phase 1: Installing Essential Dependencies

We will install the fundamental tools: PHP, Composer (its package manager), and Git.

### 1.1. Install PHP 8.2 and Extensions

We will use a PPA (Personal Package Archive) to get the latest version of PHP, along with all the extensions Laravel will need to run smoothly out of the box.

```bash
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install php8.2-cli php8.2-mbstring php8.2-xml php8.2-curl php8.2-zip php8.2-bcmath php8.2-sqlite3 unzip -y
```
- **`php8.2-cli`, `-mbstring`, `-xml`, `-curl`, `-zip`, `-bcmath`**: These are crucial PHP extensions for Laravel and its dependencies to function correctly.
- **`php8.2-sqlite3`**: **(Key step to prevent errors)**. This installs the "driver" or "translator" that PHP needs to communicate with SQLite databases. Laravel is configured to use SQLite by default, and this package prevents the `"could not find driver"` error.
- **`unzip`**: A system utility for decompressing files, required by Composer for some operations.

### 1.2. Install Composer

We download the Composer installer and make it globally accessible so we can use the `composer` command from any directory.

```bash
curl -sS https://getcomposer.org/installer | php
```
- **`curl ... | php`**: Downloads and executes the official Composer installer script. The pipe (`|`) sends the script's output directly to the PHP interpreter. This creates a `composer.phar` file in the current directory.

```bash
sudo mv composer.phar /usr/local/bin/composer
```
- **`sudo mv ...`**: Moves the Composer executable to a system path, renaming it to `composer`. This makes the `composer` command globally available in the terminal.

### 1.3. Install Git

```bash
sudo apt install git -y
```
- **`git`**: Installs the industry-standard distributed version control system, which is essential for working with repositories and deploying on platforms like Render.

### 1.4. Verify the Tools

We confirm that all tools were installed correctly and are recognized by the system.

```bash
php -v
composer --version
git --version
```
- If these commands return a version number, the installation was successful.

## Phase 2: Creating and Configuring the Project

Now, we create the Laravel project and prepare its database so it's ready to run.

### 2.1. Create the Project

```bash
cd ~
composer create-project laravel/laravel my-laravel-project
cd my-laravel-project
```
- **`composer create-project ...`**: Creates a new Laravel project in a directory named `my-laravel-project`.
- **`cd my-laravel-project`**: We move into the project's directory. **All subsequent commands must be run from here.**

### 2.2. Prepare the Initial Database (Key Steps)

Before running the application, we create the database file and run the migrations to build the table structure. This prevents the `"no such table: sessions"` error.

```bash
touch database/database.sqlite
```
- **`touch`**: A Linux command that creates an empty file if it doesn't exist.
- **`database/database.sqlite`**: This is the default path and filename Laravel looks for when using its default SQLite database configuration.

```bash
php artisan migrate
```
- **`php artisan migrate`**: This Laravel command reads the "migration" files (which are like blueprints for the database) and creates all the necessary tables, including the `users` and `sessions` tables.

## Phase 3: Running the Development Server

With the project created and the database prepared, the application should now start without any errors.

```bash
php artisan serve --host=0.0.0.0
```
- **`php artisan serve`**: Starts Laravel's built-in development server.
- **`--host=0.0.0.0`**: Allows the server to be accessible from outside the VM (i.e., from your host machine's browser).

To access it, find your VM's IP address by running `ip addr show` in **ANOTHER** terminal, then navigate to `http://<YOUR_VM_IP>:8000` in your browser. You should see the Laravel welcome page immediately.

## Phase 4: Setting up Git & SSH Connection with GitHub

We establish a secure connection between our VM and GitHub.

### 4.1. Configure Your Git Identity

```bash
git config --global user.name "Your Full Name"
git config --global user.email "your_email@example.com"
```
- **`git config`**: Configures Git variables. The `--global` flag applies the settings to all repositories for your user on this machine. This name and email will be associated with your commits.

### 4.2. Generate a New SSH Key

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```
- **`ssh-keygen`**: The tool for creating SSH authentication keys.
- **`-t ed25519`**: Specifies the key type. `ed25519` is a modern, fast, and secure algorithm.
- **`-C "..."`**: Adds a comment to the key, useful for identifying it later.
- Follow the on-screen prompts: press **Enter** to accept the default file location, and then enter a strong **passphrase** twice for security.

### 4.3. Add the SSH Key to the SSH Agent

The SSH agent manages your key in memory so you don't have to type your passphrase on every connection.

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```
- **`eval "$(ssh-agent -s)"`**: Starts the agent in the background.
- **`ssh-add`**: Adds your private key identity to the agent.

### 4.4. Add the Public SSH Key to GitHub

Copy the **PUBLIC** part of your key to give to GitHub.

```bash
cat ~/.ssh/id_ed25519.pub
```
- **`cat`**: Displays the content of the file. Copy the entire output.
- Now, in your browser:
  1.  Go to your **GitHub** account.
  2.  Click your avatar > **Settings**.
  3.  In the left menu, go to **SSH and GPG keys**.
  4.  Click **New SSH key**.
  5.  Give it a descriptive **Title** (e.g., "Laravel Dev VM").
  6.  Paste the key into the **Key** field.
  7.  Click **Add SSH key**.

### 4.5. Verify the Connection with GitHub

```bash
ssh -T git@github.com
```
- **`ssh -T`**: Attempts to connect to GitHub via SSH for testing purposes. If prompted, type `yes`.
- If you see a welcome message with your username, the connection is successful!

## Phase 5: Initializing the Repository & Pushing the Code

Finally, we put our project under version control and push it to a new repository on GitHub.

First, make sure you have created a new, **empty repository** on GitHub.

```bash
# Initialize the local repository
git init

# Add all files to version control
git add .

# Create the first commit
git commit -m "Initial commit: Fresh Laravel installation"

# Rename the primary branch to 'main'
git branch -M main

# Connect your local repository to the remote one on GitHub (replace the URL)
git remote add origin git@github.com:your-username/your-repository-name.git

# Push your code to GitHub
git push -u origin main
```
