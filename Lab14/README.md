# 🧪 Lab 14 – Terraform + Ansible: Dynamic Inventory, Roles & Automated Nginx/PHP & Docker Deployment

Estimated Duration: 3 hours  
Instructions: Complete all tasks using a **GitHub Codespace (Linux environment)** created and authenticated with the GitHub CLI. A repository named `Lab14` must be used as your working directory inside the Codespace. When finished, push your work to a repository named:

`CC_<student_Name>_<student_roll_number>/Lab14`

> **Important:**  
> - All steps that require GH CLI / Codespace MUST be performed inside the **Codespace shell**.  
> - Use a Codespace image (or dev container) that has **AWS CLI** and **Terraform** pre‑installed (or install them yourself in the Codespace).  
> - Do **not** authenticate GH CLI / AWS CLI outside the Codespace shell.  
> - Do **not** commit secrets, private keys, or Terraform state.

---

## 🎯 Objective

In this lab you will:

- Use **GitHub Codespaces** or **GH CLI** as your development environment.
- Clone and work with an existing Terraform + Ansible project.
- Use Terraform to provision EC2 instances and security groups.
- Use Ansible to:
  - Manage static and dynamic hosts inventories (including `aws_ec2` plugin).
  - Configure Nginx and HTTPS with self‑signed certificates.
  - Deploy a PHP web app via roles.
  - Install Docker and Docker Compose.
  - Deploy a Dockerized **Gitea** application.
- Automate Ansible execution from Terraform using a `null_resource`.
- Organize your Ansible code using **roles** (`nginx`, `ssl`, `webapp`).

---

## Task List

In this lab you will:

