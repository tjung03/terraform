# Web server cluster example (staging environment)

This folder contains an example [Terraform](https://www.terraform.io/) configuration that deploys a cluster of web servers 
(using [EC2](https://aws.amazon.com/ec2/) and [Auto Scaling](https://aws.amazon.com/autoscaling/)) and a load balancer
(using [ELB](https://aws.amazon.com/elasticloadbalancing/)) in an [Amazon Web Services (AWS) 
account](http://aws.amazon.com/). The load balancer listens on port 80 and returns the text "Hello, World" for the 
`/` URL. The code for the cluster and load balancer are defined as a Terraform module in
[modules/services/webserver-cluster](../../../../modules/services/webserver-cluster).

For more info, please see Chapter 5, "Terraform Tips & Tricks: Loops, If-Statements, Deployment, and Gotchas", of 
*[Terraform: Up and Running](http://www.terraformupandrunning.com)*.

## Pre-requisites

* You must have [Terraform](https://www.terraform.io/) installed on your computer. 
* You must have an [Amazon Web Services (AWS) account](http://aws.amazon.com/).
* You must deploy the MySQL database in [data-stores/mysql](../../data-stores/mysql) BEFORE deploying the
  configuration in this folder.

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

In `variables.tf`, fill in the name of the S3 bucket and key where the remote state is stored for the MySQL database
(you must deploy the configuration in [data-stores/mysql](../../data-stores/mysql) first):

```hcl
variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket used for the database's remote state storage"
  type        = string
  default     = "<YOUR BUCKET NAME>"
}

variable "db_remote_state_key" {
  description = "The name of the key in the S3 bucket used for the database's remote state storage"
  type        = string
  default     = "<YOUR STATE PATH>"
}
```

Review the plan before applying to the intended account:

```bash
terraform init
terraform plan
terraform apply
```

When the `apply` command completes, it will output the DNS name of the load balancer. To test the load balancer:

```
curl "http://$(terraform output -raw alb_dns_name)/"
```

Clean up when you're done:

```
terraform destroy
```