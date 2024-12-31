# Log Service Application Deployment with GitHub Actions and Azure Functions

This repository contains a simple log service application using Azure Functions, with Infrastructure as Code (IaC) driven by ARM templates and a CI/CD pipeline powered by GitHub Actions. The solution consists of two serverless functions:

1. **Function 1**: Receives a log entry and stores it in Azure Cosmos DB Table API.
2. **Function 2**: Retrieves the 100 most recent log entries, sorted by timestamp, in JSON format.

## Features

- **Serverless Functions**: Utilizes Azure Functions for handling log entries.
- **Infrastructure as Code (IaC)**: Deploys resources using ARM templates.
- **CI/CD Pipeline**: Uses GitHub Actions to automatically deploy the solution to Azure.

## Table of Contents

- Prerequisites
- Repository Structure
- Deploying the Solution
- CI/CD Pipeline
- Function 1: Receive Log Entry
- Function 2: Retrieve Log Entries
- ARM Template Setup
- Environment Variables

## Prerequisites

Before using this repository, ensure that you have the following tools installed:

- **Azure CLI**: For authenticating and interacting with Azure.
- **GitHub Actions**: The pipeline will run automatically on each push to the repository, so ensure your repository is connected to GitHub.

Additionally, you must have an Azure account and Service Principal credentials set up for deployment.

## Repository Structure

The repository is organized as follows:

```plaintext
├── ReceiveLogEntry
│   ├── __init__.ps1         # PowerShell code for the function that receives log entries
│   ├── function.json        # Bindings for the ReceiveLogEntry function
├── RetrieveLogEntries
│   ├── __init__.ps1         # PowerShell code for the function that retrieves log entries
│   ├── function.json        # Bindings for the RetrieveLogEntries function
├── .github
│   └── workflows
│       └── deploy.yml       # GitHub Actions pipeline configuration
├── azuredeploy.json         # ARM template for Azure resource provisioning
├── azuredeploy.parameters.json # Parameters file for the ARM template
└── README.md                # This file
```

## Deploying the Solution

### 1. Set up Azure Resources

The ARM template is used to provision the following Azure resources:

- **Resource Group**: A container for the other Azure resources.
- **Storage Account**: Used to store log data.
- **Function Apps**: Two Azure Functions to handle log entries.
- **Cosmos DB Account**: Used to store log entries in a table.

Steps to deploy:

1. Set the appropriate values for the parameters in `azuredeploy.parameters.json`.
2. Push your changes to the `main` branch to trigger the GitHub Actions workflow.

### 2. Configure the Environment

Make sure to set up the following GitHub Secrets to securely store your Azure credentials:

- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_TENANT_ID`
- `ARM_SUBSCRIPTION_ID`
- `resourceGroup`
- `FUNCTION_APP_NAME_RECEIVE_LOG`
- `FUNCTION_APP_NAME_RETRIEVE_LOG`

## CI/CD Pipeline

The CI/CD pipeline is defined in `deploy.yml` and runs automatically on every push to the repository. The pipeline consists of the following steps:

1. **Checkout Code**: Retrieves the latest version of the repository.
2. **Log in to Azure**: Authenticates to Azure using the Service Principal credentials stored in GitHub secrets.
3. **Create Resource Group**: Creates the resource group in Azure.
4. **Generate Unique Suffix**: Generates a unique suffix for resource names.
5. **Create Cosmos DB Account**: Creates the Cosmos DB account.
6. **Deploy ARM Template**: Deploys the ARM template to create Azure resources.
7. **Retrieve Cosmos DB Connection String**: Retrieves the connection string for the Cosmos DB account.
8. **Deploy Functions**: Packages and deploys the `ReceiveLogEntry` and `RetrieveLogEntries` functions to the respective Azure Function Apps.
9. **Upload Publish Profiles**: Uploads the publish profiles for the function apps as artifacts.

## Function 1: Receive Log Entry

### `__init__.ps1`

This function receives a log entry via an HTTP POST request and stores it in Azure Cosmos DB Table API. It expects the following JSON format for the log entry:

```json
{
  "severity": "info", 
  "message": "This is a test log"
}
```

- **PartitionKey**: Set to "LogEntry".
- **RowKey**: A unique identifier (UUID) is generated automatically.
- **DateTime**: The current UTC timestamp is stored in ISO format.
- **Severity**: The severity of the log entry (info, warning, error).
- **Message**: The content of the log message.

### `function.json`

This file configures the function trigger to listen for HTTP POST requests.

## Function 2: Retrieve Log Entries

### `__init__.ps1`

This function retrieves the 100 most recent log entries from Azure Cosmos DB Table API. It queries the table for all log entries, sorts them by datetime (in descending order), and returns the latest 100 entries in JSON format.

### `function.json`

This file configures the function trigger to listen for HTTP GET requests.

## ARM Template Setup

The ARM template is used to manage the infrastructure in Azure. The key resources are:

- `Microsoft.Storage/storageAccounts`: Defines the storage account to store the logs.
- `Microsoft.Web/serverfarms`: Defines the App Service Plan.
- `Microsoft.Web/sites`: Creates the Azure Function Apps for both "receive" and "retrieve" log entries.
- `Microsoft.Insights/components`: Creates the Application Insights resource.
- `Microsoft.DocumentDB/databaseAccounts`: Creates the Cosmos DB account.

### ARM Template Files Overview

- **`azuredeploy.json`**: Contains the primary ARM template configuration for all resources.
- **`azuredeploy.parameters.json`**: Specifies the parameter values for the ARM template.

## Environment Variables

Ensure the following environment variables are set in the Azure Function Apps:

- `AzureWebJobsStorage`: The connection string for the Azure Storage Account.
- `FUNCTIONS_WORKER_RUNTIME`: Set to `powershell` for PowerShell-based functions.
- `COSMOS_DB_CONNECTION_STRING`: The connection string for the Cosmos DB account.

## Conclusion

This repository provides a fully automated solution for deploying serverless log services using Azure Functions, ARM templates, and GitHub Actions. The solution includes two functions: one for receiving log entries and storing them in Azure Cosmos DB Table API, and another for retrieving the most recent log entries. With a complete CI/CD pipeline in GitHub Actions, the deployment and management of the solution are streamlined and efficient.
