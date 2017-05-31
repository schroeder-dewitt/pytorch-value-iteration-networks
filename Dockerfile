# FROM defines the base image
FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04

######################################
# SECTION 1: Essentials              #
######################################

# Set up SSH server (https://docs.docker.com/engine/examples/running_ssh_service/)
RUN apt-get -y update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:source' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

#Fix SSH mode issue
RUN echo "export PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:\$PATH" >> /root/.bashrc
RUN echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/nvidia/lib:/usr/local/nvidia/lib64" >> /root/.bashrc

#Update apt-get and upgrade
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils # Fix 
RUN apt-get -y upgrade

#Install python3 pip3
RUN apt-get -y install python3
RUN apt-get -y install python3-pip
RUN pip3 install pip --upgrade
RUN pip3 install numpy scipy

#Install python2.7  pip
RUN apt-get -y install python2.7
RUN wget https://bootstrap.pypa.io/get-pip.py && python2.7 get-pip.py
RUN pip install pip --upgrade
RUN pip install numpy scipy

# Set up ssh keys in order to be able to checkout TorrVision
ADD ./install/ssh-keys /root/.ssh
RUN chmod -R 600 /root/.ssh
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts

#Set everything up for user "user"
RUN mkdir /home/user
RUN cp -R /root/.ssh /home/user/.ssh
RUN chmod -R 600 /home/user/.ssh

# set up directories
RUN mkdir -p /root/vin
RUN mkdir -p /root/vin/tmp
RUN mkdir -p /root/vin/lib

######################################
# SECTION 2: CV packages             #
######################################

### -------------------------------------------------------------------
### install OpenCV 3 with python3 bindings and CUDA 8
### -------------------------------------------------------------------
# ADD ./install/opencv3 /root/vin/install/opencv3
# RUN chmod +x /root/vin/install/opencv3/install.sh && /root/vin/install/opencv3/install.sh /root/vin/lib python3

#### -------------------------------------------------------------------
#### install pytorch
#### -------------------------------------------------------------------
# ADD ./install/pytorch /root/vin/install/pytorch
# RUN chmod +x /root/vin/install/pytorch/install.sh && /root/vin/install/pytorch/install.sh /root/vin/lib 3
# RUN pip3 install torchvision


#### -------------------------------------------------------------------
#### Install Visdom/Visdom logger repo
#### -------------------------------------------------------------------
# WORKDIR /root/vin/lib
# RUN pip3 install visdom
# RUN git clone https://github.com/torrvision/logger && cd logger \
#                                                   && pip3 install -r requirements.txt \
#                                                   && python3 setup.py install

#### -------------------------------------------------------------------
#### Install PyTorch Vin implementation dependencies
#### -------------------------------------------------------------------
# RUN pip3 install http://download.pytorch.org/whl/cu80/torch-0.1.12.post2-cp35-cp35m-linux_x86_64.whl
# RUN pip3 install torchvision scipy numpy matplotlib

RUN apt-get install -y python-dev
RUN apt-get install -y python python-tk idle python-pmw python-imaging

# Keep installation at Python3
RUN pip install http://download.pytorch.org/whl/cu80/torch-0.1.12.post2-cp27-none-linux_x86_64.whl 
ADD ./install/vin /root/vin/install/vin
WORKDIR /root/vin/install/vin
RUN pip install -U -r requirements.txt 

############################################
## SECTION: Additional libraries and tools #
############################################
RUN apt-get update && apt-get install -y vim
RUN pip3 install easydict jupyter joblib pandas

############################################
## SECTION: Final instructions and configs #
############################################

RUN apt-get update && apt-get install -y gdb
RUN apt-get install -y firefox
RUN apt-get install -y libcanberra-gtk-module
RUN pip install matplotlib
RUN pip3 install pyyaml
# RUN pip3 install dicttoxml
RUN pip3 install snakeviz
RUN apt-get install -y libssl-dev
RUN pip3 install fabric3 h5py

# set up matplotlibrc file so have Qt5Agg backend by default
RUN mkdir /root/.matplotlib && touch /root/.matplotlib/matplotlibrc && echo "backend: Qt5Agg" >> /root/.matplotlib/matplotlibrc
RUN echo "export PYTHONPATH=/root/vin:\$PYTHONPATH" >> /root/.bashrc
#includes killall etc
RUN apt-get install -y psmisc

# Fix some linux issue
ENV DEBIAN_FRONTEND teletype

# Add keys to ssh-agent
RUN eval "$(ssh-agent -s)" && ssh-add /root/.ssh/id_rsa

# Expose ports
EXPOSE 22
EXPOSE 8888
EXPOSE 8097

#Start SSH server
CMD ["/usr/sbin/sshd", "-D"]

