
# Python Part:
In the python module we generate the zip file for AWS Lambda that includes the needed pip packages and the latest python code.

For Zip file Lambda version:
first create `venv`:
```
python3 -m venv venv
source venv/bin/activate
```

Once activated the venv, install dependencies from requirements.txt inside your venv:
pip install -r requirements.txt


Later, package all the dependencies and zip it:
```
pip install --target package_to_zip -r requirements.txt
cp index.py package_to_zip/
cd package_to_zip
zip -r ../../terraform/lambda.zip .
cd ..
```

After the zip file is located inside the `Terraform folder`, disable the `venv` using:
```
deactivate
```



# Terraform Part:
Inside the `Terraform folder`, you can run the AWS Infrastructure using:
```
terraform init
terraform plan
terraform apply
```

And to destroy:
```
terraform destroy
```



# AWS Lambda:
Will be in charge of verify the CSV file from S3 is correct, and later initialize AWS Glue.

# Accesing S3 static website hosting isolated in Folders
To access the static website files in each folder, just use the S3 Host URL adding in the path the Folder name, for example `/uploads/`:
```
http://my-files-s3-website.eu-central-0.amazonaws.com/uploads/
```

<!-- # AWS Glue:
Using terraform we had to add a Crawler, Catalog and the Glue Job, in order we can have a functional ETL pipeline. -->