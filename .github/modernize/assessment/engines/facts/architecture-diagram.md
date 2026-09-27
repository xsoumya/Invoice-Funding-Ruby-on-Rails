# Architecture Diagram

This application is a Rails customer enquiry service packaged as a Docker image and designed for AWS ECS Fargate. The deployed baseline used an Application Load Balancer, private ECS tasks, private PostgreSQL, ECR, Secrets Manager, and CloudWatch Logs.

## Application Architecture

<!-- mermaid-checked: no \n, no em-dash/en-dash, no {} in labels, subgraphs are id["label"], arrows are -->|"label"|, all subgraphs closed by end, ids unique -->
```mermaid
flowchart TD
    subgraph ClientLayer["Client Layer"]
        Browser["Web Browser"]
    end
    subgraph AwsNetwork["AWS Network"]
        Alb["Application Load Balancer"]
        Ecs["ECS Fargate Service"]
        Rds[[("PostgreSQL RDS")]]
    end
    subgraph AppLayer["Rails Application"]
        Form["Customer Enquiry Form"]
        Controller["Enquiries Controller"]
        Model["Enquiry Model"]
    end
    subgraph PlatformServices["AWS Platform Services"]
        Ecr["Amazon ECR"]
        Secrets["Secrets Manager"]
        Logs["CloudWatch Logs"]
    end

    Browser -->|"HTTP requests"| Alb
    Alb -->|"port 3000"| Ecs
    Ecs -->|"runs"| Form
    Form -->|"submits"| Controller
    Controller -->|"validates and saves"| Model
    Model -->|"SQL"| Rds
    Ecs -->|"reads credentials"| Secrets
    Ecs -->|"writes logs"| Logs
    Ecr -->|"provides image"| Ecs
```

### Technology Stack Summary

| Layer | Technology | Version | Purpose |
|---|---|---|---|
| Application | Ruby on Rails | 6.1.7.10 | Web application and routing |
| Runtime | Ruby | 3.3.5 | Application runtime |
| Web server | WEBrick | 1.9.2 | Container HTTP server |
| Local database | SQLite | sqlite3 gem 1.7.3 | Local development |
| Production database | Amazon RDS PostgreSQL | AWS managed | Persistent enquiry storage |
| Container | Docker | Multi-stage image | Reproducible deployment artifact |
| Compute | ECS Fargate | AWS managed | Serverless container execution |
| Ingress | Application Load Balancer | AWS managed | Public HTTP traffic and health checks |
| Registry | Amazon ECR | AWS managed | Immutable container image storage |
| Secrets | AWS Secrets Manager | AWS managed | Database URL and Rails secret |
| Observability | CloudWatch Logs | AWS managed | Container log collection |
| Infrastructure | Terraform | 1.9+ | AWS resource provisioning |

### Data Storage & External Services

Local development uses SQLite. Production uses a private PostgreSQL RDS instance in the VPC, with its connection URL and `SECRET_KEY_BASE` supplied to ECS from Secrets Manager. ECR stores the container image, the load balancer routes traffic to private ECS tasks, and CloudWatch receives application logs. No external email, cache, queue, or third-party API is currently configured.

### Key Architectural Decisions

- ECS tasks run in private subnets and receive traffic only from the Application Load Balancer.
- Container images are built for `linux/amd64`, matching the Fargate runtime platform.
- Terraform owns infrastructure state; application releases use immutable ECR image tags.

## Component Relationships

<!-- mermaid-checked: no \n, no em-dash/en-dash, no {} in labels, subgraphs are id["label"], arrows are -->|"label"|, all subgraphs closed by end, ids unique -->
```mermaid
flowchart LR
    subgraph PresentationLayer["Presentation"]
        cForm["Enquiry Form"]
        cLayout["Application Layout"]
    end
    subgraph BusinessLayer["Business Logic"]
        cController["Enquiries Controller"]
        cValidation["Enquiry Validation"]
    end
    subgraph DataLayer["Data Access"]
        cModel["Enquiry Model"]
        cMigration["Enquiries Migration"]
    end
    subgraph InfrastructureLayer["Infrastructure"]
        cRoutes["Rails Routes"]
        cDatabase[[("PostgreSQL Database")]]
        cHealth["Health Endpoint"]
    end

    cRoutes -->|"maps root and POST"| cController
    cController -->|"renders"| cForm
    cLayout -->|"wraps"| cForm
    cController -->|"builds and saves"| cModel
    cModel -->|"uses"| cValidation
    cModel -->|"persists"| cDatabase
    cMigration -->|"creates schema"| cDatabase
    cHealth -->|"returns HTTP 200"| cRoutes
```

### Component Inventory

| Component | Layer | Type | Responsibility |
|---|---|---|---|
| Enquiry Form | Presentation | ERB view | Collects customer details and message |
| Application Layout | Presentation | ERB layout | Provides page shell, metadata, and stylesheet |
| Enquiries Controller | Business Logic | Rails controller | Handles form display, submission, and redirect |
| Enquiry Validation | Business Logic | Active Record validations | Checks required fields, email, and message length |
| Enquiry Model | Data Access | Active Record model | Represents and persists enquiries |
| Enquiries Migration | Data Access | Rails migration | Defines the enquiries table |
| Rails Routes | Infrastructure | Router | Maps `/` and `/enquiries` requests |
| PostgreSQL Database | Infrastructure | RDS data store | Stores submitted enquiries in production |
| Health Endpoint | Infrastructure | Controller endpoint | Provides `/health` for the load balancer |
