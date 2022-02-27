import logging
import azure.functions as func
from FastAPIApp import app  # Main API application
# Always use relative import for custom module
# from .package.module import MODULE_VALUE

@app.get("/sample")
async def index():
  return {
      "info": "Try /hello/Shivani for parameterized Flask route.\n Try /module for module import guidance",}

@app.get("/hello/{name}")
async def get_name(
  name: str,):
  return {
      "name": name,}

@app.get("/module")
async def module():
    return {
        "loaded from FastAPI.package.module": MODULE_VALUE,}

def main(req: func.HttpRequest, context: func.Context) -> func.HttpResponse:
    return func.AsgiMiddleware(app).handle(req, context)