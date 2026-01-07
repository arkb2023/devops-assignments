Terraform Execution Location: Local Machine
$ terraform apply  
AWS Cloud (creates 4 EC2 instances)


# On local machine (one-time setup)
cd terraform/
terraform init
terraform plan
terraform apply

# Output: 4 EC2 instances created in AWS
# Take note of IP addresses:
# - Worker1-IP: <IP1>
# - Worker2-IP: <IP2>
# - Worker3-IP: <IP3>
# - Worker4-IP: <IP4>

TBD: Set these IPs in Ansible inventory