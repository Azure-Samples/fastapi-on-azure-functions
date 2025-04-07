import logging
import azure.functions as func
from fastapi import FastAPI

app = FastAPI()

@app.get("/sample")
async def index():
    return {
        "info": "Try /hello/Shivani for parameterized route.",
    }

@app.get("/hello/{name}")
async def get_name(name: str):
    return {
        "name": name
    }

@app.get("/api/sample")
async def api_index():
    return {
        "info": "Try /api/hello/Shivani for parameterized route.",
    }

@app.get("/api/hello/{name}")
async def api_get_name(name: str):
    return {
        "name": name
    }

# Create a function app instance
function_app = func.FunctionApp()

# Register the function with an HTTP trigger
@function_app.route(route="{*route}", auth_level=func.AuthLevel.ANONYMOUS)
async def main(req: func.HttpRequest) -> func.HttpResponse:
    """Each function is automatically registered through the @function_app decorator."""
    logging.info('Python HTTP trigger function processed a request.')
    return await func.AsgiMiddleware(app).handle_async(req)
