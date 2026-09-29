# MySQL on RDS example (staging environment)

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

Use a profile with temporary AWS credentials. If your account provides IAM Identity Center, configure and sign in to a profile; select the profile for both the AWS provider and any S3 backend. Check the account before creating resources. See the [AWS CLI Identity Center guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html) and [Terraform provider credentials guide](https://developer.hashicorp.com/terraform/tutorials/configuration-language/configure-providers).

```bash
aws configure sso --profile terraform-lab
aws sso login --profile terraform-lab
export AWS_PROFILE=terraform-lab
aws sts get-caller-identity
```

If IAM Identity Center is unavailable, use an approved profile that supplies temporary credentials and set `AWS_PROFILE` to its name. Keep credentials out of Terraform files and this repository.

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

Review the plan after backend initialization, then apply only to the intended account:

```bash
terraform plan
terraform apply
```

Clean up when you're done:

```
terraform destroy
```