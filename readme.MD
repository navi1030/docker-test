# Terraform & Infrastructure-as-Code (IaC)
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

(`images/highlevel architecture.drawio.png`)

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

