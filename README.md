# Northstar customer enquiries

A single-page customer enquiry flow built with Ruby on Rails. SQLite is used locally; production uses PostgreSQL on Amazon Aurora.

## Requirements

- Ruby 2.6 or newer
- Rails 6.1.7.10
- SQLite3

The current machine has Apple's system Ruby 2.6, but its Ruby headers are unavailable for native gem compilation. Use a version manager such as `rbenv` or `mise` with Ruby 3.1+ before running the app locally.

## Run

```sh
bundle install
bin/rails db:migrate
bin/rails server
```

Open `http://localhost:3000`. The form is available at `/`, and successful submissions are stored in `db/development.sqlite3`.

## ECS Fargate deployment

The production container listens on port `3000` and exposes `GET /health` for the load balancer.

1. Use the Terraform workflow below to create ECR and the ECS Fargate service behind an Application Load Balancer. Configure the target group health check as `/health` on port `3000`.

2. Terraform creates Aurora PostgreSQL and provides these ECS task environment values:

```text
RAILS_ENV=production
DATABASE_URL=postgresql://...
SECRET_KEY_BASE=<stored in AWS Secrets Manager>
FORCE_SSL=true
```

3. Run the migration as an ECS one-off task before sending traffic to a new release:

```sh
bundle exec rails db:migrate
```

Keep `DATABASE_URL` and `SECRET_KEY_BASE` in Secrets Manager rather than committing them to the task definition. Configure CloudWatch Logs for the container and use at least two tasks across multiple Availability Zones for production.

## Provision AWS with Terraform

The `infra/` directory creates the VPC, public and private subnets, NAT gateway, ECR repository, Aurora PostgreSQL cluster, Secrets Manager secret, ECS cluster and service, Application Load Balancer, IAM execution role, and CloudWatch log group.

Prerequisites:

- Terraform 1.6+
- AWS CLI credentials with permission to create the listed resources
- Docker Desktop running

From the project root:

```sh
cd infra
cp terraform.tfvars.example terraform.tfvars
```

Create the ECR repository first, then build and push a unique image tag:

```sh
terraform init
terraform apply -target=aws_ecr_repository.app -var-file=terraform.tfvars
```

Build and publish the Rails image using the `ecr_repository_url` Terraform output:

```sh
REPOSITORY_URL=$(terraform output -raw ecr_repository_url)
cd ..
IMAGE_TAG=$(git rev-parse --short HEAD)
docker build -t "$REPOSITORY_URL:$IMAGE_TAG" .
aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin "$(echo "$REPOSITORY_URL" | cut -d/ -f1)"
docker push "$REPOSITORY_URL:$IMAGE_TAG"
cd infra
sed -i.bak "s#^container_image.*#container_image = \"$REPOSITORY_URL:$IMAGE_TAG\"#" terraform.tfvars
rm -f terraform.tfvars.bak
```

Run Terraform again after pushing the image. Open the deployed application with:

```sh
cd infra
terraform output -raw load_balancer_url
```

The generated database password and Rails secret are stored in Secrets Manager and also exist in Terraform state. Use an encrypted remote S3 backend with DynamoDB locking before sharing this configuration or using it with a team. The current module uses a single NAT gateway to keep the baseline cost lower; add one NAT gateway per Availability Zone for higher availability.
