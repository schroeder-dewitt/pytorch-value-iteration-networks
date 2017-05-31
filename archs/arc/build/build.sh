#!/bin/bash
# Ensure that you have installed nvidia-docker and the latest nvidia graphics driver!


SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# Build and run the image
echo "Building image..."
sudo nvidia-docker build --build-arg pass=$SPASSWORD -t arc_compile .
echo "Removing older image..."
sudo nvidia-docker rm -f arc_compile0
echo "Running image..."
sudo nvidia-docker run --privileged -d -v /dev:/dev --ipc=host -p 52022:22 -p 8098:8097 -p 8888:8888 -p 6006:6006 --name arc_compile0 \
      -v $SCRIPTPATH/bin:/arc_compile/bin \
      arc_compile

# Retrieve IP and port of Docker instance and container
CONTAINERIP=$(sudo nvidia-docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' arc_compile0);
DOCKERIP=$(/sbin/ifconfig docker0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
echo "CONTAINER IP:":$CONTAINERIP
echo "DOCKER IP:":$DOCKERIP
DOCKERPORTSTRING=$(sudo nvidia-docker port arc_compile0 22)
DOCKERPORT=${DOCKERPORTSTRING##*:}
echo "DOCKER PUBLISHED PORT 22 -> :":$DOCKERPORT
echo "IdentityFile $SCRIPTPATH/.sshauth/arc_compile.rsa" >> ~/.ssh/config
ssh-keygen -f ~/.ssh/known_hosts -R [$DOCKERIP]:$DOCKERPORT
echo "Login password is: ":$SPASSWORD
echo "LOGIN LIKE: ssh -o PubkeyAuthentication=no -o StrictHostKeyChecking=no -X -p $DOCKERPORT root@$DOCKERIP" >> login.txt
ssh -o PubkeyAuthentication=no -o StrictHostKeyChecking=no -X -p $DOCKERPORT root@$DOCKERIP

