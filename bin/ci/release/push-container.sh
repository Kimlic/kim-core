#!/bin/bash
set -e

# login into DockerHub
if [ ! $DOCKER_HUB_ACCOUNT  ]; then
  echo "[E] You need to specify Docker Hub account as DOCKER_HUB_ACCOUNT env variable."
  exit 1
fi

echo "Logging in into Docker Hub";
echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin

CONTAINER_VERSION="${PROJECT_VERSION}-${TRAVIS_JOB_NUMBER}"
RELEASE_VERSION=$NEXT_VERSION
HUB_ACCOUNT=$DOCKER_HUB_ACCOUNT

if [[ "${TRAVIS_PULL_REQUEST}" == "false" && "${TRAVIS_BRANCH}" == "${TRUNK_BRANCH}" ]]; then

  echo "[I] Tagging image '${PROJECT_NAME}:${CONTAINER_VERSION}' into a Docker Hub repository '${HUB_ACCOUNT}/${PROJECT_NAME}:${CONTAINER_VERSION}'.."
  docker tag "${PROJECT_NAME}:${CONTAINER_VERSION}" "${HUB_ACCOUNT}/${PROJECT_NAME}:${CONTAINER_VERSION}"

  echo "[I] Assigning additional tag '${HUB_ACCOUNT}/${PROJECT_NAME}:latest'.."
  docker tag "${PROJECT_NAME}:${CONTAINER_VERSION}" "${HUB_ACCOUNT}/${PROJECT_NAME}:latest"

  echo "[I] Pushing changes to Docker Hub.."
  docker push "${HUB_ACCOUNT}/${PROJECT_NAME}"
fi
