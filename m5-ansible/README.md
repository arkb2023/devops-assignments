Ansible Assignment - 1
  Tasks To Be Performed:
  1. Setup Ansible cluster with 3 nodes
  2. On slave 1 install Java
  3. On slave 2 install MySQL server
  Do the above tasks using Ansible Playbooks

Ansible Assignment - 2
  Tasks To Be Performed:
  1. Create a script which can add text “This text has been added by custom script” to /tmp.1.txt
  2. Run this script using Ansible on all the hosts

Ansible Assignment - 3
Tasks To Be Performed:
1. Create 2 Ansible roles
2. Install Apache2 on slave1 using one role and NGINX on slave2 using the other role
3. Above should be implemented using different Ansible roles

Ansible Assignment - 4
Tasks To Be Performed:
1. Use the previous deployment of Ansible cluster
2. Configure the files folder in the role with index.html which should be replaced with the original index.html
All of the above should only happen on the slave which has NGINX installed using the role.

Ansible Assignment - 5
Tasks To Be Performed:
1. Create a new deployment of Ansible cluster of 5 nodes
2. Label 2 nodes as test and other 2 as prod
3. Install Java on test nodes
4. Install MySQL server on prod nodes
Use Ansible roles for the above and group the hosts under test and prod


ansible-assignments/
├── ansible.cfg                  # Global config: inventory=inventory/, roles_path=roles/
├── inventory/
│   ├── hosts-3node.ini         # Assignment 1-4: [control], [slave1], [slave2]
│   └── hosts-5node.ini         # Assignment 5: [control], [test:children], [prod:children]
├── group_vars/                 # Shared vars (e.g., all.yml for common packages)
│   └── all.yml
├── roles/                      # Reusable roles
│   ├── java/
│   │   ├── tasks/main.yml      # apt: name=openjdk-11-jdk state=present
│   │   ├── handlers/main.yml   # service restart if needed
│   │   └── vars/main.yml
│   ├── mysql/
│   │   ├── tasks/main.yml      # apt: name=mysql-server, debconf tasks
│   │   └── handlers/main.yml   # service mysql start/enabled
│   ├── apache2/
│   │   ├── tasks/main.yml      # apt: apache2, service enabled
│   │   └── templates/          # Optional index.html.j2
│   └── nginx/
│       ├── tasks/main.yml      # apt: nginx, service enabled
│       ├── files/index.html    # Custom index for Assignment 4
│       └── handlers/main.yml
├── assignment-1/
│   ├── site.yml                # Playbook: hosts=all, tasks for slave1 java, slave2 mysql
│   ├── README.md               # Solution overview, execution, screenshots
│   └── images/                 # java -version, mysql --version outputs
├── assignment-2/
│   ├── files/add-text.sh       # #!/bin/bash echo "This text..." >> /tmp/1.txt
│   ├── site.yml                # script: src=files/add-text.sh
│   └── README.md
├── assignment-3/
│   ├── site.yml                # import_role: java on slave1? Wait, apache/nginx roles
│   └── README.md
├── assignment-4/
│   ├── site.yml                # Target nginx hosts, copy files/index.html to /var/www/html/
│   └── README.md
└── assignment-5/
    ├── site.yml                 # groups: test, prod; roles on respective groups
    └── README.md
