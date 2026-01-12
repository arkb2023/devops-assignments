
## Capstone Project - II:

### **Scenario**  
You are hired as a DevOps Engineer for Analytics Pvt Ltd. This company is a product based organization which uses Docker for their containerization needs within the company. The final product received a lot of traction in the first few weeks of launch. Now with the increasing demand, the organization needs to have a platform for automating deployment, scaling and operations of application containers across clusters of hosts. As a DevOps Engineer, you need to
implement a DevOps lifecycle such that all the requirements are implemented without any change in the Docker containers in the testing environment.  

Up until now, this organization used to follow a monolithic architecture with just 2 developers. The product is present on: https://github.com/hshar/website.git  

**Following are the specifications of the lifecycle:**  
1. Git workflow should be implemented. Since the company follows a monolithic architecture of development, you need to take care of version control. The release should happen only on the 25th of every month.  
2. CodeBuild should be triggered once the commits are made in the master branch.  
3. The code should be containerized with the help of the Dockerfile. The Dockerfile should be built every time if there is a push to GitHub. Create a custom Docker image using a Dockerfile  
4. As per the requirement in the production server, you need to use the Kubernetes cluster and the containerized code from Docker Hub should be deployed with 2 replicas. Create a NodePort service and configure the same for port 30008.  
5. Create a Jenkins Pipeline script to accomplish the above task.  
6. For configuration management of the infrastructure, you need to deploy the configuration on the servers to install necessary software and configurations.  
7. Using Terraform, accomplish the task of infrastructure creation in the AWS cloud provider.  

**Architectural Advice:**  
Softwares to be installed on the respective machines using configuration management.  
- `Worker1:` Jenkins, Java  
- `Worker2:` Docker, Kubernetes  
- `Worker3:` Java, Docker, Kubernetes  
- `Worker4:` Docker, Kubernetes  
---

## 1. Requirements

**Functional Requirements**
- **Infrastructure Provisioning:** Terraform IaC provisions 4 EC2 instances in AWS ap-south-1 with required VPC, subnets, and security groups
- **Configuration Management:** Ansible automates software installation across all workers per architectural specifications (Worker1=jenkins+java, Worker2=k3s-control, Worker3-4=k3s-agents)
- **Git Workflow:** Master branch commits trigger AWS CodeBuild builds; monthly releases occur on the 25th
- **Build Pipeline:** AWS CodeBuild receives GitHub webhook, builds Docker image from `hshar/website` repository, and pushes `hshar/website:latest` to Docker Hub
- **Deployment Pipeline:** Jenkins on Worker1 continuously polls Docker Hub. Upon detecting new `hshar/website:latest` image, Jenkins executes `kubectl set image deployment/website=hshar/website:latest`, triggering automatic rollout to K3s cluster
- **Application Runtime:** 3-node K3s cluster (Worker2=control plane, Worker3-4=agents) runs website Deployment with 2 replicas and NodePort service on port 30008
- **Validation:** Website application serves correctly at `http://worker2-public-ip:30008`

**Non-Functional Requirements**
- **Source Control:** GitHub repository hosts `hshar/website` application source code and Dockerfile
- **Artifact Management:** Docker Hub registry stores versioned `hshar/website` container images
- **Authentication:** GitHub PAT enables CodeBuild GitHub integration; Docker Hub PAT enables Jenkins Docker operations
- **Idempotency:** Terraform and Ansible configurations support repeated execution without side effects
- **Observability:** Jenkins logs at `/var/log/jenkins/jenkins.log`; K3s cluster status via `kubectl get nodes`

---

## 2. High Level Workflow

**Four-phase deployment strategy** transforms bare AWS infrastructure into a fully operational CI/CD pipeline.

### 2.1. AWS Infrastructure Provisioning
- **VPC + EC2 Instances (Terraform IaC)**  One-time execution from local machine provisions- 4 EC2 instances across ap-south-1a/b, VPC with Internet Gateway, public subnets, and security groups (22, 8080, 6443, 30008). Outputs EC2 public IPs for Ansible inventory.

  ![caption](./images/01-terraform-workflow-diagram.png)

