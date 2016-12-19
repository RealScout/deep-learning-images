#!/bin/bash -ex

set -o pipefail

BAZEL_VERSION=0.3.2
TENSORFLOW_VERSION=v0.11.0

# set up a big tmp space and a permanent tensorflow space
sudo mkdir -p -m 1777 /mnt/tmp /tensorflow

# install global deps
sudo apt update
sudo apt install -y build-essential curl git openjdk-8-jdk python3-dev python3-numpy python3-pip python3-wheel swig zip zlib1g-dev

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

# install tensorflow
pushd /tensorflow
# add --recurse-submodules if < 0.9
git clone -b $TENSORFLOW_VERSION https://github.com/tensorflow/tensorflow .
(
set -a
test -e /tmp/tensorflow-build-conf.sh && source /tmp/tensorflow-build-conf.sh
GCC_HOST_COMPILER_PATH=/usr/bin/gcc PYTHON_BIN_PATH=/usr/bin/python3 \
    ./configure < /dev/null
bazel build -c opt $BAZEL_CONFIG //tensorflow/tools/pip_package:build_pip_package
bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
)
sudo /usr/bin/pip3 install /tmp/tensorflow_pkg/tensorflow-0.11.0-py3-none-any.whl

# build retrainer
bazel build -c opt --copt=-mavx tensorflow/examples/image_retraining:retrain
popd

# validate python installation
/usr/bin/python3 -c 'import tensorflow'
