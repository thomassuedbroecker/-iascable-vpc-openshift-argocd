#!/bin/bash

# ************************************
# To be executed in the `tool container`!
# ************************************

PROJECT_NAME="my-ibm-vpc-roks-argocd"

# 1. Navigate to workspace
pwd
cd ../workspace/${PROJECT_NAME}

# 2. Execute apply
sh apply.sh
ls ./terraform

# 3. Navigate to the mapped volume
cd ../../
cd src/{PROJECT_NAME}/terraform

# 4. Delete backup
rm -Rf bin2 
rm clis-debug.log
rm terraform.tfstate
