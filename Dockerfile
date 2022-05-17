ARG ROS_VERSION=latest
FROM ros:$ROS_VERSION

ARG ROS_VERSION
ENV ROS_VERSION=${ROS_VERSION}

RUN \
  export DEBIAN_FRONTEND=noninteractive && \
  echo "ROS Version is: " ${ROS_VERSION} && \
  apt-get update -yq && apt-get install -yq \
  apt-utils \
    git \
    sudo \
    tmux \
    vim \
    htop \
    zsh \
    net-tools \
    iputils-* \
    curl \
    iproute2 \
    build-essential \
    ros-${ROS_VERSION}-desktop \
  && \
  rm -rf /var/lib/apt/lists/*

