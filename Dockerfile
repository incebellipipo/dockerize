ARG ROS_DISTRO=latest
FROM ros:$ROS_DISTRO

ARG ROS_DISTRO
ENV ROS_DISTRO=${ROS_DISTRO}

RUN \
  export DEBIAN_FRONTEND=noninteractive && \
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
    wget \
    iproute2 \
    build-essential \
    mesa-utils \
    ros-${ROS_DISTRO}-desktop \
  && \
  rm -rf /var/lib/apt/lists/*

ARG NVIDIA_DRIVER_VERSION
ENV NVIDIA_DRIVER_VERSION=${NVIDIA_DRIVER_VERSION}

RUN \
  if [ ! -z "${NVIDIA_DRIVER_VERSION}" ] ; then \
    BASE_URL=http://us.download.nvidia.com/XFree86/Linux-$(uname -m)/${NVIDIA_DRIVER_VERSION}/NVIDIA-Linux-$(uname -m)-${NVIDIA_DRIVER_VERSION}.run ;\
    response=$(curl --write-out '%{http_code}' --silent --output nvidia-driver.run $BASE_URL) ;\
    if [[ "$response" != "404" ]] ; then \
      chmod +x nvidia-driver.run ;\
      ./nvidia-driver.run --accept-license --ui=none --no-kernel-module --no-questions --no-systemd;\
    fi ;\
  fi
