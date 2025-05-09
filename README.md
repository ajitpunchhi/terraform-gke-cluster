
This repository contains Terraform code to deploy a production-ready Google Kubernetes Engine (GKE) cluster with a complete infrastructure setup including VPC networking, load balancing, and persistent storage.
🏗️ Architecture
https://github.com/user-attachments/assets/c04a4736-b836-4bc9-8d34-4229bb5b0c0c

The infrastructure is based on a modular design with the following components:
ComponentDescriptionGKE ClusterConfigurable as either Standard or AutopilotControl PlaneWith API Server, Scheduler, and Resource ControllersNode PoolsConfigurable node pools for different workloadsVPC NetworkingDedicated VPC with subnets and secondary IP ranges for pods and servicesPersistent StorageStorage classes for SSD and standard persistent disksLoad BalancerGlobal HTTP/HTTPS load balancer with health checks and SSL support
```hcl
📂 Module Structure
terraform-gke-infrastructure/
├── modules/
│   ├── gke/            # GKE cluster configuration
│   ├── vpc/            # VPC networking setup
│   ├── storage/        # Persistent storage configuration
│   └── load_balancer/  # Load balancer setup
├── environments/
│   ├── dev/            # Development environment
│   ├── staging/        # Staging environment
│   └── prod/           # Production environment
└── .github/workflows/  # CI/CD configuration with GitHub Actions
```
✅ Prerequisites

Google Cloud Platform (GCP) account
Project with the necessary APIs enabled:

Compute Engine API
Kubernetes Engine API
Container Registry API
Cloud Storage API


Service account with appropriate permissions
Terraform v1.0.0+
Google Cloud SDK

🛠️ Setup Instructions
1. Clone the Repository
bashgit clone https://github.com/your-org/terraform-gke-infrastructure.git
cd terraform-gke-infrastructure
2. Configure Authentication
Create a service account key file and set the environment variable:
bashexport GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json
3. Update Configuration
Edit the terraform.tfvars file with your specific configuration values:
hclproject_id = "your-project-id"
region     = "us-central1"
zones      = ["us-central1-a", "us-central1-b", "us-central1-c"]

# VPC Configuration
vpc_name    = "gke-vpc"
subnet_name = "gke-subnet"
subnet_cidr = "10.0.0.0/20"
pod_cidr    = "10.16.0.0/14"
service_cidr = "10.20.0.0/20"

# GKE Configuration
cluster_name = "gke-cluster"
enable_autopilot = false
private_cluster = true
release_channel = "REGULAR"

# Node Pool Configuration
node_pools = [
  {
    name               = "general-pool"
    node_count         = 2
    preemptible        = false
    machine_type       = "e2-standard-4"
    disk_size_gb       = 100
    disk_type          = "pd-standard"
    enable_autoscaling = true
    min_node_count     = 1
    max_node_count     = 5
    max_surge          = 1
    max_unavailable    = 0
    labels             = { "env" = "prod", "pool" = "general" }
    tags               = ["gke-node", "general-pool"]
    taints             = []
  }
]
4. Initialize and Apply Terraform
bash# Initialize Terraform
terraform init

# See what changes will be applied
terraform plan

# Apply the changes
terraform apply
🔄 CI/CD with GitHub Actions
This repository includes a GitHub Actions workflow for continuous integration and deployment:
yamlname: 'Terraform CI/CD'

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
  workflow_dispatch:

