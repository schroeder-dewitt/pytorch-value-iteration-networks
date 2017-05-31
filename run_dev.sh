#!/bin/bash 
# Ensure that you have installed nvidia-docker and the latest nvidia graphics driver!


SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# Build and run the image
echo "Building image..."
sudo nvidia-docker build --build-arg pass=$SPASSWORD -t vin .
echo "Removing older image..."
sudo nvidia-docker rm -f vin0
echo "Running image..."
sudo nvidia-docker run --privileged -d -v /dev:/dev --ipc=host -p 52027:22 -p 8100:8097 -p 8890:8888 -p 6010:6006 --name vin0 \
      -v $SCRIPTPATH/src:/root/vin/src \
      -v $SCRIPTPATH/docker_share:/root/vin/docker_share \
      -v $SCRIPTPATH/archs:/root/vin/archs \
      vin

# Retrieve IP and port of Docker instance and container
CONTAINERIP=$(sudo nvidia-docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' vin0);
DOCKERIP=$(/sbin/ifconfig docker0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
echo "CONTAINER IP:":$CONTAINERIP
echo "DOCKER IP:":$DOCKERIP
DOCKERPORTSTRING=$(sudo nvidia-docker port vin0 22)
DOCKERPORT=${DOCKERPORTSTRING##*:}
echo "DOCKER PUBLISHED PORT 22 -> :":$DOCKERPORT
echo "LOGIN LIKE: ssh -o PubkeyAuthentication=no -o StrictHostKeyChecking=no -X -p $DOCKERPORT root@$DOCKERIP" >> login.txt
ssh -o PubkeyAuthentication=no -o StrictHostKeyChecking=no -X -p $DOCKERPORT root@$DOCKERIP

