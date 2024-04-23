#### Attention
If you are looking for a better solution go and checkout [osrf's rocker](https://github.com/osrf/rocker) repository

# Dockerized ROS Environment

This script allows you to create docker containers where you can run graphical programs like [Gazebo](http://gazebosim.org/) without much effort.
This automation mimics your local installation and allows you to run your programs in a sandbox environment.
It mounts your home directory to the container and shares the same user variables.

### Installation

_There is no need to install this "package"._ But if you wish you can do something like:

1. Create some local directory like `~/.dockerize`
2. Clone this repository in `~/.dockerize`
3. Create symlink to`~./.dockerize/dockerize.sh` `/usr/local/bin/dockerize`
4. Call `ROS_DISTRO=noetic dockerize` anywhere

```bash
cd ~
git clone https://github.com/incebellipipo/dockerize .dockerize
sudo ln -s ~/.dockerize/dockerize.sh /usr/local/bin/dockerize
```

## Usage

**Build images**

Building images is pretty straight forward.
The script builds the image with ROS version described in `ROS_DISTRO` environment variable.
It could be set to versions of ROS which are published in [docker hub](https://hub.docker.com/_/ros).

```bash
ROS_DISTRO=humble ./dockerize.sh build
```

**Run images**

```bash
./dockerize.sh run
```

The user does not belong to any group in the first run. You can check it by running `groups` command. Thus, after logging in to the container, you need to log in again to be in the groups where your local user belongs. This is necessary to access the devices like `/dev/dri` and `/dev/snd`, etc.

```bash
# Inside Docker
$ su - ${USER}
Password:
```

Upon running the container, you may use TMUX or VSCode remote development to do development.

**Attaching running container**

```bash
ROS_DISTRO=humble ./dockerize.sh attach
```

**Stopping running container**

```bash
ROS_DISTRO=humble ./dockerize.sh stop
```

**Cleaning detached containers**

```bash
ROS_DISTRO=humble ./dockerize.sh clean
```

## Nvidia driver setup inside the container

On the host
```#!/bin/bash
export NVIDIA_DRIVER_VERSION="$(nvidia-smi --query-gpu=driver_version --format=csv,noheader)"
wget http://us.download.nvidia.com/XFree86/Linux-x86_64/"$NVIDIA_DRIVER_VERSION"/NVIDIA-Linux-x86_64-"$NVIDIA_DRIVER_VERSION".run
mv NVIDIA-Linux-x86_64-"$NVIDIA_DRIVER_VERSION".run NVIDIA-DRIVER.run
```
In the container
```
sudo ./NVIDIA-DRIVER.run -a -N --ui=none --no-kernel-module
```

Credits: https://stackoverflow.com/a/44187181
## Customization

Customize just like create any other Dockerfile.
