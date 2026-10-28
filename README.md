# Terraform SonarQube AWS DevSecOps Project

## Overview

This project demonstrates deploying a self-hosted SonarQube Community Edition server on AWS EC2 using Terraform and Docker Compose, then integrating automated code analysis with GitHub Actions.

## Technologies Used

- AWS EC2
- Terraform
- Docker and Docker Compose
- SonarQube Community Edition
- PostgreSQL
- GitHub Actions
- GitHub Secrets
- Linux, DNS, and HTTPS

## Architecture and Workflow

1. Define AWS infrastructure using Terraform.
2. Provision an Ubuntu EC2 instance and supporting networking resources.
3. Deploy SonarQube and PostgreSQL using Docker Compose.
4. Configure a custom domain and HTTPS access.
5. Add the Payment Service source code to the GitHub repository.
6. Configure GitHub Actions secrets for SonarQube authentication.
7. Run automated SonarQube analysis when configured GitHub events occur.
8. Review code-quality findings and quality-gate results.

## GitHub Actions Integration

Workflow file: `.github/workflows/sonarqube-payment.yml`

The workflow analyses the `payment-service` directory using the SonarQube project key `payment-service`.

Authentication is configured through GitHub repository secrets:
- `SONAR_TOKEN`
- `SONAR_HOST_URL`


## Results

The successful analysis demonstrated that GitHub Actions could communicate with SonarQube and complete the configured analysis.

Recorded results:
- Lines of code: 167
- Open issues: 2
- Code duplication: 0.0%
- Reported code coverage: 0.0%
- Quality gate: Passed

A passing quality gate does not guarantee that the code is free of all bugs or security vulnerabilities.

## Challenges and Lessons Learned

- Troubleshot SonarQube project authorization and analysis-token permissions.
- Validated Terraform configuration using `terraform fmt` and `terraform validate`.
- Learned the importance of protecting Terraform state and sensitive configuration files.
- Learned that manually deleting AWS resources can leave Terraform state out of sync.
- Identified the importance of persistent database storage and backups.

## Cleanup and Redeployment

The original AWS resources were manually deleted after testing. The project files remain available for documentation and potential redeployment.

Before redeployment, verify the Terraform configuration, variables, AWS region, and current infrastructure state. Do not reuse an old state file without checking whether its resources still exist.


## Related Application Repository

The Payment Service source code and working GitHub Actions
SonarQube workflow are maintained in my application repository:

[ecommerce-kubernetes-manifests](https://github.com/bisolaadebola/ecommerce-kubernetes-manifests)

The Terraform repository documents the AWS infrastructure
used to host SonarQube and the DevSecOps integration.

## Author

Cloud and DevOps portfolio project demonstrating Infrastructure as Code, containerized deployment, CI/CD integration, and automated code analysis.
