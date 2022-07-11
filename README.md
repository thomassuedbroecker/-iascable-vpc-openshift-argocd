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

Combine with additional modules:

* Initial approach: 

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

* Second approach: 

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

* Third approach: 

Now going to define some variable in the initial BOM file.

I noticed that the variables **weren't** used in th variables file 
`output/my-ibm-vpc-roks-argocd/terraform/variables.tf`.

```yaml
apiVersion: cloudnativetoolkit.dev/v1alpha1
kind: BillOfMaterial
metadata:
  name: my-ibm-vpc-roks-argocd
spec:
  modules:
    # Virtual Private Cloud
    - name: ibm-vpc
      variables:
      - name: ibm-vpc_name
        value: "tsued-gitops-sample"
    - name: ibm-vpc-subnets
      variables:
      - name: ibm-vpc-subnets_label
        value: "tsued-gitops-sample"
      - name: ibm-vpc-subnets__count
        value: 1
    - name: ibm-vpc-gateways
    # ROKS
    - name: ibm-ocp-vpc
      variables:
        - name: cluster_name
          value: "tsued-gitops-sample"
        - name: worker_count
          value: 2
        - name: region
          value: "eu-de" 
    # Install OpenShift GitOps and Bootstrap GitOps (aka. ArgoCD)
    - name: argocd-bootstrap
      variables:
        - name: gitops_repo_username
          value: "thomassuedbroecker"
        - name: gitops_repo_token
        - name: gitops_repo_type
          value: "GIT"
        - name: gitops_repo_project
          value: "iascable-vpc-openshift-argocd-gitops"
        - name: gitops_repo_server_name
          value: "tsued-gitops-sample"
```

### Step 2: Build the project based on Bill of Material BOM file

```sh
iascable build -i my-vpc-roks-argocd-bom.yaml
```

Defined in the variables in the `output/my-ibm-vpc-roks-argocd/terraform/variables.tf` file (for the second approach).

