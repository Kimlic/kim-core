#!/bin/bash
PREVIOUS_VERSION=$PROJECT_VERSION

LAST_COMMIT=$(git log --pretty=format:"%h" -2)
LAST_COMMITS_MESSAGE=$(git show --quiet --pretty=format:%B $LAST_COMMIT)

MAJOR_CHANGES=$(grep -io '^\[major\]' <<< "${LAST_COMMITS_MESSAGE}" | wc -l)
MINOR_CHANGES=$(grep -io '^\[minor\]' <<< "${LAST_COMMITS_MESSAGE}" | wc -l)
PATCH_CHANGES=$(grep -io '^\[patch\]' <<< "${LAST_COMMITS_MESSAGE}" | wc -l)

# Convert values to numbers (trims leading spaces)
MAJOR_CHANGES=$(expr $MAJOR_CHANGES + 0)
MINOR_CHANGES=$(expr $MINOR_CHANGES + 0)
PATCH_CHANGES=$(expr $PATCH_CHANGES + 0)

# Generate next version.
parts=( ${PREVIOUS_VERSION//./ } )
NEXT_MAJOR_VERSION=$(expr ${parts[0]} + ${MAJOR_CHANGES})

if [[ ${MAJOR_CHANGES} != "0" ]]; then
  NEXT_MINOR_VERSION="0"
else
  NEXT_MINOR_VERSION=$(expr ${parts[1]} + ${MINOR_CHANGES})
fi;

if [[ ${MAJOR_CHANGES} != "0" || ${MINOR_CHANGES} != "0" ]]; then
  NEXT_PATCH_VERSION="0"
elif [[ ${PATCH_CHANGES} == "0" ]]; then
  NEXT_PATCH_VERSION=$(expr ${parts[2]} + 1)
else
  NEXT_PATCH_VERSION=$(expr ${parts[2]} + ${PATCH_CHANGES})
fi;

NEXT_VERSION="${NEXT_MAJOR_VERSION}.${NEXT_MINOR_VERSION}.${NEXT_PATCH_VERSION}"

if [[ "${MAJOR_CHANGES}" == "0" && "${MINOR_CHANGES}" == "0" && "${PATCH_CHANGES}" == "0" ]]; then
  echo "[ERROR] No version changes was detected (no patch, minor or major changes)."
  export VERSION_ERROR="[ERROR] No version changes was detected (no patch, minor or major changes)."
fi;

# Show version info
echo
echo "Version information: "
echo " - Previous version was ${PREVIOUS_VERSION}"
echo " - There was ${MAJOR_CHANGES} major, ${MINOR_CHANGES} minor and ${PATCH_CHANGES} patch changes since then"
echo " - Next version will be ${NEXT_VERSION}"

export PREVIOUS_VERSION=$PREVIOUS_VERSION
export NEXT_VERSION=$NEXT_VERSION
export PROJECT_VERSION=$NEXT_VERSION
