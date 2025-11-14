import boto3
import botocore
import json
import csv
from datetime import datetime

def read_file():
    try:
        with open('/var/task/hola-test.txt', "r") as f:
            return f.read()
            # OR ANOTHER WAY.. :
            # for line in f:
            #     print(line, end="")  # the 'END' avoid blank lines in logs

    except (FileNotFoundError, OSError) as e:
        print(f"I/O error: {e}")
        return {"error": str(e)}


def lambda_handler(event, context):
    content = read_file()
    return content