env:
  TF_LOG: INFO
  GOOGLE_CREDENTIALS: ${{ secrets.GOOGLE_CREDENTIALS }}
  TF_VAR_project_id: ${{ secrets.GCP_PROJECT_ID }}

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout
      uses: actions/checkout@v3

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.5.7

    - name: Terraform Format
      id: fmt
      run: terraform fmt -check -recursive
      continue-on-error: true

    - name: Terraform Init
      id: init
      run: terraform init

    - name: Terraform Validate
      id: validate
      run: terraform validate -no-color

    - name: Terraform Plan
      id: plan
      if: github.event_name == 'pull_request'
      run: terraform plan -no-color -input=false
      continue-on-error: true

    # On PRs, the workflow will add a comment with the plan
    - name: Update Pull Request
      uses: actions/github-script@v6
      if: github.event_name == 'pull_request'
      env:
        PLAN: "terraform\n${{ steps.plan.outputs.stdout }}"
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}
        script: |
          const output = `#### Terraform Format and Style 🖌\`${{ steps.fmt.outcome }}\`
          #### Terraform Initialization ⚙️\`${{ steps.init.outcome }}\`
          #### Terraform Validation 🤖\`${{ steps.validate.outcome }}\`
          #### Terraform Plan 📖\`${{ steps.plan.outcome }}\`
          
          <details><summary>Show Plan</summary>
          
          \`\`\`\n
          ${process.env.PLAN}
          \`\`\`
          
          </details>
          
          *Pushed by: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;
          
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: output
          })

    # Only apply changes when merged to main
    - name: Terraform Apply
      if: github.ref == 'refs/heads/main' && github.event_name == 'push'
      run: terraform apply -auto-approve -input=false

    - name: Terraform Output
      if: github.ref == 'refs/heads/main' && github.event_name == 'push'
      run: terraform output
Required Secrets
Set up the following GitHub repository secrets:

GOOGLE_CREDENTIALS: The JSON content of your service account key
GCP_PROJECT_ID: Your Google Cloud project ID

📚 Module Documentation
GKE Module
hclmodule "gke" {
  source = "./modules/gke"

  project_id           = var.project_id
  region               = var.region
  zones                = var.zones
  regional             = var.regional
  cluster_name         = var.cluster_name
  vpc_name             = module.vpc.vpc_name
  subnet_name          = module.vpc.subnet_name
  pod_range_name       = module.vpc.pod_range_name
  service_range_name   = module.vpc.service_range_name
  enable_autopilot     = var.enable_autopilot
  service_account_email = var.service_account_email
  private_cluster      = var.private_cluster
  enable_private_endpoint = var.enable_private_endpoint
  master_ipv4_cidr_block = var.master_ipv4_cidr_block
  release_channel      = var.release_channel
  node_pools           = var.node_pools
}
VPC Module
hclmodule "vpc" {
  source = "./modules/vpc"

  project_id   = var.project_id
  region       = var.region
  vpc_name     = var.vpc_name
  subnet_name  = var.subnet_name
  subnet_cidr  = var.subnet_cidr
  pod_cidr     = var.pod_cidr
  service_cidr = var.service_cidr
}
Storage Module
hclmodule "storage" {
  source = "./modules/storage"
  count  = var.enable_autopilot ? 0 : 1
  depends_on = [module.gke]

  namespace        = var.storage_namespace
  create_shared_pvc = var.create_shared_pvc
  shared_pvc_size  = var.shared_pvc_size
}
Load Balancer Module
hclmodule "load_balancer" {
  source = "./modules/load_balancer"
  depends_on = [module.gke]

  project_id        = var.project_id
  zone              = var.zones[0]
  lb_name           = var.lb_name
  backend_port_name = var.backend_port_name
  health_check_port = var.health_check_port
  health_check_path = var.health_check_path
  neg_name          = var.neg_name
  instance_group_url = var.instance_group_url
  enable_cdn        = var.enable_cdn
  enable_ssl        = var.enable_ssl
  ssl_domains       = var.ssl_domains
  host_rules        = var.host_rules
  path_matchers     = var.path_matchers
}
🔍 Features

Multi-environment Support: Deploy to dev, staging, and production environments with different configurations
Security-focused: Private clusters with limited access and secure networking
High Availability: Regional clusters with multiple availability zones
Scalability: Autoscaling node pools and flexible configurations
Observability: Integrated logging and monitoring
CI/CD Integration: GitHub Actions workflows for automated deployments

🧪 Testing
To validate your configuration:
bash# Ensure code is formatted properly
terraform fmt -recursive

# Validate the Terraform files
terraform validate

# Run a plan to check for any errors
terraform plan
🔐 Security Best Practices

Use private clusters with restricted access
Implement least privilege for service accounts
Enable Workload Identity for pod-level authentication
Use Binary Authorization for image validation
Apply network policies to restrict traffic

🤝 Contributing

Fork the repository
Create a feature branch (git checkout -b feature/amazing-feature)
Commit your changes (git commit -m 'Add some amazing feature')
Push to the branch (git push origin feature/amazing-feature)
Open a Pull Request

📝 License
This project is licensed under the Apache License 2.0 - see the LICENSE file for details.
