#!/bin/bash -e

set -o pipefail

CAFFE_VERSION=${1:-master}

sudo apt update

sudo apt install -y gfortran git libatlas-base-dev libboost-all-dev libbz2-dev libffi-dev libfreeimage-dev \
     libgflags-dev libgoogle-glog-dev libhdf5-serial-dev libjpeg62 libleveldb-dev liblmdb-dev libopencv-dev \
     libprotobuf-dev libsnappy-dev libssl-dev libxml2-dev libxslt-dev protobuf-compiler python-dev python-minimal \
     python-numpy python-pip python-yaml

sudo apt clean
sudo rm -rf /var/lib/apt/lists/*

sudo pip2 install -U pip

pushd /tmp
git clone https://github.com/BVLC/caffe.git

pushd caffe
git checkout $CAFFE_VERSION
cat python/requirements.txt | xargs -L 1 sudo pip2 install
cp /tmp/caffe-Makefile.config Makefile.config
make all pycaffe distribute -j4
make runtest
sudo mkdir -p /opt && sudo mv distribute /opt/caffe
sudo sh -c 'git rev-parse HEAD > /opt/caffe/git-rev'

popd # caffe

rm -rf caffe
popd # /tmp

sudo sh -c 'cat > /usr/lib/python2.7/dist-packages/caffe.pth <<EOF
/opt/caffe/python/
EOF
'

sudo sh -c 'cat > /etc/ld.so.conf.d/caffe-ld-so.conf <<EOF
/opt/caffe/lib
EOF
'

sudo ldconfig
