#!/bin/bash

# Membuat image Docker bernama item-app dengan tag v1
docker build -t item-app:v1 .

# Menampilkan daftar semua image Docker di lokal
docker images

# Mengubah nama image agar sesuai format Docker Hub
docker tag item-app:v1 ardidafa/item-app:v1

# Login ke Docker Hub menggunakan variabel lingkungan untuk password
echo $PASSWORD_DOCKER_HUB | docker login -u ardidafa --password-stdin

# Mengunggah image ke Docker Hub
docker push ardidafa/item-app:v1