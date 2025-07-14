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