- **CodeBuild provisioning (ShellScript + Terraform):**  One-time execution from local machine to provisions IAM role, CodeBuild project `website-build`, and Secrets Manager integration for GitHub PAT + DockerHub credentials. Configures GitHub source (https://github.com/arkb2023/website.git), buildspec.yml, and webhook for master branch push events. Completes Docker image build/push automation prerequisites.

  ![caption](./images/02-codebuild-workflow-diagram.png)

### 2.2. Configuration Management (Ansible)
  
Two-stage Ansible orchestration - Stage1 bootstraps Worker1 as controller, manual SSH bridge enables passwordless access, Stage2 executes 6-phase setup delivering exact software stack (Worker1: Jenkins+Java+Ansible, Worker2: Docker+K3s control, Worker3-4: Docker+K3s agents).

  ![caption](./images/03-ansible-workflow-diagram.png)

### 2.3. End-to-End CI/CD Pipeline (Operational)
  
Recurring automated workflow - GitHub push triggers CodeBuild → DockerHub → Jenkins polling → K3s deployment rollout → website live at NodePort 30008. Zero manual intervention post-setup.

  ![caption](./images/04-cicd-pipeline-diagram.png)

---

## 3. Architecture

The architecture diagram illustrates the end-to-end CI/CD pipeline deployed in AWS ap-south-1, featuring both infrastructure components and operational workflows.

![Arch](./images/main.drawio.png)

**AWS Cloud Resources (ap-south-1):**  
- **Region & Availability Zones:** Deployed across `ap-south-1a` `ap-south-1b`  and `ap-south-1c` for high availability
- **VPC & Networking:** VPC setup featuring **Internet Gateway** for public internet connectivity and **Public Subnet** configured with route table default route (0.0.0.0/0 → IGW)

- **4 EC2 Instances** with required software mapping per specifications:  
  | Worker | Software Stack |
  |--------|---------------|
  | **Worker1 (Controller)** | Jenkins Master, Java, Ansible Controller |
  | **Worker2** | Docker, K3s Control Plane |
  | **Worker3** | Java, Docker, K3s Agent |
  | **Worker4** | Docker, K3s Agent |
- **AWS CodeBuild** for automated Docker image building

**External Services:**
- **GitHub:** [arkb2023/website](https://github.com/arkb2023/website.git) repository for source control with master branch workflow
- **DockerHub:** [arkb2023/website:latest](https://hub.docker.com/repository/docker/arkb2023/website/tags/latest) as centralized container registry


---

## 4. Repository organization:
- Terraform IaC:
  Implementats AWS EC2 infrastructure for 4-workers in ap-south-1. Separates networking (VPC+IGW+public subnets) from compute (4x EC2 instances across ap-south-1a/b/c). Outputs EC2 public IPs for Ansible inventory.

  **Detailed code structure**: [project2/terraform](./terraform/)  
  ```bash
  ├── main.tf              # Root module orchestrates vpc + ec2 modules
  ├── outputs.tf           # EC2 public IPs, VPC ID, security group IDs
  ├── terraform.tfvars     # Environment config (region, AZs, instance type)
  ├── variables.tf         # Input validation + descriptions
  ├── versions.tf          # Provider constraints (aws ~> 5.0)
  └── modules/             # Reusable, self-contained infrastructure modules
      ├── vpc/             # Networking layer
      │   ├── main.tf      # VPC + IGW + public subnets + route tables
      │   ├── outputs.tf   # vpc_id, public_subnet_ids, igw_id
      │   ├── variables.tf # vpc_cidr, public_subnets
      │   └── versions.tf  # Module provider pinning
      └── ec2/             # Compute layer (4 workers)
          ├── main.tf      # 4x EC2 (Worker1-4) + security groups
          ├── outputs.tf   # instance_public_ip, instance_id
          ├── variables.tf # Input validation + descriptions
          └── versions.tf  # Module provider pinning

- Ansible Configuration Management:   
  
  The design follows **2-stage deployment pattern** with **8 modular roles** enabling configuration management of AWS EC2 worker instances.

  - **Stage1:**  
    - **Purpose:** Bootstrap Worker1 as Ansible controller from localhost
    - **Associated Ansible objects:**
      - Inventory: [inventory/stage1-hosts.ini](./ansible/inventory/stage1-hosts.ini) 
      - Playbook: [playbooks/stage1-site.yml](./ansible/playbooks/stage1-site.yml)
      - Role: [roles/controller](./ansible/roles/controller)
    - **Outcome**: Worker1 ready with `ansible-core` (pip), SSH keys distributed, passwordless SSH to workers2-4 established

  - **Stage2:**  
    - **Purpose:** 6-phase orchestration delivering Jenkins + **Containerd CRI K3s cluster**
    - **Associated Ansible objects:**
      - Inventory: [inventory/stage2-hosts.ini](./ansible/inventory/stage2-hosts.ini) 
      - Playbook: [playbooks/stage2-site.yml](./ansible/playbooks/stage2-site.yml)
      - **Roles (8 total):**
        1. [roles/common](./ansible/roles/common) - Base packages (all nodes)
        2. [roles/java](./ansible/roles/java) - OpenJDK 17 (Worker1,3)
        3. [roles/jenkins](./ansible/roles/jenkins) - Jenkins LTS + kubeconfig
        4. [roles/k3s_common](./ansible/roles/k3s_common) - **Containerd CRI** setup
        5. [roles/k3s_control_plane](./ansible/roles/k3s_control_plane) - K3s server
        6. [roles/k3s_worker](./ansible/roles/k3s_worker) - K3s agents  
        7. [roles/kubectl](./ansible/roles/kubectl) - Client + kubeconfig sync
    - **Outcome**: 
      - **Worker1**: Jenkins master (8080), Java 17, kubectl with kubeconfig access
      - **3-node Containerd K3s cluster**:
        | Node | Role | Components |
        |------|------|------------|
        | Worker2 | Control Plane | Containerd + K3s server (6443) |
        | Worker3 | Agent | **Containerd + K3s agent + Java** |
        | Worker4 | Agent | Containerd + K3s agent |

  - **Detailed code structure**: [project2/ansible](./ansible/)  
    ```bash
    ├── ansible.stage1.cfg        # Local execution config
    ├── ansible.stage2.cfg        # SSH execution config  
    ├── generate-inventory.sh     # AWS/Multipass inventory generator
    ├── inventory/
    │   ├── stage1-hosts.ini      # localhost → Worker1
    │   └── stage2-hosts.ini      # 4-node targeting
    ├── playbooks/
    │   ├── stage1-site.yml       # Controller bootstrap
    │   └── stage2-site.yml       # 6-phase deployment
    └── roles/                    # 8 production-grade roles
        ├── common               # curl, git, python3-pip
        ├── controller           # ansible-core + SSH setup (4 tasks)
        ├── java                 # OpenJDK 17 (Worker1,3 per spec)
        ├── jenkins              # Jenkins + kubeconfig fix
        ├── k3s_common           # **Containerd CRI** (containerd.toml.j2)
        ├── k3s_control_plane    # K3s server (Worker2)
        ├── k3s_worker           # K3s agents (Worker3-4)
        └── kubectl              # Client sync from control plane
    ```

- AWS CodeBuild Provisioning Code: [project2/codebuild](./codebuild/)  

  IaC solution provisions **AWS CodeBuild project** (`website-build`) for automated Docker image builds. Bootstrap script `setup-codebuild.sh` creates AWS Secrets Manager entries for GitHub PAT + DockerHub credentials. Terraform module creates IAM role/policy with least-privilege access and fully configured CodeBuild project pointing to `arkb2023/website` GitHub repo.

  **Components:**
  - **Bootstrap Script** `setup-codebuild.sh`: Wraps AWS CLI `aws secretsmanager create-secret` for GitHub PAT + DockerHub PAT storage
  - **Terraform IaC** provisions:
    - **IAM Role** `website-build-service-role` for CodeBuild assume-role
    - **Inline Policy** with granular permissions:
      - **CloudWatch Logs**: `logs:CreateLogGroup`, `CreateLogStream`, `PutLogEvents`
      - **Secrets Manager**: `secretsmanager:GetSecretValue` for `github_token_secret_arn` + `dockerhub_token_secret_arn`
    - **CodeBuild Project** `website-build`:
      | Property | Value |
      |----------|-------|
      | Source | GitHub: `https://github.com/arkb2023/website.git` (main branch) |
      | Buildspec | `buildspec.yml` (Docker build + DockerHub push) |
      | Environment | `aws/codebuild/standard:7.0` + privileged mode |
      | Artifacts | `NO_ARTIFACTS` (pushes directly to DockerHub) |
      | Logs | CloudWatch enabled |

  **Detailed code structure:**
  ```bash
  codebuild/
  ├── setup-codebuild.sh      # Secrets Manager bootstrap (8 steps)
  ├── main.tf                 # Calls codebuild_project module
  ├── terraform.tfvars        # github_token_secret_arn, dockerhub_token_secret_arn
  ├── variables.tf            # project_name, github_repo_url, buildspec_path
  └── modules/
      └── codebuild_project/
          ├── main.tf         # IAM role + CodeBuild resources
          ├── outputs.tf      # Project ARN for webhook setup
          └── variables.tf    # Module inputs with validation
  ```

- Kubernetes Application Rollout: [project2/kubernetes](./kubernetes/)  
  
  Declarative Kubernetes manifests provisioning **website application** with `2 replicas` and external access via **NodePort 30008**. Deployment uses `arkb2023/website:latest` from DockerHub (CodeBuild output). Service exposes port 80 to NodePort 30008 matching security group and Jenkins rollout command (`kubectl set image deployment/website=arkb2023/website:latest`).

  - **Detailed manifest structure:**
    ```bash
    Kubernetes
    ├── website-deployment.yaml  # Deployment: website-dep, 2 replicas, latest image
    └── website-service.yaml     # Service: website-svc, port 80 → NodePort 30008
    ```

- GitHub Application Repository: [arkb2023/website](https://github.com/arkb2023/website.git)  
  **Application repository forked from [hshar/website](https://github.com/hshar/website.git)** per project requirements. Enhanced with complete **CI/CD pipeline configuration** enabling automated GitHub → CodeBuild → DockerHub → Jenkins → K3s workflow.

  **Pipeline Components:**
  - **[Dockerfile](https://github.com/arkb2023/website/blob/main/Dockerfile)**: Containerizes application using `httpd:2.4-alpine` base → `arkb2023/website:latest`
  - **[buildspec.yml](https://github.com/arkb2023/website/blob/main/buildspec.yml)**: AWS CodeBuild configuration using DockerHub PAT from Secrets Manager → builds/pushes image
  - **[Jenkinsfile](https://github.com/arkb2023/website/blob/main/Jenkinsfile)**: Jenkins pipeline polls DockerHub → `kubectl set image deployment/website=arkb2023/website:latest` → verifies `http://localhost:30008`


  **CI/CD Application Repository (Fork + Pipeline)**
  ```
  ├── Dockerfile              # httpd:2.4-alpine → arkb2023/website:latest
  ├── buildspec.yml           # CodeBuild: build → DockerHub push
  ├── jenkinsfile             # Jenkins: poll DockerHub → kubectl rollout
  ├── index.html              # Application entrypoint (port 80)
  └── images/github3.jpg      # Static assets
  ```
### 5. TBD  
<!-- ### 1. Foundation (Infrastructure & Configuration)
### 2. CI Pipeline (CodeBuild + Docker Registry)
### 3. CD Pipeline (Jenkins + Kubernetes Deployment)
### 4: Validation

### 2. Architecture

[REpositoryAccounts Used:]

![Arch](./images/VPC-EC2-network/main-arch.png)

### 1. Solution Overview
Complete DevOps pipeline: GitHub → AWS CodeBuild → Docker Hub → Jenkins → AWS EC2 Kubernetes cluster -> http://<IP>:30008

![caption](./images/VPC-EC2-network/01-high-level-end-to-end-workflow.png)
---


**Playbook:** [playbooks/stage2-site.yml](./ansible/playbooks/stage2-site.yml)
|Groups | Roles |
|---------------------|---------|
| controller | controller, common, jenkins, java, kubectl|[roles/common/tasks/main.yml](./ansible/roles/controller/tasks/main.yml), [roles/common/tasks/main.yml](./ansible/roles/common/tasks/main.yml), [roles/jenkins/tasks/main.yml](./ansible/roles/jenkins/tasks/main.yml),[roles/java/tasks/main.yml](./ansible/roles/java/tasks/main.yml), [roles/kubectl/tasks/main.yml](./ansible/roles/kubectl/tasks/main.yml)
| k3s-cluster | k3s-common | [roles/k3s_common/tasks/main.yml](./ansible/roles/k3s_common/tasks/main.yml)
| k3s_control_plane| k3s_control_plane |[roles/k3s_control_plane/tasks/main.yml](./ansible/roles/k3s_control_plane/tasks/main.yml)
| k3s-workers | k3s_worker |[roles/k3s_worker/tasks/main.yml](./ansible/roles/k3s_worker/tasks/main.yml)

| all nodes | common |


- **Roles:**
  - [controller](./ansible/roles/controller/tasks/main.yml): Role for Ansible core setup
  - [jenkins](./ansible/roles/jenkins/tasks/main.yml): Role for Jenkins setup
  - [java](./ansible/roles/java/tasks/main.yml): Role for Jenkins setup
  - [k3s_common](./ansible/roles/k3s_common/tasks/main.yml): Role for K3s prequisite setup
  - [k3s_control_plane](./ansible/roles/k3s_control_plane/tasks/main.yml): Role for K3s server (control plane) setup
  - [k3s_worker](./ansible/roles/k3s_worker/tasks/main.yml): Role for K3s agent (worker) setup
  - [kubectl](./ansible/roles/kubectl/tasks/main.yml): Role for kubernetes client
  - [common](./ansible/roles/common/tasks/main.yml): Role for supporing required packages

- **Playbooks:**  
  Two playbooks are difined based on ????
  Two playbooks establish a two-stage deployment pipeline architecture, separating controller bootstrapping from 4-node cluster orchestration. Stage1 runs from WSL2/client to worker1(controller), while Stage2 executes from the controller targeting all nodes via SSH keys established in the bridge step

  **Stage1 [Playbook](./ansible/playbooks/stage1-site.yml):**  
  - **Purpose:** Initial Ansible controller setup from client/Ubuntu development system to `Worker1`, enabling 4-node inventory management.
  - **Mapped Role**: The `controller` role installs ansible core and supporting packages.
  - **Outcome**: `Worker1` becomes the central controller with passwordless SSH to workers2-4, ready for `stage2-site.yml` execution.

  **Stage2 [Playbook](./ansible/playbooks/stage2-site.yml):**  
  - **Purpose:** 6-phase orchestration defined across 4 worker nodes, 
      - common packages on all 4 nodes
      - Java/Jenkins on `Worker1` node
      - K3s prereqs:  control plane on `Worker2`, agents on `Worker3-4`
      - kubectl client: kubernetes client CLI on `Worker1`
  - **Mapped Roles**: `common`, `java`, `k3s_common`, `k3s_control_plane`, `k3s_worker`, `kubectl` and `jenkins`
  - **Outcome**: Operational 4 node cluster,
    - `Worker1`: Jenkins master (port 8080) + kubectl with kubeconfig access + Java 17
    - `Worker2`: K3s control plane (6443)
    - `Worker3 & Worker4`: K3s agents (joined K3s cluster)

project2 [main]$ source env.local.sh


1) GitHub repo → CodeBuild Source (GITHUB type)
2) IAM role → secretsmanager:GetSecretValue (PAT secret)
3) CodeBuild fetches PAT, clones repo via GitHub API

project2 [main]$ cd codebuild/
codebuild [main]$ ./setup-codebuild.sh
project2 [main]$ cd ~/workspace/website && echo test >> README.md && git add README.md && git commit -m test && git push origin main

# check the build auto trigger pushes image to dockerhub

multipass [main]$ cd multipass
multipass [main]$ ./create-cluster.sh
multipass [main]$ cd ansible
ansible [main]$ ./generate-inventory.sh
ansible [main]$ ansible all -i inventory/dynamic_hosts.ini -m ping
worker1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
worker4 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
worker2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
worker3 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
ansible [main]$
ansible [main]$ ansible-playbook playbooks/site.yml -i inventory/dynamic_hosts.ini -t common
ansible [main]$ ansible-playbook playbooks/site.yml -i inventory/dynamic_hosts.ini -t jenkins
ansible [main]$ ansible-playbook playbooks/site.yml -i inventory/dynamic_hosts.ini -t k3s-common
ansible [main]$ ansible-playbook playbooks/site.yml -i inventory/dynamic_hosts.ini -t k3s-control-plane
ansible [main]$ ansible-playbook playbooks/site.yml -i inventory/dynamic_hosts.ini -t k3s-worker

# Test:
ansible [main]$ ansible worker2 -i inventory/dynamic_hosts.ini -m shell -a "sudo kubectl get pods -n kube-system"
ansible [main]$ ansible worker2 -i inventory/dynamic_hosts.ini -m shell -a "sudo kubectl get nodes -o wide"
# Does not work!
ansible [main]$ ansible-playbook playbooks/site.yml -i inventory/dynamic_hosts.ini -t   k3s-verify  -vv -->



<!-- Utility/debug commands
ansible [main]$ ansible worker1 -i inventory/dynamic_hosts.ini -m shell -a "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
ansible [main]$ ssh -i ../multipass/ssh-keys/multipass_key ubuntu@10.158.148.234
ansible all -i inventory/dynamic_hosts.ini -m shell -a "ping -c 1 worker2"
ansible [main]$ ansible worker1 -i inventory/dynamic_hosts.ini -m shell -a "sudo systemctl status jenkins | head -20"
ansible [main]$ chromium-browser --no-sandbox --disable-gpu http://10.184.96.51:8080

Jenkins: chromium-browser --no-sandbox --disable-gpu http://10.158.148.119:8080/login?from=%2F -->


```
# From WSL2/Ubuntu (~/project2/ansible)
# STAGE1: Deploy Ansible on controller (worker1)
ansible-playbook playbooks/stage1-site.yml -i inventory/stage1-hosts.ini -vv

# Expected output:
# ansible-core installed
# SSH keypair generated: /home/ubuntu/.ssh/id_rsa (4096-bit)
# Public key saved to: /home/ubuntu/.ssh/controller_pubkey.txt

# SSH bridge
# ----------
# 1: Get controller's public key
cd  ../multipass/
ssh -i ./ssh-keys/multipass_key ubuntu@10.158.148.119 "cat ~/.ssh/id_rsa.pub" > ./ssh-keys/controller_key.pub

# 2: Get actual IPs from multipass
#multipass list --format json | jq -r '.list[] | "\(.name): \(.ipv4[0])"'
multipass [main]$ multipass list --format json | jq -r '.list[] | "\(.name): \(.ipv4[0])"'
worker1: 10.158.148.119
worker3: 10.158.148.234
worker2: 10.158.148.130
worker4: 10.158.148.86
ansible [main]$
# Note IPs for worker2, worker3, worker4
# : Distribute key (replace IPs from multipass list)

# worker2
ssh -i ./ssh-keys/multipass_key ubuntu@10.158.148.130 "echo '$(cat ./ssh-keys/controller_key.pub)' >> ~/.ssh/authorized_keys"
# worker3
ssh -i ./ssh-keys/multipass_key ubuntu@10.158.148.234 "echo '$(cat ./ssh-keys/controller_key.pub)' >> ~/.ssh/authorized_keys"

# worker4
ssh -i ./ssh-keys/multipass_key ubuntu@10.158.148.86 "echo '$(cat ./ssh-keys/controller_key.pub)' >> ~/.ssh/authorized_keys"

# Step 4: Verify from controller
ssh -i ./multipass/ssh-keys/multipass_key ubuntu@10.158.148.119 \
  "ssh -i ~/.ssh/id_rsa ubuntu@10.158.148.120 'whoami'"
# Expected: ubuntu

# 5: Copy project2 to controller
cd ../
# mount in case of multipass
multipass mount project2/ k8s-master:/mnt/repo
# scp in case of AWS
scp -r -i ./multipass/ssh-keys/multipass_key . ubuntu@10.158.148.119:~/project2/

# STAGE2: From Controller ========
# SSH to controller
ssh -i ./multipass/ssh-keys/multipass_key ubuntu@10.158.148.119

# From INSIDE worker1:
cd ~/project2/ansible

# Create stage2 inventory with actual IPs
# Run Stage2
ubuntu@worker1:/mnt/repo/ansible$ ansible-playbook playbooks/stage2-site.yml -i inventory/stage2-hosts.ini -t common -vv
# Stage1 (from WSL2):
cd ~/project2/ansible
ANSIBLE_CONFIG=./ansible.stage1.cfg \
  ansible-playbook playbooks/stage1-site.yml -i inventory/stage1-hosts.ini -vv
# Stage2 (from worker1):
cd ~/project2/ansible
ANSIBLE_CONFIG=./ansible.stage2.cfg \
  ansible-playbook playbooks/stage2-site.yml -i inventory/stage2-hosts.ini -vv


# Verify cluster
kubectl get nodes

cd kubernetes/
kubectl apply -f website-deployment.yaml
kubectl apply -f website-service.yaml
kubectl get deployment website-dep
kubectl get service website-svc
kubectl get pods -l app=website

```
