#!/bin/bash

# This file can be used to build and publish docker images based
# on git tags if docker cloud is being tempermental.
#
# Note:
#   * In this script the command 'bash run_tests.sh' is used to
#     run the flask unit tests.  You may need to change it to
#     match the command in your repository.
#   * This script should be copied into your repository in the
#     same folder as the Dockerfile file.
#   * If running this on the AWS server you may need to login
#     to your docker cloud account by running `docker login` first
#     or you won't be able to publish images.
#     You'll see "denied: requested access to the resource is denied"
#
# Usage:
#
# 	bash publish-tag.sh [your docker repo] [git tag to build]
#
# Example:  Build the 0.0.1 tag and publish to hub.docker.com mathyourlife/docker-cloud-test
#
#	bash publish-tag.sh mathyourlife/docker-cloud-test 0.0.1
#
# Example: Build the "latest" image from the current master branch
#
#   bash publish-tag.sh mathyourlife/docker-cloud-test latest
#

set -e

if [ -z "$2" ]; then
	echo "Error: 2 parameters are required"
	echo ""
	echo "Usage: bash $0 [your docker repo] [git tag to build]"
	exit 1
fi

DOCKER_REPO=$1
BUILD_VERSION=$2

build_test_publish() {
	DOCKER_REPO=$1
	BUILD_VERSION=$2
	if [ "$BUILD_VERSION" == "latest" ]; then
		git checkout master
		DOCKER_TAG="latest"
	else
		git checkout $BUILD_VERSION
		DOCKER_TAG="release-$BUILD_VERSION"
	fi
	docker build -t "$DOCKER_REPO:$DOCKER_TAG" .
	docker run "$DOCKER_REPO:$DOCKER_TAG" bash run_tests.sh
	if [ "$?" == "0" ]; then
		docker push "$DOCKER_REPO:$DOCKER_TAG"
	fi
}

build_test_publish $DOCKER_REPO $BUILD_VERSION