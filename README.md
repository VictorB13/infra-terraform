# infra-terraform

Create the AWS infrastructure for the todo app (Infrastructure as Code).

## Stack

- Terraform
- AWS (VPC, security group, EC2, IAM, S3 state backend)

## Modules

| Module | Purpose |
|---|---|
| `state-backend` | S3 + DynamoDB for Terraform remote state (bootstrap first) |
| `network` | VPC, subnet, IGW, route table |
| `security` | Security group (`22`, `80`, `443`) |
| `compute` | EC2, key pair, IAM role/instance profile |

## Run manually

1. Bootstrap remote state once (from `modules/state-backend` if not already created).

2. From the repo root:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Useful outputs after apply:

- `ec2_public_ip`
- `ec2_public_dns`

## Pipelines / Jobs (trigger from GitHub UI)

| Workflow | Purpose |
|---|---|
| **Build** | Terraform apply → wait for SSH → Ansible (`infra-ansible` site.yml) |
| **Destroy** | `terraform destroy` |

### Required GitHub secrets

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `SSH_PUBLIC_KEY` — used by Terraform for the EC2 key pair
- `SSH_PRIVATE_KEY` — used by Ansible to SSH into the instance
- `ANSIBLE_REPO_TOKEN` — GitHub PAT with read access to `VictorB13/infra-ansible` (required if that repo is private)

Optional variable: `BUCKET_NAME` (defaults to `todo-app-tfstate-victor`).

## Notes

- Region: `eu-central-1`
- State backend: S3 + DynamoDB lock table (see `backend.tf`)
- Node OS config (k3s, iptables) lives in the `infra-ansible` repo
- Keep `terraform.tfvars` local — it is gitignored
