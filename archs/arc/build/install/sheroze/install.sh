cd /slamdoom/libs/
wget https://github.com/zeromq/libzmq/releases/download/v4.2.1/zeromq-4.2.1.tar.gz && tar -zxvf zeromq-4.2.1.tar.gz && rm zeromq-4.2.1.tar.gz
cd /slamdoom/libs/zeromq-4.2.1
./configure && make -j12 && make -j12 install

git clone https://github.com/zeromq/cppzmq.git /slamdoom/libs/cppzmq
cd /slamdoom/libs/cppzmq
wget https://raw.githubusercontent.com/Kitware/Remus/master/CMake/FindZeroMQ.cmake
rm -Rf build && mkdir build && cd build && cmake -DCMAKE_MODULE_PATH=/slamdoom/libs/cppzmq ..

cd /slamdoom/libs/
git clone https://github.com/shehroze37/Augmented-Deep-Reinforcement-Learning-for-3D-environments.git sheroze

cd /slamdoom/libs/sheroze/
git am --signoff < /slamdoom/install/sheroze/sheroze_slam_cmake.patch
git am --signoff < /slamdoom/install/sheroze/sheroze_zmq_rgbd.cc.patch
cd /slamdoom/libs/sheroze/slam
rm -Rf ./build && mkdir -p ./build && cd ./build && cmake -DCMAKE_MODULE_PATH=/usr/local/include/eigen/cmake -DZMQ_INCLUDE_DIR=/usr/local/include -DZMQ_LIBRARY=/usr/local/lib/libzmq.so -DORBSLAM2_LIBRARY=/slamdoom/libs/orbslam2/lib/libORB_SLAM2.so -DBG2O_LIBRARY=/slamdoom/libs/orbslam2/Thirdparty/g2o/lib/libg2o.so -DDBoW2_LIBRARY=/slamdoom/libs/orbslam2/Thirdparty/DBoW2/lib/libDBoW2.so ..
cd /slamdoom/libs/sheroze/slam/build
export CPATH=/usr/local/include/eigen/:/slamdoom/tmp/orbslam2:/slamdoom/libs/cppzmq:/usr/local/include/
export LD_LIBRARY_PATH=/slamdoom/libs/orbslam2/Thirdparty/DBoW2/lib
make -j12