| Variable | Type | Description | default |
| --- | --- | --- | --- |
| `argocd-bootstrap_bootstrap_prefix` | **string** | The prefix used in ArgoCD to bootstrap the application | **no default** |
| `argocd-bootstrap_create_webhook` | **bool** | Flag indicating that a webhook should be created in the gitops repo to notify argocd of changes | **false** |
| `region` | **string** | The IBM Cloud region where the cluster will be/has been installed. | **no default** |
| `ibmcloud_api_key` | **string** | The IBM Cloud api token. | **no default** |
| `cluster_name` | **string** | The name of the cluster that will be created within the resource group. | **no default** |
| `worker_count` | **number** | The number of worker nodes that should be provisioned for classic infrastructure. | **1** |
| `cluster_flavor` | **string** | The machine type that will be provisioned for classic infrastructure. | **bx2.4x16** |
| `ocp_version` | **string** | The version of the OpenShift cluster that should be provisioned (format 4.x). | **4.10** |
| `cluster_exists` | **bool** | Flag indicating if the cluster already exists (true or false). | **false** |
| `cluster_disable_public_endpoint` | **bool** | Flag indicating that the public endpoint should be disabled. | **false** |
| `name_prefix` | **string** | The prefix name for the service. If not provided it will default to the resource group name. | **no default** |
| `cluster_ocp_entitlement` | **string** | Value that is applied to the entitlements for OCP cluster provisioning. | **cloud_pak** |
| `cluster_force_delete_storage` | **bool** | Attribute to force the removal of persistent storage associtated with the cluster. | **false** |
| `cluster_tags` | **string** | Tags that should be added to the instance | **"[]"** |
| `cluster_kms_enabled` | **bool** | Flag indicating that kms encryption should be enabled for this cluster | **false** |
| `cluster_kms_id` | **string** | The crn of the KMS instance that will be used to encrypt the cluster. | **null** |
| `cluster_kms_key_id` | **string** | The id of the root key in the KMS instance that will be used to encrypt the cluster. | **null** |
| `cluster_kms_private_endpoint` | **bool** | Flag indicating that the private endpoint should be used to connect the KMS system to the cluster. | **true** |
| `cluster_login` | **bool** | Flag indicating that after the cluster is provisioned, the module should log into the cluster | **false** |
| `ibm-vpc_name` | **string** | The name of the vpc instance | **""** |
| `ibm-vpc_provision` | **bool** | Flag indicating that the instance should be provisioned. If false then an existing instance will be looked up | **true** |
| `ibm-vpc_address_prefix_count` | **number** | The number of ipv4_cidr_blocks | **0** |
| `ibm-vpc_address_prefixes` | **string** | List of ipv4 cidr blocks for the address prefixes (e.g. ['10.10.10.0/24']). If you are providing cidr blocks then a value must be provided for each of the subnets. If you don't provide cidr blocks for each of the subnets then values will be generated using the {ipv4_address_count} value. | **"[]"** |
| `ibm-vpc_base_security_group_name` | **string** | The name of the base security group. If not provided the name will be based on the vpc name | **""** |
| `ibm-vpc_internal_cidr` | **string** | The cidr range of the internal network | **"10.0.0.0/8"** |
| `ibm-vpc_tags` | **string** | Tags that should be added to the instance | **"[]"** |
| `ibm-vpc-gateways_provision` | **bool** | Flag indicating that the gateway must be provisioned | **true** |
| `ibm-vpc-gateways_tags` | **string** | Tags that should be added to the instance | **"[]"** |
| `ibm-vpc-subnets_zone_offset` | **number** | The offset for the zone where the subnet should be created. The default offset is 0 which means the first subnet should be created in zone xxx-1 | **0** |
| `ibm-vpc-subnets__count` | **number** | The number of subnets that should be provisioned | **1** |
| `ibm-vpc-subnets_label` | **string** | Label for the subnets created | **"default"** |
| `ibm-vpc-subnets_ipv4_cidr_blocks` | **string** | List of ipv4 cidr blocks for the subnets that will be created (e.g. ['10.10.10.0/24']). If you are providing cidr blocks then a value must be provided for each of the subnets. If you don't provide cidr blocks for each of the subnets then values will be generated using the {ipv4_address_count} value. | **"[]"** |
| `ibm-vpc-subnets_ipv4_address_count` | **number** | The size of the ipv4 cidr block that should be allocated to the subnet. If {ipv4_cidr_blocks} are provided then this value is ignored. | **256** |
| `ibm-vpc-subnets_provision` | **bool** | Flag indicating that the subnet should be provisioned. If 'false' then the subnet will be looked up. | **true** |
| `ibm-vpc-subnets_acl_rules` | **string** | List of rules to set on the subnet access control list | **"[]"** |
| `ibm-vpc-subnets_tags` | **string** | Tags that should be added to the instance | **"[]"** |
| `gitops_repo_host` | **string** | The host for the git repository. The git host used can be a GitHub, GitHub Enterprise, Gitlab, Bitbucket, Gitea or Azure DevOps server. If the host is null assumes in-cluster Gitea instance will be used. | **""** |
| `gitops_repo_type` | **string** | [Deprecated] The type of the hosted git repository. | **"GIT"** |
| `gitops_repo_org` | **string** | The org/group where the git repository exists/will be provisioned. If the value is left blank then the username org will be used. | **""** |
| `gitops_repo_project` | **string** | The project that will be used for the git repo. (Primarily used for Azure DevOps repos) | **""** |
| `gitops_repo_username` | **string** | The username of the user with access to the repository | **"thomassuedbroecker"** |
| `gitops_repo_token` | **string** | The personal access token used to access the repository | **""** |
| `gitops_repo_gitea_host` | **string** | The host for the default gitea repository. | **""** |
| `gitops_repo_gitea_org` | **string** | The org/group for the default gitea repository. If not provided, the value will default to the username org | **""** |
| `gitops_repo_gitea_username` | **string** | The username of the default gitea repository | **""** |
| `gitops_repo_gitea_token` | **string** | The personal access token used to access the repository | **""** |
| `gitops_repo_repo` | **string** | The short name of the repository (i.e. the part after the org/group name)"** |
| `gitops_repo_branch` | **string** | The name of the branch that will be used. If the repo already exists (provision=false) then it is assumed this branch already exists as well | **"main"** |
| `gitops_repo_public` | **bool** | Flag indicating that the repo should be public or private | **false** |
| `gitops_repo_gitops_namespace` | **string** | The namespace where ArgoCD is running in the cluster | **"openshift-gitops"** |
| `gitops_repo_server_name` | **string** | The name of the cluster that will be configured via gitops. This is used to separate the config by cluster | **"default_gitops"** |
| `gitops_repo_strict` | **bool** | Flag indicating that an error should be thrown if the repo already exists | **false** |
| `sealed-secret-cert_cert` | **string** | The public key that will be used to encrypt sealed secrets. If not provided, a new one will be generated | **""** |
| `sealed-secret-cert_private_key` | **string** | The private key that will be used to decrypt sealed secrets. If not provided, a new one will be generated | **""** |
| `sealed-secret-cert_cert_file` | **string** | The file containing the public key that will be used to encrypt the sealed secrets. If not provided a new public key will be generated | **""** |
| `sealed-secret-cert_private_key_file` | **string** | The file containin the private key that will be used to encrypt the sealed secrets. If not provided a new private key will be generated | **""** |
| `resource_group_name` | **string** | The name of the resource group"** |
| `resource_group_sync` | **string** | Value used to order the provisioning of the resource group | **""** |
| `cos_resource_location` | **string** | Geographic location of the resource (e.g. us-south, us-east) | **"global"** |
| `cos_tags` | **string** | Tags that should be applied to the service | **"[]"** |
| `cos_plan` | **string** | The type of plan the service instance should run under (lite or standard) | **"standard"** |
| `cos_provision` | **bool** | Flag indicating that cos instance should be provisioned | **true** |
| `"cos_label"` | **string** | The name that should be used for the service, particularly when connecting to an existing service. If not provided then the name will be defaulted to {name prefix}-{service} | **"cos"** |

