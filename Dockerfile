ARG ROS_VERSION=latest
FROM ros:$ROS_VERSION

ARG ROS_VERSION
ENV ROS_VERSION=${ROS_VERSION}

RUN \
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
    ros-${ROS_VERSION}-desktop

RUN \
  apt-get update && \
  apt-get install -y \
    libcanberra-gtk-module \
    python-catkin-tools \
  && \
  rm -rf /var/lib/apt/lists/*

RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections
