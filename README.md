# REST API Service
This is a simple Node.js service that consumes data from JSONPlaceholder and displays it through a public endpoint.

## Deployment
The service is deployed on Azure App Service and is accessible through a public endpoint.

## CI/CD
The CI/CD pipeline is implemented using GitHub Actions and includes stages for building, testing, and deploying the application.

## Infrastructure as Code
The infrastructure is managed using Terraform and includes the following resources:

Azure Resource Group
Azure App Service Plan
Azure App Service
DevSecOps
Security scanning is integrated into the CI/CD pipeline using open-source tools.

# Repository Structure
```plaintext
rest-api-service-appservice/
├── .github/
│   └── workflows/
|       ├── deploy.yml
│       ├── terraform-updated.yml
│       ├── terraform.yml
├── terraform/
│   ├── main.tf
|   ├── variables.tf
|   ├── provider.tf
|   ├── backend.tf
|   ├── dev.tfvars
├── src/
│   ├── index.js
│   ├── package.json
│   ├── package-lock.json
|   ├── __test__
|       └── app.test.jest 
├── web.config
└── README.md
```

# Overview of main.tf
main.tf defines the architecture of the infrastructure. It includes the following resources:

Resource Group: Defines the Azure resource group.
Virtual Network: Creates a virtual network with a default subnet.
Subnet: Creates a gateway subnet.
Public IP for Application Gateway: Allocates a static public IP.
Application Gateway: Configures an Azure Application Gateway.
Log Analytics Workspace: Creates a Log Analytics workspace.
Application Insights: Sets up Azure Application Insights.
App Service Plans: Creates App Service plans in Southeast Asia and Brazil South.
Linux Web Apps: Defines Linux Web Apps for different regions.
Autoscale Settings: Configures autoscaling for the App Service plans.
CI/CD Infrastructure Pipeline Overview
The CI/CD pipeline for infrastructure deployment uses GitHub Actions. It includes:

# Workflow Dispatch: Allows manual trigger with environment selection (dev, test, uat, prod).
Environment Variables: Sets up Azure credentials.
Terraform Initialization and Validation: Initializes and validates Terraform configurations.
Terraform Plan and Apply: Creates and applies Terraform plans. Manual approval is required for uat and prod environments.
CI/CD for App Deployment Overview
The CI/CD pipeline for application deployment uses GitHub Actions. It includes:

# Build Stage: Installs dependencies, runs static code analysis, vulnerability scans, and tests.
Artifact Upload: Zips the application and uploads it as an artifact.
Deployment Stages: Deploys the application to Azure Web Apps for different environments (dev, test, uat, prod). Manual approval is required for uat and prod environments.
Node.js App Overview
The Node.js application consists of:

# Express Server: Handles HTTP requests.
Axios: Used to fetch data from the JSONPlaceholder API.
Health Check Endpoint: Returns a 200 status to indicate the service is running.
API Endpoint: Fetches and returns posts from the JSONPlaceholder API.
