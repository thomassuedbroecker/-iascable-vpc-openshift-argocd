# Use IasCable to create a VPC and a Red Hat OpenShift cluster with Argo CD installed on IBM Cloud

Verify the available Modules:

* Example BOM [https://github.com/cloud-native-toolkit/automation-solutions/blob/main/boms/software/gitops/200-openshift-gitops.yaml] which is linked to following modules: 
    
    * IBM OpenShift login [ocp-login](https://github.com/cloud-native-toolkit/terraform-ocp-login) - login to existing OpenShift cluster
    * GitOps repo [gitops-repo](https://github.com/cloud-native-toolkit/terraform-tools-gitops) - creates the GitOps Repo
    * ArgoCD Bootstrap [argocd-bootstrap](https://github.com/cloud-native-toolkit/terraform-tools-argocd-bootstrap)
    * Namespace [gitops-namespace](https://github.com/cloud-native-toolkit/terraform-gitops-namespace)
    * Cluster Config [gitops-cluster-config](https://github.com/cloud-native-toolkit/terraform-gitops-cluster-config)
    * Console Link Job [gitops-console-link-job](https://github.com/cloud-native-toolkit/terraform-gitops-console-link-job)


### Step 1: Write the Bill of Material BOM file

Combine with additional modules

```yaml
apiVersion: cloudnativetoolkit.dev/v1alpha1
kind: BillOfMaterial
metadata:
  name: my-ibm-vpc-roks-argocd
  labels:
    type: software
    code: '200'
  annotations:
    displayName: OpenShift GitOps Bootstrap
    description: Provisions OpenShift GitOps (ArgoCD) into an existing cluster and bootstraps it to a gitops repository
spec:
  modules:
    # Virtual Private Cloud
    - name: ibm-vpc
    - name: ibm-vpc-subnets
    - name: ibm-vpc-gateways
    # ROKS
    - name: ibm-ocp-vpc
      variables:
        - name: worker_count
          value: 1  
    # Login to existing OpenShift cluster
    - name: ocp-login
    # Create the GitOps Repo
    - name: gitops-repo
    # Install OpenShift GitOps and Bootstrap GitOps (aka. ArgoCD)
    - name: argocd-bootstrap
      variables:
        - name: create_webhook
          value: true
        - name: prefix
          value: maximo
    # Define namespace for the cloud native toolkit
    - name: gitops-namespace
      alias: toolkit_namespace
      default: true
      variables:
        - name: name
          value: toolkit
    - name: gitops-cluster-config
    - name: gitops-console-link-job
```

```yaml
apiVersion: cloudnativetoolkit.dev/v1alpha1
kind: BillOfMaterial
metadata:
  name: my-ibm-vpc-roks-argocd
spec:
  modules:
    # Virtual Private Cloud
    - name: ibm-vpc
    - name: ibm-vpc-subnets
    - name: ibm-vpc-gateways
    # ROKS
    - name: ibm-ocp-vpc
      variables:
        - name: worker_count
          value: 1
    # Install OpenShift GitOps and Bootstrap GitOps (aka. ArgoCD)
    - name: argocd-bootstrap
```

### Step 2: Build the project based on Bill of Material BOM file

```sh
iascable build -i my-vpc-roks-argocd-bom.yaml
```

### Step 3: Execute the `terraform init` command

Navigate to the `output/my-ibm-vpc-roks/terraform` folder and execute the `terraform init` command.

```sh
cd output/my-ibm-vpc-roks-argocd/terraform
terraform init
```

### Step 4: Execute the `terraform apply`  command

Execute the `terraform apply` command.

```sh
terraform apply -auto-approve
```

* Output:

```sh
var.gitops_repo_repo
  The short name of the repository (i.e. the part after the org/group name)

  Enter a value: iascable-vpc-openshift-argocd-gitops
var.ibmcloud_api_key
  The IBM Cloud api token

  Enter a value: xxx
var.region
  The IBM Cloud region where the cluster will be/has been installed.

  Enter a value: eu-de
var.resource_group_name
  The name of the resource group

  Enter a value: default
```

Error during the setup:

```sh
╷
│ Error: local-exec provisioner error
│ 
│   with module.gitops_repo.module.gitops-repo.null_resource.repo,
│   on .terraform/modules/gitops_repo.gitops-repo/main.tf line 31, in resource "null_resource" "repo":
│   31:   provisioner "local-exec" {
│ 
│ Error running command '.terraform/modules/gitops_repo.gitops-repo/scripts/create-repo.sh '' '' 'iascable-vpc-openshift-argocd-gitops' 'false' 'i1gTSuETN6wl8gv7'
│ 'false'': exit status 1. Output: Usage: create-repo.sh GIT_HOST ORG REPO [PUBLIC]
│ 
╵
╷
│ Error: External Program Execution Failed
│ 
│   with module.gitops_repo.module.setup_clis.data.external.setup-binaries,
│   on .terraform/modules/gitops_repo.setup_clis/main.tf line 22, in data "external" "setup-binaries":
│   22:   program = ["bash", "${path.module}/scripts/setup-binaries.sh"]
│ 
│ The data source received an unexpected error while attempting to execute the program.
│ 
│ Program: /bin/bash
│ Error Message: Error downloading yq3 from https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64
│ 
│ State: exit status 1
```