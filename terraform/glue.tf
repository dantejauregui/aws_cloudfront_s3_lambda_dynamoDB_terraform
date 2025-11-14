# resource "aws_glue_catalog_database" "etl" {
#   name = "csv_pipeline_db"
# }

# resource "aws_glue_crawler" "raw_csv_crawler" {
#   name          = "raw-csv-crawler"
#   role          = aws_iam_role.glue_role.arn
#   database_name = aws_glue_catalog_database.etl.name

#   s3_target {
#     path = "s3://${aws_s3_bucket.my_files.bucket}/uploads/"
#   }

#   table_prefix = "uploads_"
#   schema_change_policy {
#     update_behavior = "UPDATE_IN_DATABASE"
#     delete_behavior = "LOG"
#   }
# }

# resource "aws_glue_crawler" "processed_crawler" {
#   name          = "processed-csv-crawler"
#   role          = aws_iam_role.glue_role.arn
#   database_name = aws_glue_catalog_database.etl.name

#   s3_target {
#     path = "s3://${aws_s3_bucket.my_files.bucket}/outputs/"
#   }

#   table_prefix = "outputs_"
#   schema_change_policy {
#     update_behavior = "UPDATE_IN_DATABASE"
#     delete_behavior = "LOG"
#   }
# }

# data "aws_iam_policy_document" "glue_assume" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["glue.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "glue_role" {
#   name               = "csv-glue-role"
#   assume_role_policy = data.aws_iam_policy_document.glue_assume.json
# }

# resource "aws_iam_policy" "glue_policy" {
#   name   = "csv-glue-s3-policy"
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect   = "Allow",
#         Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"],
#         Resource = [
#           aws_s3_bucket.raw.arn,
#           "${aws_s3_bucket.raw.arn}/*",
#           aws_s3_bucket.processed.arn,
#           "${aws_s3_bucket.processed.arn}/*"
#         ]
#       },
#       {
#         Effect   = "Allow",
#         Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
#         Resource = ["*"]
#       },
#       {
#         Effect   = "Allow",
#         Action   = [
#           "glue:CreateTable", "glue:UpdateTable", "glue:GetTable", "glue:GetDatabase",
#           "glue:BatchCreatePartition", "glue:BatchGetPartition"
#         ],
#         Resource = ["*"]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "glue_attach" {
#   role       = aws_iam_role.glue_role.name
#   policy_arn = aws_iam_policy.glue_policy.arn
# }

# resource "aws_s3_object" "glue_script" {
#   bucket  = aws_s3_bucket.raw.id
#   key     = "scripts/etl.py"
#   content = file("${path.module}/glue/etl.py")
# }

# resource "aws_glue_job" "csv_etl" {
#   name     = "csv-etl-job"
#   role_arn = aws_iam_role.glue_role.arn

#   command {
#     name            = "glueetl"
#     script_location = "s3://${aws_s3_bucket.raw.bucket}/${aws_s3_object.glue_script.key}"
#     python_version  = "3"
#   }

#   default_arguments = {
#     "--job-language"     = "python"
#     "--TempDir"          = "s3://${aws_s3_bucket.processed.bucket}/_tmp/"
#     "--raw_bucket"       = aws_s3_bucket.raw.bucket
#     "--processed_bucket" = aws_s3_bucket.processed.bucket
#   }

#   glue_version       = "4.0"
#   number_of_workers  = 2
#   worker_type        = "G.1X"
# }
