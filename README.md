# Use IasCable to create a VPC and a Red Hat OpenShift cluster with Argo CD installed on IBM Cloud

Our objective is to create an initial setup in an IBM Cloud environment for GitOps.

The `Software Everywhere` framework and `IasCable` CLI do provide an awesome way to eliminate writing `Terraform` modules for diffent clouds to create and configure resources. We are going to reuse Terraform moduls which the `Software Everywhere` catalog does provide.

Surly, we need to know the needed outline for the cloud architecture which does depend on the cloud environment we are going to use.

As I said `Software Everywhere` catalog does provide  the reuse of existing Terraform modules, which we use by just combining by writing a "`Bill of Material file`" and configure the variables for the related Terraform modules when it is need.

> We will not write any Terraform code, we will only combine existing Terraform modules and configure them!

In that scenario we will use IBM Cloud with a `Virtual Private Cloud` and a `Red Hat OpenShift cluster` with `Argo CD installed` and integrated with a GitHub project.

Steps to work with `Software Everywhere` and `IasCable`.

1. Define a target outline of the architecture
2. Identify the needed `Software Everywhere` Terraform modules for the target outline
3. Write a customized `BOM` to combine the modules
4. Use `IasCable` to create the scaffolding for a `IasCable` project
5. Use a tools container to execute the Terraform modules in the scaffolding project outline of the `IasCable` project
6. Depending on the container runtime you are going to use on your computer, you maybe have copy the project inside the running container because of access right restrictions. Because the project folder is mapped as a volume to the project.

Let us first verify with modules we are going to use for own custom `BOM`. This contains two topics first the initial `GitOps` configuration and second the setup a cloud infrastructure.

