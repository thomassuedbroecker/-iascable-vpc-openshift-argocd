#!/bin/bash

# ************************************
# To executed in the `tool container`!
# ************************************

PROJECT_NAME="my-ibm-vpc-roks-argocd"

# 1. Navigate to workspace
cd ../workspace/${PROJECT_NAME}

# 2. Execute apply
sh apply.sh

# 3. Backup execution in local project
cp -R ../workspace/${PROJECT_NAME} .

