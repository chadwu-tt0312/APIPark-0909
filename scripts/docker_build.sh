#!/bin/bash

set -e

cd "$(dirname "$0")/../"
LOCAL_PATH=$(pwd)
ARCH=$1
User=$2
BuildMode=$3
if [[ "${BuildMode}" == "" ]];then
  BuildMode="all"
fi

if [[ "${ARCH}" == "" ]];then
  ARCH="amd64"
fi

# 编译可执行文件
echo "./scripts/build.sh 'cmd ${BuildMode} ${ARCH}'"
./scripts/build.sh "cmd" "" "${BuildMode}" ${ARCH}

source ./scripts/common.sh
APP="apipark"


mkdir -p scripts/cmd/ && cp cmd/${APP} scripts/cmd/ && cp cmd/apipark_ai_event_listen scripts/cmd/

# VERSION=$(gen_version)
VERSION="1.9.5-beta-0910"


SYS_ARCH=$(arch)
echo "SYS_ARCH: ${SYS_ARCH}"
echo "ARCH: ${ARCH}"
if [[ (${SYS_ARCH} == "aarch64" || ${SYS_ARCH} == "arm64") && $ARCH == "amd64" ]];then
  OPTIONS="--platform=linux/amd64"
elif [[ (${SYS_ARCH}  == "amd64" || ${SYS_ARCH} == "x86_64") && $ARCH == "arm64" ]];then
  OPTIONS="--platform=linux/arm64"
fi

if [[ "${User}" == "" ]];then
  User="eolinker"
fi

# imageName=${User}/${APP}:${VERSION}-${ARCH}
imageName=${User}/${APP}:${VERSION}
# docker rmi -f ${imageName}
podman rmi -f ${imageName}

echo "docker build ${OPTIONS} -t ${imageName} --build-arg VERSION=${VERSION} --build-arg APP=${APP}  -f ./scripts/Dockerfile ./scripts/"
# docker build ${OPTIONS} -t ${imageName} --build-arg VERSION=${VERSION} --build-arg APP=${APP}  -f ./scripts/Dockerfile ./scripts/
podman build ${OPTIONS} -t ${imageName} --build-arg VERSION=${VERSION} --build-arg APP=${APP}  -f ./scripts/Dockerfile ./scripts/


