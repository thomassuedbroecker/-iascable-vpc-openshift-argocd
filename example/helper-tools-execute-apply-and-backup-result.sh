#!/bin/bash

# ************************************
# To be executed in the `tool container`!
# ************************************

PROJECT_NAME="my-ibm-vpc-roks-argocd"
WORKSPACES_PATH="/workspaces"
MAPPED_VOLUME_PATH="/terraform"

# 1. Navigate to workspace
pwd
cd ${WORKSPACES_PATH}/${PROJECT_NAME}

# 2. Execute apply
sh apply.sh
ls -a ./terraform

# 3. List the created resources
cd ${WORKSPACES_PATH}/${PROJECT_NAME}/terraform 
terraform state list

# 4. Copy current start to mapped volume
cp -Rf ${WORKSPACES_PATH}/${PROJECT_NAME} ${MAPPED_VOLUME_PATH}


