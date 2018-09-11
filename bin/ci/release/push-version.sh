#!/bin/bash
# This setup works with Travis-CI.
# You need to specify $DOCKER_HUB_ACCOUNT, $DOCKER_USERNAME and $DOCKER_PASSWORD before using this script.
set -e

# Github
REPO_URL="https://github.com/${TRAVIS_REPO_SLUG}.git";

echo "Setting Gih user/password";
git config --global user.email "travis@travis-ci.com";
git config --global user.name "Travis-CI";
git config --global push.default upstream;
git remote add upstream ${REPO_URL} &> /dev/null

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_URL="https://github.com/${TRAVIS_REPO_SLUG}.git";

if [[ "${TRAVIS_PULL_REQUEST}" == "false" ]]; then
  git add "${PROJECT_DIR}/mix.exs";
  git add docs;
  git commit -m "Increment version [ci skip]";

  echo "Current branch: ${TRAVIS_BRANCH}"
  echo "Trunk branch: ${TRUNK_BRANCH}"

  if [[ "${TRAVIS_BRANCH}" == "${TRUNK_BRANCH}" ]]; then

    # Save some useful information
    REPO=`git config remote.origin.url`
    SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
    SHA=`git rev-parse --verify HEAD`

    # Get the deploy key by using Travis's stored variables to decrypt deploy_key.enc
    ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
    ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
    ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
    ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
    openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in "${TRAVIS_BUILD_DIR}/github_deploy_key.enc" -out github_deploy_key -d
    chmod 600 github_deploy_key
    eval `ssh-agent -s`
    ssh-add github_deploy_key

    echo "Pushing changes back to origin repo.";
    git pull --rebase $SSH_REPO HEAD:$TRUNK_BRANCH;
    git push $SSH_REPO HEAD:$TRUNK_BRANCH;
    echo "Done.";
  else
    echo "[I] This build is not in a trunk or maintenance branch, new version will not be created"
  fi;
else
  echo "[I] This build is a pull request, new version will not be created"
fi;
