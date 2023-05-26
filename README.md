# Wordpress App

This repo will create a Wordpress App in your AWS account.  It will create its own full network and deploy de app using
Fargate and RDS Serverless.  You can deploy it using Cloud Formation or Terraform.

## Cloud Formation Deployment

To deploy Cloud formation, make sure to upload all the files to S3 in your account.  Also make sure you update the
wordpress-blog-main-stack.yaml file by replacing the <S3_PATH> placeholder for the actual path where you are going to
upload the files.  For a detailed explanation on how to run the Cloud Formation temples, please go to:
https://abdiels.com/2023/05/15/infrastructure-as-code.html

## Terraform Scripts

Make sure you have Terraform installed and your AWS credentials setup.  Then you can execute the terraform commands
from within the repo's terraform folder:

```
terraform init
terraform apply
```
For a more detailed explanation on how to run Terraform, please visit: https://abdiels.com/2023/05/15/infrastructure-as-code.html
