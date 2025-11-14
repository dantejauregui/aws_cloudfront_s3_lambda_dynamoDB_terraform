import boto3
import botocore
import json
import csv
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel("INFO")

def lambda_handler(event, context):
    logger.info("Lambda started")
    return {"message": "ok"}
