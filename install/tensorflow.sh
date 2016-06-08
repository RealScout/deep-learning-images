#!/bin/bash -e

set -o pipefail

BAZEL_VERSION=tags/0.2.2
TENSORFLOW_VERSION=v0.8.0rc0

# set up a big tmp space and a permanent tensorflow space
sudo mkdir -p -m 1777 /mnt/tmp /tensorflow

# install global deps
sudo apt-get update
sudo apt-get install -y build-essential git swig zip zlib1g-dev

# install bazel deps
sudo apt-get install -y software-properties-common  # for add-apt-repository
sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get update
sudo apt-get install -y openjdk-8-jdk
sudo update-alternatives --config java
sudo update-alternatives --config javac

# install bazel
pushd /mnt/tmp
git clone https://github.com/bazelbuild/bazel.git
pushd bazel
git checkout $BAZEL_VERSION
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
git clone -b $TENSORFLOW_VERSION --recurse-submodules https://github.com/tensorflow/tensorflow .
GCC_HOST_COMPILER_PATH=/usr/bin/gcc PYTHON_BIN_PATH=/usr/local/bin/python \
    CUDA_TOOLKIT_PATH=/usr/local/cuda CUDNN_INSTALL_PATH=/usr/local/cuda \
    TF_NEED_CUDA=1 TF_CUDA_VERSION=7.5 TF_CUDNN_VERSION=4 \
    TF_CUDA_COMPUTE_CAPABILITIES=3.0 TF_UNOFFICIAL_SETTING=1 \
    ./configure
bazel build -c opt --config=cuda //tensorflow/tools/pip_package:build_pip_package
bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
sudo /usr/local/bin/pip install /tmp/tensorflow_pkg/tensorflow-0.8.0rc0-py3-none-any.whl

# build retrainer
bazel build -c opt --copt=-mavx tensorflow/examples/image_retraining:retrain
popd
