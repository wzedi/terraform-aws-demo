# symbiote-terraform-task
Demonstrates how I approach terraform implementations.

## Instructions

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

### Terraform Backend

The [Terraform backend](https://www.terraform.io/language/settings/backends) stores the state for the deployment.

This solution uses the [AWS S3 backend](https://www.terraform.io/language/settings/backends/s3) with Dynamodb State Locking.

According to best practice the bucket is versioned, to protect against accidental loss and corruption, and encrypted at rest.

[State locking](https://www.terraform.io/language/state/locking) is implemented to protected against potential corruption where multiple deployments are run concurrently.

The backend must be deployed before deploying the solution stack.

### Solution Stack

The solution stack incldues the VPC, RDS instance and EC2 instance.