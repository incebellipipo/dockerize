#### Attention
If you are looking for a better solution go and checkout [osrf's rocker](https://github.com/osrf/rocker) repository

# Dockerized ROS Environment

This "package" allows you to create docker images where you can run graphical  programs like [Gazebo](http://gazebosim.org/) without effort. Docker image is based on official ROS docker images, but it can easily be changed to something else. 

Here is the list that i didn't done _yet™_:
 - [ ] Cross platform container support for network and UI operations
 - [ ] Support for NVidia Graphics Cards

### Installation

_There is no need to install this "package"._ But if you wish you can do something like:

1. Create some local directory like `~/.dockerize`
2. Clone this repository in `~/.dockerize`
3. Create symlink to`~./.dockerize/dockerize.sh` `/usr/local/bin/dockerize`
4. Call `dockerize` anywhere

```bash
$ mkdir -p ~/.dockerize
$ cd ~/.dockerize
$ git clone https://github.com/incebellipipo/dockerize
$ sudo ln -s ~/.dockerize/dockerize.sh /usr/local/bin/dockerize
```



## Usage

**Build images**

Building images is pretty straight forward, only consumed variable here is `ROS_VERSION` environment variable. It could be set to versions of ROS which are published in [docker hub](https://hub.docker.com/_/ros).

```bash
$ export ROS_VERSION=kinetic
$ ./dockerize.sh build
```

**Run images**

```bash
$ ./dockerize.sh run
```

In order to run graphics applications like gazebo, you need to be in `video` group.  The user after you logged in to docker container is won't be in all groups where your local user belongs even though all user variables will be shared. As a quick work around you need to be logged in once again by using `su` command

```bash
# Inside Docker
$ su - ${USER}
Password:
```
_I personally recommend tmux after that._

**Attaching running container**

```bash
$ ./dockerize.sh attach
```

**Stopping running container**

```bash
$ ./dockerize.sh stop
```

**Cleaning detached containers**

```bash
$ ./dockerize.sh clean
```



## Customization

Customize just like create any other Dockerfile.
