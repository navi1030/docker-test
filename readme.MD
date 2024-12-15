# Terraform & Infrastructure-as-Code (IaC)

## Create the VPC and subnets, Create the GKE cluster with 2 node pools, Store Terraform states in a GCS bucket.

### The code is in the terraform folder

## Explain how you would automate the process using TFActions

```yaml
name: Terraform Workflow

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  terraform:
    name: Terraform
    runs-on: ubuntu-latest

    steps:
      # Step 1: Checkout the repository code
      - name: Checkout Code
        uses: actions/checkout@v3

      # Step 2: Authenticate with Google Cloud
      - name: Setup Google Cloud
        uses: google-github-actions/auth@v1
        with:
          credentials_json: ${{ secrets.GOOGLE_CREDENTIALS }}

      # Step 3: Setup Terraform
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0

      # Step 4: Initialize Terraform (includes GCS backend configuration)
      - name: Terraform Init
        run: terraform init

      # Step 5: Generate Terraform Plan
      - name: Terraform Plan
        run: terraform plan

      # Step 6: Apply the Terraform Plan
      - name: Terraform Apply
        run: terraform apply -auto-approve 
```

# GCP Concepts & Networking

## Design a high-level architecture diagram showing the networking setup

![alt text](https://github.com/navi1030/codimite_assignment/blob/9bdda3f9fe05a4929001880343dc2bc0dd3b8a45/images/highlevelarchitecture.png)

## How you would secure the setup.
- Sensitive data and services (Cloud SQL and Redis) are isolated in a separate VPC, reducing the risk of lateral attacks.
- Use Cloud Monitoring and Cloud Logging to monitor network traffic, detect anomalies, and generate alerts.
- Use private IPs for Cloud SQL and Redis to ensure that they are only accessible from within the VPCs. Disable public IP access to these services.
- Define least privilege firewall rules to restrict communication between VPCs. For example:
- Allow only GKE nodes in VPC 2 to access specific ports (3306 for Cloud SQL, 6379 for Redis) in VPC 1. Block all inbound traffic except those explicitly allowed.
- Enable DNS resolution for private zones across VPCs to simplify service discovery without exposing services publicly.
- Use Cloud NAT for GKE nodes to provide controlled outbound internet access without exposing private IPs.
- Use Cloud Monitoring and Cloud Logging to monitor network traffic, detect anomalies, and generate alerts.
- Enable Cloud Armor to protect against DDoS attacks if a public-facing load balancer is used.

## How you would optimize costs while maintaining high availability.

- Use node auto-scaling to dynamically adjust the number of nodes in the cluster based on workload demands.
- Use Preemptible VMs (Spot VMs) for non-critical workloads (e.g., batch processing or stateless services).
- Deploy regional GKE clusters to ensure high availability while avoiding cross-region traffic costs.
- Use read replicas in the same region to offload read traffic from the primary database, reducing the load on more expensive primary instances.
- Use memory-optimized tiers that match your application's caching needs. Avoid over-provisioning Redis instances.

# CI/CD & GitHub Actions

## Write a sample GitHub Actions workflow YAML file to:Build and push the Docker image to GCR,Include steps for linting and running tests.

### The code is in the .github\workflows\docker-gcr-new.yml file

## Explain how you configure the deployment through ArgoCD

- Step 1: Install ArgoCD in GKE
```Bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

-  step 2: Expose the ArgoCD Server
```Bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

- step 3: Retrieve Default Admin Password
```Bash
kubectl -n argocd get secret argocd-initial-admin-secret \
          -o jsonpath="{.data.password}" | base64 -d; echo
```
- step 4: Save Credentials in GitHub Secrets
- setp 5: Prepare Kubernetes Manifests
- step 5: Automating Cluster Registration and deployment in GitHub Workflow
```yaml
# Get the current kubeconfig context
        CONTEXT=$(kubectl config current-context)

        # Login to ArgoCD
        argocd login ${{ secrets.ARGOCD_SERVER_URL }} \
          --username ${{ secrets.ARGOCD_USERNAME }} \
          --password ${{ secrets.ARGOCD_PASSWORD }} \
          --insecure

        # Add the GKE cluster to ArgoCD
        argocd cluster add $CONTEXT

    - name: Deploy Kubernetes Manifests via ArgoCD
      run: |
        argocd app create my-flask-app \
          --repo https://github.com/your/repo.git \
          --path k8s/manifests \
          --dest-server https://kubernetes.default.svc \
          --dest-namespace default || \
        argocd app sync my-flask-app
```

# Security & Automation Guardrails

## Write a sample Conftest policy that ensures all Terraform code includes encryption for GCS buckets and restrict the project
### The code is in the policy\terraform.rego file

## Write a Trivy command to scan a Docker image during a GitHub Actions pipeline.
### The code is in the .github\workflows\docker-gcr-new.yml file
```yaml
      - name: Scan Docker Image for Vulnerabilities
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.IMAGE_TAG }}
          severity: HIGH,CRITICAL
          ignore-unfixed: false 
```

# Problem-Solving & Troubleshooting Scenario

## Explain your approach to troubleshooting the issue.

- Start by examining the logs of the application pods to identify any specific error messages or patterns that indicate the nature of the network timeout.
- Use kubectl get events to check for any Kubernetes events that might indicate issues with pod scheduling, networking, or resource allocation.
- Confirm the status of the pods using kubectl get pods to ensure they are running as expected.
- Verify the network configuration, including VPC settings, firewall rules, and Cloud SQL instance settings.
- Use tools like kubectl exec to run connectivity tests from within the application pods to the Cloud SQL instance. For example, use ping or curl to check if the instance is reachable.
- Verify that the DNS resolution between the application pods and CloudSQL is working correctly, especially if you are using the CloudSQL instance's hostname for connections.
- Verify that firewall rules allow traffic from GKE clusters to Cloud SQL. Check for any recent changes in firewall configurations that might have impacted connectivity.
- Check if the application pods are hitting resource limits (CPU/memory) which could lead to performance degradation.
- Review Cloud SQL metrics for any signs of resource exhaustion, such as high CPU usage or connection limits being reached.

## Describe tools and steps you would use to resolve the network timeout and prevent future occurrences.

- Scale up the GKE cluster if necessary to ensure that there are enough resources for the pods to run smoothly.
- Add autoscaling policies to automatically adjust the number of nodes based on resource usage.
- Enable CloudSQL High Availability  for automatic failover in case of any outages, reducing the risk of downtime.
- Set up monitoring for network performance using tools like Cloud Monitoring and Cloud Logging to track latency, packet loss, or network errors between GKE and CloudSQL.
