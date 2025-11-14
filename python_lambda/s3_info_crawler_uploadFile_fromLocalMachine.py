import boto3
import botocore
import json
import csv
from datetime import datetime

def list_s3_buckets():
    try:
        s3_resource = boto3.resource("s3")

        bucket_iterator = s3_resource.buckets.all()

        print("List of S3 Buckets")

        current_datetime = str(datetime.now().strftime("%Y-%m-%d-%H-%M-%S"))
        filename = "ec2-inventory-" + current_datetime + ".csv"

        with open("/tmp/"+ filename, "w", newline="") as file:
            writer = csv.writer(file)
            writer.writerow(["Bucket Name", "Creation Date"])


            for bucket in bucket_iterator:
                writer.writerow([bucket.name, bucket.creation_date])
            
            print("The CSV file has been correctly exported!")

            return filename
        

    except botocore.exceptions.ClientError as e:
        print(e.response["Error"]["Message"])


def s3_upload_file(filename):
    try:
        s3_client = boto3.resource("s3")

        s3_client.Bucket("my-csv-file-0f929c91").upload_file(
            "/tmp/" + filename, 
            "outputs/" + filename)

        print("The CSV file has been correctly uploaded to S3!")

    except botocore.exceptions.ClientError as e:
        print(e.response["Error"]["Message"])


def lambda_handler(event, context):
    file = list_s3_buckets()
    s3_upload_file(file)