# aws-terraform-build
This project provisions a production-style AWS platform using Terraform:
Overview

This project provisions a production-style AWS platform using Terraform:

Multi-AZ VPC

Public ALB

Private ECS Fargate service

Private RDS database

S3 bucket + Lambda trigger

CloudWatch logs, alarms & dashboard

CI/CD via GitHub Actions & GitLab CI

OIDC-based secure AWS authentication (no static keys)

🏗 Architecture
Infrastructure Components
Layer	Service
Networking	VPC, Subnets, IGW, Route Tables
Load Balancing	ALB
Compute	ECS Fargate
Database	RDS (Multi-AZ capable subnet group)
Storage	S3
Eventing	Lambda (S3 trigger)
Observability	CloudWatch Logs + Alarms + Dashboard
Security	IAM Roles (Least Privilege)
CI/CD	GitHub Actions + GitLab CI (OIDC)
📁 Project Structure
aws-interview-platform/
  envs/
    dev/
      main.tf
      provider.tf
      variables.tf
      terraform.tfvars
      outputs.tf
  modules/
    networking/
    database/
    storage_lambda/
    ecs_app/
    observability/
  lambda/
    handler.py
⚙️ Prerequisites

AWS CLI configured

Terraform ≥ 1.6

AWS region: us-east-1

IAM OIDC roles created for GitHub & GitLab

🔐 OIDC Roles (Already Created)

You must have:

terraform-github-oidc

terraform-gitlab-oidc

Each with:

Trust policy for respective OIDC provider

Permissions policy for VPC, ECS, RDS, S3, Lambda, CloudWatch

💻 Local Deployment

From:

cd envs/dev

Run:

terraform fmt -recursive
terraform init -upgrade
terraform validate
terraform plan
terraform apply
🌐 Outputs

After apply:

terraform output

Important outputs:

alb_dns_name

uploads_bucket_name

🧪 Testing the Platform
1️⃣ Test ALB + ECS
terraform output alb_dns_name

Then:

curl http://<ALB_DNS_NAME>

Expected:

HTTP 200

Nginx default page

✅ Confirms:

VPC routing works

Public ALB works

ECS service registered

Private tasks reachable only via ALB

2️⃣ Test Lambda Trigger

Upload file to S3:

aws s3 cp test.txt s3://<uploads_bucket_name>/test.txt --region us-east-1

Then check CloudWatch Logs:

aws logs describe-log-groups --region us-east-1

Expected:

Lambda execution log entry

✅ Confirms:

S3 event wiring works

Lambda permissions correct

Logging enabled

3️⃣ Validate RDS Is Private
aws rds describe-db-instances --region us-east-1 \
  --query "DBInstances[?contains(DBInstanceIdentifier, 'interview-dev')].[PubliclyAccessible]"

Expected:

false

✅ Confirms:

Database is not internet exposed

Subnet group spans ≥ 2 AZs

📊 Monitoring Validation

Check in AWS Console:

CloudWatch → Alarms

CloudWatch → Dashboards

Alarms configured for:

ALB 5xx errors

ECS CPU

ECS Memory

🔄 GitHub CI/CD Setup

Create:

.github/workflows/terraform-dev.yml

Paste:

name: terraform-dev

on:
  pull_request:
  push:
    branches: ["main"]
  workflow_dispatch:

permissions:
  id-token: write
  contents: read

jobs:
  plan:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: envs/dev

    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3

      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
          aws-region: us-east-1

      - run: terraform init -upgrade
      - run: terraform fmt -recursive -check
      - run: terraform validate
      - run: terraform plan

  apply:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: dev
    defaults:
      run:
        working-directory: envs/dev

    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3

      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
          aws-region: us-east-1

      - run: terraform init -upgrade
      - run: terraform apply -auto-approve

Add GitHub Secret:

AWS_ROLE_TO_ASSUME = arn:aws:iam::<account-id>:role/terraform-github-oidc
🦊 GitLab CI/CD Setup

Create:

.gitlab-ci.yml

Paste:

stages:
  - validate
  - plan
  - apply

variables:
  TF_ROOT: "envs/dev"

default:
  image: hashicorp/terraform:1.6.6
  before_script:
    - cd "$TF_ROOT"
    - terraform --version

validate:
  stage: validate
  script:
    - terraform init -upgrade
    - terraform fmt -recursive -check
    - terraform validate

plan:
  stage: plan
  script:
    - terraform init -upgrade
    - terraform plan
  only:
    - merge_requests

apply:
  stage: apply
  script:
    - terraform init -upgrade
    - terraform apply -auto-approve
  when: manual
  only:
    - main

Add GitLab CI Variable:

AWS_ROLE_ARN = arn:aws:iam::<account-id>:role/terraform-gitlab-oidc
🛑 Destroy Environment

From:

cd envs/dev

Run:

terraform destroy -auto-approve

If RDS blocks deletion:
Ensure:

deletion_protection = false
skip_final_snapshot = true
