#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"


if [ -z "$ROS_VERSION" ] ; then
  ROS_VERSION=kinetic
fi

DOCKER_PATH=$DIR
CONTAINER_NAME=${USER}_${ROS_VERSION}
CONTAINER_IMAGE=${USER}:${ROS_VERSION}

function build {
    docker build --build-arg ROS_VERSION=${ROS_VERSION} -t $CONTAINER_IMAGE $DOCKER_PATH
}

function run {
    docker stop $CONTAINER_NAME &> /dev/null
    docker rm $CONTAINER_NAME &> /dev/null
    # xhost +
    # PROJECT SPECIFIC
    docker run \
        -it \
        --rm \
        --privileged \
        --user $(id -u):$(id -g) \
 		  	--env="DISPLAY=${DISPLAY}" \
        --env="QT_X11_NO_MITSHM=1" \
    		--volume="/etc/group:/etc/group:ro" \
    		--volume="/etc/passwd:/etc/passwd:ro" \
    		--volume="/etc/shadow:/etc/shadow:ro" \
    		--volume="/etc/sudoers.d:/etc/sudoers.d:ro" \
    		--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
        --device /dev/dri/ \
        --device /dev/vga_arbiter/ \
        --volume $HOME:$HOME \
        --name $CONTAINER_NAME \
        $CONTAINER_IMAGE /bin/bash
}

function clean {
    containers=$(docker ps -a -q -f status=exited)
    if [ -n "$containers" ]; then
        docker rm -v $containers > /dev/null
    fi

    images=$(docker images -f "dangling=true" -q)
    if [ -n "$images" ]; then
        docker rmi $images > /dev/null
    fi
}

function attach {
    docker exec -it $CONTAINER_NAME /bin/bash
}

function stop {
    docker stop $CONTAINER_NAME &> /dev/null
}

case "$1" in
    build|run|attach|stop|clean)
        $1
        ;;
    *)
        echo $"Usage: $0 {clean|build|run|attach|stop}"
        echo $"   Consumed env varilabes:"
        echo $"     - ROS_VERSION        "
        exit 1
        ;;
esac
