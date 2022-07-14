#!/bin/bash

# ************************************
# To executed in the `tool container`!
# ************************************

# Basic global variables
PROJECT_NAME="my-ibm-vpc-roks-argocd"

# 1. Create a workspace folder
ls 
mkdir ../workspace

# 2. Copy project into the workspace
cp -R ./${PROJECT_NAME} ../workspace
cd ../workspace/${PROJECT_NAME}

# 3. Execute apply
sh apply.sh