### Step 2.1: Use `output/my-ibm-vpc-roks-argocd/apply.sh` to configure the terraform variables.

The apply.sh scripts will create:

* a tempoary `output/my-ibm-vpc-roks-argocd/variables.yaml.tmp` file
* a `output/my-ibm-vpc-roks-argocd/variables.yaml` file
* a `output/my-ibm-vpc-roks-argocd/terraform/variables.tf` file
* a `output/my-ibm-vpc-roks-argocd/terraform/variables.tfvars` file
* several folders `.kube`, `.terraform`, `.tmp`, `bin2`, `docs`
* it creates a GitHub private project which contains you ID for the `cloud native toolkit`

```sh
cd output/my-ibm-vpc-roks-argocd
sh apply.sh
```

* Interactive output:

```sh
Provide a value for 'ibmcloud_api_key':
  The IBM Cloud api token
> XXXX
Provide a value for 'worker_count':
  The number of worker nodes that should be provisioned for classic infrastructure
> (2) 2
Provide a value for 'cluster_flavor':
  The machine type that will be provisioned for classic infrastructure
> (bx2.4x16) bx2.4x16
Provide a value for 'ibm-vpc-subnets__count':
  The number of subnets that should be provisioned
> (3) 1
Provide a value for 'gitops_repo_host':
  The host for the git repository. The git host used can be a GitHub, GitHub Enterprise, Gitlab, Bitbucket, Gitea or Azure DevOps server. If the host is null assumes in-cluster Gitea instance will be used.
> github.com
Provide a value for 'gitops_repo_org':
  The org/group where the git repository exists/will be provisioned. If the value is left blank then the username org will be used.
> thomassuedbroecker
Provide a value for 'gitops_repo_project':
  The project that will be used for the git repo. (Primarily used for Azure DevOps repos)
> https://github.com/thomassuedbroecker/iascable-vpc-openshift-argocd-gitops
Provide a value for 'gitops_repo_username':
  The username of the user with access to the repository
> thomassuedbroecker
Provide a value for 'gitops_repo_token':
  The personal access token used to access the repository
> XXX
> thomassuedbroecker
Provide a value for 'gitops_repo_token':
  The personal access token used to access the repository
> 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
Provide a value for 'gitops_repo_repo':
  The short name of the repository (i.e. the part after the org/group name)
> thomassuedbroecker
Provide a value for 'resource_group_name':
  The name of the resource group
> default
```

