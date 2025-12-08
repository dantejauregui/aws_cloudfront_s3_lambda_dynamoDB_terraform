resource "aws_dynamodb_table" "serverless_webapp_table" {
  name         = "serverless_webapp_table"
  hash_key     = "id"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }
}


# DynamoDB table definition stays the same. Handle the "views" attribute and its value in your application code (Lambda).
# More documentation:  https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.CoreComponents.html
