#!/bin/bash

# ************************************
# To be executed in the `tool container`!
# ************************************

PROJECT_NAME="my-ibm-vpc-roks-argocd"
BACKUP_PATH="src/${PROJECT_NAME}/terraform"

# 1. Navigate to workspace
pwd
cd ../workspace/${PROJECT_NAME}

# 2. Execute apply
sh destroy.sh


# 3. Navigate to the mapped volume
cd ${BACKUP_PATH}

# 4. Copy the state to the mapped volume
cp -Rf ../workspace/${PROJECT_NAME} .


