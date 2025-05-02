#!/bin/bash

# Script untuk build dan push Docker image untuk aplikasi frontend Karsa Jobs UI
# Script ini harus dijalankan dari dalam direktori karsajobs/frontend

# Variabel username untuk Docker Hub
USERNAME="ardidafa"
# Optional tag, defaultnya adalah latest atau dari parameter pertama script
TAG="${1:-latest}"

# ==============================================================
# Step 1: Build Docker image dari Dockerfile yang tersedia
# ==============================================================
echo "Building Docker image: ${USERNAME}/karsajobs-ui:${TAG}"
docker build -t ${USERNAME}/karsajobs-ui:${TAG} -t ${USERNAME}/karsajobs-ui:latest .

# ==============================================================
# Step 2: Login ke Docker Hub menggunakan Personal Access Token
# ==============================================================
echo "Logging in to Docker Hub"
# Menggunakan environment variable DOCKER_HUB_PAT atau PASSWORD_DOCKER_HUB
# Jika menjalankan dari Jenkins, PAT akan disediakan oleh credentials
# Jika menjalankan manual, gunakan PASSWORD_DOCKER_HUB yang di-export sebelumnya
TOKEN="${DOCKER_HUB_PAT:-$PASSWORD_DOCKER_HUB}"
echo $TOKEN | docker login -u ${USERNAME} --password-stdin

# ==============================================================
# Step 3: Push image ke Docker Hub
# ==============================================================
echo "Pushing image to Docker Hub: ${USERNAME}/karsajobs-ui:${TAG}"
docker push ${USERNAME}/karsajobs-ui:${TAG}
docker push ${USERNAME}/karsajobs-ui:latest

echo "Process completed successfully!"