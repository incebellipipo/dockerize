ARG ROS_VERSION=latest
FROM ros:$ROS_VERSION

RUN \
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
    build-essential

RUN \
  apt-get update && \
  apt-get install -y \
    libcanberra-gtk-module \
    python-catkin-tools \
  && \
  rm -rf /var/lib/apt/lists/*

RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections
