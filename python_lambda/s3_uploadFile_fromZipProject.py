import boto3
import botocore
import json
import csv
from datetime import datetime

# In this usecase, the hola.txt file was uploaded already within the lambda zip file project, 
# so is located already in the Lambda service (cloud) an can be accessed only using this Path: /var/task/hola.txt 
def s3_upload_file():
    try:
        s3 = boto3.client('s3')
        s3.upload_file('/var/task/hola-test.txt', 'my-csv-file-f535c8bd', 'uploads/hola-test.txt')

    except botocore.exceptions.ClientError as e:
        print(e.response["Error"]["Message"])


def lambda_handler(event, context):
    s3_upload_file()