<!--
---
page_type: sample
languages:
- azdeveloper
- python
- bicep
products:
- azure
- azure-functions
urlFragment: fastapi-on-azure-functions
name: Using FastAPI Framework with Azure Functions
description: This is a sample Azure Function app created with the FastAPI framework using Azure Functions Python v2 programming model and Flex Consumption plan.
---
-->
<!-- YAML front-matter schema: https://review.learn.microsoft.com/en-us/help/contribute/samples/process/onboarding?branch=main#supported-metadata-fields-for-readmemd -->

# Using FastAPI Framework with Azure Functions

Azure Functions supports WSGI and ASGI-compatible frameworks with HTTP-triggered Python functions. This sample demonstrates creating an Azure Function app using FastAPI with the Azure Functions Python v2 programming model and modern infrastructure including Flex Consumption plan, managed identity, and optional VNet integration.

## Features

- **Azure Functions Python v2 Programming Model**: Uses direct function decorators, no function.json files needed
- **Native FastAPI Support**: Leverages Azure Functions' built-in FastAPI integration
- **Flex Consumption Plan**: Modern, scalable hosting plan replacing the deprecated Y1 plan
- **Managed Identity**: Secure authentication without connection strings
- **Optional VNet Integration**: Enhanced security with virtual network isolation
- **Modern Infrastructure**: Uses Azure Verified Modules (AVM) for secure and compliant resource deployment

## Prerequisites

+ [Python 3.12](https://www.python.org/)
+ [Azure Functions Core Tools](https://learn.microsoft.com/azure/azure-functions/functions-run-local?pivots=programming-language-python#install-the-azure-functions-core-tools)
+ [Azure Developer CLI (AZD)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
+ To use Visual Studio Code to run and debug locally:
  + [Visual Studio Code](https://code.visualstudio.com/)
  + [Azure Functions extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurefunctions)

## Getting Started

You can initialize a project from this template in one of these ways:

+ Use this `azd init` command from an empty local (root) folder:

    ```shell
    azd init --template fastapi-on-azure-functions
    ```

    Supply an environment name, such as `fastapiapp` when prompted. In `azd`, the environment is used to maintain a unique deployment context for your app.

+ Clone the GitHub template repository locally using the `git clone` command:

    ```shell
    git clone https://github.com/Azure-Samples/fastapi-on-azure-functions.git
    cd fastapi-on-azure-functions
    ```

## Local Development

### Setup Local Environment

Add a file named `local.settings.json` in the root of your project with the following contents:

```json
{
    "IsEncrypted": false,
    "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "python"
    }
}
```

### Create Virtual Environment

The way that you create your virtual environment depends on your operating system.
Open the terminal, navigate to the project folder, and run these commands:

#### Linux/macOS/bash

```bash
python -m venv .venv
source .venv/bin/activate
```

#### Windows (Cmd)

```shell
py -m venv .venv
.venv\scripts\activate
```

### Run Local Development Server

1. Install the necessary requirements:

    ```shell
    pip install -r requirements.txt
    ```

2. Start the Functions host locally:

    ```shell
    func start
    ```

3. Test the endpoints:

    - GET endpoint: <http://localhost:7071/sample>
    - Parameterized endpoint: <http://localhost:7071/hello/YourName>

## Azure Functions Python v2 Model

This sample uses the Azure Functions Python v2 programming model with direct FastAPI integration:

```python
import azure.functions as func
from fastapi import FastAPI

# Initialize FastAPI app
fastapi_app = FastAPI()

@fastapi_app.get("/sample")
async def index():
    return {
        "info": "Try /hello/Shivani for parameterized route.",
    }

@fastapi_app.get("/hello/{name}")
async def get_name(name: str):
    return {
        "name": name,
    }

# Azure Functions app using ASGI with FastAPI
app = func.AsgiFunctionApp(app=fastapi_app, http_auth_level=func.AuthLevel.ANONYMOUS)
```

Key advantages of this approach:
- **No function.json files**: Configuration is done through decorators
- **Native FastAPI support**: No custom wrappers needed
- **Simplified project structure**: Single file for function definitions
- **Better development experience**: Full FastAPI features supported

## Deployment to Azure

Deploy using Azure Developer CLI:

```shell
azd up
```

This command provisions the function app with required Azure resources and deploys your code. By default, the deployment includes:

- **Flex Consumption Plan**: Modern scaling with FC1 tier
- **Managed Identity**: Secure authentication for Azure resources
- **Virtual Network**: Optional network isolation (enabled by default)
- **Application Insights**: Monitoring and diagnostics
- **Storage Account**: Required for Functions runtime

### VNet Configuration

By default, this sample deploys with a virtual network (VNet) for enhanced security. The `VNET_ENABLED` parameter controls this:
- When `VNET_ENABLED` is `true` (default), resources are deployed with VNet isolation
- When `VNET_ENABLED` is `false`, resources are deployed with public access

To disable VNet for this sample:
```bash
azd env set VNET_ENABLED false
azd up
```

## Infrastructure

The infrastructure uses Azure Verified Modules (AVM) for secure, compliant deployments:

- **Function App**: Flex Consumption plan with Python 3.12 runtime
- **Storage Account**: Secure storage with managed identity authentication
- **Application Insights**: Monitoring with AAD authentication
- **Virtual Network**: Optional network isolation
- **Private Endpoints**: Secure connectivity when VNet is enabled

## Testing in Azure

After deployment, test these different paths on the deployed URL: 

```
https://<FunctionAppName>.azurewebsites.net/sample
https://<FunctionAppName>.azurewebsites.net/hello/FastAPI
```

You can test using:
- [Visual Studio Code with REST Client extension](https://marketplace.visualstudio.com/items?itemName=humao.rest-client)
- [PowerShell Invoke-RestMethod](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-restmethod)
- [curl](https://curl.se/)
- [Bruno](https://www.usebruno.com/)

> [!CAUTION]  
> For scenarios where you have sensitive data, such as credentials, secrets, access tokens, 
> API keys, and other similar information, make sure to use a tool that protects your data 
> with the necessary security features, works offline or locally, doesn't sync your data to 
> the cloud, and doesn't require that you sign in to an online account.

## Clean Up Resources

When you're done, you can delete the function app and related resources from Azure to avoid incurring further costs:

```shell
azd down
```

## Next Steps

Now you have a modern Azure Function App using the FastAPI framework with Azure Functions Python v2 programming model. You can continue building on it to develop more sophisticated applications.

To learn more:
- [Azure Functions Python v2 Programming Model](https://learn.microsoft.com/azure/azure-functions/functions-reference-python?tabs=get-started%2Casgi%2Capplication-level&pivots=python-mode-decorators)
- [FastAPI Integration with Azure Functions](https://learn.microsoft.com/azure/azure-functions/functions-bindings-http-webhook-trigger?tabs=python-v2%2Cisolated-process%2Cnodejs-v4%2Cfunctionsv2&pivots=programming-language-python#example)
- [Flex Consumption Plan](https://learn.microsoft.com/azure/azure-functions/flex-consumption-plan)
