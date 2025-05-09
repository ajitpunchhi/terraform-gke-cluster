# Terraform GKE Infrastructure

This repository contains Terraform code to deploy a Google Kubernetes Engine (GKE) cluster with a complete infrastructure setup including VPC networking, load balancing, and persistent storage.

## Architecture

The infrastructure is based on a modular design with the following components:

- **GKE Cluster**: Configurable as either Standard or Autopilot
- **Control Plane**: With API Server, Scheduler, and Resource Controllers
- **Node Pools**: Configurable node pools for different workloads
- **VPC Networking**: Dedicated VPC with subnets and secondary IP ranges for pods and services
- **Persistent Storage**: Storage classes for SSD and standard persistent disks
- **Load Balancer**: Global HTTP/HTTPS load balancer with health checks and SSL support

## Module Structure

The code is organized into the following structure:

- **modules/**: Reusable Terraform modules
  - **gke/**: GKE cluster configuration
  - **vpc/**: VPC networking setup
  - **storage/**: Persistent storage configuration
  - **load_balancer/**: Load balancer setup
- **environments/**: Environment-specific configurations
  - **dev/**: Development environment
  - **staging/**: Staging environment
  - **prod/**: Production environment
- **.github/workflows/**: CI/CD configuration with GitHub Actions

## Prerequisites

- Google Cloud Platform (GCP) account
- Project with the necessary APIs enabled:
  - Compute Engine API
  - Kubernetes Engine API
  - Container Registry API
  - Cloud Storage API
- Service account with appropriate permissions
- Terraform v1.0.0+
- Google Cloud SDK

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/gke-terraform-project.git
cd gke-terraform-project
```

### 2. Configure Authentication

Create a service account key file and set the environment variable:

```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json
```

### 3. Update Configuration

Edit the `terraform.tfvars` file with your specific configuration values:

```hcl
project_id = "your-project-id"
region     = "us-central1"
zones      = ["us-central1-a", "us-central1-b", "us-central1-c"]
# ... other configuration options
```

### 4. Initialize Terraform

```bash
terraform init
```

### 5. Plan the Deployment

```bash
terraform plan
```

### 6. Apply the Configuration

```bash
terraform apply
```

## CI/CD with GitHub Actions

This repository includes a GitHub Actions workflow for continuous integration and deployment:

1. On pull requests, it will:
   - Format check the Terraform code
   - Initialize and validate the configuration
   - Generate and attach a plan to the PR

2. On merge to main, it will:
   - Apply the configuration changes
   - Output the results

### Required Secrets

Set up the following GitHub repository secrets:

- `GOOGLE_CREDENTIALS`: The JSON content of your service account key
- `GCP_PROJECT_ID`: Your Google Cloud project ID

## Module Documentation

### GKE Module

The GKE module creates a Google Kubernetes Engine cluster with the following configurable options:

- Standard or Autopilot cluster type
- Regional or zonal deployment
- Public or private cluster
- Node pool configurations
- Release channel
- Maintenance window

### VPC Module

The VPC module creates a network with:

- Custom VPC
- Subnet with secondary IP ranges for pods and services
- Firewall rules
- NAT gateway for outbound connectivity

### Storage Module

The Storage module creates:

- Storage classes for different disk types
- Optional persistent volume claims

### Load Balancer Module

The Load Balancer module creates:

- Global HTTP/HTTPS load balancer
- Backend services
- Health checks
- SSL certificates (optional)
- URL path routing

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.