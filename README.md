---
page_type: sample
languages:
- python
products:
- azure
- azure-functions
description: "This is a sample Azure Function app created with the FastAPI framework."
title: Using FastAPI Framework with Azure Functions
author: shreyabatra4, vrdmr
urlFragment: azure-functions-python-create-fastapi-app
---

# Using FastAPI Framework with Azure Functions

Azure Functions supports WSGI and ASGI-compatible frameworks with HTTP-triggered Python functions. This can be helpful if you are familiar with a particular framework, or if you have existing code you would like to reuse to create the Function app. The following is an example of creating an Azure Function app using Fast API.

## Prerequisites

You can develop and deploy a function app using either Visual Studio Code or the Azure CLI. Make sure you have the required prerequisites for your preferred environment:

* [Prerequisites for VS Code](https://docs.microsoft.com/azure/azure-functions/create-first-function-vs-code-python#configure-your-environment)
* [Prerequisites for Azure CLI](https://docs.microsoft.com/azure/azure-functions/create-first-function-cli-python#configure-your-local-environment)

## Setup

Clone or download [this sample's repository](https://github.com/Azure-Samples/fastapi-on-azure-functions/), and open the `fastapi-on-azure-functions` folder in Visual Studio Code or your preferred editor (if you're using the Azure CLI).

## Using FastAPI Framework in an Azure Function App

The code in the sample folder has already been updated to support use of the FastAPI. Let's walk through the changed files.

The `requirements.txt` file has an additional dependency of the `fastapi` and `nest_asyncio` modules:

```
azure-functions
fastapi
nest_asyncio
```


The file host.json includes the a `routePrefix` key with a value of empty string.

```json
{
  "version": "2.0",
  "extensions": {
    "http": {
        "routePrefix": ""
    }
  }
}
```


Inside the `WrapperFunction` folder, the file `function.json` includes a `route` key in the bindings:

```json
{
  "scriptFile": "__init__.py",
  "bindings": [
    {
      "authLevel": "anonymous",
      "type": "httpTrigger",
      "direction": "in",
      "name": "req",
      "methods": [
        "get",
        "post"
      ],
      "route": "/{*route}"
    },
    {
      "type": "http",
      "direction": "out",
      "name": "$return"
    }
  ]
}
```

In that same folder, the `__init__.py` file uses `AsgiMiddleware` to redirect invocations to a FastAPI app with two routes defined.

```python
import logging
import azure.functions as func
import nest_asyncio
from FastAPIApp import app  # Main API application

nest_asyncio.apply()


@app.get("/sample")
async def index():
    return {
        "info": "Try /hello/Shivani for parameterized route.",
    }


@app.get("/hello/{name}")
async def get_name(name: str):
    return {
        "name": name,
    }

async def main(req: func.HttpRequest, context: func.Context) -> func.HttpResponse:
    """Each request is redirected to the ASGI handler."""
    return func.AsgiMiddleware(app).handle(req, context)
```

## Running the sample

### Testing locally

First run the command below to install the necessary requirements.

```log
pip3 install -r requirements.txt
```

If you are using VS Code for development, follow [the instructions for running a function locally](https://docs.microsoft.com/azure/azure-functions/create-first-function-vs-code-python#create-an-azure-functions-project). Otherwise, follow [these instructions for using Core Tools commands directly to run the function locally](https://docs.microsoft.com/azure/azure-functions/functions-run-local?tabs=v4%2Cwindows%2Cpython%2Cportal%2Cbash#start).

Once the function is running, test the function at the local URL displayed in the Terminal panel:

```log
Functions:
        WrapperFunction: [GET,POST] http://localhost:7071/{*route}
```

Try out URLs corresponding to the handlers in the app, both the simple path and the parameterized path:

```
http://localhost:7071/sample
http://localhost:7071/hello/YourName
```

### Testing in Azure

If you are using VS Code for development, follow [these instructions for using the extension to create resources and deploying to Azure](https://docs.microsoft.com/en-us/azure/azure-functions/create-first-function-vs-code-python#publish-the-project-to-azure). Otherwise, follow [these instructions for using the Azure CLI to create resources and deploy to Azure](https://docs.microsoft.com/en-us/azure/azure-functions/create-first-function-cli-python?tabs=azure-cli%2Cbash%2Cbrowser#create-supporting-azure-resources-for-your-function).

Once deployed, test different paths on the deployed URL, using either a browser or a tool like Postman.

```
http://<FunctionAppName>.azurewebsites.net/sample
http://<FunctionAppName>.azurewebsites.net/hello/Foo
```

## Conclusion and Next Steps

Now you have a simple Azure Function App using the FastAPI framework, and you can continue building on it to develop more sophisticated applications.

To learn more about leveraging WSGI and ASGI-compatible frameworks, see [Web frameworks](https://docs.microsoft.com/azure/azure-functions/functions-reference-python?tabs=asgi%2Cazurecli-linux%2Capplication-level#web-frameworks).
