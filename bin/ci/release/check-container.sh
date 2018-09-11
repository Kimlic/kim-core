#!/bin/bash
# This script can check if a local Docker container with created image started succesfully.
docker logs ${PROJECT_NAME} --details --since 5h;

IS_RUNNING=$(docker inspect --format='{{ .State.Running }}' ${PROJECT_NAME});

if [ -z "$IS_RUNNING" ] || [ $IS_RUNNING != "true" ]; then
  echo "[E] Container is not started.";
  exit 1;
fi;
