ARG ROS_VERSION=latest
FROM ros:$ROS_VERSION

ARG ROS_VERSION
ENV ROS_VERSION=${ROS_VERSION}

ARG NVIDIA_VERSION
ENV NVIDIA_VERSION=${NVIDIA_VERSION}

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

RUN \
  if [ ! -z "${NVIDIA_VERSION}" ] ; then \
    BASE_URL=http://us.download.nvidia.com/XFree86/Linux-$(uname -m)/${NVIDIA_VERSION}/NVIDIA-Linux-$(uname -m)-${NVIDIA_VERSION}.run ;\
    response=$(curl --write-out '%{http_code}' --silent --output nvidia-driver.run $BASE_URL) ;\
    if [[ "$response" != "404" ]] ; then \
      chmod +x nvidia-driver.run ;\
      ./nvidia-driver.run --accept-license --ui=none --no-kernel-module --no-questions --no-systemd;\
    fi ;\
  fi
