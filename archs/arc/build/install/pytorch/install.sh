#!/usr/bin/env bash

#$1 should be python2.7 or python3
#$2 should be pip or pip3

yum -y update && yum -y install \
         build-essential \
         cmake \
         git \
         curl \
         ca-certificates \
         libjpeg-dev \
         libpng-dev \
         libblas-dev \
         liblapack-dev \
         libatlas-base-dev \
         libatlas-dev &&\
     	 rm -rf /var/lib/apt/lists/*

if [ ! -d "$1/pytorch" ]; then
    git clone https://github.com/pytorch/pytorch.git $1/pytorch
    cd $1/pytorch
    git checkout 77fbc12f2334ad219e3c94301fd7237c4a3a86f3
fi
cd $1/pytorch
rm -rf build
cat requirements.txt | xargs -n1 pip install --no-cache-dir && \
    TORCH_CUDA_ARCH_LIST="3.5 5.2" TORCH_NVCC_FLAGS="-Xfatbin -compress-all" \
    CMAKE_LIBRARY_PATH=/usr/lib/python$2 \
    CMAKE_INCLUDE_PATH=/usr/include/python$2 \
    pip$2 install -v .