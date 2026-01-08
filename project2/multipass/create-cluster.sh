#!/bin/bash
set -e

multipass delete --purge worker{1..4}  || true
#sleep 3
echo "Creating Project2 Multipass Cluster..."

# Generate SSH keys
mkdir -p ssh-keys
ssh-keygen -t ed25519 -f ssh-keys/multipass_key -N "" -C "project2@multipass" || true

#for node in worker{1..4}; do
for node in worker{1..4}; do
  multipass launch 22.04 --name $node --cpus 2 --memory 4G --disk 20G
# done


# #sleep 30  # Wait for boot
# for node in worker{1..4}; do
  multipass exec $node -- sudo bash -c "cat >> /home/ubuntu/.ssh/authorized_keys" < ssh-keys/multipass_key.pub
  multipass exec $node -- sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys
  multipass exec $node -- sudo chmod 600 /home/ubuntu/.ssh/authorized_keys
done

# Generate Terraform-like outputs
multipass list --format json > output.json
#echo "Cluster ready! IPs in output.json"
echo "IPs:"
jq -r '.list[1:][] | "\(.name): \(.ipv4[0])"' output.json
cat output.json

