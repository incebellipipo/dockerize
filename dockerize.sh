#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

DOCKER_PATH=$DIR
ROS_VERSION=${ROS_VERSION:-melodic}
NVIDIA_VERSION=`modinfo -F version nvidia`

function build {
    docker build --build-arg ROS_VERSION=${ROS_VERSION} --build-arg=NVIDIA_VERSION=${NVIDIA_VERSION} -t ${USER}:${ROS_VERSION} $DOCKER_PATH
}

function run {

    if docker ps -a | grep $CONTAINER_NAME -q ; then
        docker start $CONTAINER_NAME
        return
    fi

    docker stop $CONTAINER_NAME &> /dev/null
    docker rm $CONTAINER_NAME &> /dev/null
    xhost +
    # PROJECT SPECIFIC
    docker run \
        -it \
        --privileged \
        --net=host \
        --user $(id -u):$(id -g) \
            --env="DISPLAY" \
            --volume="/etc/group:/etc/group:ro" \
            --volume="/etc/passwd:/etc/passwd:ro" \
            --volume="/etc/shadow:/etc/shadow:ro" \
            --volume="/etc/sudoers.d:/etc/sudoers.d:ro" \
            --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
            --volume="/dev:/dev:rw" \
        --workdir $HOME \
        --volume $HOME:$HOME \
        --name $CONTAINER_NAME \
        $CONTAINER_IMAGE $SHELL
}

function attach {
    docker exec -it $CONTAINER_NAME $COMMAND
}

function stop {
    docker stop $CONTAINER_NAME &> /dev/null
}

function clean {
    containers=$(docker ps -a -q -f status=exited)
    if [ -n "$containers" ]; then
        docker rm -v $containers > /dev/null
    fi
}

function remove {
    images=$(docker images -f "dangling=true" -q)
    if [ -n "$images" ]; then
        docker rmi $images > /dev/null
    fi
}

function install {
  sudo ln -s $DIR/dockerize.sh /usr/local/bin/dockerize
}

case "$1" in
    install ) shift
      install
    ;;
    build ) shift
        while [ "$1" != "" ]; do
                case $1 in
                    -v | --ros_version )    shift
                                            ROS_VERSION=$1
                                            ;;
                    * )                     echo "Builds container image which has ros and some useful tools"
                                            echo "Usage:"
                                            echo "-v | --ros_version    : sets ros distro which created image will include. Default: melodic"
                                            echo "-h | --help           : displays this message"
                                            exit 1
                                            ;;
                esac
                shift
            done
            if [ -z "$ROS_VERSION" ] ; then
                ROS_VERSION=melodic
            fi
            echo "Ros Version Set To ${ROS_VERSION}"
        build
    ;;
    run ) shift
        while [ "$1" != "" ]; do
            case $1 in
                -n | --container_name ) shift
                                        CONTAINER_NAME=$1
                                        ;;
                -v | --ros_version )    shift
                                        ROS_VERSION=$1
                                        CONTAINER_NAME=${USER}_${ROS_VERSION}
                                        ;;
                -p | --project )        shift
                                        CONTAINER_IMAGE=${USER}:${1}
                                        CONTAINER_NAME=${USER}_${1}
                                        ;;
                -i | --image )          shift
                                        CONTAINER_IMAGE=$1
                                        ;;
                * )                     echo "Creates and attaches a container with some options"
                                        echo "Usage:"
                                        echo "-n | --container_name : sets the container name which will be created. Default: ${USER}_${ROS_VERSION}"
                                        echo "-v | --ros_version    : sets ros distro which defines container image as ${USER}:${ROS_VERSION}"
                                        echo "-p | --project        : sets project name which defines container image as ${USER}:project. With this option the ros_version parameter(-v) will be overwriten"
                                        echo "-i | --image          : sets the docker image. With this option the other parameters except container name(-n) will be overwriten"
                                        echo "-h | --help           : displays this message"
                                        exit 1
                                        ;;
            esac
            shift
        done
        if [ -z "$CONTAINER_IMAGE" ] ; then
            echo "Ros Version Set To ${ROS_VERSION}"
            CONTAINER_IMAGE="${USER}:${ROS_VERSION}"
        fi
        if [ -z "$CONTAINER_NAME" ] ; then
            CONTAINER_NAME="${USER}_${ROS_VERSION}"
        fi
        echo "Container Name Set To ${CONTAINER_NAME}"
        echo "CONTAINER_Image Set To ${CONTAINER_IMAGE}"
        run
    ;;
    attach ) shift
        while [ "$1" != "" ]; do
                case $1 in
                    -n | --container_name ) shift
                                            CONTAINER_NAME=$1
                                            ;;
                    -c | --command ) shift
                                            COMMAND=$1
                                            ;;
                    * )                     echo "Attaches a container with a command"
                                            echo "Usage:"
                                            echo "-n | --container_name : sets the container name which will be attached. Default: ${USER}_${ROS_VERSION}"
                                            echo "-c | --command        : sets the command which will run Default: $SHELL"
                                            echo "-h | --help           : displays this message"
                                            exit 1
                                            ;;
                esac
                shift
            done
            if [ -z "$CONTAINER_NAME" ] ; then
                CONTAINER_NAME="${USER}_${ROS_VERSION}"
            fi
            if [ -z "$COMMAND" ] ; then
                COMMAND=$SHELL
            fi
            echo "Container Name Set To ${CONTAINER_NAME}"
            echo "Command Set To ${COMMAND}"
        attach
    ;;
    stop ) shift
        while [ "$1" != "" ]; do
                case $1 in
                    -n | --container_name ) shift
                                            CONTAINER_NAME=$1
                                            ;;
                    * )                     echo "Stops a running container"
                                            echo "Usage:"
                                            echo "-n | --container_name : sets the container name which will be attached. Default: ${USER}_${ROS_VERSION}"
                                            echo "-h | --help           : displays this message"
                                            exit 1
                                            ;;
                esac
                shift
            done
            if [ -z "$CONTAINER_NAME" ] ; then
                CONTAINER_NAME="${USER}_${ROS_VERSION}"
            fi
            echo "Stopping container ${CONTAINER_NAME}"
            stop
    ;;
    clean ) shift
        if [ "$1" != "" ]; then
            echo "Cleans running containers"
            echo "Usage:"
            echo "-h | --help           : displays this message"
            exit 1
        fi
        echo "Please type Yes to verify cleaning"
        read Verification
        if [ "$Verification" == "Yes" ]; then
            clean
        else
            echo "Cleaning could not be verified"
        fi
    ;;
    remove ) shift
        if [ "$1" != "" ]; then
            echo "Removes all dangling images"
            echo "Usage:"
            echo "-h | --help           : displays this message"
            exit 1
        fi
        echo "Please type Yes to verify cleaning"
        read Verification
        if [ "$Verification" == "Yes" ]; then
            remove
        else
            echo "Cleaning could not be verified"
        fi
    ;;
    *)  echo "Dockerize has following functions. Please type --help with any command for features. Example:  dockerize run --help"
        echo
        echo
        echo "install   :Install this tool to system by creating symlink"
        echo "build     :Builds a container image which has ros and some useful tools"
        echo "run       :Creates and attaches a container with some options"
        echo "attach    :Attaches a container with a command"
        echo "stop      :Stops a running container"
        echo "clean     :Clears all dangling containers"
        echo "remove    :Removes images without running containers"
        exit 1
        ;;
esac
