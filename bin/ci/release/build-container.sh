#!/bin/bash
# This script builds an image based on a Dockerfile and mix.exs that is located in root of git working tree.
set -e

export CONTAINER_VERSION="${PROJECT_VERSION}-${TRAVIS_JOB_NUMBER}"

echo "[I] Building a Docker container '${PROJECT_NAME}' (version '${CONTAINER_VERSION}') from path '${PROJECT_DIR}'.."
docker build --tag "${PROJECT_NAME}:${CONTAINER_VERSION}" \
             --file "${PROJECT_DIR}/Dockerfile" \
             --build-arg APP_VERSION=$PROJECT_VERSION \
             --build-arg APP_NAME=$PROJECT_NAME \
             "${PROJECT_DIR}/../../"
