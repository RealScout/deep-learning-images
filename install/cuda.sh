#!/bin/bash -e

# get access to NVIDIA apt repo
curl -LO http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_7.5-18_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1404_7.5-18_amd64.deb
rm cuda-repo-ubuntu1404_7.5-18_amd64.deb

# up
sudo apt-get update

# install dependencies
sudo apt-get install -y build-essential cmake gfortran git \
     hdf5-tools libatlas-base-dev libboost-all-dev libgflags-dev libgoogle-glog-dev libgoogle-glog0 libhdf5-serial-dev \
     libleveldb-dev liblmdb-dev libopencv-core-dev libopencv-highgui-dev libprotoc-dev libsnappy-dev libsnappy1 \
     libstdc++6-4.8-dbg opencl-headers protobuf-compiler python-pip

# DRM workaround
sudo apt-get install -y linux-image-extra-`uname -r` linux-headers-`uname -r` linux-image-`uname -r`

# Install CUDA
## for some reason this fails the first time
set +e
sudo apt-get install -y cuda
set -e
sudo apt-get install -y cuda
sudo sh -c 'cat > /etc/ld.so.conf.d/cuda.conf <<EOF
/usr/local/cuda-7.5/lib64
EOF
'
sudo ldconfig

# Tidy up
sudo apt-get clean

# verify
nvidia-smi
