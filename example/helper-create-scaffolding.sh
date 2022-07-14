#!/bin/bash

# Basic global variables
CONTAINER_ENGINE="colima"

# 1. Create scaffolding
iascable build -i my-vpc-roks-argocd-bom.yaml

# 2. Navigate to created 'scaffolding'
cd output

# 3. Start container engine
"${CONTAINER_ENGINE}" start

# 4. Start tools container
sh launch.sh
