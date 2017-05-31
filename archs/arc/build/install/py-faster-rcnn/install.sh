#!/usr/bin/env bash
set -e # Fail immediately on error

cd /slamdoom/libs/ && git clone --recursive https://github.com/rbgirshick/py-faster-rcnn.git py-faster-rcnn
cd /slamdoom/libs/py-faster-rcnn && git checkout 96dc9f1dea3087474d6da5a98879072901ee9bf9
# install dependencies
yum -y install libatlas-base-dev libprotobuf-dev liblmdb-dev libleveldb-dev libsnappy-dev libopencv-dev libhdf5-serial-dev protobuf-compiler libgflags-dev libgoogle-glog-dev liblmdb-dev
yum -y install --no-install-recommends libboost-all-dev
mkdir -p /slamdoom/install

# RUN cd /slamdoom/install/py-faster-rcnn && dpkg-source -x *.dsc
# install py-faster-rcnn dependencies
tar -zxvf /slamdoom/install/py-faster-rcnn/cudnn-7.0-linux-x64-v3.0.8-prod.tgz -C /slamdoom/libs
mv /slamdoom/libs/cuda /slamdoom/libs/cudnn3
export CPLUS_INCLUDE_PATH=/slamdoom/libs/cudnn3/include:$CPLUS_INCLUDE_PATH
export LD_LIBRARY_PATH=/slamdoom/libs/cudnn3/lib64/:$LD_LIBRARY_PATH
# Workarounds from https://github.com/BVLC/caffe/wiki/Ubuntu-14.04-ec2-instance
mkdir /slamdoom/libs/gflags
cd /slamdoom/libs/gflags
wget https://github.com/schuhschuh/gflags/archive/master.zip && unzip master.zip
cd gflags-master && mkdir build && cd build && export CXXFLAGS="-fPIC" && cmake .. && make VERBOSE=1 && make && make install
# install pycaffe dependencies
yum -y install python3-tk
pip3 install scikit-image scipy matplotlib protobuf
# compile py-faster-rcnn
cd /slamdoom/libs/py-faster-rcnn/lib
pip3 install cython
sed -i -- 's/python/python3/g' Makefile && 2to3 -w ./setup.py
make
cd /slamdoom/libs/py-faster-rcnn/caffe-fast-rcnn
mkdir build
cd /slamdoom/libs/py-faster-rcnn/caffe-fast-rcnn/build
#Somehow, we need to purge CuDNN5 files, despite setting the relevant CMake-parameters (this is not exactly clean, but I don't know what environment variables need to be set!)
mv /usr/local/cuda/include/cudnn.h /usr/local/cuda/include/_cudnn.h
mv /usr/local/cuda/lib64/libcudnn.so /usr/local/cuda/lib64/_libcudnn.so
cmake -DBoost_PYTHON_LIBRARY_DEBUG=/usr/lib/x86_64-linux-gnu/libboost_python-py35.so \
          -DBoost_PYTHON_LIBRARY_RELEASE=/usr/lib/x86_64-linux-gnu/libboost_python-py35.so \
          -DPYTHON_EXECUTABLE=/usr/bin/python3 \
          -DPYTHON_INCLUDE_DIR=/usr/include/python3.5 \
          -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.5m.so \
	  -DCUDNN_INCLUDE=/slamdoom/libs/cudnn3/include \
          -DCUDNN_LIBRARY=/slamdoom/libs/cudnn3/lib64/libcudnn.so \
          -DCUDNN_ROOT=/slamdoom/libs/cudnn3/ \
          -DCUDA_ARCH_BIN="35 50" \
          -DCUDA_ARCH_NAME=Manual ..
