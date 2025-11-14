resource "random_id" "bucket_suffix" {
  byte_length = 4
}


resource "aws_s3_bucket" "my_files" {
  bucket = "my-files-${random_id.bucket_suffix.hex}"

  #for testing purposes:
  force_destroy = true
}
resource "aws_s3_bucket_versioning" "my_csv_file" {
  bucket = aws_s3_bucket.my_files.id

  versioning_configuration {
    status = "Disabled"
  }
}
resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.my_files.id

  # Witht the following options, we block public access of the S3 static files (html, css):
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


data "aws_iam_policy_document" "site_policy" {
  statement {
    sid    = "AllowCloudFrontRead"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.my_files.arn}/*",
    ]

    #TESTING NOW THIS SNIPPET:
    # condition {
    #   test     = "StringEquals"
    #   variable = "AWS:SourceArn"
    #   values   = [aws_cloudfront_distribution.dist.arn]
    # }
  }
}
resource "aws_s3_bucket_policy" "static_website_cloudfront_read" {
  bucket = aws_s3_bucket.my_files.id
  policy = data.aws_iam_policy_document.site_policy.json

  depends_on = [aws_s3_bucket.my_files, aws_s3_bucket_public_access_block.static_website]
}


#Creation of Folders inside S3 automatically:
resource "aws_s3_object" "prefix_uploads" {
  bucket  = aws_s3_bucket.my_files.id
  key     = "uploads/"
  content = "" # zero-byte object
}
# resource "aws_s3_object" "prefix_outputs" {
#   bucket  = aws_s3_bucket.my_files.id
#   key     = "outputs/"
#   content = ""
# }


## DISABLE "STATIC WEBSITE HOSTING" feature, because we are using "Cloudfront + OAC" instead (also S3 should remain Private):
# resource "aws_s3_bucket_website_configuration" "poc_static_website" {
#   bucket = aws_s3_bucket.my_files.id

#   index_document {
#     suffix = "index.html"
#   }

#   error_document {
#     key = "error.html"
#   }
# }


resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.my_files.id
  key    = "index.html"
  source = "build/index.html"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag         = filemd5("build/index.html")
  content_type = "text/html"
}
resource "aws_s3_object" "style_css" {
  bucket = aws_s3_bucket.my_files.id
  key    = "style.css"
  source = "build/style.css"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag         = filemd5("build/style.css")
  content_type = "text/css"
}
resource "aws_s3_object" "error_html" {
  bucket = aws_s3_bucket.my_files.id
  key    = "error.html"
  source = "build/error.html"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag         = filemd5("build/error.html")
  content_type = "text/html"
}
