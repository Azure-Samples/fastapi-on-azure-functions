import logging
import azure.functions as func
from ..function_app import main

async def handler(req: func.HttpRequest, context: func.Context) -> func.HttpResponse:
    """Each function is automatically passed the context upon invocation."""
    logging.info('HTTP trigger function processed a request.')
    # Make sure we're properly awaiting the main function
    return await main(req)