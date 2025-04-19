# Smart Vault (Automated EC2 Backups with Terraform) In Progress
An Infrastructure as Code (IaC) solution to automate EC2 snapshots and manage retention.

## Features
- Snapshots only EC2 instances tagged with `Backup=True`
- Scheduled via EventBridge (daily 03:00 UTC)
- Lambda handles snapshot logic and tagging
- Fully deployed using Terraform
- (In Progress) SNS alerts on backup success/failure
- (In Progress) Extendable to S3 or cross-region workflows

## Tech Stack
- **AWS Lambda**
- **AWS EventBridge**
- **AWS EC2 & EBS Snapshots**
- **Terraform (IaC)**
- **AWS IAM**
- **AWS SNS** (optional)
- **Ubuntu CLI (via WSL)**

## Outcome
A cost-efficient, secure, and repeatable EC2 backup system that can be deployed in minutes via Terraform and run serverlessly on a schedule.

## In Progress
- [ ] Add retention logic for old snapshots (cleanup policy)
- [ ] Integrate CloudWatch Logs for visibility
- [ ] Create architecture diagram for documentation
- [ ] Write unit tests for Lambda function
