# infra-terraform

Create the AWS infrastructure for the todo app (Infrastructure as Code).

## Stack

- Terraform
- AWS (VPC, security group, EC2, IAM, S3 state backend, SSM Parameter Store)

## Modules

| Module | Purpose |
|---|---|
| `state-backend` | S3 + DynamoDB for Terraform remote state |
| `network` | VPC, subnet, IGW, route table |
| `security` | Security group (`22`, `80`, `443`) |
| `compute` | EC2, key pair, IAM role/instance profile |

## Run manually

1. From the repo root (state backend is bootstrapped automatically in the **Build** workflow;
   locally, create S3 + DynamoDB once first if they do not exist — see `modules/state-backend`):

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
| **Build** | Bootstrap S3/DynamoDB → Terraform apply → Ansible → store connection info in SSM |
| **Destroy** | `terraform destroy` + delete SSM instance parameters |

### Required GitHub secrets

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `SSH_PUBLIC_KEY` — used by Terraform for the EC2 key pair
- `SSH_PRIVATE_KEY` — used by Ansible to SSH into the instance

Optional variable: `BUCKET_NAME` (defaults to `todo-app-tfstate-victor`).

## SSM Parameter Store (after Build)

Standard parameters — **free** for this usage. Stored under `/todo-app/`:

| Parameter | Type | Contents |
|---|---|---|
| `/todo-app/ec2_public_ip` | String | EC2 public IP |
| `/todo-app/ec2_public_dns` | String | EC2 public DNS |
| `/todo-app/kubeconfig` | SecureString | k3s kubeconfig (server = `127.0.0.1:6443` for SSH tunnel) |

**Not** stored in SSM (stay in GitHub Secrets): AWS keys, SSH private/public key.

### Read them later

```bash
aws ssm get-parameter --name /todo-app/ec2_public_ip --query Parameter.Value --output text
aws ssm get-parameter --name /todo-app/kubeconfig --with-decryption --query Parameter.Value --output text > ~/.kube/todo-k3s.yaml
```

Then SSH tunnel + `kubectl` as documented in the project notes.

## Notes

- Region: `eu-central-1`
- State backend: S3 + DynamoDB lock table (see `backend.tf`)
- Node OS config (k3s, iptables) lives in the `infra-ansible` repo
- Keep `terraform.tfvars` local — it is gitignored
