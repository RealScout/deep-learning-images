#!/bin/bash -e

#
# Mostly from https://github.com/BVLC/caffe/wiki/Caffe-on-EC2-Ubuntu-14.04-Cuda-7
#

# get access to NVIDIA apt repo
curl -LO http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_8.0.44-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1604_8.0.44-1_amd64.deb
rm cuda-repo-ubuntu1604_8.0.44-1_amd64.deb

# up
sudo apt update
sudo apt upgrade -y

# install dependencies
sudo apt install -y build-essential cmake gfortran git \
     hdf5-tools libatlas-base-dev libboost-all-dev libgflags-dev libgoogle-glog-dev libgoogle-glog0v5 libhdf5-serial-dev \
     libleveldb-dev liblmdb-dev libopencv-core-dev libopencv-highgui-dev libprotoc-dev libsnappy-dev libsnappy1v5 \
     libstdc++6-4.8-dbg opencl-headers protobuf-compiler python-minimal python-pip

# DRM workaround
sudo apt install -y linux-image-extra-`uname -r` linux-headers-`uname -r` linux-image-`uname -r`

# Install CUDA
## for some reason this fails the first time
sudo apt install -y cuda
sudo sh -c 'cat > /etc/ld.so.conf.d/cuda.conf <<EOF
/usr/local/cuda-8.0/lib64
EOF
'
sudo ldconfig

# Tidy up
sudo apt clean

# verify
nvidia-smi
