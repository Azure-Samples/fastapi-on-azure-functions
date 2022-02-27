import logging
import azure.functions as func
from FastAPIApp import app  # Main API application
import nest_asyncio
nest_asyncio.apply()

@app.get("/sample")
async def index():
  return {
      "info": "Try /hello/Shivani for parameterized route.",}

@app.get("/hello/{name}")
async def get_name(
  name: str,):
  return {
      "name": name,}

async def main(req: func.HttpRequest, context: func.Context) -> func.HttpResponse:
    return func.AsgiMiddleware(app).handle(req, context)
