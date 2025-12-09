
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



# S3 important notes before "terraform apply"!:
## Accesing S3 static website hosting isolated in Folders
Due to we are using AWS Cloudfront in front of S3 static files, then *the S3 bucket has to remain Private* so Cloudfront can be the only one to access it through OAC. Meaning we will use a Cloudfront Distribution URL in the browser to access the index.html file, and not the traditional S3 hosting URL.


## JS Script as Terraform Template waits input from Lambda URL before being deployed
Now we are using a Terraform template for the JS script called "script.js.tpl", and it waits until Lambda URL gets generated in order to use it in the JS script. So now this phase work automatically.



# AWS Cloudfront & AWS Route53 - important notes before "terraform apply"!:
We are following these steps:  https://www.youtube.com/watch?v=KfpJlp7BqfI&list=PLjl2dJMjkDjnwCR6eTLBhjt_45Ua7N9vn&index=5

As suggestion, create Hosted Zone and paste the NS records to your Registar before runnning `terraform apply`, which means the below steps should be done in "preparation stage" before the "terraform stage" starts:

## Create a public hosted zone in Route53 (Manually for now):
This creates an authoritative hosted zone for yourdomain.com in AWS.

It will generate 4 NS records like:

```
ns-123.awsdns-xx.com
ns-456.awsdns-yy.net
…
```

These are the nameservers you must put into Namecheap (cause in my case I bought the domain there).


## Pointing your domain at AWS Route 53 (manually for now, at Namecheap in my case):

Manual steps:
* Go to Namecheap → `Domain` → `Nameservers`

* Change from “Namecheap Basic DNS” (or whatever) to `Custom DNS`

* Paste the 4 nameservers from `AWS Route53 Hostzone`

* It may take 48 hours to set those changes, and from that moment, all DNS records must be managed in AWS Route 53, not Namecheap.

* Create a Certificate using AWS Certficate Manager(ACM) and create a `CNAME record` for this in AWS Route53 (so is ready to accept domains or subdomains in the Cloudfront URL).

Possible with Terraform:
* In case you use a subdomain for the new Cloudfront URL using your specific Domain you purchased (suggested), you also have to create a `A type record` in AWS Route53 for this Subdomain, and enable `Alias` option, and select `Route Traffic` to: `Alias to Cloudfront distribution`.



## Creating SSL Certificate for custom domains using AWS ACM in the us-east-1 Region (manually for now):
* Go to AWS ACM in the US East (N. Virginia) Region (us-east-1) is specfic because is requirement!!!
* Then, click in "request a certificate" > ""request a Public certificate"". Later in the section `Fully qualified domain name`, write the `wildcard + Domain`, for example:
```
*.example.com
```


* The rest leave selected as default and click finally in "request" button.



## Validating the new Certificate creating a CNAME record in Route53 (manually for now):
* First click in the certificate to see the detail, and there you will find a button called `Create records in Route53`.

* After clicking that option, you will see a final button called `Create records`.

* Finally verify its created the CNAME record in the respective `Hosted zone name`.



## In Cloudfront, add Alternate (sub)domain name (using Terraform):
* Write the Alternate domain name.

* Select the SSL certificate created in AWS ACM in the US East (N. Virginia) Region (us-east-1) is specfic because is requirement!!!



## Create a "A" Record in Route53 for the subdamin just added (using Terraform):
* Create a "A" Record in Route53 for the new subdomain



# AWS Lambda notes:
We are keeping different lambda scripts, but the one the is main used in AWS Lambda will be `index.py`




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




# Avoiding conflict with Pulumi resources/state:
- In Terraform we will detail `Profile` and `Tags` inside the Provider in this way to avoid conflicts:
```
provider "aws" {
  profile = "default"
  region  = "eu-central-1"

  default_tags {
    tags = {
      ManagedBy = "Terraform"
    }
  }
}
```

And use `naming conventions` for terraform starting with `tf-`:
```
resource "aws_s3_bucket" "tf-my-bucket-123" {
  bucket = "my-bucket-1234567890-pulumi-demo-dantej"
}
```


- Make sure create a AWS credentials profile 
```
[default]
aws_access_key_id=...
aws_secret_access_key=...

[pulumi]
aws_access_key_id=...
aws_secret_access_key=...
```


And configured in this way later:
```
pulumi config set aws:profile pulumi
pulumi config set aws:region eu-central-1    # or your region
```


- Create Pulumi resources adding default `Tags`(using Resource Transformation hook),  and `naming conventions` starting with `plm-`:

```
import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";
import * as awsx from "@pulumi/awsx";

// Register a stack-wide transformation to inject default tags
pulumi.runtime.registerStackTransformation((args) => {
    const props = args.props as any;

    // If the resource supports tags, merge in our default
    if (props && typeof props === "object" && "tags" in props) {
        props.tags = {
            ...props.tags,
            ManagedBy: "Pulumi",
        };
    }

    return {
        props,
        opts: args.opts,
    };
});

// Create an AWS resource (S3 Bucket) – NO need to specify ManagedBy here
const bucket = new aws.s3.Bucket("plm-my-bucket-1234567890-pulumi-demo-dantej", {
    // Optional: you can still add other custom tags, they’ll be merged
    // tags: {
    //     Project: "demo",
    // },
});

// Export the name of the bucket
export const bucketName = bucket.id;
```




# NEXT CHALLENGES:
- Now that the UI visits counter is finished and stored in dynamoDB, create a form in a website storing the personal data in dynamoDB following this tutorial:

https://www.youtube.com/watch?v=__o-9F9NBjg&list=PLjl2dJMjkDjlSARq_6kppW3nvUVIfy0Ut&index=7