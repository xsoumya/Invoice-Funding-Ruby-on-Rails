# Deployment Summary

## What Was Built

- A single-page Rails customer enquiry form with validation and persistence.
- Local SQLite development support and production PostgreSQL support.
- A multi-stage Docker image running Rails as a non-root user.
- A `/health` endpoint for load balancer checks.
- Terraform for VPC, subnets, NAT, ECR, ECS Fargate, ALB, RDS PostgreSQL, Secrets Manager, IAM, and CloudWatch Logs.

## AWS Deployment Steps Completed

1. Installed Ruby 3.3.5 through `mise` and installed Rails dependencies.
2. Installed Terraform 1.9.8 locally.
3. Validated and initialized the Terraform module in `infra/`.
4. Created the ECR repository in `ap-southeast-2`.
5. Built and pushed the Rails image to ECR.
6. Corrected the image build to `linux/amd64` for ECS Fargate.
7. Created the VPC, public and private subnets, NAT gateway, route tables, security groups, ECS cluster, RDS PostgreSQL, ALB, Secrets Manager secret, IAM execution role, and CloudWatch log group.
8. Created two ECS tasks and verified healthy ALB targets with an HTTP 200 response from `/health`.
9. Destroyed the AWS stack using Terraform at the user’s request.

## Current State

The AWS application stack has been destroyed. The Terraform state retained only the ECS execution role because the active IAM user lacked `iam:ListInstanceProfilesForRole` during role deletion. The local Rails project and Terraform source remain available for a future redeployment.

## CI/CD Pipeline

`.github/workflows/deploy.yml` is configured for pushes to `main` and manual dispatch. It uses GitHub OIDC through the `AWS_DEPLOY_ROLE_ARN` repository secret, bootstraps ECR, builds the image for `linux/amd64`, pushes the commit SHA as an immutable tag, applies Terraform, runs `bundle exec rails db:migrate` as an ECS one-off task, waits for ECS stability, and prints the load balancer URL.

Before enabling the workflow, configure an AWS deployment role trusted by GitHub Actions and add this repository secret:

```text
AWS_DEPLOY_ROLE_ARN=arn:aws:iam::<account-id>:role/<github-actions-deploy-role>
```

## Important Lessons

- Build on Apple Silicon with `docker build --platform linux/amd64` for the current Fargate task definition.
- ECS, ALB, and RDS may need AWS service-linked roles created by an administrator.
- Free Tier account restrictions required standard RDS PostgreSQL instead of Aurora and the `db.t4g.micro` class.
- Use immutable image tags rather than `latest` in ECR.
