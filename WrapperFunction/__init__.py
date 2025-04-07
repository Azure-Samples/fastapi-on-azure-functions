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

async def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    return await func.AsgiMiddleware(app).handle_async(req)
