#!/bin/bash

docker build -t item-app:v1 .

docker images

docker tag item-app:v1 ardidafa/item-app:v1

echo $PASSWORD_DOCKER_HUB | docker login -u ardidafa --password-stdin

docker push ardidafa/item-app:v1