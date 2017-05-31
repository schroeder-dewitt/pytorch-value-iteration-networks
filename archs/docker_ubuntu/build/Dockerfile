# FROM defines the base image
FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04
#TODO: CENTOS!!!

######################################
# SECTION 1: Essentials              #
######################################

# Set up SSH server (https://docs.docker.com/engine/examples/running_ssh_service/)
RUN apt-get update && apt-get install -y openssh-server
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

######################################
# SECTION 2: CV packages             #
######################################

### -------------------------------------------------------------------
### install OpenCV 3 with python3 bindings and CUDA 8
### -------------------------------------------------------------------
ADD ./install/opencv3 /slamdoom/install/opencv3
RUN chmod +x /slamdoom/install/opencv3/install.sh && /slamdoom/install/opencv3/install.sh /slamdoom/libs python3

#### -------------------------------------------------------------------
#### install pytorch
#### -------------------------------------------------------------------
ADD ./install/pytorch /slamdoom/install/pytorch
RUN chmod +x /slamdoom/install/pytorch/install.sh && /slamdoom/install/pytorch/install.sh /slamdoom/libs 3
RUN pip3 install torchvision

#### -------------------------------------------------------------------
#### install OpenAI gym and gym-doom
#### -------------------------------------------------------------------
RUN apt-get update && apt-get install -y python-numpy cmake zlib1g-dev libjpeg-dev libboost-all-dev gcc libsdl2-dev wget unzip git
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

#### -------------------------------------------------------------------
#### Install Boost for Boost.Python
#### -------------------------------------------------------------------
#WORKDIR /slamdoom/tmp
#RUN wget https://downloads.sourceforge.net/project/boost/boost/1.63.0/boost_1_63_0.tar.gz

#### -------------------------------------------------------------------
#### Install SqueezeDet
#### -------------------------------------------------------------------
#WORKDIR /slamdoom/libs
#RUN git clone https://github.com/BichenWuUCB/squeezeDet.git
#WORKDIR /slamdoom/libs/squeezeDet/
#RUN git checkout 8ea2af7f59dde0369b70136492694bdde19dd22b
#WORKDIR /slamdoom/libs/squeezeDet
#ADD ./install/squeezeDet/squeezeDet_python3.git.patch /slamdoom/install/squeezeDet_python3.git.patch
#RUN git config --global user.name "Slamdoom" && git config --global user.email "slamdoom@slam.doom" && git am --signoff < /slamdoom/install/squeezeDet_python3.git.patch

#### -------------------------------------------------------------------
#### Install ORBSLAM2
#### -------------------------------------------------------------------
ADD ./install/orbslam2 /slamdoom/install/orbslam2
RUN chmod +x /slamdoom/install/orbslam2/install.sh && /slamdoom/install/orbslam2/install.sh


#### -------------------------------------------------------------------
#### Install Sheroze repo
#### -------------------------------------------------------------------
ADD ./install/sheroze /slamdoom/install/sheroze
RUN chmod +x /slamdoom/install/sheroze/install.sh && /slamdoom/install/sheroze/install.sh


#### -------------------------------------------------------------------
#### Install Visdom/Visdom logger repo
#### -------------------------------------------------------------------
WORKDIR /slamdoom/libs
RUN pip3 install visdom
RUN git clone https://github.com/torrvision/logger && cd logger \
                                                   && pip3 install -r requirements.txt \
                                                   && python3 setup.py install

#### -------------------------------------------------------------------
#### Install Vizdoom
#### -------------------------------------------------------------------
WORKDIR /slamdoom/libs

RUN git clone git@github.com:schroeder-dewitt/ViZDoom.git && cd ViZDoom && git checkout 501c33d9ffa890a3308685cc97f9f8436026e668 && mkdir -p build && chmod +x ./build.sh && ./build.sh
RUN echo "export PYTHONPATH=/slamdoom/libs/ViZDoom/bin/python3/pip_package:\$PYTHONPATH" >> /root/.bashrc
RUN echo "export PYTHONPATH=/slamdoom/libs/ViZDoom/bin/python3/pip_package:\$PYTHONPATH" >> /home/user/.bashrc

RUN pip3 install http://bit.ly/csc161graphics # python graphics package (vor cheat.py in alband/vizdoom)


############################################
## SECTION: Additional libraries and tools #
############################################

RUN apt-get install -y vim
RUN pip3 install easydict jupyter joblib pandas

#### -------------------------------------------------------------------
#### Build ORBSLAM2 python interface
#### -------------------------------------------------------------------
#RUN cd /slamdoom/src/slam/orbslam2/boost && chmod +x build.sh && ./build.sh
RUN echo "export PYTHONPATH=/slamdoom/src/slam/orbslam2/boost/build:\$PYTHONPATH" >> /root/.bashrc
RUN echo "export PYTHONPATH=/slamdoom/src/slam/orbslam2/boost/build:\$PYTHONPATH" >> /home/user/.bashrc
#### -------------------------------------------------------------------
#### Build heatmap cython interface
#### -------------------------------------------------------------------
#RUN cd /slamdoom/src/rl/agents/bhatti/heatmap && chmod +x build.sh && ./build.sh

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
RUN pip3 install fabric3

# set up matplotlibrc file so have Qt5Agg backend by default
RUN mkdir /root/.matplotlib && touch /root/.matplotlib/matplotlibrc && echo "backend: Qt5Agg" >> /root/.matplotlib/matplotlibrc


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

