import os
import json
import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ.get("TABLE_NAME", "serverless_webapp_table")
table = dynamodb.Table(TABLE_NAME)

# You decide the key for the global counter
GLOBAL_ID = "global-visits"

def lambda_handler(event, context):
    logger.info("Incoming event: %s", json.dumps(event))

    # Always increment the same item
    item_id = GLOBAL_ID

    resp = table.update_item(
        Key={"id": item_id},
        UpdateExpression="SET visits = if_not_exists(visits, :zero) + :inc",
        ExpressionAttributeValues={
            ":zero": 0,
            ":inc": 1,
        },
        ReturnValues="UPDATED_NEW",
    )

    new_visits = int(resp["Attributes"]["visits"])

    logger.info("Updated item %s to visits=%s", item_id, new_visits)

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
        },
        "body": json.dumps({"visits": new_visits}),
    }
