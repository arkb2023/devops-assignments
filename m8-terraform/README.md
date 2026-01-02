

lets incrementally build terraform project for these specs,

--------------
Stage #1:
1) Create an EC2 service in the default subnet in the Ohio region

1. EC2 → Instances → Filter "hello-ec2"
   ✅ Status: 2/2 checks passed, Running
   ✅ AMI: ami-0503ed50b531cc445 (Ubuntu 22.04)
   ✅ Type: t3.micro
   ✅ Public IP: 3.x.x.x (matches terraform output)

2. EC2 → Security Groups → "hello-ec2-sg"
   ✅ Inbound: SSH (22) ← 103.148.39.14/32 ✓
   ✅ VPC: default

3. VPC → Subnets → Default subnet (us-east-2a/b/c)
   ✅ Instance attached to first available


Stage #2
1. Destroy the previous deployment
2. Create a new EC2 instance with an Elastic IP

Stage #3:
1. Destroy the previous deployment
2. Create 2 EC2 instances in Ohio and N.Virginia respectively
3. Rename Ohio’s instance to ‘hello-ohio’ and Virginia’s instance to ‘hello-virginia’

Stage #4:
1. Destroy the previous deployments
2. Create a VPC with the required components using Terraform
3. Deploy an EC2 instance inside the VPC

Stage #5:
1. Destroy the previous deployments
2. Create a script to install Apache2
3. Run this script on a newly created EC2 instance
4. Print the IP address of the instance in a file on the local once deployed

------------

Lets start with stage 1 first. 
Define directory structure it shold be scalable to all stages incrementally
Give the code for stage #1 only. it should be reusable in other stages with incrementally
