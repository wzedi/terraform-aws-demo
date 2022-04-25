# symbiote-terraform-task
Demonstrates how I approach terraform implementations.

## TL;DR

To get started:

1. Run docker for your environment.
1. Deploy with `AWS_PROFILE=myprofile make deploy`
1. Test HTTP requests to the instance through the ALB: `AWS_PROFILE=myprofile make test-alb`
    * Alternatively grab the ALB DNS name from the stack outputs printed when deploy was run and paste that into a browser
1. Test the instance connection to the database: `AWS_PROFILE=myprofile make test-mysql`
    * Alternatively grant the ALB DNS name from the stack outputs printed when deploy was run and paste that intoa browser with `/mysql-test.php` appended
1. Destroy with `AWS_PROFILE=myprofile make destroy`. Before running this step the following manual steps are required in the console:
    * RDS deletion protection must be disabled
    * The state bucket must be emptied

## Usage

This project has two stacks - the terraform backend and the main solution.

To deploy the entire solution:

1. Setup your environment.
    * REQUIRED: Run the Docker daemon for your environment. This project runs `terraform` and `jq` through docker.
    * REQUIRED: This is an AWS deployment. You'll need either an AWS credentials file and profile name or login to AWS
        * If you are using a credentials file set `$AWS_PROFILE` as required. The default config file location is `${HOME}/.aws`. Set `$AWS_CONFIG_DIR` to override the default.
        * If you are using AWS credentials please ensure `$AWS_ACCESS_KEY_ID`, `$AWS_SECRET_ACCESS_KEY` and `$AWS_REGION` are set.
    * OPTIONAL: The Terraform plan will output to a default location. To override the default set `$PLAN_FILE`
1. Deploy the backend and the solution stack: `make deploy`. This will:
    * Deploy the Terraform backend.
        * The Terraform state file for the backend is stored locally and should be committed.
    * Deploy the solution stack.

### Deploy example:

```
% AWS_PROFILE=myprofile make deploy
```

### Destroy example:

Note: To avoid errors when destroying the stack deletion protection must be removed from the RDS instance. To do this:

1. Login to the RDS console
1. Find the RDS instance for this stack
1. Click to Modify the instance
1. Disable instance protection near the bottom of the form

The backend bucket must also be emptied.

```
% AWS_PROFILE=myprofile make destroy
```

### Other terraform commands

Terraform commands like `init` and `plan` are also implemented as `make` targets.

The backend stack can also be managed separately to the solution stack.

The various `make` targets are listed here. The `*-init`, `*-plan`, `*-apply` and `*-destroy` targets each run the corresponding terraform command.

* backend-init
* backend-plan
* backend-apply
* backend-output
* backend-destroy
* backend-deploy  - runs terraform `init`, `plan` and `apply` for the backend stack
* solution-init
* solution-plan
* solution-apply
* solution-destroy
* solution-deploy  - runs terraform `init`, `plan` and `apply` for the solution stack
* deploy - deploy the backend and the solution stack - runs terraform `init`, `plan` and `apply` for both stacks
* destroy - destroy the solution stack then destroy the backend stack


## Requirements

“We are keen for you to take a look at a small task to demonstrate how you approach terraform implementations.

We would like to get you to create a small terraform infrastructure manifest for us that does the following;

· Creates a VPC for the infrastructure to exist within
· Creates Public and Private subnets
· Creates a single EC2 instance that is behind an ALB
· Creates an RDS that the EC2 instance is able to connect to (Either Mysql or Postgresql is fine)
· Has some simple cloudwatch monitors (i.e CPU monitor)
· The EC2 instance is part of an Autoscaling group

In terms of how to build the solution, we are more than happy with the use of community modules to be able to build the solution (modules sourced from registry.terraform.io) or your own if that's how you want to approach it.

At the end, we hope to have terraform codebase that we can add our own credentials to and then spin up the running environment to take a look around.

We think that the task should not take more than a couple of hours to complete.

## Solution

### Overview

The project uses `make` to manage deployment tasks

This is a Terraform project but it does not assume Terraform is installed locally. Rather the project uses Terraform's Docker image to run commands.

You'll need the Docker daemon running before running the deployment tasks in this project.

There is also a dependency on `jq` to parse the backend state for the bucket name and lock table name. This also uses the Docker image for `jq` so it is not required to be installed locally.

### Terraform Backend

The [Terraform backend](https://www.terraform.io/language/settings/backends) stores the state for the deployment.

This solution uses the [AWS S3 backend](https://www.terraform.io/language/settings/backends/s3) with Dynamodb State Locking.

According to best practice the bucket is versioned, to protect against accidental loss and corruption, and encrypted at rest.

[State locking](https://www.terraform.io/language/state/locking) is implemented to protected against potential corruption where multiple deployments are run concurrently.

The backend must be deployed before deploying the solution stack.

### Solution Stack

The back-end details are passed to the solution stack as follows:

1. The backend stack outputs the bucket name and table name
1. The make target for all solution stack terraform commands uses `terraform output -json` and parses the names out using `jq`
1. The names are then passed into the `main.tf.template` file to create the `main.tf` file with correct backend config

The solution stack includes the VPC, RDS instance and EC2 instance.

The RDS instance is deployed into a "server" security group that allows ingress from the "client" security group only.

The EC2 instance is deployed into the "client" security group allowing mysql connections to the server.

The EC2 instance is deployed to the "target" security group allowing http and https traffic in and all traffic out.

Connect to the instance via SSM connection in the EC2 console.

The Cloud Watch Agent has been installed and configured to stream the system log to Cloud Watch. The log group is `messages` and log stream names are instance IDs.

### Gotchas and Troubleshooting

* If you do destroy the stack and then attempt to redeploy the database password secret name will be in conflict and must be changed in the rds config (maybe it should be a var)
* When destroying the stack with `var.rds_skip_final_snapshot` set to `true` the destroy will fail after timeout because the DB options group is in use by the final snapshot and cannot be deleted. The final snapshot must be manually deleted.

## Possible improvements given time

* The userdata creates a bunch of files with bash heredocs - there are better ways to do that
* the DB password lookup in the PHP script shells out to the AWS CLI - this would be better done with the AWS SDK
* Fully implement IAM authentication to the database
* PHP script not connecting successfully to the database - I think possibly related to MySQL 8 - possibly an exercise for the interview
