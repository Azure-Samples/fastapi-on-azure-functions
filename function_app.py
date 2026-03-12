import azure.functions as func
from fastapi import FastAPI

fast_app = FastAPI()


@fast_app.get("/sample")
async def index():
    return {
        "info": "Try /hello/Shivani for parameterized route.",
    }


@fast_app.get("/hello/{name}")
async def get_name(name: str):
    return {
        "name": name,
    }


app = func.AsgiFunctionApp(app=fast_app, http_auth_level=func.AuthLevel.ANONYMOUS)