* Configuration for GitOps related  

    * IBM OpenShift login [ocp-login](https://github.com/cloud-native-toolkit/terraform-ocp-login) - login to existing OpenShift cluster
    * GitOps repo [gitops-repo](https://github.com/cloud-native-toolkit/terraform-tools-gitops) - creates the GitOps Repo
    * ArgoCD Bootstrap [argocd-bootstrap](https://github.com/cloud-native-toolkit/terraform-tools-gitops)

    * Related simplified architecture
    ![](images/SoftwareEverywhere-GitOps.drawio.png)
  
* Cloud infrastructure/services resources related modules

  * [IBM VPC `ibm-vpc`](https://github.com/cloud-native-toolkit/terraform-ibm-vpc)
  * [IBM VPC Subnets `ibm-vpc-subnets`](https://github.com/cloud-native-toolkit/terraform-ibm-vpc-subnets)
  * [IBM Cloud VPC Public Gateway `ibm-vpc-gateways`](https://github.com/cloud-native-toolkit/terraform-ibm-vpc-gateways)
  * [IBM OpenShift VPC cluster `ibm-ocp-vpc`](https://github.com/cloud-native-toolkit/terraform-ibm-ocp-vpc)
  * [IBM Object Storage `ibm-object-storage`](https://github.com/cloud-native-toolkit/terraform-ibm-object-storage)

  * Related simplified architecture
   ![](images/SoftwareEverywhere-OpenShift-Infrastructure.drawio.png)


### Step 1: Write the Bill of Material `BOM` file

Combine Terraform modules and define some variables in the initial `BOM` file.

> Note: When you going to use variables, keep in mind you must use the name of the variables defined in the module and use `alias: ibm-vpc` to define the prefix.

```yaml
apiVersion: cloudnativetoolkit.dev/v1alpha1
kind: BillOfMaterial
metadata:
  name: my-ibm-vpc-roks-argocd
spec:
  modules:
    # Virtual Private Cloud - related
    # - subnets
    # - gateways
    - name: ibm-vpc
      alias: ibm-vpc
      version: v1.16.0
      variables:
      - name: name
        value: "tsued-gitops-sample"
      - name: tags
        value: ["tsuedro"]
    - name: ibm-vpc-subnets
      alias: ibm-vpc-subnets
      version: v1.13.2
      variables:
        - name: _count
          value: 1
        - name: name
          value: "tsued-gitops-sample"
        - name: tags
          value: ["tsuedro"]
    - name: ibm-vpc-gateways
    # ROKS - related
    # - objectstorage
    - name: ibm-ocp-vpc
      alias: ibm-ocp-vpc
      version: v1.15.5
      variables:
        - name: name
          value: "tsued-gitops"
        - name: worker_count
          value: 2
        - name: tags
          value: ["tsuedro"]
    - name: ibm-object-storage
      alias: ibm-object-storage
      version: v4.0.3
      variables:
        - name: name
          value: "cos_tsued_gitops"
        - name: tags
          value: ["tsuedro"]
        - name: label
          value: ["cos_tsued"]
    # Install OpenShift GitOps and Bootstrap GitOps (aka. ArgoCD) - related
    # - argocd
    # - gitops
    - name: argocd-bootstrap
      alias: argocd-bootstrap
      version: v1.12.0
      variables:
        - name: repo_token
    - name: gitops-repo
      alias: gitops-repo
      version: v1.20.2
      variables:
        - name: host
          value: "github.com"
        - name: type
          value: "GIT"
        - name: org
          value: "thomassuedbroecker"
        - name: username
          value: "thomassuedbroecker"
        - name: project
          value: "iascable-gitops"
        - name: repo
          value: "iascable-gitops"
```

### Step 2: Install [colima](https://github.com/abiosoft/colima) container engine

Example for an installation on macOS.

```sh
brew install docker colima
```

### Step 3: Start [colima](https://github.com/abiosoft/colima)

```sh
colima start
```

### Step 4: Build the project based on Bill of Material `BOM` file

```sh
iascable build -i my-vpc-roks-argocd-bom.yaml
```

* Output:

```sh
Loading catalog from url: https://modules.cloudnativetoolkit.dev/index.yaml
Name: my-ibm-vpc-roks-argocd
Writing output to: ./output
```

### Step 5: Copy helper bash scripts into the output folder

```sh
cp helper-tools-create-container-workspace.sh ./output
cp helper-tools-execute-apply-and-backup-result.sh ./output
cp helper-tools-execute-destroy-and-delete-backup.sh ./output
```

### Step 6: Start the tools container provided by the `IasCable`

```sh
cd output
sh launch.sh
```

### Step 7 (inside the container): In the running container verify the mapped resources 

```sh
~/src $ ls
helper-tools-create-container-workspace.sh
helper-tools-execute-apply-and-backup-result.sh
launch.sh
my-ibm-vpc-roks-argocd
```

### Step 8 (inside the container): Create a workspace folder in your container and copy your `IasCabel` project into it

All these tasks are automated in the helper bash script I wrote.

```sh
sh helper-tools-create-container-workspace.sh
ls ../workspace
```

* Output:

You can see the copied `IasCable` project folder inside the container.

```sh
my-ibm-vpc-roks-argocd
```

### Step 9 (inside the container): Execute the `apply.sh` and backup the result into the mapped volume

All these tasks are automated in the helper bash script I wrote.

```sh
sh helper-tools-execute-apply-and-backup-result.sh
```

* Interactive output:

```sh
Variables can be provided in a yaml file passed as the first argument

Provide a value for 'gitops-repo_host':
  The host for the git repository. The git host used can be a GitHub, GitHub Enterprise, Gitlab, Bitbucket, Gitea or Azure DevOps server. If the host is null assumes in-cluster Gitea instance will be used.
> (github.com) 
Provide a value for 'gitops-repo_org':
  The org/group where the git repository exists/will be provisioned. If the value is left blank then the username org will be used.
> (thomassuedbroecker) 
Provide a value for 'gitops-repo_project':
  The project that will be used for the git repo. (Primarily used for Azure DevOps repos)
> (iascable-gitops)
Provide a value for 'gitops-repo_username':
  The username of the user with access to the repository
> (thomassuedbroecker) 
Provide a value for 'gitops-repo_token':
  The personal access token used to access the repository
> 
> Provide a value for 'ibmcloud_api_key':
> XXX
Provide a value for 'region':
> eu-de
Provide a value for 'worker_count':
  The number of worker nodes that should be provisioned for classic infrastructure
> (2)
Provide a value for 'ibm-ocp-vpc_flavor':
  The machine type that will be provisioned for classic infrastructure
> (bx2.4x16) 
Provide a value for 'ibm-vpc-subnets__count':
  The number of subnets that should be provisioned
> (1) 
Provide a value for 'resource_group_name':
  The name of the resource group
> default
```

The invoked `apply.sh` script will create:

* a temporary `workspace/my-ibm-vpc-roks-argocd/variables.yaml.tmp` file
* a `workspace/my-ibm-vpc-roks-argocd/variables.yaml` file
* a `workspace/my-ibm-vpc-roks-argocd/terraform/variables.tf` file
* a `workspace/my-ibm-vpc-roks-argocd/terraform/variables.tfvars` file
* several folders `.kube`, `.terraform`, `.tmp`, `bin2`, `docs`
* it creates a GitHub private project which contains you ID for the `cloud native toolkit`

> Note: Here you can sample of the content of an example for a generated variables.yaml file [link](/overview-variables.md) and here you can find a example for the created [BOM file](/example/example-create-bom-file.yaml).

* Output:

Move on with the setup and apply Terraform.

```sh
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

After a while you should get following output.

```sh
Apply complete! Resources: 91 added, 0 changed, 0 destroyed.
```

* Major resources which were created:
 
  * Cloud infrastructure/services resources

    * 1 x VPC
      ![](images/resources-02-vpc.png)
    * 1 x Subnet
      ![](images/resources-03-subnet.png)
    * 4 Security groups
      Two were created during the subnet creation and two are related to the created Red Hat OpenShift cluster.
      ![](images/resources-04-security-groups.png)
    * 1 x Virtual Private Endpoint
      ![](images/resources-05-virtual-private-endpoint.png)
    * 1 x Public Gateway
      ![](images/resources-06-public-gateway.png)
    * 2 x Access Control Lists
      One war created for the VPC and one during the creation of the subnet.
      ![](images/resources-07-access-control-list.png)
    * 1 x Routing Table
      ![](images/resources-08-routing-table.png)
    * 1 x Red Hat OpenShift Cluster
      ![](images/resources-09-openshift-cluster.png)
    * 1 x Object Storage
      ![](images/resources-10-object-storage.png)
  
  * Cluster and GitOps configuration

     * `Red Hat OpenShift GitOps` operator and `Red Hat OpenShift Pipelines`  operator
      ![](images/cluster-configuration-01-operators.png)
    * `GitHub` project as ArgoCD repository
      ![](images/cluster-configuration-02-github-project.png)
    * Preconfigure ArgoCD project
      ![](images/cluster-configuration-03-argocd-project.png)
      
* Then it creates a `terraform.tfvars` file based on the entries you gave and executes init and apply command from Terraform.

> Be aware the `key information` is saved in text format in the `output/my-ibm-vpc-roks-argocd/terraform/terraform.tfvars` file! 



### Step 10 (inside the container): Destory create resources

> Note: Ensure you didn't delete created files before.
 
```sh
sh helper-tools-execute-destroy-and-delete-backup.sh
```

* Output:

It also deleted the created private GitHub project.

```sh
Destroy complete! Resources: 89 destroyed.
```