* Then it creates a `terraform.tfvars` file based on the entries you gave and executes init and apply command from Terraform.

> Be aware the `key information` is saved in text format in the `output/my-ibm-vpc-roks-argocd/terraform/terraform.tfvars` file!

```sh
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

* Output result:

```sh
╷
│ Error: local-exec provisioner error
│ 
│   with module.gitops_repo.null_resource.initialize_gitops,
│   on .terraform/modules/gitops_repo/main.tf line 91, in resource "null_resource" "initialize_gitops":
│   91:   provisioner "local-exec" {
│ 
│ Error running command '.terraform/modules/gitops_repo/scripts/initialize-gitops.sh 'github.com/thomassuedbroecker/thomassuedbroecker.git'
│ 'openshift-gitops' 'default'': exit status 126. Output: Cloning into
│ '/Users/thomassuedbroecker/Downloads/dev/iascable-vpc-openshift-argocd/example/output/my-ibm-vpc-roks-argocd/terraform/.tmp/gitops-repo/.tmpgitops'...
│ .terraform/modules/gitops_repo/scripts/initialize-gitops.sh: line 57:
│ /Users/thomassuedbroecker/Downloads/dev/iascable-vpc-openshift-argocd/example/output/my-ibm-vpc-roks-argocd/terraform/bin2/yq4: cannot
│ execute binary file

```

### Step Step 2.2: Use `output/my-ibm-vpc-roks-argocd/destroy.sh` to delete the instances

* Output:

It also delete the created private GitHub project.

```sh
Destroy complete! Resources: 89 destroyed.
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

* Output for the initial approach:

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

-> Error during the setup:

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

* Output for the second approach:

```sh
│ Error: local-exec provisioner error
│ 
│   with module.gitops_repo.null_resource.initialize_gitops,
│   on .terraform/modules/gitops_repo/main.tf line 91, in resource "null_resource" "initialize_gitops":
│   91:   provisioner "local-exec" {
│ 
│ Error running command '.terraform/modules/gitops_repo/scripts/initialize-gitops.sh
│ 'github.com/thomassuedbroecker/iascable-vpc-openshift-argocd-gitops.git' 'openshift-gitops'
│ 'default_gitops'': exit status 126. Output: Cloning into
│ '/Users/thomassuedbroecker/Downloads/dev/iascable-vpc-openshift-argocd/example/output/my-ibm-vpc-roks-argocd/terraform/.tmp/gitops-repo/.tmpgitops'...
│ .terraform/modules/gitops_repo/scripts/initialize-gitops.sh: line 57:
│ /Users/thomassuedbroecker/Downloads/dev/iascable-vpc-openshift-argocd/example/output/my-ibm-vpc-roks-argocd/terraform/bin2/yq4:
│ cannot execute binary file
```

### Step 5: Execute the `terraform destroy` command

> Note: Ensure you didn't delete created files before.

To destroy the provisioned resources, run the following:

```sh
terraform destroy -auto-approve
```

* Output interaction:

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
