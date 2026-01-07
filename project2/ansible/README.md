Ansible Execution Location: Local Machine
$ ansible-playbook
SSH into 4 EC2 instances (install software)

# Local machine
# Run playbooks
ansible-playbook -i inventory.ini playbooks/worker1.yml
ansible-playbook -i inventory.ini playbooks/worker2.yml
ansible-playbook -i inventory.ini playbooks/worker3_4.yml

