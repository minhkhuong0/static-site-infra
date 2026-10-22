This is the IaC for my [continuously deployed static website](https://github.com/minhkhuong0/portfolio): [nhmk.de](https://nhmk.de)
## Terraform provisions the following resources:
- AWS: EC2 t3.micro Instance with debian, Security Group, VPC with public a subnet, IAM role for SSM, S3 bucket for staging
- Cloudflare: DNS records for www and root, Page rule to redirect root to www, Page rule to activate flexible SSL
- Outputs EC2 instance ID and public IP
## Ansible roles:
- common: Sets timezone, upgrades
- docker: Adds the Docker repo, installs the packages and add ssm-user to the docker group
- nginx: Deploys the docker-compose.yaml with NGINX to the EC2 using SSM and runs docker compose up
