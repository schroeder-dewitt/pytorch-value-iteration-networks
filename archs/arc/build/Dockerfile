# FROM defines the base image
FROM nvidia/cuda:8.0-devel-centos6

######################################
# SECTION 1: Essentials              #
######################################

# Set up SSH server (https://docs.docker.com/engine/examples/running_ssh_service/)
RUN yum -y update && yum -y install  openssh-server openssh-clients
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

#Update yum and upgrade
#RUN yum update && yum -y install  --no-install-recommends apt-utils # Fix
RUN yum -y upgrade

#Install python3 pip3
# RUN yum -y  install python3
# RUN yum -y install python3-pip
RUN yum -y install zlib-dev zlib-devel openssl-devel sqlite-devel bzip2-devel
RUN yum -y install yum-utils && yum-builddep python &&  curl -O https://www.python.org/ftp/python/3.5.0/Python-3.5.0.tgz \
    && tar xf Python-3.5.0.tgz && cd Python-3.5.0 && ./configure && make && make install
# RUN yum -y install python34-setuptools && easy_install-3.4 pip
RUN yum -y install wget && wget https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py
RUN pip3 install pip --upgrade
RUN pip3 install numpy scipy

#Install python2.7  pip
RUN yum -y install python
RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py
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

######################################
# SECTION 2: CV packages             #
######################################

### -------------------------------------------------------------------
### install OpenCV 3 with python3 bindings and CUDA 8
### -------------------------------------------------------------------
### ADD ./install/opencv3 /slamdoom/install/opencv3
### RUN chmod +x /slamdoom/install/opencv3/install.sh && /slamdoom/install/opencv3/install.sh /slamdoom/libs python3

#### -------------------------------------------------------------------
#### install pytorch
#### -------------------------------------------------------------------
ADD ./install/pytorch /slamdoom/install/pytorch
RUN yum -y install git
RUN chmod +x /slamdoom/install/pytorch/install.sh && /slamdoom/install/pytorch/install.sh /slamdoom/libs 3
RUN pip3 install torchvision

#### -------------------------------------------------------------------
#### install OpenAI gym and gym-doom
#### -------------------------------------------------------------------
RUN yum update && yum -y install python-numpy cmake zlib1g-dev libjpeg-dev libboost-all-dev gcc libsdl2-dev wget unzip git
# RUN pip3 install gym ppaquette-gym-doom
#WORKDIR /slamdoom/libs
#RUN git clone git@github.com:torrvision/gym-doom.git
#RUN echo "export PYTHONPATH=/slamdoom/libs/gym-doom:\$PYTHONPATH" >> /root/.bashrc && echo "export PYTHONPATH=/slamdoom/libs/gym-doom:\$PYTHONPATH" >> /home/user/.bashrc


#### -------------------------------------------------------------------
#### install tensorflow
#### -------------------------------------------------------------------
# RUN pip3 install tensorflow-gpu

#### -------------------------------------------------------------------
#### install py-faster-rcnn, including caffe version supplied with it
#### -------------------------------------------------------------------
# download and install py-faster-rcnn caffe version with python bindings
ADD ./install/py-faster-rcnn /slamdoom/install/py-faster-rcnn
RUN chmod +x /slamdoom/install/py-faster-rcnn/install.sh && /slamdoom/install/py-faster-rcnn/install.sh

#
##### -------------------------------------------------------------------
##### Install ORBSLAM2
##### -------------------------------------------------------------------
#ADD ./install/orbslam2 /slamdoom/install/orbslam2
#RUN chmod +x /slamdoom/install/orbslam2/install.sh && /slamdoom/install/orbslam2/install.sh
#
#
##### -------------------------------------------------------------------
##### Install Sheroze repo
##### -------------------------------------------------------------------
#ADD ./install/sheroze /slamdoom/install/sheroze
#RUN chmod +x /slamdoom/install/sheroze/install.sh && /slamdoom/install/sheroze/install.sh
#
#
##### -------------------------------------------------------------------
##### Install Visdom/Visdom logger repo
##### -------------------------------------------------------------------
#WORKDIR /slamdoom/libs
#RUN pip3 install visdom
#RUN git clone https://github.com/torrvision/logger && cd logger \
#                                                   && pip3 install -r requirements.txt \
#                                                   && python3 setup.py install
#
##### -------------------------------------------------------------------
##### Install Vizdoom
##### -------------------------------------------------------------------
#WORKDIR /slamdoom/libs
#
#RUN git clone git@github.com:schroeder-dewitt/ViZDoom.git && cd ViZDoom && git checkout 501c33d9ffa890a3308685cc97f9f8436026e668 && mkdir -p build && chmod +x ./build.sh && ./build.sh
#RUN echo "export PYTHONPATH=/slamdoom/libs/ViZDoom/bin/python3/pip_package:\$PYTHONPATH" >> /root/.bashrc
#RUN echo "export PYTHONPATH=/slamdoom/libs/ViZDoom/bin/python3/pip_package:\$PYTHONPATH" >> /home/user/.bashrc
#
#RUN pip3 install http://bit.ly/csc161graphics # python graphics package (vor cheat.py in alband/vizdoom)
#

#############################################
### SECTION: Additional libraries and tools #
#############################################
#
#RUN yum -y install vim
#RUN pip3 install easydict jupyter joblib pandas
#
##### -------------------------------------------------------------------
##### Build ORBSLAM2 python interface
##### -------------------------------------------------------------------
##RUN cd /slamdoom/src/slam/orbslam2/boost && chmod +x build.sh && ./build.sh
#RUN echo "export PYTHONPATH=/slamdoom/src/slam/orbslam2/boost/build:\$PYTHONPATH" >> /root/.bashrc
#RUN echo "export PYTHONPATH=/slamdoom/src/slam/orbslam2/boost/build:\$PYTHONPATH" >> /home/user/.bashrc
##### -------------------------------------------------------------------
##### Build heatmap cython interface
##### -------------------------------------------------------------------
##RUN cd /slamdoom/src/rl/agents/bhatti/heatmap && chmod +x build.sh && ./build.sh
#
#############################################
### SECTION: Final instructions and configs #
#############################################
#
#RUN yum update && yum -y install gdb
#RUN yum -y install firefox
#RUN yum -y install libcanberra-gtk-module
#RUN pip install matplotlib
#RUN pip3 install pyyaml
## RUN pip3 install dicttoxml
#RUN pip3 install snakeviz
#RUN yum -y install libssl-dev
#RUN pip3 install fabric3
#
## set up matplotlibrc file so have Qt5Agg backend by default
#RUN mkdir /root/.matplotlib && touch /root/.matplotlib/matplotlibrc && echo "backend: Qt5Agg" >> /root/.matplotlib/matplotlibrc

# Fix some linux issue
ENV DEBIAN_FRONTEND teletype

# Expose ports
EXPOSE 22
EXPOSE 8888
EXPOSE 8097

# Add SSH keys
COPY ./install/ssh-keys/* /root/.ssh/

#Start SSH server
CMD ["/usr/sbin/sshd", "-D"]