make -j12 && make install && make pycaffe
#Don't forget to de-purge CuDNN5 files
mv /usr/local/cuda/include/_cudnn.h /usr/local/cuda/include/cudnn.h
mv /usr/local/cuda/lib64/_libcudnn.so /usr/local/cuda/lib64/libcudnn.so
# mv /slamdoom/libs/py-faster-rcnn /slamdoom/libs/.
rm /slamdoom/libs/py-faster-rcnn/caffe-fast-rcnn/python/caffe/_caffe.so && ln -s /slamdoom/libs/py-faster-rcnn/caffe-fast-rcnn/build/lib/_caffe.so /slamdoom/libs/py-faster-rcnn/caffe-fast-rcnn/python/caffe/_caffe.so
touch /root/.bashrc
echo "export PYTHONPATH=/slamdoom/libs/py-faster-rcnn/caffe-fast-rcnn/python:\$PYTHONPATH" >> /root/.bashrc
echo "export PYTHONPATH=/slamdoom/libs/py-faster-rcnn/lib:\$PYTHONPATH" >> /root/.bashrc
echo "export LD_LIBRARY_PATH=/slamdoom/libs/py-faster-rcnn/caffe-fast-rcnn/build/lib:\$LD_LIBRARY_PATH" >> /root/.bashrc
/slamdoom/libs/py-faster-rcnn/data/scripts/fetch_faster_rcnn_models.sh
2to3 -w /slamdoom/libs/py-faster-rcnn/lib/fast_rcnn/test.py
2to3 -w /slamdoom/libs/py-faster-rcnn/lib/rpn/proposal_layer.py
2to3 -w /slamdoom/libs/py-faster-rcnn/lib/rpn/generate_anchors.py
2to3 -w /slamdoom/libs/py-faster-rcnn/lib/utils/blob.py
2to3 -w /slamdoom/libs/py-faster-rcnn/caffe-fast-rcnn/python/caffe/pycaffe.py
2to3 -w /slamdoom/libs/py-faster-rcnn/tools/train_net.py
2to3 -w /slamdoom/libs/py-faster-rcnn/lib/fast_rcnn/train.py
2to3 -w /slamdoom/libs/py-faster-rcnn/lib/fast_rcnn/config.py
2to3 -w /slamdoom/libs/py-faster-rcnn/lib/roi_data_layer/roidb.py
2to3 -w /slamdoom/libs/py-faster-rcnn/lib/roi_data_layer/layer.py
2to3 -w /slamdoom/libs/py-faster-rcnn/lib/roi_data_layer/minibatch.py
2to3 -w /slamdoom/libs/py-faster-rcnn/lib/rpn/anchor_target_layer.py
2to3 -w /slamdoom/libs/py-faster-rcnn/lib/rpn/proposal_target_layer.py
2to3 -w /slamdoom/libs/py-faster-rcnn/lib/datasets/pascal_voc.py
2to3 -w /slamdoom/libs/py-faster-rcnn/lib/datasets/voc_eval.py
2to3 -w /slamdoom/libs/py-faster-rcnn/lib/datasets/coco.py
2to3 -w /slamdoom/libs/py-faster-rcnn/lib/datasets/imdb.py
2to3 -w /slamdoom/libs/py-faster-rcnn/lib/pycocotools/coco.py
2to3 -w /slamdoom/libs/py-faster-rcnn/lib/pycocotools/cocoeval.py
mkdir /slamdoom/libs/py-faster-rcnn/data/slamdoom/
mkdir /slamdoom/libs/py-faster-rcnn/models/slamdoom/
ln -s /slamdoom/data/py-faster-rcnn-bhatti_zf /slamdoom/libs/py-faster-rcnn/data/slamdoom/bhatti_zf
ln -s /slamdoom/data/py-faster-rcnn-bhatti_zf /slamdoom/libs/py-faster-rcnn/models/slamdoom/bhatti_zf
sed -i -- 's/pascal_voc//g' /slamdoom/libs/py-faster-rcnn/lib/fast_rcnn/config.py
echo "export PYTHONPATH=/slamdoom/libs/py-faster-rcnn/tools:\$PYTHONPATH" >> /root/.bashrc
echo "export PYTHONPATH=/slamdoom/libs/py-faster-rcnn/lib:\$PYTHONPATH" >> /root/.bashrc
echo "export PYTHONPATH=/slamdoom/src:\$PYTHONPATH" >> /root/.bashrc
echo "export PYTHONPATH=/slamdoom:\$PYTHONPATH" >> /root/.bashrc