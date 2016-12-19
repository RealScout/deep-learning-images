#!/bin/bash -ex

set -o pipefail

BAZEL_VERSION=0.3.2
TENSORFLOW_VERSION=v0.11.0

# set up a big tmp space and a permanent tensorflow space
sudo mkdir -p -m 1777 /mnt/tmp /tensorflow

# install global deps
sudo apt update
sudo apt install -y build-essential curl git openjdk-8-jdk swig zip zlib1g-dev

# install bazel deps
#sudo update-alternatives --config java
#sudo update-alternatives --config javac
sudo apt clean
sudo rm -rf /var/lib/apt/lists/*

# install bazel
pushd /mnt/tmp
git clone -b $BAZEL_VERSION https://github.com/bazelbuild/bazel.git
pushd bazel
./compile.sh
sudo cp output/bazel /usr/bin
popd
popd

# install anaconda python 3.5
pushd /mnt/tmp
curl -o Anaconda3-4.0.0-Linux-x86_64.sh -L http://repo.continuum.io/archive/Anaconda3-4.0.0-Linux-x86_64.sh
echo "36a558a1109868661a5735f5f32607643f6dc05cf581fefb1c10fb8abbe22f39 Anaconda3-4.0.0-Linux-x86_64.sh" | sha256sum -c -
sudo bash -c 'bash Anaconda3-4.0.0-Linux-x86_64.sh -b -f -p /usr/local'
sudo /usr/local/bin/conda install -y anaconda python=3.5
sudo /usr/local/bin/conda install -y pip
popd

# install tensorflow
pushd /tensorflow
# add --recurse-submodules if < 0.9
git clone -b $TENSORFLOW_VERSION https://github.com/tensorflow/tensorflow .
(
set -a
test -e /tmp/tensorflow-build-conf.sh && source /tmp/tensorflow-build-conf.sh
GCC_HOST_COMPILER_PATH=/usr/bin/gcc PYTHON_BIN_PATH=/usr/local/bin/python \
    ./configure < /dev/null
bazel build -c opt $BAZEL_CONFIG //tensorflow/tools/pip_package:build_pip_package
bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
)
sudo /usr/local/bin/pip install /tmp/tensorflow_pkg/tensorflow-0.11.0-py3-none-any.whl

# build retrainer
bazel build -c opt --copt=-mavx tensorflow/examples/image_retraining:retrain
popd
