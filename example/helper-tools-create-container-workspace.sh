#!/bin/bash

# ************************************
#  To be executed in the `tool container`!
# ************************************

# Basic global variables
PROJECT_NAME="my-ibm-vpc-roks-argocd"
WORKSPACES_PATH="/workspaces"
MAPPED_VOLUME_PATH="/terraform"

# 1. Copy project into the workspace
cp -R ./${PROJECT_NAME} ${WORKSPACES_PATH}
cp ./${PROJECT_NAME}/*.* ${WORKSPACES_PATH}
cd ${WORKSPACES_PATH}/${PROJECT_NAME}
