#!/bin/bash

# Basic global variables
DOCKER_CMD="docker"
DOCKER_IMAGE="quay.io/ibmgaragecloud/cli-tools:v1.1"
SUFFIX=$(echo $(basename ${SCRIPT_DIR}) | base64 | sed -E "s/[^a-zA-Z0-9_.-]//g" | sed -E "s/.*(.{5})/\1/g")
CONTAINER_NAME="cli-tools-${SUFFIX}"
ENV_FILE=""
PROJECTNAME="my-ibm-vpc-roks-argocd"
CONTAINER_ENGINE="colima"

# 1. Get root directory
SCRIPT_DIR="$(cd $(dirname $0); pwd -P)"
SRC_DIR="${SCRIPT_DIR}/output"
SUFFIX=$(echo $(basename ${SCRIPT_DIR}) | base64 | sed -E "s/[^a-zA-Z0-9_.-]//g" | sed -E "s/.*(.{5})/\1/g")
CONTAINER_NAME="cli-tools-${SUFFIX}"

# 2. Start container engine
"${CONTAINER_ENGINE}" start

# 3. Verify if credentials do exist?
if [[ -f "credentials.properties" ]]; then
  ENV_FILE="--env-file credentials.properties"
fi

# 4. Start tools container
${DOCKER_CMD} run -itd --name ${CONTAINER_NAME} -v ${SRC_DIR}:/home/devops/src ${ENV_FILE} -w /home/devops/src ${DOCKER_IMAGE}

# 5. Attach to the tools container
echo "Attaching to running container..."
${DOCKER_CMD} attach ${CONTAINER_NAME}