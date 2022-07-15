#!/bin/bash

# ************************************
# To be executed in the `tool container`!
# ************************************

PROJECT_NAME="my-ibm-vpc-roks-argocd"
BACKUP_PATH_LOCAL_MACHINE="/home/devops/src"
ROOT_PATH="/home/devops"


# 1. Navigate to workspace
pwd
cd ${ROOT_PATH}/workspace/${PROJECT_NAME}

# 2. Execute apply
sh apply.sh
ls -a ./terraform

# 3. List the created resources
cd ${ROOT_PATH}/workspace/${PROJECT_NAME}/terraform 
terraform state list

# 4. Copy current start to mapped volume
cp -Rf ${ROOT_PATH}/workspace/${PROJECT_NAME} ${BACKUP_PATH_LOCAL_MACHINE}


