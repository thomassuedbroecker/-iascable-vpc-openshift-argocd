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

