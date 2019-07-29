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
    zsh

RUN \
  apt-get update && \
  apt-get install -y \
    libcanberra-gtk-module && \
  rm -rf /var/lib/apt/lists/*

RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections
