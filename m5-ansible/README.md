### Ansible projects  

**Cluster Setups:**  
1. [Cluster: 3-Node Setup](./setup-3-nodes/README.md)  
2. [Cluster: 5-Node Setup](./setup-5-nodes/README.md)

---

**Assignments:**  
1. [Basic Playbook](./a01/README.md)  
2. [Copy Module](./a02/README.md)  
3. [Apache + Nginx Roles](./a03/README.md)  
4. [Custom NGINX Index](./a04/README.md)  
5. [5-Node Java + MySQL](./a05/README.md)  

---

**[m5-ansible/](../m5-ansible/) code organization:**  
<pre>
# --------- Module 5 Root folder ----------------------------------
m5-ansible/  
├── README.md                          # Master TOC + assignments
├── ansible.cfg                        # Global Ansible config
└── inventory/
    ├── hosts-3node.ini                # A1-A4 cluster IPs/groups
    └── hosts-5node.ini                # A5 cluster IPs/groups
# ---------- 3 & 5 Node cluster setup ------------------------------
├── setup-3-nodes                      # 3-node cluster setup
│   └── README.md                      
├── setup-5-nodes                      # 5-node cluster setup 
│   └── README.md        

# ------------ Reusable Roles --------------------------------------
├── roles/                             # Reusable roles
│   ├── apache2/
│   │   ├── tasks/main.yml             # Apache2 install/start
│   ├── java/
│   │   ├── tasks/main.yml             # OpenJDK 11 install
│   ├── mysql/
│   │   ├── tasks/main.yml             # MySQL install/start/enable
│   └── nginx/
│       ├── tasks/main.yml             # NGINX install/start
│       ├── handlers/main.yml          # NGINX restart handler
│       └── files/index.html           # A4 custom index

# ------------ Assignment #1 --------------------------------------
├── a01/                                Basic playbook
│   ├── README.md                      # Steps + screenshots
│   ├── images/                        # Proof screenshots
│   └── site.yml                       # Single play: all hosts

# ------------ Assignment #2 --------------------------------------
├── a02/                               # Copy module
│   ├── README.md
│   ├── files/add-text.sh              # Source script
│   ├── images/
│   └── site.yml                       # Copy task

# ------------ Assignment #3 -------------------------------------
├── a03/                               # Roles intro
│   ├── README.md
│   ├── images/
│   └── site.yml                       # Multi-play: apache(slave1), nginx(slave2)

# ------------ Assignment #4 -------------------------------------
├── a04/                               # Custom files
│   ├── README.md
│   └── images/                        # Screenshots

# ------------ Assignment #5 -------------------------------------
├── a05/                               # Groups + multi-role
│   ├── README.md
│   ├── images/                        # Screenshots
│   └── site.yml                       # Multi-play: java(test), mysql(prod)
</pre>

---