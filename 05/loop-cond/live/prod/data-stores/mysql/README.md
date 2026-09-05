# MySQL on RDS example (production environment)

This folder contains an example [Terraform](https://www.terraform.io/) configuration that deploys a MySQL database  (using 
[RDS](https://aws.amazon.com/rds/) in an [Amazon Web Services (AWS) account](http://aws.amazon.com/). 

For more info, please see Chapter 5, "Terraform Tips & Tricks: Loops, If-Statements, Deployment, and Gotchas", of 
*[Terraform: Up and Running](http://www.terraformupandrunning.com)*.

## Pre-requisites

* You must have [Terraform](https://www.terraform.io/) installed on your computer. 
* You must have an [Amazon Web Services (AWS) account](http://aws.amazon.com/).

Please note that this code was written for Terraform 1.x.

## Quick start

Applying this example creates AWS resources and may incur charges. 

Configure your [AWS access 
keys](http://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) as 
environment variables:

```
read -r -p 'AWS access key ID: ' AWS_ACCESS_KEY_ID
read -r -s -p 'AWS secret access key: ' AWS_SECRET_ACCESS_KEY
printf '\n'
export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
```

Configure the database credentials as environment variables:

```
read -r -p 'Database username: ' TF_VAR_db_username
read -r -s -p 'Database password: ' TF_VAR_db_password
printf '\n'
export TF_VAR_db_username TF_VAR_db_password
```

The S3 backend block is already present in `main.tf`. Supply an existing bucket, a state key unique to this environment, and its region during initialization:

```bash
read -r -p 'S3 bucket: ' TF_STATE_BUCKET
read -r -p 'State key: ' TF_STATE_KEY
terraform init -backend-config="bucket=$TF_STATE_BUCKET" -backend-config="key=$TF_STATE_KEY" -backend-config="region=us-east-2"
```

The web module reads DB state from `us-east-2`. For S3 state locking, see the [repository compatibility guide](../../../../../../docs/examples.md#버전과-호환성).

Deploy the code:

```
terraform init
terraform apply
```

Clean up when you're done:

```
terraform destroy
```