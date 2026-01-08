#!/bin/bash
cd ../multipass

# Clear previous
> ../ansible/inventory/dynamic_hosts.ini

jq -r '
  .list[] | 
  select(.name | startswith("worker")) | 
  if .name == "worker1" then
    "[jenkins_master]\n" + (.name + " ansible_host=" + .ipv4[0] + " ansible_user=ubuntu ansible_ssh_private_key_file=../multipass/ssh-keys/multipass_key\n")
  elif .name == "worker2" then
    "[k3s_control_plane]\n" + (.name + " ansible_host=" + .ipv4[0] + " ansible_user=ubuntu ansible_ssh_private_key_file=../multipass/ssh-keys/multipass_key\n")
  elif .name == "worker3" then
    "[worker3]\n" + (.name + " ansible_host=" + .ipv4[0] + " ansible_user=ubuntu ansible_ssh_private_key_file=../multipass/ssh-keys/multipass_key\n")
  elif .name == "worker4" then
    "[worker4]\n" + (.name + " ansible_host=" + .ipv4[0] + " ansible_user=ubuntu ansible_ssh_private_key_file=../multipass/ssh-keys/multipass_key\n")
  else
    "[unknown]\n" + (.name + " ansible_host=" + .ipv4[0] + " ansible_user=ubuntu ansible_ssh_private_key_file=../multipass/ssh-keys/multipass_key\n")
  end
' output.json >> ../ansible/inventory/dynamic_hosts.ini

cat << 'EOF' >> ../ansible/inventory/dynamic_hosts.ini
[k3s_workers:children]
worker3
worker4

[k3s_cluster:children]
k3s_control_plane
k3s_workers

[all_nodes:children]
jenkins_master
k3s_cluster

[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
ansible_python_interpreter=/usr/bin/python3
ansible_become=yes
ansible_become_method=sudo
ansible_become_user=root
k3s_version=stable
EOF

echo "Full inventory:"
cat ../ansible/inventory/dynamic_hosts.ini
