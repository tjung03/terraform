# IAM user example

This folder contains example [Terraform](https://www.terraform.io/) configuration that create several 
[IAM](https://aws.amazon.com/iam/) users in an [Amazon Web Services (AWS) account](http://aws.amazon.com/). 

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

If IAM Identity Center is unavailable, use an approved profile that supplies temporary credentials and set `AWS_PROFILE` to its name. Existing `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, or `AWS_SESSION_TOKEN` values can take precedence over a profile, so check the active credentials and account before applying. Keep credentials out of Terraform files and this repository.

In `variables.tf`, fill in the `default` parameter to configure if the "neo" IAM user should be given full access to 
CloudWatch or only read-only access:

```hcl
variable "give_neo_cloudwatch_full_access" {
  description = "If true, neo gets full access to CloudWatch"
  type        = bool
  # Set this parameter to true or false!
  # default   = true
}
```

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