- [Task 0 – Lab Setup (Codespace & GH CLI)](#task-0--lab-setup-codespace--gh-cli)
- [Task 1 – Generate ssh key and Initial Terraform apply](#task-1--generate-ssh-key-and-initial-terraform-apply)
- [Task 2 – Static Ansible inventory with two EC2 instances](#task-2--static-ansible-inventory-with-two-ec2-instances)
- [Task 3 – Scale to three instances & group-based inventory](#task-3---scale-to-three-instances--group-based-inventory)
- [Task 4 – Global ansible.cfg & first nginx playbook](#task-4--global-ansiblecfg--first-nginx-playbook)
- [Task 5 – Single nginx target group & HTTPS prerequisites](#task-5--single-nginx-target-group--https-prerequisites)
- [Task 6 – Ansible-managed SSL certificates](#task-6---ansible-managed-ssl-certificates)
- [Task 7 – PHP front-end deployment with templates](#task-7---php-front-end-deployment-with-templates)
- [Task 8 – Docker & Docker Compose provisioning via Ansible](#task-8--docker--docker-compose-provisioning-via-ansible)
- [Task 9 – Gitea Docker stack via Ansible + Terraform security group update](#task-9--gitea-docker-stack-via-ansible--terraform-security-group-update)
- [Task 10 – Automating Ansible with Terraform (null_resource)](#task-10--automating-ansible-with-terraform-null_resource)
- [Task 11 – Dynamic inventory with aws_ec2 plugin](#task-11--dynamic-inventory-with-aws_ec2-plugin)
- [Task 12 – Filtering EC2 instances by tags & instance type](#task-12--filtering-ec2-instances-by-tags--instance-type)
- [Task 13 – Ansible roles: nginx, ssl, webapp](#task-13--ansible-roles-nginx-ssl-webapp)
- [Cleanup](#cleanup)
- [Submission](#submission)




---

## Task 0 – Lab Setup (Codespace & GH CLI)

1. Fork the repo [terraform_machine](https://github.com/WaqasSaleem97/terraform_machine.git)
2. **Create/open Codespace** on your GitHub account (from `terraform_machine` repo).  
   - **Save screenshot as:** `task0_codespace_open.png` — browser showing the Codespace opened.

3. Inside the Codespace terminal, verify:

```bash
aws --version
terraform --version
ansible --version || echo "ansible not yet installed"
```

- **Save screenshot as:** `task0_env_check.png` — Codespace terminal showing `aws --version`, `terraform -version`, and `ansible --version` or the “not installed yet” message.

3. Ensure AWS CLI is configured with credentials that have permissions to create EC2, VPC, subnets, and security groups in region **`me-central-1`**:

```bash
aws sts get-caller-identity
```

- **Save screenshot as:** `task0_aws_config.png` — output of `aws sts get-caller-identity`.

**Screenshots Required:**
- `task0_codespace_open.png`
- `task0_env_check.png`
- `task0_aws_config.png`

---

## Task 1 – Generate ssh key and Initial Terraform apply

You will start from an existing repository and prepare Terraform variables and SSH keys.

1. **Check SSH directory & generate SSH key pair** if not already present:

```bash
ls ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
ls -la ~/.ssh
```

- **Save screenshot as:** `task1_ssh_keygen_before.png` — `ls ~/.ssh` before key generation.
- **Save screenshot as:** `task1_ssh_keygen.png` — output of `ssh-keygen` command.
- **Save screenshot as:** `task1_ssh_keygen_after.png` — `ls -la ~/.ssh` showing `id_ed25519` and `id_ed25519.pub`.

2. **Create `terraform.tfvars`** in the repo root:

```bash
cd /workspaces/terraform_machine
touch terraform.tfvars
ls -la terraform.tfvars
```

- **Save screenshot as:** `task1_terraform_tfvars_created.png` — `touch terraform.tfvars` and `ls -la terraform.tfvars`.

Add the following content:

```hcl
vpc_cidr_block = "10.0.0.0/16"
subnet_cidr_block = "10.0.10.0/24"
availability_zone = "me-central-1a"
env_prefix = "dev"
instance_type = "t3.micro"
public_key = "~/.ssh/id_ed25519.pub"
private_key = "~/.ssh/id_ed25519"
```

- **Save screenshot as:** `task1_terraform_tfvars.png` — content of `terraform.tfvars`.

3. **Initialize Terraform**:

```bash
terraform init
```

- **Save screenshot as:** `task1_terraform_init.png` — `terraform init` output.

4. **Apply Terraform** to create **2 EC2 instances** (as defined in the existing Terraform code):

```bash
terraform apply -auto-approve
```

- **Save screenshot as:** `task1_terraform_apply_2_instances.png` — `terraform apply` output showing 2 instances created.

5. **Check outputs**:

```bash
terraform output
```

- **Save screenshot as:** `task1_terraform_output_ips.png` — `terraform output` showing instance IPs.

**Screenshots Required:**
- `task1_ssh_keygen_before.png`
- `task1_ssh_keygen.png`
- `task1_ssh_keygen_after.png`
- `task1_terraform_tfvars_created.png`
- `task1_terraform_tfvars.png`
- `task1_terraform_init.png`
- `task1_terraform_apply_2_instances.png`
- `task1_terraform_output_ips.png`

---

## Task 2 – Static Ansible inventory with two EC2 instances

You will install Ansible (via `pipx`), create a static inventory, and verify connectivity.

1. **Install Ansible (core) using pipx**:

```bash
pipx install ansible-core
ansible --version
```

- **Save screenshot as:** `task2_ansible_install.png` — `pipx install ansible-core` and `ansible --version` output.

2. **Obtain the two public IPs** of your EC2 instances:

```bash
terraform output
```

- **Save screenshot as:** `task2_terraform_output_ips.png` — `terraform output` listing at least 2 EC2 public IPs.

3. **Create Ansible inventory file `hosts`**:

```bash
touch hosts
ls -la hosts
```

- **Save screenshot as:** `task2_hosts_created.png` — confirmation that `hosts` file exists.

Add the following (**replace `<public-ip-ec2>` with your 2 real IPs**):

```ini
<public-ip-ec2>	ansible_user=ec2-user	ansible_ssh_private_key_file=~/.ssh/id_ed25519
<public-ip-ec2>	ansible_user=ec2-user	ansible_ssh_private_key_file=~/.ssh/id_ed25519
```

- **Save screenshot as:** `task2_hosts_initial.png` — content of `hosts` with two IP lines.

4. **Test connectivity**:

```bash
ansible all -i hosts -m ping
```

- **Save screenshot as:** `task2_ansible_ping_initial.png` — initial `ansible all -i hosts -m ping` output (success or failure).

5. If it fails due to host key checking, **add** this to each line in `hosts`:

```ini
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

- **Save screenshot as:** `task2_hosts_with_common_args.png` — `hosts` content with `ansible_ssh_common_args` added.

6. Retry:

```bash
ansible all -i hosts -m ping
```

- **Save screenshot as:** `task2_ansible_ping_success.png` — successful ping output.

**Screenshots Required:**
- `task2_ansible_install.png`
- `task2_terraform_output_ips.png`
- `task2_hosts_created.png`
- `task2_hosts_initial.png`
- `task2_ansible_ping_initial.png`
- `task2_hosts_with_common_args.png`
- `task2_ansible_ping_success.png`

---

## Task 3 - Scale to three instances & group-based inventory

You will expand to 3 web servers via Terraform’s `count` and restructure your inventory into groups.

1. **Update your Terraform module for webservers** in `main.tf` to use `count = 3`:

```hcl
module "myapp-webserver" {
  source            = "./modules/webserver"
  env_prefix        = var.env_prefix
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  public_key        = var.public_key
  my_ip             = local.my_ip
  vpc_id            = aws_vpc.myapp_vpc.id
  subnet_id         = module.myapp-subnet.subnet.id

  # Loop count
  count           = 3
  # Use count.index to differentiate instances
  instance_suffix = count.index
}
```

- **Save screenshot as:** `task3_main_tf_count_3.png` — `main.tf` snippet showing `count = 3`.

2. **Apply Terraform** to get 3 instances:

```bash
terraform apply -auto-approve
```

- **Save screenshot as:** `task3_terraform_apply_3_instances.png` — terraform apply output creating 3 instances.

3. **Check outputs**:

```bash
terraform output
```

- **Save screenshot as:** `task3_terraform_output_3_ips.png` — `terraform output` listing 3 public IPs.

4. **Rewrite your `hosts` file** using group definitions:

```ini
[ec2]
<public-ip-ec2>
<public-ip-ec2>

[ec2:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[droplet]
<public-ip-third-ec2>

[droplet:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

- **Save screenshot as:** `task3_hosts_grouped.png` — `hosts` showing `[ec2]` and `[droplet]` with three IPs.

5. **Test group connectivity**:

```bash
ansible ec2 -i hosts -m ping
```

- **Save screenshot as:** `task3_ansible_ec2_ping.png` — output of `ansible ec2 -i hosts -m ping`.

6. **Test single host by IP**:

```bash
ansible <one-public-ip-from-ec2-group> -i hosts -m ping
```

- **Save screenshot as:** `task3_ansible_single_ip_ping.png` — ping output for one EC2 IP.

7. **Test droplet group**:

```bash
ansible droplet -i hosts -m ping
```

- **Save screenshot as:** `task3_ansible_droplet_ping.png` — ping output for `droplet` group.

8. **Test all hosts**:

```bash
ansible all -i hosts -m ping
```

- **Save screenshot as:** `task3_ansible_all_ping.png` — ping output for all instances.

**Screenshots Required:**
- `task3_main_tf_count_3.png`
- `task3_terraform_apply_3_instances.png`
- `task3_terraform_output_3_ips.png`
- `task3_hosts_grouped.png`
- `task3_ansible_ec2_ping.png`
- `task3_ansible_single_ip_ping.png`
- `task3_ansible_droplet_ping.png`
- `task3_ansible_all_ping.png`

---

## Task 4 – Global ansible.cfg & first nginx playbook

You will configure a **global Ansible configuration file**, then create a basic playbook for nginx.

1. **Create global Ansible configuration**:

```bash
vim ~/.ansible.cfg
```

Add:

```ini
[default]
host_key_checking = False
interpreter_python = /usr/bin/python3
```

- **Save screenshot as:** `task4_global_ansible_cfg.png` — content of `~/.ansible.cfg`.

2. **Remove `ansible_ssh_common_args`** from `hosts` (delete from all groups).  
   - **Save screenshot as:** `task4_hosts_without_common_args.png` — `hosts` after removal.

3. **Confirm connectivity**:

```bash
ansible all -i hosts -m ping
```

- **Save screenshot as:** `task4_ansible_ping_after_cfg.png` — ping output showing success, no strict host checking warning.

4. **Create `my-playbook.yaml`**:

```bash
touch my-playbook.yaml
ls -la my-playbook.yaml
```

- **Save screenshot as:** `task4_my_playbook_created.png` — existence of `my-playbook.yaml`.

Add:

```yaml
---
- name: Configure nginx web server
  hosts: ec2
  become: true
  tasks:
    - name: install nginx and update cache
      yum:
        name: nginx
        state: present
        update_cache: yes

    - name: start nginx server
      service:
        name: nginx
        state: started
```

- **Save screenshot as:** `task4_my_playbook_ec2.png` — content of `my-playbook.yaml` with `hosts: ec2`.

5. **Run the playbook** on `[ec2]` group:

```bash
ansible-playbook -i hosts my-playbook.yaml
```

- **Save screenshot as:** `task4_ansible_play_ec2.png` — playbook output for `ec2` group.

6. **Verify** nginx default page on `[ec2]` servers by visiting `http://<public-ip-ec2>`.  
   - **Save screenshot as:** `task4_nginx_browser_ec2.png` — browser showing nginx default page for an `ec2` instance.

7. **Change target to droplet**:

Edit `my-playbook.yaml` to:

```yaml
  hosts: droplet
```

- **Save screenshot as:** `task4_my_playbook_droplet.png` — playbook with `hosts: droplet`.

8. Re-run:

```bash
ansible-playbook -i hosts my-playbook.yaml
```

- **Save screenshot as:** `task4_ansible_play_droplet.png` — output of playbook for `droplet` group.

9. Verify nginx default page on droplet:  
   - **Save screenshot as:** `task4_nginx_browser_droplet.png` — browser showing nginx page on `droplet`.

**Screenshots Required:**
- `task4_global_ansible_cfg.png`
- `task4_hosts_without_common_args.png`
- `task4_ansible_ping_after_cfg.png`
- `task4_my_playbook_created.png`
- `task4_my_playbook_ec2.png`
- `task4_ansible_play_ec2.png`
- `task4_nginx_browser_ec2.png`
- `task4_my_playbook_droplet.png`
- `task4_ansible_play_droplet.png`
- `task4_nginx_browser_droplet.png`

---

## Task 5 – Single nginx target group & HTTPS prerequisites

You will prepare **project‑level Ansible configuration** and adjust nginx installation scope.

1. **Create project‑level `ansible.cfg`** in repo root:

```bash
touch ansible.cfg
ls -la ansible.cfg
```

- **Save screenshot as:** `task5_project_ansible_cfg_created.png` — project `ansible.cfg` presence.

Add:

```ini
[defaults]
host_key_checking=False
interpreter_python = /usr/bin/python3
```

- **Save screenshot as:** `task5_project_ansible_cfg.png` — project-level `ansible.cfg` content.

2. **Switch Terraform EC2 count back to 1**:

In `main.tf`:

```hcl
count = 1
```

- **Save screenshot as:** `task5_main_tf_count_1.png` — snippet showing `count = 1`.

3. Apply:

```bash
terraform apply -auto-approve
```

- **Save screenshot as:** `task5_terraform_apply_one_instance.png` — apply output with one instance.

4. Outputs:

```bash
terraform output
```

- **Save screenshot as:** `task5_terraform_output_single_ip.png` — single EC2 public IP.

5. **Adjust `hosts`**:

```ini
[nginx]
<single-public-ip>

[nginx:vars]
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_user=ec2-user
```

- **Save screenshot as:** `task5_hosts_nginx_group.png` — hosts file for `[nginx]`.

6. **Update `my-playbook.yaml`**:

```yaml
---
- name: Configure nginx web server
  hosts: nginx
  become: true
  tasks:
    - name: install nginx and update cache
      yum:
        name: nginx
        state: present
        update_cache: yes

    - name: install openssl
      yum:
        name: openssl
        state: present

    - name: start nginx server
      service:
        name: nginx
        state: started
        enabled: true
```

- **Save screenshot as:** `task5_my_playbook_nginx_group.png` — playbook with `hosts: nginx`.

7. **Run the playbook**:

```bash
ansible-playbook -i hosts my-playbook.yaml
```

- **Save screenshot as:** `task5_ansible_play_nginx_group.png` — playbook output.

8. **Verify nginx default page** at `http://<public-ip>`.  
   - **Save screenshot as:** `task5_nginx_browser_single.png` — browser view.

**Screenshots Required:**
- `task5_project_ansible_cfg_created.png`
- `task5_project_ansible_cfg.png`
- `task5_main_tf_count_1.png`
- `task5_terraform_apply_one_instance.png`
- `task5_terraform_output_single_ip.png`
- `task5_hosts_nginx_group.png`
- `task5_my_playbook_nginx_group.png`
- `task5_ansible_play_nginx_group.png`
- `task5_nginx_browser_single.png`

---

## Task 6 - Ansible-managed SSL certificates

Extend your playbook to generate **self‑signed SSL certificates** using dynamic public IP.

1. Append this play after the nginx play in `my-playbook.yaml`:

```yaml
- name: Configure SSL certificates
  hosts: nginx
  become: true
  tasks:
    - name: Create SSL private directory
      file:
        path: /etc/ssl/private
        state: directory
        mode: '0700'

    - name: Create SSL certs directory
      file:
        path: /etc/ssl/certs
        state: directory
        mode: '0755'

    - name: Get IMDSv2 token
      uri:
        url: "http://169.254.169.254/latest/api/token"
        method: PUT
        headers:
          X-aws-ec2-metadata-token-ttl-seconds: "3600"
        return_content: yes
      register: imdsv2_token

    - name: Get current public IP
      uri:
        url: "http://169.254.169.254/latest/meta-data/public-ipv4"
        headers:
          X-aws-ec2-metadata-token: "{{ imdsv2_token.content }}"
        return_content: yes
      register: public_ip

    - name: Show current public IP
      debug:
        msg: "Public IP: {{ public_ip.content }}"

    - name: Generate self-signed SSL certificate
      command: >
        openssl req -x509 -nodes -days 365
        -newkey rsa:2048
        -keyout /etc/ssl/private/selfsigned.key 
        -out /etc/ssl/certs/selfsigned.crt 
        -subj "/CN={{ public_ip.content }}" 
        -addext "subjectAltName=IP:{{ public_ip.content }}" 
        -addext "basicConstraints=CA:FALSE"
        -addext "keyUsage=digitalSignature,keyEncipherment"
        -addext "extendedKeyUsage=serverAuth"
      args:
        creates: /etc/ssl/certs/selfsigned.crt
```

- **Save screenshot as:** `task6_my_playbook_ssl_section.png` — SSL block in `my-playbook.yaml`.

2. Run:

```bash
ansible-playbook -i hosts my-playbook.yaml
```

- **Save screenshot as:** `task6_ansible_play_ssl.png` — SSL tasks output.

3. SSH and verify:

```bash
ssh ec2-user@<public-ip> -i ~/.ssh/id_ed25519
sudo cat /etc/ssl/certs/selfsigned.crt
sudo cat /etc/ssl/private/selfsigned.key
exit
```

- **Save screenshot as:** `task6_ssl_cert_file.png` — `cat /etc/ssl/certs/selfsigned.crt`.
- **Save screenshot as:** `task6_ssl_key_file.png` — `cat /etc/ssl/private/selfsigned.key`.

**Screenshots Required:**
- `task6_my_playbook_ssl_section.png`
- `task6_ansible_play_ssl.png`
- `task6_ssl_cert_file.png`
- `task6_ssl_key_file.png`

---

## Task 7 - PHP front-end deployment with templates

Deploy a PHP application and Nginx configuration using Ansible `copy` and `template`.

1. **Create directories and files**:

```bash
mkdir -p files templates
touch files/index.php
touch templates/nginx.conf.j2
ls -R
```

- **Save screenshot as:** `task7_files_templates_created.png` — `ls -R` showing `files/index.php` and `templates/nginx.conf.j2`.

2. **Fill `files/index.php`** with the following PHP metadata page:

```php
<?php
// Get hostname
$hostname = gethostname();

// Deployment date
$deployed_date = date("Y-m-d H:i:s");

// Metadata base URL
$metadata_base = "http://169.254.169.254/latest/";

// Function to get IMDSv2 token
function getImdsV2Token() {
    $ch = curl_init("http://169.254.169.254/latest/api/token");
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_CUSTOMREQUEST  => "PUT",
        CURLOPT_HTTPHEADER     => [
            "X-aws-ec2-metadata-token-ttl-seconds: 21600"
        ],
        CURLOPT_TIMEOUT        => 2
    ]);

    $token = curl_exec($ch);
    curl_close($ch);

    return $token ?: null;
}

// Function to fetch metadata using token
function getMetadata($path, $token) {
    $url = "http://169.254.169.254/latest/meta-data/" . $path;

    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER     => [
            "X-aws-ec2-metadata-token: $token"
        ],
        CURLOPT_TIMEOUT        => 2
    ]);

    $value = curl_exec($ch);
    curl_close($ch);

    return $value ?: "N/A";
}

// Fetch token
$token = getImdsV2Token();

// Fetch metadata only if token is available
$instance_id = $token ? getMetadata("instance-id", $token) : "N/A";
$private_ip  = $token ? getMetadata("local-ipv4", $token) : "N/A";
$public_ip   = $token ? getMetadata("public-ipv4", $token) : "N/A";
$public_dns  = $token ? getMetadata("public-hostname", $token) : "N/A";
?>
<!DOCTYPE html>
<html>
<head>
    <title>Frontend Web Server</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255, 255, 255, 0.1);
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
        }
        h1 {
            color: #fff;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .info {
            margin: 15px 0;
            padding: 10px;
            background: rgba(255,255,255,0.2);
            border-radius: 5px;
        }
        .label {
            font-weight: bold;
            color: #ffd700;
        }
        .info a {
            color: white;           /* same as other values */
            text-decoration: none;  /* remove underline */
            font-weight: normal;
        }

        .info a:hover {
            text-decoration: underline; /* optional: underline on hover */
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Nginx Front End Web Server </h1>

        <div class="info"><span class="label">Hostname:</span> <?= htmlspecialchars($hostname) ?></div>
        <div class="info"><span class="label">Instance ID:</span> <?= htmlspecialchars($instance_id) ?></div>
        <div class="info"><span class="label">Private IP:</span> <?= htmlspecialchars($private_ip) ?></div>
        <div class="info"><span class="label">Public IP:</span> <?= htmlspecialchars($public_ip) ?></div>
        <div class="info"><span class="label">Public DNS:</span>
            <a href="https://<?= htmlspecialchars($public_dns) ?>" target="_blank">
            https://<?= htmlspecialchars($public_dns) ?></a>
        </div>
        <div class="info"><span class="label">Deployed:</span> <?= $deployed_date ?></div>
        <div class="info"><span class="label">Status:</span> ✅ Active and Running</div>
        <div class="info"><span class="label">Managed By:</span> Terraform + Ansible</div>
    </div>
</body>
</html>
```

- **Save screenshot as:** `task7_index_php_content.png` — content of `files/index.php` in editor or `cat`.

3. **Fill `templates/nginx.conf.j2`** with the following Nginx configuration template:

```nginx
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request"'
                      '$status $body_bytes_sent "$http_referer"'
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    upstream backend_servers {
        server 158.252.94.241:80;
        server 158.252.94.242:80 backup;
    }

    server {
        listen 443 ssl;
        server_name {{ server_public_ip }};
        ssl_certificate /etc/ssl/certs/selfsigned.crt;
        ssl_certificate_key /etc/ssl/private/selfsigned.key;

        location / {
            root /usr/share/nginx/html;
            index index.php index.html index.htm;
    #       proxy_pass http://158.252.94.241:80;
    #       proxy_pass http://backend_servers;

            # 🔴 This block is necessary for Php Website
            location ~ \.php$ {
                include fastcgi_params;
                fastcgi_pass unix:/run/php-fpm/www.sock;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            }
        }
    }

    server {
        listen 80;
        server_name _;
        return 301 https://$host$request_uri;
    }
}
```

- **Save screenshot as:** `task7_nginx_conf_template.png` — content of `templates/nginx.conf.j2`.

4. **Add this play to `my-playbook.yaml`**:

```yaml
- name: Deploy Nginx website and configuration files
  hosts: nginx
  become: true
  tasks:
    - name: install php-fpm and php-curl
      yum:
        name:
          - php-fpm
          - php-curl
        state: present

    - name: Copy website files
      copy:
        src: files/index.php
        dest: /usr/share/nginx/html/index.php
        owner: nginx
        group: nginx
        mode: '0644'

    - name: Copy nginx.conf template
      template:
        src: templates/nginx.conf.j2
        dest: /etc/nginx/nginx.conf
        owner: root
        group: root
        mode: '0644'

    - name: Restart nginx
      service:
        name: nginx
        state: restarted

    - name: Start and enable php-fpm
      service:
        name: php-fpm
        state: started
        enabled: true
```

- **Save screenshot as:** `task7_my_playbook_web_deploy.png` — updated `my-playbook.yaml` including this play.

5. **Run the playbook**:

```bash
ansible-playbook -i hosts my-playbook.yaml
```

- **Save screenshot as:** `task7_ansible_play_web_deploy.png` — playbook output showing PHP/nginx tasks executed.

6. Visit `https://<public-ip>`:
   - Accept SSL warning.
   - Verify the PHP page content.

- **Save screenshot as:** `task7_php_https_browser.png` — browser showing PHP web page via HTTPS.

**Screenshots Required:**
- `task7_files_templates_created.png`
- `task7_index_php_content.png`
- `task7_nginx_conf_template.png`
- `task7_my_playbook_web_deploy.png`
- `task7_ansible_play_web_deploy.png`
- `task7_php_https_browser.png`

---
## Task 8 – Docker & Docker Compose provisioning via Ansible

Deploy Docker and Docker Compose on a new EC2 instance.

1. **Destroy old infrastructure**:

```bash
terraform destroy -auto-approve
```

- **Save screenshot as:** `task8_terraform_destroy_old.png` — destroy output for old stack.

2. **Recreate fresh infrastructure** (1 instance):

```bash
terraform apply -auto-approve
terraform output
```

- **Save screenshot as:** `task8_terraform_apply_docker_instance.png` — new apply.
- **Save screenshot as:** `task8_terraform_output_new_ip.png` — output showing new instance IP.

3. **Update `hosts`**:

```ini
[docker_servers]
<public-ip-new-ec2>

[docker_servers:vars]
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_user=ec2-user
```

- **Save screenshot as:** `task8_hosts_docker_servers.png` — `hosts` file showing `[docker_servers]`.

4. **Replace `my-playbook.yaml`** content with:

```yaml
---
- name: Configure Docker
  hosts: all
  become: true
  tasks:
    - name: install docker and update cache
      yum:
        name: docker
        state: present
        update_cache: yes

- name: Install Docker Compose
  hosts: all
  become: true
  gather_facts: true
  tasks:
    - name: create docker cli-plugins directory
      file:
        path: /usr/local/lib/docker/cli-plugins
        state: directory
        mode: '0755'

    - name: install docker-compose
      get_url:
        url: https://github.com/docker/compose/releases/latest/download/docker-compose-linux-{{ lookup('pipe', 'uname -m') }}
        dest: /usr/local/lib/docker/cli-plugins/docker-compose
        mode: +x

    - name: View architecture of the system
      debug:
        msg: "System architecture of {{ inventory_hostname }} is {{ ansible_facts['architecture'] }}"

    - name: Alternate method to view architecture of the system
      debug:
        msg: "System architecture of {{inventory_hostname}} is {{ lookup('pipe', 'uname -m') }}"

    - name: restart docker service
      service:
        name: docker
        state: restarted
```

- **Save screenshot as:** `task8_my_playbook_docker.png` — new Docker playbook content.

5. **Run the play**:

```bash
ansible-playbook -i hosts my-playbook.yaml
```

- **Save screenshot as:** `task8_ansible_play_docker.png` — playbook output installing Docker and Compose.

6. **Verify Docker**:

```bash
ssh ec2-user@<public-ip> -i ~/.ssh/id_ed25519
sudo docker ps
exit
```

- **Save screenshot as:** `task8_docker_ps_remote.png` — `sudo docker ps` output from EC2 instance.

**Screenshots Required:**
- `task8_terraform_destroy_old.png`
- `task8_terraform_apply_docker_instance.png`
- `task8_terraform_output_new_ip.png`
- `task8_hosts_docker_servers.png`
- `task8_my_playbook_docker.png`
- `task8_ansible_play_docker.png`
- `task8_docker_ps_remote.png`

---

## Task 9 – Gitea Docker stack via Ansible + Terraform security group update

Run containers for **Gitea + Postgres** and open port `3000` in the security group.

1. **Extend `my-playbook.yaml`** by appending:

```yaml
- name: Adding user to docker group
  hosts: all
  become: true
  vars_files:
    - project-vars.yaml
  tasks:
    - name: add user to docker group
      user:
        name: "{{ normal_user }}"
        groups: docker
        append: yes

    - name: reconnect to apply group changes
      meta: reset_connection

    - name: verify docker access
      command: docker ps
      register: docker_ps
      changed_when: false

    - name: display docker ps output
      debug:
        var: docker_ps.stdout

    - name: fail if docker is not accessible
      fail:
        msg: "Docker is not accessible on this host"
      when: docker_ps.rc != 0
```

- **Save screenshot as:** `task9_my_playbook_add_user_to_docker.png` — new play appended in `my-playbook.yaml`.

2. **Create `project-vars.yaml`**:

```bash
touch project-vars.yaml
```

Add:

```yaml
normal_user: ec2-user
docker_compose_file_location: <location-of-file>
```

- **Save screenshot as:** `task9_project_vars.png` — content of `project-vars.yaml`.

3. **Add the deploy containers play**:

```yaml
- name: Deploy Docker Containers
  hosts: all
  become: true
  user: "{{ normal_user }}"
  vars_files:
    - project-vars.yaml
  tasks:
    - name: check if docker-compose file exists
      stat:
        path: /home/{{ normal_user }}/compose.yaml
      register: compose_file

    - name: copy docker-compose file
      copy:
        src: "{{ docker_compose_file_location }}/compose.yaml"
        dest: /home/{{ normal_user }}/compose.yaml
        mode: '0644'
      when: not compose_file.stat.exists

    - name: deploy containers using docker-compose
      command: docker compose up -d
      register: compose_result
      changed_when: "'Creating' in compose_result.stdout or 'Recreating' in compose_result.stdout"
```

- **Save screenshot as:** `task9_my_playbook_deploy_containers.png` — final `my-playbook.yaml` with Docker deploy play.

4. **Create `compose.yaml`** in repo root:

```bash
touch compose.yaml
```

Fill with the Gitea + Postgres stack from instructions in **`compose.yaml`**.
```yaml
services:
  gitea:
    image: gitea/gitea:latest
    container_name: gitea
    environment:
      - DB_TYPE=postgres
      - DB_HOST=db:5432
      - DB_NAME=gitea
      - DB_USER=gitea
      - DB_PASSWD=gitea
    restart: always
    volumes:
      - gitea:/data
    ports:
      - 3000:3000
    extra_hosts:
      - "www.jenkins.com:host-gateway"
    networks:
      - webnet
  db:
    image: postgres:alpine
    container_name: gitea_db
    environment:
      - POSTGRES_USER=gitea
      - POSTGRES_PASSWORD=gitea
      - POSTGRES_DB=gitea
    restart: always
    volumes:
      - gitea_postgres:/var/lib/postgresql/data
    expose:
      - 5432
    networks:
      - webnet

volumes:
  gitea_postgres:
    name: gitea_postgres
  gitea:
    name: gitea

networks:
  webnet:
    name: webnet
```

- **Save screenshot as:** `task9_compose_yaml.png` — content of `compose.yaml`.

5. **Run playbook** and visit the public-ip on your browser but webpage will not be shown due to permission issue:

```bash
ansible-playbook -i hosts my-playbook.yaml
```

- **Save screenshot as:** `task9_ansible_play_gitea.png` — playbook output showing Gitea/db containers created.

6. **Update security group** in `modules/webserver/main.tf` to add port `3000`:

```hcl
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
```

- **Save screenshot as:** `task9_sg_ingress_3000.png` — `web_sg` snippet showing `3000/tcp` ingress.

7. Apply:

```bash
terraform apply -auto-approve
```

- **Save screenshot as:** `task9_terraform_apply_sg_3000.png` — apply output updating SG.

8. **Access Gitea**:

Visit `http://<public-ip>:3000`.

- **Save screenshot as:** `task9_gitea_browser.png` — browser showing Gitea UI.

**Screenshots Required:**
- `task9_my_playbook_add_user_to_docker.png`
- `task9_project_vars.png`
- `task9_my_playbook_deploy_containers.png`
- `task9_compose_yaml.png`
- `task9_ansible_play_gitea.png`
- `task9_sg_ingress_3000.png`
- `task9_terraform_apply_sg_3000.png`
- `task9_gitea_browser.png`

---

## Task 10 – Automating Ansible with Terraform (null_resource)

Have Terraform trigger Ansible automatically after EC2 creation.

1. **Add `null_resource`** to `main.tf`:

```hcl
resource "null_resource" "configure_server" {
  triggers = {
    webserver_public_ips_for_ansible = join(",", [for i in module.myapp-webserver : i.aws_instance.public_ip])
  }

  depends_on = [module.myapp-webserver]

  provisioner "local-exec" {
    command = <<-EOT
      ansible-playbook -i ${self.triggers.webserver_public_ips_for_ansible}, \
      --private-key "${var.private_key}" --user ec2-user \
      my-playbook.yaml
    EOT
  }
}
```

- **Save screenshot as:** `task10_null_resource_main_tf.png` — `main.tf` showing `null_resource` block.

2. **Destroy and recreate** infrastructure:

```bash
terraform destroy -auto-approve
terraform apply -auto-approve
```

- **Save screenshot as:** `task10_terraform_destroy_before_null.png` — destroy output.
- **Save screenshot as:** `task10_terraform_apply_with_local_exec.png` — apply output showing `local-exec` / Ansible execution.

3. If Ansible fails due to readiness, **add a wait play** at the top of `my-playbook.yaml`:

```yaml
- name: Wait for some time to ensure system readiness
  hosts: all
  tasks:
    - name: Wait 300 seconds for port 22 to become open and contain "OpenSSH"
      wait_for:
        port: 22
        host: "{{ inventory_hostname }}"
        delay: 10
        timeout: 300
      delegate_to: localhost
```

- **Save screenshot as:** `task10_my_playbook_wait_for_ssh.png` — top wait play in file.

4. **Destroy and apply again**:

```bash
terraform destroy -auto-approve
terraform apply -auto-approve
```

- **Save screenshot as:** `task10_terraform_apply_after_wait.png` — apply output after wait fix.

5. Verify Gitea / Nginx application is reachable at the appropriate URL.  
   - **Save screenshot as:** `task10_app_browser_post_null_resource.png` — browser confirming app is up after Terraform+Ansible.

**Screenshots Required:**
- `task10_null_resource_main_tf.png`
- `task10_terraform_destroy_before_null.png`
- `task10_terraform_apply_with_local_exec.png`
- `task10_my_playbook_wait_for_ssh.png`
- `task10_terraform_apply_after_wait.png`
- `task10_app_browser_post_null_resource.png`

---

## Task 11 – Dynamic inventory with aws_ec2 plugin

Let Ansible discover EC2 instances dynamically via the `aws_ec2` inventory plugin.

1. **Update `ansible.cfg`**:

```ini
[defaults]
host_key_checking=False
interpreter_python = /usr/bin/python3
deprecation_warnings = False

enable_plugins = aws_ec2
private_key_file = ~/.ssh/id_ed25519
```

- **Save screenshot as:** `task11_ansible_cfg_aws_ec2.png` — content of `ansible.cfg` with plugin configuration.

2. **Create `inventory_aws_ec2.yaml`**:

```bash
touch inventory_aws_ec2.yaml
ls -la inventory_aws_ec2.yaml
```

- **Save screenshot as:** `task11_inventory_aws_ec2_created.png` — file created.

Add initial content:

```yaml
---
plugin: aws_ec2
regions:
  - me-central-1
```

- **Save screenshot as:** `task11_inventory_aws_ec2_initial.png` — content of initial inventory file.

3. **Ensure Terraform code** includes both dev and prod webservers in **`main.tf`**:

```hcl
provider "aws" {
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
}

resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
     Name = "${var.env_prefix}-vpc"
  }
}

module "myapp-subnet" {
  source = "./modules/subnet"
  vpc_id = aws_vpc.myapp_vpc.id
  subnet_cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone
  env_prefix = var.env_prefix
  default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id
}

module "myapp-webserver" {
  source = "./modules/webserver"
  env_prefix = var.env_prefix
  instance_type = var. instance_type
  availability_zone = var.availability_zone
  public_key = var.public_key
  my_ip = local.my_ip
  vpc_id = aws_vpc.myapp_vpc.id
  subnet_id = module.myapp-subnet.subnet.id
  
  # Loop count
  count             = 1
  # Use count.index to differentiate instances
  instance_suffix   = count.index
}

module "myapp-webserver-prod" {
  source = "./modules/webserver"
  env_prefix = "prod"
  instance_type = "t3.nano"
  availability_zone = var.availability_zone
  public_key = var.public_key
  my_ip = local.my_ip
  vpc_id = aws_vpc.myapp_vpc.id
  subnet_id = module.myapp-subnet.subnet.id
  
  # Loop count
  count             = 1
  # Use count.index to differentiate instances
  instance_suffix   = count.index
}
```

- **Save screenshot as:** `task11_main_tf_dev_prod_modules.png` — snippet of `main.tf` showing `myapp-webserver` and `myapp-webserver-prod`.

4. **Add outputs in `outputs.tf`**:

```hcl
output "webserver_public_ips" {
  value = [for i in module.myapp-webserver : i.aws_instance.public_ip]
}

output "prod-webserver_public_ips" {
  value = [for i in module.myapp-webserver-prod : i.aws_instance.public_ip]
}
```

- **Save screenshot as:** `task11_outputs_tf_dev_prod_ips.png` — content of `outputs.tf` with both outputs.

5. **Rebuild infra**:

```bash
terraform init
terraform apply -auto-approve
terraform output
```

- **Save screenshot as:** `task11_terraform_apply_dynamic_setup.png` — apply output for dev/prod instances.
- **Save screenshot as:** `task11_terraform_output_dynamic_ips.png` — `terraform output` showing dev and prod IPs.

6. **Install `boto3` and `botocore`**:

```bash
$(which python) -m pip install boto3 botocore
```
- Verify the version
```bash
$(which python) -c "import boto3, botocore; print(boto3.__version__)"
```

- **Save screenshot as:** `task11_boto_install.png` — pip install output.
- **Save screenshot as:** `task11_boto_version.png` — printed version line.

7. **Check inventory graph**:

```bash
ansible-inventory -i inventory_aws_ec2.yaml --graph
```

- **Save screenshot as:** `task11_ansible_inventory_graph_initial.png` — graph output showing `@all`, `@ungrouped`, and `@aws_ec2` hosts.

**Screenshots Required:**
- `task11_ansible_cfg_aws_ec2.png`
- `task11_inventory_aws_ec2_created.png`
- `task11_inventory_aws_ec2_initial.png`
- `task11_main_tf_dev_prod_modules.png`
- `task11_outputs_tf_dev_prod_ips.png`
- `task11_terraform_apply_dynamic_setup.png`
- `task11_terraform_output_dynamic_ips.png`
- `task11_boto_install.png`
- `task11_boto_version.png`
- `task11_ansible_inventory_graph_initial.png`

---

## Task 12 – Filtering EC2 instances by tags & instance type

Augment the inventory plugin to group by tags and instance type, then limit plays to specific groups.

1. **Modify `inventory_aws_ec2.yaml`** to add tag‑based grouping:

```yaml
---
plugin: aws_ec2
regions:
  - me-central-1

keyed_groups:
  - key: tags
    prefix: tag
    separator: "_"
```

- **Save screenshot as:** `task12_inventory_aws_ec2_tag_groups.png` — updated inventory file.

Check graph:

```bash
ansible-inventory -i inventory_aws_ec2.yaml --graph
```

- **Save screenshot as:** `task12_inventory_graph_tag_groups.png` — `ansible-inventory` graph showing tag groups.

2. **Extend to group by instance type as well**:

```yaml
---
plugin: aws_ec2
regions:
  - me-central-1

keyed_groups:
  - key: tags
    prefix: tag
    separator: "_"

  - key: instance_type
    prefix: instance_type
    separator: "_"
```

- **Save screenshot as:** `task12_inventory_aws_ec2_instance_type_groups.png` — inventory with tags + instance_type.

Check graph again:

```bash
ansible-inventory -i inventory_aws_ec2.yaml --graph
```

- **Save screenshot as:** `task12_inventory_graph_full.png` — graph showing both tag and instance type groups.

3. **Prepare `my-playbook.yaml`** for nginx+SSL+PHP on `hosts: all`:

```yaml
---
- name: Configure nginx web server
  hosts: all
  become: true
  tasks:
  - name: install nginx and update cache
    yum:
      name: nginx
      state: present
      update_cache: yes

  - name: install openssl
    yum:
      name: openssl
      state: present
  
  - name: start nginx server
    service:
      name: nginx
      state: started
      enabled: true
  
- name: Configure SSL certificates
  hosts: all
  become: true
  tasks:
  - name: Create SSL private directory
    file:
      path: /etc/ssl/private
      state: directory
      mode: '0700'

  - name: Create SSL certs directory
    file:
      path: /etc/ssl/certs
      state: directory
      mode: '0755'

  - name: Get IMDSv2 token
    uri:
      url: "http://169.254.169.254/latest/api/token"
      method: PUT
      headers:
        X-aws-ec2-metadata-token-ttl-seconds: "3600"
      return_content: yes
    register: imdsv2_token

  - name: Get current public IP
    uri:
      url: "http://169.254.169.254/latest/meta-data/public-ipv4"
      headers:
        X-aws-ec2-metadata-token: "{{ imdsv2_token.content }}"
      return_content: yes
    register: public_ip

  - name: Show current public IP
    debug:
      msg: "Public IP: {{ public_ip.content }}"

  - name: Save public IP as fact
    set_fact:
      server_public_ip: "{{ public_ip.content }}"

  - name: Generate self-signed SSL certificate
    command: >
      openssl req -x509 -nodes -days 365
      -newkey rsa:2048
      -keyout /etc/ssl/private/selfsigned.key 
      -out /etc/ssl/certs/selfsigned.crt 
      -subj "/CN={{ public_ip.content }}" 
      -addext "subjectAltName=IP:{{ public_ip.content }}" 
      -addext "basicConstraints=CA:FALSE"
      -addext "keyUsage=digitalSignature,keyEncipherment"
      -addext "extendedKeyUsage=serverAuth"
    args:
      creates: /etc/ssl/certs/selfsigned.crt

- name: Deploy Nginx website and configuration files
  hosts: all
  become: true
  tasks:
    - name: install php-fpm and php-curl
      yum:
        name:
          - php-fpm
          - php-curl
        state: present

    - name: Copy website files
      copy:
        src: files/index.php
        dest: /usr/share/nginx/html/index.php
        owner: nginx
        group: nginx
        mode: '0644'  

    - name: Copy nginx.conf template
      template:
        src: templates/nginx.conf.j2
        dest: /etc/nginx/nginx.conf
        owner: root
        group: root
        mode: '0644'

    - name: Restart nginx
      service:
        name: nginx
        state: restarted
  
    - name: Start and enable php-fpm
      service:
        name: php-fpm
        state: started
        enabled: true
```

- **Save screenshot as:** `task12_my_playbook_all_hosts.png` — playbook configured for `hosts: all`.

4. **Run on all instances**:

```bash
ansible-playbook -i inventory_aws_ec2.yaml my-playbook.yaml
```

- **Save screenshot as:** `task12_ansible_play_all.png` — output showing all dev+prod hosts configured.

5. **Run only on dev instances**:

```bash
ansible-playbook -i inventory_aws_ec2.yaml -l tag_Name_dev_* my-playbook.yaml
```

- **Save screenshot as:** `task12_ansible_play_dev_only.png` — filtered run for dev group.

6. **Run only on prod instances**:

```bash
ansible-playbook -i inventory_aws_ec2.yaml -l tag_Name_prod_* my-playbook.yaml
```

- **Save screenshot as:** `task12_ansible_play_prod_only.png` — filtered run for prod group.

7. **Run only on `t3.micro`** instances:

```bash
ansible-playbook -i inventory_aws_ec2.yaml -l instance_type_t3_micro my-playbook.yaml
```

- **Save screenshot as:** `task12_ansible_play_t3_micro.png` — run for `instance_type_t3_micro`.

8. **Run only on `t3.nano`** instances:

```bash
ansible-playbook -i inventory_aws_ec2.yaml -l instance_type_t3_nano my-playbook.yaml
```

- **Save screenshot as:** `task12_ansible_play_t3_nano.png` — run for `instance_type_t3_nano`.

9. **Update `ansible.cfg`** to use inventory by default:

```ini
inventory = ./inventory_aws_ec2.yaml
```

- **Save screenshot as:** `task12_ansible_cfg_inventory_default.png` — `ansible.cfg` with `inventory = ./inventory_aws_ec2.yaml`.

10. Now you can simply run:

```bash
ansible-playbook -l instance_type_t3_nano my-playbook.yaml
```

- **Save screenshot as:** `task12_ansible_play_t3_nano_no_i.png` — run using default inventory (no `-i`).

**Screenshots Required:**
- `task12_inventory_aws_ec2_tag_groups.png`
- `task12_inventory_graph_tag_groups.png`
- `task12_inventory_aws_ec2_instance_type_groups.png`
- `task12_inventory_graph_full.png`
- `task12_my_playbook_all_hosts.png`
- `task12_ansible_play_all.png`
- `task12_ansible_play_dev_only.png`
- `task12_ansible_play_prod_only.png`
- `task12_ansible_play_t3_micro.png`
- `task12_ansible_play_t3_nano.png`
- `task12_ansible_cfg_inventory_default.png`
- `task12_ansible_play_t3_nano_no_i.png`

---

## Task 13 – Ansible roles: nginx, ssl, webapp

Reorganize your configuration into **roles**.

1. **Update `main.tf`** for a simple dev environment with 1 instance (as shown previously).  
```hcl
provider "aws" {
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
}

resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
     Name = "${var.env_prefix}-vpc"
  }
}

module "myapp-subnet" {
  source = "./modules/subnet"
  vpc_id = aws_vpc.myapp_vpc.id
  subnet_cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone
  env_prefix = var.env_prefix
  default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id
}

module "myapp-webserver" {
  source = "./modules/webserver"
  env_prefix = var.env_prefix
  instance_type = var. instance_type
  availability_zone = var.availability_zone
  public_key = var.public_key
  my_ip = local.my_ip
  vpc_id = aws_vpc.myapp_vpc.id
  subnet_id = module.myapp-subnet.subnet.id
  
  # Loop count
  count             = 1
  # Use count.index to differentiate instances
  instance_suffix   = count.index
}
```
   - **Save screenshot as:** `task13_main_tf_single_dev.png` — `main.tf` snippet with single `myapp-webserver` count=1.

2. **Create /ansible structure**:

```bash
mkdir -p ansible
cd ansible
mkdir inventory roles
touch ansible.cfg my-playbook.yaml
ls -R
```

- **Save screenshot as:** `task13_ansible_structure_created.png` — `ls -R` showing `ansible/`, `inventory/`, `roles/`, `ansible.cfg`, `my-playbook.yaml`.

3. **`ansible/ansible.cfg`**:

```ini
[defaults]
host_key_checking=False
interpreter_python = /usr/bin/python3
```

- **Save screenshot as:** `task13_ansible_cfg_project.png` — content of `ansible/ansible.cfg`.

4. **`ansible/inventory/hosts`**:

```ini
[nginx]
<public-ip-of-machine>

[nginx:vars]
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_user=ec2-user
```

- **Save screenshot as:** `task13_ansible_inventory_hosts.png` — content of `ansible/inventory/hosts`.

5. **Create roles**:

```bash
cd roles
ansible-galaxy role init nginx
ansible-galaxy role init ssl
ansible-galaxy role init webapp
cd ..
ls -R
```

- **Save screenshot as:** `task13_roles_created.png` — `ls -R` under `ansible/roles` showing `nginx`, `ssl`, `webapp`.

6. **Role: nginx**

- `ansible/roles/nginx/handlers/main.yml`:

```yaml
- name: Restart nginx
  service:
    name: nginx
    state: restarted
```

- **Save screenshot as:** `task13_nginx_handlers_main.png` — content of `roles/nginx/handlers/main.yml`.

- `ansible/roles/nginx/tasks/main.yml`:

```yaml
- name: Install nginx
  yum:
    name: nginx
    state: present
    update_cache: yes
  notify: Restart nginx

- name: Install openssl
  yum:
    name: openssl
    state: present

- name: Start and enable nginx
  service:
    name: nginx
    state: started
    enabled: true
```

- **Save screenshot as:** `task13_nginx_tasks_main.png` — content of `roles/nginx/tasks/main.yml`.

7. **First role‑based playbook** `ansible/my-playbook.yaml`:

```yaml
---
- name: Deploy NGINX Web Stack with SSL and PHP
  hosts: nginx
  become: true
  roles:
    - nginx
```

- **Save screenshot as:** `task13_my_playbook_nginx_only.png` — playbook using only `nginx` role.

Run:

```bash
chmod 755 $(pwd)
ansible-playbook -i inventory/hosts my-playbook.yaml
```

- **Save screenshot as:** `task13_ansible_play_nginx_only.png` — playbook output.
- **Save screenshot as:** `task13_nginx_browser_roles.png` — browser showing nginx default page via roles.

8. **Role: ssl**

- `ansible/roles/ssl/defaults/main.yml`:

```yaml
imdsv2_token_ttl: "3600"
ssl_days_valid: 365
```

- **Save screenshot as:** `task13_ssl_defaults_main.png` — content of `roles/ssl/defaults/main.yml`.

- `ansible/roles/ssl/tasks/main.yml`:

```yaml
- name: Create SSL private directory
  file:
    path: /etc/ssl/private
    state: directory
    mode: '0700'

- name: Create SSL certs directory
  file:
    path: /etc/ssl/certs
    state: directory
    mode: '0755'

- name: Get IMDSv2 token
  uri:
    url: http://169.254.169.254/latest/api/token
    method: PUT
    headers:
      X-aws-ec2-metadata-token-ttl-seconds: "{{ imdsv2_token_ttl }}"
    return_content: yes
  register: imds_token

- name: Get public IP
  uri:
    url: http://169.254.169.254/latest/meta-data/public-ipv4
    headers:
      X-aws-ec2-metadata-token: "{{ imds_token.content }}"
    return_content: yes
  register: public_ip

- name: Save public IP as fact
  set_fact:
    server_public_ip: "{{ public_ip.content }}"

- name: Generate self-signed certificate
  command: >
    openssl req -x509 -nodes -days {{ ssl_days_valid }}
    -newkey rsa:2048
    -keyout /etc/ssl/private/selfsigned.key
    -out /etc/ssl/certs/selfsigned.crt
    -subj "/CN={{ server_public_ip }}"
    -addext "subjectAltName=IP:{{ server_public_ip }}"
  args:
    creates: /etc/ssl/certs/selfsigned.crt
```

- **Save screenshot as:** `task13_ssl_tasks_main.png` — content of `roles/ssl/tasks/main.yml`.

9. **Role: webapp**

- `ansible/roles/webapp/defaults/main.yml`:

```yaml
nginx_user: nginx
nginx_worker_processes: auto
nginx_worker_connections: 1024
nginx_error_log_level: notice

# Webapp settings
web_root: /usr/share/nginx/html
web_index_file: index.php
```

- **Save screenshot as:** `task13_webapp_defaults_main.png` — content of `roles/webapp/defaults/main.yml`.

- `ansible/roles/webapp/files/index.php` – PHP metadata page.
```php
<?php
// Get hostname
$hostname = gethostname();

// Deployment date
$deployed_date = date("Y-m-d H:i:s");

// Metadata base URL
$metadata_base = "http://169.254.169.254/latest/";

// Function to get IMDSv2 token
function getImdsV2Token() {
    $ch = curl_init("http://169.254.169.254/latest/api/token");
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_CUSTOMREQUEST  => "PUT",
        CURLOPT_HTTPHEADER     => [
            "X-aws-ec2-metadata-token-ttl-seconds: 21600"
        ],
        CURLOPT_TIMEOUT        => 2
    ]);

    $token = curl_exec($ch);
    curl_close($ch);

    return $token ?: null;
}

// Function to fetch metadata using token
function getMetadata($path, $token) {
    $url = "http://169.254.169.254/latest/meta-data/" . $path;

    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER     => [
            "X-aws-ec2-metadata-token: $token"
        ],
        CURLOPT_TIMEOUT        => 2
    ]);

    $value = curl_exec($ch);
    curl_close($ch);

    return $value ?: "N/A";
}

// Fetch token
$token = getImdsV2Token();

// Fetch metadata only if token is available
$instance_id = $token ? getMetadata("instance-id", $token) : "N/A";
$private_ip  = $token ? getMetadata("local-ipv4", $token) : "N/A";
$public_ip   = $token ? getMetadata("public-ipv4", $token) : "N/A";
$public_dns  = $token ? getMetadata("public-hostname", $token) : "N/A";
?>
<!DOCTYPE html>
<html>
<head>
    <title>Frontend Web Server</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255, 255, 255, 0.1);
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
        }
        h1 {
            color: #fff;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .info {
            margin: 15px 0;
            padding: 10px;
            background: rgba(255,255,255,0.2);
            border-radius: 5px;
        }
        .label {
            font-weight: bold;
            color: #ffd700;
        }
        .info a {
            color: white;           /* same as other values */
            text-decoration: none;  /* remove underline */
            font-weight: normal;
        }

        .info a:hover {
            text-decoration: underline; /* optional: underline on hover */
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Nginx Front End Web Server </h1>

        <div class="info"><span class="label">Hostname:</span> <?= htmlspecialchars($hostname) ?></div>
        <div class="info"><span class="label">Instance ID:</span> <?= htmlspecialchars($instance_id) ?></div>
        <div class="info"><span class="label">Private IP:</span> <?= htmlspecialchars($private_ip) ?></div>
        <div class="info"><span class="label">Public IP:</span> <?= htmlspecialchars($public_ip) ?></div>
        <div class="info"><span class="label">Public DNS:</span>
            <a href="https://<?= htmlspecialchars($public_dns) ?>" target="_blank">
            https://<?= htmlspecialchars($public_dns) ?></a>
        </div>
        <div class="info"><span class="label">Deployed:</span> <?= $deployed_date ?></div>
        <div class="info"><span class="label">Status:</span> ✅ Active and Running</div>
        <div class="info"><span class="label">Managed By:</span> Terraform + Ansible</div>
    </div>
</body>
</html>

```

- **Save screenshot as:** `task13_webapp_files_index_php.png` — content of `roles/webapp/files/index.php`.

- `ansible/roles/webapp/handlers/main.yml`:

```yaml
- name: Restart nginx
  service:
    name: nginx
    state: restarted

- name: Restart php-fpm
  service:
    name: php-fpm
    state: restarted
```

- **Save screenshot as:** `task13_webapp_handlers_main.png` — content of `roles/webapp/handlers/main.yml`.

- `ansible/roles/webapp/templates/nginx.conf.j2`:
```nginx
user {{ nginx_user }};
worker_processes {{ nginx_worker_processes }};
error_log /var/log/nginx/error.log {{ nginx_error_log_level }};
pid /run/nginx.pid;

events {
    worker_connections {{ nginx_worker_connections }};
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request"'
                      '$status $body_bytes_sent "$http_referer"'
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    upstream backend_servers {
        server 158.252.94.241:80;
        server 158.252.94.242:80 backup;
    }

    server {
        listen 443 ssl;
        server_name {{ server_public_ip }};

        ssl_certificate /etc/ssl/certs/selfsigned.crt;
        ssl_certificate_key /etc/ssl/private/selfsigned.key;
        
        location / {
            root {{ web_root }};
            index {{ web_index_file }} index.html index.htm;
    #       proxy_pass http://158.252.94.241:80;
    #       proxy_pass http://backend_servers;

            location / {
                try_files $uri $uri/ =404;
            }

            # 🔴 This block is necessary for Php Website
            location ~ \.php$ {
                include fastcgi_params;
                fastcgi_pass unix:/run/php-fpm/www.sock;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            }
        }    
    }

    server {
        listen 80;
        server_name _;
        return 301 https://$host$request_uri;
    }
}
```

- **Save screenshot as:** `task13_webapp_templates_nginx_conf.png` — content of `roles/webapp/templates/nginx.conf.j2`.

- `ansible/roles/webapp/tasks/main.yml`:

```yaml
- name: Install PHP packages
  yum:
    name:
      - php-fpm
      - php-curl
    state: present
  notify: Restart php-fpm

- name: Copy PHP website
  copy:
    src: index.php
    dest: "{{ web_root }}/{{ web_index_file }}"
    owner: nginx
    group: nginx
    mode: '0644'
  notify: Restart nginx

- name: Deploy nginx config
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: Restart nginx

- name: Start and enable php-fpm
  service:
    name: php-fpm
    state: started
    enabled: true
```

- **Save screenshot as:** `task13_webapp_tasks_main.png` — content of `roles/webapp/tasks/main.yml`.

10. **Final role‑based playbook** `ansible/my-playbook.yaml`:

```yaml
---
- name: Deploy NGINX Web Stack with SSL and PHP
  hosts: nginx
  become: true
  roles:
    - nginx
    - ssl
    - webapp
```

- **Save screenshot as:** `task13_my_playbook_roles.png` — final `my-playbook.yaml` referencing three roles.

11. Run:

```bash
ansible-playbook -i inventory/hosts my-playbook.yaml
```

- **Save screenshot as:** `task13_ansible_play_roles.png` — playbook output with all roles executed.

Visit `https://<public-ip>` and verify the PHP page with metadata.  
- **Save screenshot as:** `task13_php_https_browser_roles.png` — browser showing final PHP page via HTTPS.

**Screenshots Required:**
- `task13_main_tf_single_dev.png`
- `task13_ansible_structure_created.png`
- `task13_ansible_cfg_project.png`
- `task13_ansible_inventory_hosts.png`
- `task13_roles_created.png`
- `task13_nginx_handlers_main.png`
- `task13_nginx_tasks_main.png`
- `task13_my_playbook_nginx_only.png`
- `task13_ansible_play_nginx_only.png`
- `task13_nginx_browser_roles.png`
- `task13_ssl_defaults_main.png`
- `task13_ssl_tasks_main.png`
- `task13_webapp_defaults_main.png`
- `task13_webapp_files_index_php.png`
- `task13_webapp_handlers_main.png`
- `task13_webapp_templates_nginx_conf.png`
- `task13_webapp_tasks_main.png`
- `task13_my_playbook_roles.png`
- `task13_ansible_play_roles.png`
- `task13_php_https_browser_roles.png`

---

## Cleanup

1. From the Terraform root:

```bash
terraform destroy -auto-approve
```

- **Save screenshot as:** `cleanup_terraform_destroy.png` — terminal showing destroy output.

2. Verify state:

```bash
cat terraform.tfstate
```

- **Save screenshot as:** `cleanup_tfstate.png` — `terraform.tfstate` showing no active resources or is empty.

3. Confirm that no EC2 instances remain in AWS console.  
   - **Save screenshot as:** `cleanup_aws_console.png` — AWS EC2 console showing zero running instances for this lab.

**Screenshots Required:**
- `cleanup_terraform_destroy.png`
- `cleanup_tfstate.png`
- `cleanup_aws_console.png`

---

## Submission

Create and push a repository named:

`CC_<YourName>_<YourRollNumber>/Lab14`

Recommended repository structure:

```txt
Lab14/
  modules/
    subnet/
      main.tf
      variables.tf
      outputs.tf
    webserver/
      main.tf
      variables.tf
      outputs.tf
  main.tf
  variables.tf
  outputs.tf
  locals.tf
  terraform.tfvars
  compose.yaml
  project-vars.yaml
  hosts
  inventory_aws_ec2.yaml
  my-playbook.yaml
  ansible.cfg
  ansible/
    ansible.cfg
    inventory/
      hosts
    roles/
      nginx/
        tasks/main.yml
        handlers/main.yml
      ssl/
        defaults/main.yml
        tasks/main.yml
      webapp/
        defaults/main.yml
        tasks/main.yml
        handlers/main.yml
        templates/nginx.conf.j2
        files/index.php
  screenshots/               # include ALL screenshots listed in this lab (optional)
  Lab14.md                   # this lab manual
  Lab14_solution.docx        # your solution in MS Word
  Lab14_solution.pdf         # your solution in PDF
```

**Do NOT commit:**

- Private keys (`~/.ssh/id_ed25519`, `*.pem`).
- AWS credentials.
- Terraform state files (`terraform.tfstate`, `terraform.tfstate.backup`).
- `.terraform/` directories.

Create a top-level `.gitignore` with at least:

```gitignore
.terraform/*
*.tfstate
*.tfstate.*
*.tfvars
*.pem
.terraform.lock.hcl
```

Push your completed lab to GitHub as:

`CC_<YourName>_<YourRollNumber>/Lab14`

---

## Summary of Tasks

| Task | Description | Key Concepts |
|------|-------------|--------------|
| 0 | Lab setup | Codespaces, GH CLI, environment verification |
| 1 | Clone repo & initial Terraform apply | Reusing IaC, `terraform.tfvars`, SSH keys |
| 2 | Static inventory (2 EC2) | Ansible static inventory, SSH connectivity |
| 3 | 3 instances & groups | Terraform `count`, Ansible groups |
| 4 | Global ansible.cfg & nginx play | `~/.ansible.cfg`, simple playbooks |
| 5 | Single nginx group | Project‑level `ansible.cfg`, host groups |
| 6 | SSL with Ansible | IMDSv2, self‑signed certs, `uri` module |
| 7 | PHP front‑end deploy | Templates, `copy`, php‑fpm integration |
| 8 | Docker & Compose | Package install, CLI plugins, system facts |
| 9 | Gitea Docker stack | Docker compose app, SG updates |
| 10 | Terraform‑driven Ansible | `null_resource`, `local-exec`, wait_for |
| 11 | Dynamic inventory base | `aws_ec2` plugin, boto3/botocore |
| 12 | Inventory groups & limits | Tag & instance type groups, `-l` limit |
| 13 | Roles: nginx, ssl, webapp | Ansible roles, defaults, handlers, templates |

Follow instructions precisely, capture all required screenshots with the exact filenames, verify web outputs at each step, and ensure your final repo structure and `.gitignore` align with security best practices.
