## RealScout Deep Learning Images

[Packer](http://packer.io) templates for caffe and tensorflow based EC2 GPU-enabled  machine and Docker container images from [RealScout](http://realscout.com).

## Step 0

Download the v4 cuDNN bundle from https://developer.nvidia.com/cudnn and place it in `install/`.  We haven't tried the new v5 RC yet!

You'll also need:
  * [Packer](http://packer.io)
  * An AWS Account to build AMIs
  * Docker to build container images

## Base Image

First create a base image with CUDA and cuDNN libraries installed.  We need a plain old ubuntu AMI to start building up from, the template includes a recent one that can be overriden by passing `-var ubuntu_ami=ami-xxxx` to packer.

To build your base image run: `packer build base.json`.  You should get a message about a successful build including an AMI ID like `ami-xxxxx`.

```
==> amazon-ebs: Uploading install/cudnn-7.0-linux-x64-v4.0-prod.tgz => /tmp/cudnn.tar.gz
==> amazon-ebs: Provisioning with shell script: install/cudnn.sh
==> amazon-ebs: Stopping the source instance...
==> amazon-ebs: Waiting for the instance to stop...
==> amazon-ebs: Creating the AMI: Base 1462298652
    amazon-ebs: AMI: ami-6908e904
==> amazon-ebs: Waiting for AMI to become ready...
```

Note that AMI ID, here `ami-6908e904`, we'll need it in the next step.

## Base++ Images

Now follow instructions for your favorite deep learning package.  You could combine them and make one enormous image with all of them installed.

Each of these templates will also build Docker container images.  To prevent that, pass `-only=amazon-ebs` to packer.  *note:* docker container images are not GPU-enabled as currently configured.

### Caffe Image

Caffe version: `rc2-856-gc2354b9`

To build your caffe image run: `packer build -var base_ami=ami-6908e904 caffe.json`.

### TensorFlow Image

TF Version: `v0.8.0`

To build your tensorflow image run: `packer build -var base_ami=ami-6908e904 tensorflow.json`.
