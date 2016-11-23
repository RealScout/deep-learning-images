# set for tensorflow configure
export CUDA_TOOLKIT_PATH=/usr/local/cuda
export CUDNN_INSTALL_PATH=/usr/local/cuda
export TF_NEED_CUDA=1
export TF_CUDA_VERSION=8.0
export TF_CUDNN_VERSION=5
export TF_CUDA_COMPUTE_CAPABILITIES=3.0
export TF_UNOFFICIAL_SETTING=1

# used by tensorflow.sh directly
BAZEL_CONFIG="--config=cuda"
