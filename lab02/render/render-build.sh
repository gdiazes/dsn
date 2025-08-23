#!/usr/bin/env bash
# exit on error
set -o errexit

echo "Iniciando el script de construcción de Render..."

# 1. Instalar dependencias de Composer
composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

# 2. Generar la clave de la aplicación (si no existe)
php artisan key:generate --force

# 3. Ejecutar migraciones de la base de datos
# El flag --force es VITAL en producción para evitar prompts interactivos.
php artisan migrate --force

# 4. Limpiar y cachear configuraciones para optimizar el rendimiento
echo "Cacheando configuración, rutas y vistas para producción..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 5. Si usas Vite o Mix para tus assets (descomenta la línea que necesites)
# echo "Compilando assets de producción con Vite..."
# npm install
# npm run build

echo "Script de construcción finalizado con éxito."
