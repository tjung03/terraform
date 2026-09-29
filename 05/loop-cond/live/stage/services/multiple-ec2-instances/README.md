# Multiple servers example

This folder contains an example [Terraform](https://www.terraform.io/) configuration that deploys multiple EC2 instances 
(using [EC2](https://aws.amazon.com/ec2/)). The goal of these configuration is to demonstrate how to use the +count+
parameter in Terraform, as well as some of its limitations.

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

Review the plan before applying to the intended account:

```bash
terraform init
terraform plan
terraform apply
```

Clean up when you're done:

```
terraform destroy
```