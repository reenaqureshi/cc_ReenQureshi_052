# 🧪 Lab 12 – Terraform Provisioners, Modules & Nginx Reverse Proxy/Load Balancer

Estimated Duration: 3 hours  
Instructions: Complete all tasks using a GitHub Codespace (Linux environment) created and authenticated with the GitHub CLI.  Create a repository named `Lab12`. When finished, push your work to a repository named `CC_<student_Name>_<student_roll_number>/Lab12`.

IMPORTANT: All steps that require GH CLI / Codespace MUST be performed inside the Codespace environment.  Do not authenticate GH CLI outside the Codespace shell.

---

## 🎯 Objective

In this lab you will: 

- Use GH CLI to work inside a Codespace. 
- Organize Terraform code into separate files (variables. tf, outputs.tf, locals.tf, main.tf, terraform.tfvars).
- Practice Terraform provisioners:  user_data, remote-exec, file, and local-exec.
- Create reusable Terraform modules for subnet and webserver resources.
- Configure Nginx as a reverse proxy and load balancer.
- Implement SSL/TLS with self-signed certificates.
- Configure Nginx caching for improved performance.
- Implement high availability patterns with backup servers.

---

## Task List

In this lab you will:

- [Task 0 - Lab Setup (Codespace & GH CLI)](#task-0-lab-setup-codespace--gh-cli)
- [Task 1 — Organize Terraform code into separate files](#task-1--organize-terraform-code-into-separate-files)
- [Task 2 — Use remote-exec provisioner](#task-2--use-remote-exec-provisioner)
- [Task 3 — Use file and local-exec provisioners](#task-3--use-file-and-local-exec-provisioners)
- [Task 4 — Create Terraform modules (subnet module)](#task-4--create-terraform-modules-subnet-module)
- [Task 5 — Create webserver module](#task-5--create-webserver-module)
- [Task 6 — Configure HTTPS with self-signed certificates](#task-6--configure-https-with-self-signed-certificates)
- [Task 7 — Configure Nginx as reverse proxy](#task-7--configure-nginx-as-reverse-proxy)
- [Task 8 — Configure Nginx as load balancer](#task-8--configure-nginx-as-load-balancer)
- [Task 9 — Configure high availability with backup servers](#task-9--configure-high-availability-with-backup-servers)
- [Task 10 — Enable Nginx caching](#task-10--enable-nginx-caching)
- [Cleanup — Destroy resources & verify state](#cleanup)
- [Submission](#submission)

---

## Task 0 Lab Setup (Codespace & GH CLI)

All actions below should be executed inside the Codespace shell. 

Create Codespace & connect:
```bash
# create or open codespace via GH CLI (example)
gh repo create CC_<YourName>_<YourRollNumber>/Lab12 --public
gh codespace create --repo <user_name>/Lab12
gh codespace list
gh codespace ssh -c <your_codespace_name>
```

- **Save screenshot as:** `task0_codespace_create_and_list.png` — output showing repo creation/codespace list. 
- **Save screenshot as:** `task0_codespace_ssh_connected.png` — terminal inside the Codespace shell after ssh. 

**Screenshots Required:**
- `task0_codespace_create_and_list. png`
- `task0_codespace_ssh_connected.png`

---

## Task 1 — Organize Terraform code into separate files

In this task, you will split a monolithic Terraform configuration into separate, well-organized files following best practices.

1. Create the initial project structure:
```bash
mkdir -p ~/Lab12
cd ~/Lab12
```
- **Save screenshot as:** `task1_project_directory.png` — terminal showing directory creation.

2. Create all required files:
```bash
touch main.tf variables.tf outputs.tf locals.tf terraform.tfvars entry-script.sh
```
- **Save screenshot as:** `task1_files_created.png` — terminal showing all files created (use `ls -la`).

3. Create `variables.tf` with the following content: 

```hcl name=variables.tf
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "availability_zone" {}
variable "env_prefix" {}
variable "instance_type" {}
variable "public_key" {}
variable "private_key" {}
```
- **Save screenshot as:** `task1_variables_tf.png` — content of variables.tf file.

4. Create `outputs.tf` with the following content:

```hcl name=outputs.tf
output "aws_instance_public_ip" {
  value = aws_instance.myapp-server.public_ip
}
```
- **Save screenshot as:** `task1_outputs_tf.png` — content of outputs.tf file.

5. Create `locals.tf` with the following content:

```hcl name=locals.tf
locals {
  my_ip = "${chomp(data.http.my_ip.response_body)}/32"
}

data "http" "my_ip" {
  url = "https://icanhazip.com"
}
```
- **Save screenshot as:** `task1_locals_tf.png` — content of locals.tf file.

6. Create `terraform.tfvars` with the following content:

```hcl name=terraform.tfvars
vpc_cidr_block = "10.0.0.0/16"
subnet_cidr_block = "10.0.10.0/24"
availability_zone = "me-central-1a"
env_prefix = "dev"
instance_type = "t3.micro"
public_key = "~/.ssh/id_ed25519.pub"
private_key = "~/.ssh/id_ed25519"
```
- **Save screenshot as:** `task1_terraform_tfvars. png` — content of terraform.tfvars file.

7. Create `main.tf` with the following content:

```hcl name=main.tf
provider "aws" {
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
}

resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
     Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp_subnet_1" {
  vpc_id     = aws_vpc.myapp_vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
     Name = "${var.env_prefix}-subnet-1"
  }
}

resource "aws_default_route_table" "main_rt" {
  default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
  }
    tags = {
     Name = "${var.env_prefix}-rt"
  }  
}

resource "aws_internet_gateway" "myapp_igw" {
  vpc_id = aws_vpc.myapp_vpc.id
    tags = {
     Name = "${var.env_prefix}-igw"
  }
}

resource "aws_default_security_group" "default_sg" {
  vpc_id      = aws_vpc.myapp_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
  }  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
}
  tags = {
     Name = "${var.env_prefix}-default-sg"
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name = "serverkey"
  public_key = file(var.public_key)
}

resource "aws_instance" "myapp-server" {
  ami           = "ami-05524d6658fcf35b6" # Amazon Linux 2023 Kernel 6.1 AMI
  instance_type = var.instance_type
  subnet_id     = aws_subnet.myapp_subnet_1.id
  security_groups = [aws_default_security_group.default_sg. id]
  availability_zone = var.availability_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key. key_name

  user_data = file("./entry-script.sh")

  tags = {
     Name = "${var.env_prefix}-ec2-instance"
  }
}
```
- **Save screenshot as:** `task1_main_tf.png` — content of main.tf file.

8. Create `entry-script.sh` with the following content:

```bash name=entry-script.sh
#!/bin/bash
set -e
yum update -y
yum install -y nginx
systemctl start nginx
systemctl enable nginx
```
- **Save screenshot as:** `task1_entry_script.png` — content of entry-script.sh file.

9. Generate SSH key pair if not already exists:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
```
- **Save screenshot as:** `task1_ssh_keygen.png` — terminal showing SSH key generation.

10. Initialize Terraform:
```bash
terraform init
```
- **Save screenshot as:** `task1_terraform_init.png` — terraform init output.

11. Apply the configuration:
```bash
terraform apply -auto-approve
```
- **Save screenshot as:** `task1_terraform_apply.png` — terraform apply output showing resources created.

12. Display the output:
```bash
terraform output
```
- **Save screenshot as:** `task1_terraform_output.png` — terraform output showing public IP.

13. Test nginx in browser:
- Open browser and navigate to `http://<public-ip>`
- **Save screenshot as:** `task1_nginx_browser.png` — browser showing nginx default page.

14. Destroy resources:
```bash
terraform destroy
```
- Type `yes` when prompted for confirmation.
- **Save screenshot as:** `task1_terraform_destroy.png` — terraform destroy output.

**Screenshots Required:**
- `task1_project_directory.png`
- `task1_files_created.png`
- `task1_variables_tf.png`
- `task1_outputs_tf.png`
- `task1_locals_tf.png`
- `task1_terraform_tfvars.png`
- `task1_main_tf.png`
- `task1_entry_script.png`
- `task1_ssh_keygen.png`
- `task1_terraform_init.png`
- `task1_terraform_apply.png`
- `task1_terraform_output.png`
- `task1_nginx_browser.png`
- `task1_terraform_destroy.png`

---

## Task 2 — Use remote-exec provisioner

In this task, you will replace the `user_data` approach with the `remote-exec` provisioner to install and configure nginx.

1. Modify the `aws_instance` resource in `main.tf` to use `remote-exec` provisioner: 

Replace the `user_data` line with the following provisioner block: 

```hcl
resource "aws_instance" "myapp-server" {
  ami           = "ami-05524d6658fcf35b6"
  instance_type = var.instance_type
  subnet_id     = aws_subnet.myapp_subnet_1.id
  security_groups = [aws_default_security_group.default_sg.id]
  availability_zone = var.availability_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  connection {
    type        = "ssh"
    user        = "ec2-user" 
    private_key = file(var.private_key) 
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [ 
      "sudo yum update -y",
      "sudo yum install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
     ]
  }

  tags = {
     Name = "${var. env_prefix}-ec2-instance"
  }
}
```
- **Save screenshot as:** `task2_main_tf_remote_exec.png` — main.tf showing remote-exec provisioner.

2. Apply the configuration:
```bash
terraform apply -auto-approve
```
- **Save screenshot as:** `task2_terraform_apply.png` — terraform apply output showing remote-exec execution.

3. Display the output:
```bash
terraform output
```
- **Save screenshot as:** `task2_terraform_output.png` — terraform output showing public IP.

4. Test nginx in browser:
- Open browser and navigate to `http://<public-ip>`
- **Save screenshot as:** `task2_nginx_browser.png` — browser showing nginx default page.

**Screenshots Required:**
- `task2_main_tf_remote_exec.png`
- `task2_terraform_apply.png`
- `task2_terraform_output.png`
- `task2_nginx_browser.png`

---

## Task 3 — Use file and local-exec provisioners

In this task, you will add the `file` provisioner to upload the script and the `local-exec` provisioner to log instance information locally.

1. Modify the `aws_instance` resource in `main.tf` to include all three provisioners:

```hcl
resource "aws_instance" "myapp-server" {
  ami           = "ami-05524d6658fcf35b6"
  instance_type = var.instance_type
  subnet_id     = aws_subnet.myapp_subnet_1.id
  security_groups = [aws_default_security_group.default_sg.id]
  availability_zone = var.availability_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  connection {
    type        = "ssh"
    user        = "ec2-user" 
    private_key = file(var.private_key) 
    host        = self.public_ip
  }

  provisioner "file" {
    source = "./entry-script.sh"
    destination = "/home/ec2-user/entry-script-on-ec2.sh"
  }

  provisioner "remote-exec" {
    inline = [ 
      "sudo chmod +x /home/ec2-user/entry-script-on-ec2.sh",
      "sudo /home/ec2-user/entry-script-on-ec2.sh"
     ]
  }

  provisioner "local-exec" {
    command = <<-EOF
      echo Instance ${self.id} with public IP ${self.public_ip} has been created
    EOF
  }

  tags = {
     Name = "${var.env_prefix}-ec2-instance"
  }
}
```
- **Save screenshot as:** `task3_main_tf_all_provisioners.png` — main.tf showing file, remote-exec, and local-exec provisioners.

2. Apply the configuration:
```bash
terraform apply -auto-approve
```
- **Save screenshot as:** `task3_terraform_apply.png` — terraform apply output showing all provisioners execution.

3. Display the output:
```bash
terraform output
```
- **Save screenshot as:** `task3_terraform_output.png` — terraform output showing public IP.

4. Test nginx in browser:
- Open browser and navigate to `http://<public-ip>`
- **Save screenshot as:** `task3_nginx_browser.png` — browser showing nginx default page. 

5. Destroy the resources:
```bash
terraform destroy
```
- Type `yes` when prompted. 
- **Save screenshot as:** `task3_terraform_destroy.png` — terraform destroy output.

6. Remove the provisioners and restore `user_data`:

Replace the connection and provisioner blocks with: 
```hcl
user_data = file("./entry-script.sh")
```
- **Save screenshot as:** `task3_main_tf_restored.png` — main.tf showing user_data restored.

**Screenshots Required:**
- `task3_main_tf_all_provisioners.png`
- `task3_terraform_apply.png`
- `task3_terraform_output.png`
- `task3_nginx_browser.png`
- `task3_terraform_destroy.png`
- `task3_main_tf_restored.png`

---

## Task 4 — Create Terraform modules (subnet module)

In this task, you will create a reusable subnet module to organize your infrastructure code better.

1. Create the module directory structure:
```bash
mkdir -p modules/subnet
touch modules/subnet/main.tf
touch modules/subnet/variables.tf
touch modules/subnet/outputs.tf
```
- **Save screenshot as:** `task4_module_structure.png` — terminal showing module directory structure (use `tree` or `ls -R`).

2. Create `modules/subnet/variables.tf`:

```hcl name=modules/subnet/variables.tf
variable "vpc_id" {}
variable "subnet_cidr_block" {}
variable "availability_zone" {}
variable "env_prefix" {}
variable "default_route_table_id" {}
```
- **Save screenshot as:** `task4_subnet_variables.png` — content of modules/subnet/variables.tf. 

3. Create `modules/subnet/main.tf`:

```hcl name=modules/subnet/main. tf
resource "aws_subnet" "myapp_subnet_1" {
  vpc_id     = var.vpc_id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
     Name = "${var.env_prefix}-subnet-1"
  }
}

resource "aws_default_route_table" "main_rt" {
  default_route_table_id = var.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
  }
    tags = {
     Name = "${var.env_prefix}-rt"
  }  
}

resource "aws_internet_gateway" "myapp_igw" {
  vpc_id = var.vpc_id
    tags = {
     Name = "${var.env_prefix}-igw"
  }
}
```
- **Save screenshot as:** `task4_subnet_main.png` — content of modules/subnet/main.tf.

4. Create `modules/subnet/outputs.tf`:

```hcl name=modules/subnet/outputs.tf
output "subnet" {
  value = aws_subnet.myapp_subnet_1
}
```
- **Save screenshot as:** `task4_subnet_outputs.png` — content of modules/subnet/outputs.tf.

5. Modify the root `main.tf` to use the subnet module:

Remove the subnet, route table, and internet gateway resources and replace them with:

```hcl
module "myapp-subnet" {
  source = "./modules/subnet"
  vpc_id = aws_vpc.myapp_vpc. id
  subnet_cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone
  env_prefix = var.env_prefix
  default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id
}
```

And update the instance resource to reference the module output: 
```hcl
resource "aws_instance" "myapp-server" {
  # ... other settings ...
  subnet_id     = module.myapp-subnet.subnet.id
  # ... rest of configuration ...
}
```
- **Save screenshot as:** `task4_main_tf_with_module.png` — main.tf showing module usage.

6. Initialize Terraform to download the module:
```bash
terraform init
```
- **Save screenshot as:** `task4_terraform_init.png` — terraform init output showing module initialization.

7. Apply the configuration:
```bash
terraform apply -auto-approve
```
- **Save screenshot as:** `task4_terraform_apply.png` — terraform apply output with module. 

8. Display the output:
```bash
terraform output
```
- **Save screenshot as:** `task4_terraform_output.png` — terraform output showing public IP. 

9. Test nginx in browser:
- Open browser and navigate to `http://<public-ip>`
- **Save screenshot as:** `task4_nginx_browser.png` — browser showing nginx default page.

**Screenshots Required:**
- `task4_module_structure.png`
- `task4_subnet_variables.png`
- `task4_subnet_main.png`
- `task4_subnet_outputs.png`
- `task4_main_tf_with_module.png`
- `task4_terraform_init.png`
- `task4_terraform_apply.png`
- `task4_terraform_output.png`
- `task4_nginx_browser.png`

---

## Task 5 — Create webserver module

In this task, you will create a reusable webserver module for EC2 instances.

1. Create the webserver module directory structure:
```bash
mkdir -p modules/webserver
touch modules/webserver/main.tf
touch modules/webserver/variables.tf
touch modules/webserver/outputs.tf
```
- **Save screenshot as:** `task5_webserver_module_structure.png` — terminal showing webserver module directory. 

2. Create `modules/webserver/variables.tf`:

```hcl name=modules/webserver/variables.tf
variable "env_prefix" {}
variable "instance_type" {}
variable "availability_zone" {}
variable "public_key" {}
variable "my_ip" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "script_path" {}
variable "instance_suffix" {}
```
- **Save screenshot as:** `task5_webserver_variables.png` — content of modules/webserver/variables. tf.

3. Create `modules/webserver/main.tf`:

```hcl name=modules/webserver/main.tf
resource "aws_security_group" "web_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.env_prefix}-web-sg-${var.instance_suffix}"
  description = "Security group for web server allowing HTTP, HTTPS and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
}
  tags = {
     Name = "${var.env_prefix}-default-sg"
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name = "${var.env_prefix}-serverkey-${var.instance_suffix}"
  public_key = file(var.public_key)
}

resource "aws_instance" "myapp-server" {
  ami           = "ami-05524d6658fcf35b6" # Amazon Linux 2023 Kernel 6.1 AMI
  instance_type = var. instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  availability_zone = var.availability_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  user_data = file(var.script_path)
  
  tags = {
     Name = "${var.env_prefix}-ec2-instance-${var.instance_suffix}"
  }
}
```
- **Save screenshot as:** `task5_webserver_main.png` — content of modules/webserver/main.tf.

4. Create `modules/webserver/outputs.tf`:

```hcl name=modules/webserver/outputs.tf
output "aws_instance" {
  value = aws_instance.myapp-server
}
```
- **Save screenshot as:** `task5_webserver_outputs.png` — content of modules/webserver/outputs.tf.

5. Modify the root `main.tf`:

Remove the security group, key pair, and instance resources.  Replace them with:

```hcl
module "myapp-webserver" {
  source = "./modules/webserver"
  env_prefix = var.env_prefix
  instance_type = var. instance_type
  availability_zone = var.availability_zone
  public_key = var.public_key
  my_ip = local.my_ip
  vpc_id = aws_vpc.myapp_vpc.id
  subnet_id = module.myapp-subnet.subnet.id
  script_path = "./entry-script.sh"
  instance_suffix = "0"
}
```
- **Save screenshot as:** `task5_main_tf_webserver_module.png` — main.tf showing webserver module usage.

6. Update `outputs.tf`:

```hcl name=outputs.tf
output "webserver_public_ip" {
  value = module.myapp-webserver.aws_instance.public_ip
}
```
- **Save screenshot as:** `task5_outputs_updated.png` — updated outputs.tf.

7. Initialize Terraform:
```bash
terraform init
```
- **Save screenshot as:** `task5_terraform_init.png` — terraform init output.

8. Apply the configuration:
```bash
terraform apply -auto-approve
```
- **Save screenshot as:** `task5_terraform_apply.png` — terraform apply output with webserver module.

9. Display the output:
```bash
terraform output
```
- **Save screenshot as:** `task5_terraform_output.png` — terraform output showing webserver public IP.

10. Test nginx in browser:
- Open browser and navigate to `http://<public-ip>`
- **Save screenshot as:** `task5_nginx_browser.png` — browser showing nginx default page.

11. Destroy resources:
```bash
terraform destroy
```
- Type `yes` when prompted.
- **Save screenshot as:** `task5_terraform_destroy.png` — terraform destroy output.

**Screenshots Required:**
- `task5_webserver_module_structure.png`
- `task5_webserver_variables.png`
- `task5_webserver_main.png`
- `task5_webserver_outputs.png`
- `task5_main_tf_webserver_module.png`
- `task5_outputs_updated.png`
- `task5_terraform_init.png`
- `task5_terraform_apply.png`
- `task5_terraform_output.png`
- `task5_nginx_browser.png`
- `task5_terraform_destroy.png`

---

## Task 6 — Configure HTTPS with self-signed certificates

In this task, you will configure Nginx to serve traffic over HTTPS using self-signed certificates.

1. Update `entry-script.sh` with SSL configuration:

```bash name=entry-script.sh
#!/bin/bash
set -e
yum update -y
yum install -y nginx
systemctl start nginx
systemctl enable nginx

# Create directories for SSL certificates if they don't exist
mkdir -p /etc/ssl/private
mkdir -p /etc/ssl/certs

# Get IMDSv2 token
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Get current public IP
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)

PUBLIC_HOSTNAME=$(curl -s -H "X-aws-ec2-metadata-token:  $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-hostname)

# Generate self-signed certificate with dynamic IP
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/selfsigned.key \
  -out /etc/ssl/certs/selfsigned.crt \
  -subj "/CN=$PUBLIC_IP" \
  -addext "subjectAltName=IP:$PUBLIC_IP" \
  -addext "basicConstraints=CA:FALSE" \
  -addext "keyUsage=digitalSignature,keyEncipherment" \
  -addext "extendedKeyUsage=serverAuth"

echo "Self-signed certificate created for IP: $PUBLIC_IP"

# Backup existing nginx. conf
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

# Overwrite nginx.conf with the desired content
cat <<EOF > /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /run/nginx. pid;

events {
    worker_connections 1024;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request"'
                      '\$status \$body_bytes_sent "\$http_referer"'
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

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
        server_name $PUBLIC_IP;
        ssl_certificate /etc/ssl/certs/selfsigned.crt;
        ssl_certificate_key /etc/ssl/private/selfsigned.key;

        location / {
            root /usr/share/nginx/html;
            index index.html;
    #       proxy_pass http://158.252.94.241:80;
    #       proxy_pass http://backend_servers;
            
        }
    }

    server {
        listen 80;
        server_name _;
        return 301 https://\$host\$request_uri;
    }
}
EOF

# Test and restart Nginx
systemctl restart nginx
```
- **Save screenshot as:** `task6_entry_script_https.png` — updated entry-script.sh with HTTPS configuration.

2. Apply the configuration:
```bash
terraform apply -auto-approve
```
- **Save screenshot as:** `task6_terraform_apply.png` — terraform apply output. 

3. Display the output:
```bash
terraform output
```
- **Save screenshot as:** `task6_terraform_output.png` — terraform output showing public IP. 

4. Test HTTPS in browser:
- Open browser and navigate to `https://<public-ip>`
- You will see a warning:  "Warning:  Potential Security Risk Ahead"
- Click "Advanced" button
- Click "Accept the Risk and Continue"
- **Save screenshot as:** `task6_browser_security_warning.png` — browser showing security warning. 
- **Save screenshot as:** `task6_nginx_https_browser.png` — browser showing nginx page over HTTPS after accepting risk.

5. Verify HTTP to HTTPS redirect:
- Open browser and navigate to `http://<public-ip>`
- Verify it redirects to `https://<public-ip>`
- **Save screenshot as:** `task6_http_redirect.png` — browser showing redirect from HTTP to HTTPS.

**Screenshots Required:**
- `task6_entry_script_https.png`
- `task6_terraform_apply.png`
- `task6_terraform_output.png`
- `task6_browser_security_warning.png`
- `task6_nginx_https_browser.png`
- `task6_http_redirect.png`

---

## Task 7 — Configure Nginx as reverse proxy

In this task, you will create a backend web server and configure Nginx to act as a reverse proxy.

1. Create `apache.sh` script for backend web server:

```bash name=apache.sh
#!/bin/bash
yum update -y
yum install httpd -y
systemctl start httpd
systemctl enable httpd
echo "<h1>Welcome to My Web Server</h1>" > /var/www/html/index.html
hostnamectl set-hostname myapp-webserver
echo "<h2>Hostname:  $(hostname)</h2>" >> /var/www/html/index.html
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") 
echo "<h2>Private IP: $(curl -s -H "X-aws-ec2-metadata-token: $TOKEN"  http://169.254.169.254/latest/meta-data/local-ipv4)</h2>" >> /var/www/html/index.html
echo "<h2>Public IP: $(curl -s -H "X-aws-ec2-metadata-token: $TOKEN"  http://169.254.169.254/latest/meta-data/public-ipv4)</h2>" >> /var/www/html/index.html
echo "<h2>Public DNS: $(curl -s -H "X-aws-ec2-metadata-token: $TOKEN"  http://169.254.169.254/latest/meta-data/public-hostname)</h2>" >> /var/www/html/index.html
echo "<h2>Deployed via Terraform</h2>" >> /var/www/html/index. html
```
- **Save screenshot as:** `task7_apache_script.png` — content of apache.sh file.

2. Add the backend web server module to `main.tf`:

```hcl
module "myapp-web-1" {
  source = "./modules/webserver"
  env_prefix = var.env_prefix
  instance_type = var.instance_type
  availability_zone = var.availability_zone
  public_key = var.public_key
  my_ip = local.my_ip
  vpc_id = aws_vpc. myapp_vpc.id
  subnet_id = module.myapp-subnet.subnet.id
  script_path = "./apache.sh"
  instance_suffix = "1"
}
```
- **Save screenshot as:** `task7_main_tf_web1.png` — main. tf showing myapp-web-1 module. 

3. Update `outputs.tf`:

```hcl
output "aws_web-1_public_ip" {
  value = module.myapp-web-1.aws_instance.public_ip
}
```
- **Save screenshot as:** `task7_outputs_web1.png` — outputs.tf with web-1 output.

4. Apply the configuration:
```bash
terraform apply -auto-approve
```
- **Save screenshot as:** `task7_terraform_apply.png` — terraform apply output showing both instances created.

5. Get the outputs:
```bash
terraform output
```
- **Save screenshot as:** `task7_terraform_output.png` — showing both public IPs.

6. SSH into the webserver (Nginx proxy server):
```bash
ssh ec2-user@<webserver-public-ip>
```
- **Save screenshot as:** `task7_ssh_webserver. png` — SSH session to webserver.

7. Edit the Nginx configuration: 
```bash
sudo vim /etc/nginx/nginx.conf
```

Modify the location block to proxy to web-1:
```nginx
        location / {
    #        root /usr/share/nginx/html;
    #        index index. html;
             proxy_pass http://<web-1-public-ip>:80;
    #       proxy_pass http://backend_servers;
            
        }
```
- **Save screenshot as:** `task7_nginx_conf_reverse_proxy.png` — nginx.conf showing proxy_pass configuration.

8. Restart Nginx:
```bash
sudo systemctl restart nginx
```
- **Save screenshot as:** `task7_nginx_restart.png` — terminal showing nginx restart command.

9. View Nginx logs and configuration files:
```bash
cat /var/log/nginx/error.log
```
- **Save screenshot as:** `task7_error_log.png` — content of error. log.

```bash
cat /var/log/nginx/access.log
```
- **Save screenshot as:** `task7_access_log.png` — content of access.log.

```bash
cat /etc/nginx/mime.types
```
- **Save screenshot as:** `task7_mime_types.png` — content of mime.types.

```bash
cat /etc/ssl/certs/selfsigned.crt
```
- **Save screenshot as:** `task7_ssl_cert.png` — content of selfsigned.crt. 

```bash
sudo cat /etc/ssl/private/selfsigned.key
```
- **Save screenshot as:** `task7_ssl_key.png` — content of selfsigned.key.

10. Test reverse proxy in browser:
- Open browser and navigate to `https://<webserver-public-ip>`
- You should see the web-1 Apache page through the Nginx proxy
- **Save screenshot as:** `task7_reverse_proxy_browser.png` — browser showing web-1 content through proxy.

**Screenshots Required:**
- `task7_apache_script.png`
- `task7_main_tf_web1.png`
- `task7_outputs_web1.png`
- `task7_terraform_apply.png`
- `task7_terraform_output.png`
- `task7_ssh_webserver.png`
- `task7_nginx_conf_reverse_proxy.png`
- `task7_nginx_restart.png`
- `task7_error_log.png`
- `task7_access_log.png`
- `task7_mime_types.png`
- `task7_ssl_cert.png`
- `task7_ssl_key.png`
- `task7_reverse_proxy_browser.png`

---

## Task 8 — Configure Nginx as load balancer

In this task, you will add a second backend server and configure Nginx to load balance between them.

1. Add the second web server module to `main.tf`:

```hcl
module "myapp-web-2" {
  source = "./modules/webserver"
  env_prefix = var.env_prefix
  instance_type = var.instance_type
  availability_zone = var. availability_zone
  public_key = var.public_key
  my_ip = local.my_ip
  vpc_id = aws_vpc.myapp_vpc.id
  subnet_id = module.myapp-subnet.subnet.id
  script_path = "./apache.sh"
  instance_suffix = "2"
}
```
- **Save screenshot as:** `task8_main_tf_web2.png` — main.tf showing myapp-web-2 module.

2. Update `outputs.tf`:

```hcl
output "aws_web-2_public_ip" {
  value = module. myapp-web-2.aws_instance.public_ip
}
```
- **Save screenshot as:** `task8_outputs_web2.png` — outputs.tf with web-2 output. 

3. Apply the configuration:
```bash
terraform apply -auto-approve
```
- **Save screenshot as:** `task8_terraform_apply.png` — terraform apply output showing web-2 created.

4. Get all outputs:
```bash
terraform output
```
- **Save screenshot as:** `task8_terraform_output.png` — showing all three public IPs.

5. SSH into the webserver (Nginx proxy):
```bash
ssh ec2-user@<webserver-public-ip>
```

6. Edit Nginx configuration for load balancing:
```bash
sudo vim /etc/nginx/nginx.conf
```

Update the upstream block and location: 
```nginx
    upstream backend_servers {
        server <web-1-public-ip>:80;
        server <web-2-public-ip>:80;
    }

    # ...  in server block: 
        location / {
    #        root /usr/share/nginx/html;
    #        index index.html;
    #        proxy_pass http://<web-1-public-ip>:80;
            proxy_pass http://backend_servers;
            
        }
```
- **Save screenshot as:** `task8_nginx_conf_load_balancer.png` — nginx.conf showing load balancing configuration.

7. Restart Nginx:
```bash
sudo systemctl restart nginx
```
- **Save screenshot as:** `task8_nginx_restart.png` — terminal showing nginx restart.

8. Test load balancing in browser:
- Open browser and navigate to `https://<webserver-public-ip>`
- Reload the page multiple times
- You should see the content alternating between web-1 and web-2 (check the hostname/IP in the page)
- **Save screenshot as:** `task8_load_balancer_web1.png` — browser showing web-1 content.
- **Save screenshot as:** `task8_load_balancer_web2.png` — browser showing web-2 content after reload.

**Screenshots Required:**
- `task8_main_tf_web2.png`
- `task8_outputs_web2.png`
- `task8_terraform_apply.png`
- `task8_terraform_output.png`
- `task8_nginx_conf_load_balancer.png`
- `task8_nginx_restart.png`
- `task8_load_balancer_web1.png`
- `task8_load_balancer_web2.png`

---

## Task 9 — Configure high availability with backup servers

In this task, you will configure one server as primary and another as backup for high availability.

1. SSH into the webserver: 
```bash
ssh ec2-user@<webserver-public-ip>
```

2. Edit Nginx configuration for high availability:
```bash
sudo vim /etc/nginx/nginx.conf
```

Update the upstream block to make web-2 a backup: 
```nginx
    upstream backend_servers {
        server <web-1-public-ip>:80;
        server <web-2-public-ip>:80 backup;
    }
```
- **Save screenshot as:** `task9_nginx_conf_ha_web1_primary.png` — nginx.conf with web-2 as backup.

3. Restart Nginx:
```bash
sudo systemctl restart nginx
```

4. Test in browser:
- Open browser and navigate to `https://<webserver-public-ip>`
- Reload multiple times
- You should ONLY see web-1 (primary server)
- **Save screenshot as:** `task9_ha_web1_only.png` — browser showing only web-1 content on multiple reloads.

5. Switch backup configuration:
```bash
sudo vim /etc/nginx/nginx.conf
```

Update to make web-1 backup:
```nginx
    upstream backend_servers {
        server <web-1-public-ip>:80 backup;
        server <web-2-public-ip>:80;
    }
```
- **Save screenshot as:** `task9_nginx_conf_ha_web2_primary.png` — nginx.conf with web-1 as backup. 

6. Restart Nginx:
```bash
sudo systemctl restart nginx
```

7. Test in browser:
- Reload multiple times
- You should ONLY see web-2 (now the primary server)
- **Save screenshot as:** `task9_ha_web2_only.png` — browser showing only web-2 content on multiple reloads.

**Screenshots Required:**
- `task9_nginx_conf_ha_web1_primary.png`
- `task9_ha_web1_only.png`
- `task9_nginx_conf_ha_web2_primary.png`
- `task9_ha_web2_only.png`

---

## Task 10 — Enable Nginx caching

In this task, you will enable caching in Nginx to improve performance.

1. SSH into the webserver:
```bash
ssh ec2-user@<webserver-public-ip>
```

2. Edit Nginx configuration to enable caching:
```bash
sudo vim /etc/nginx/nginx.conf
```

Add proxy cache configuration in the http block and location block:
```nginx
http {
    proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m inactive=60m max_size=1g;
    
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    # ... other settings ...

    upstream backend_servers {
        server <web-1-public-ip>:80;
        server <web-2-public-ip>:80;
    }

    server {
        listen 443 ssl;
        server_name $PUBLIC_IP;
        ssl_certificate /etc/ssl/certs/selfsigned.crt;
        ssl_certificate_key /etc/ssl/private/selfsigned.key;

        location / {
    #        root /usr/share/nginx/html;
    #        index index.html;
    #        proxy_pass http://<web-1-public-ip>:80;
            proxy_pass http://backend_servers;
            proxy_cache my_cache;
            proxy_cache_valid 200 60m;
            proxy_cache_key "$scheme$request_uri";
            add_header X-Cache-Status $upstream_cache_status;
        }
    }

    # ... rest of config ...
}
```
- **Save screenshot as:** `task10_nginx_conf_cache.png` — nginx.conf showing cache configuration.

3. Restart Nginx:
```bash
sudo systemctl restart nginx
```
- **Save screenshot as:** `task10_nginx_restart.png` — terminal showing nginx restart.

4. Test caching in browser:
- Open browser developer tools (F12)
- Navigate to Network tab
- Visit `https://<webserver-public-ip>`
- Check response headers for `X-Cache-Status`
- First request should show `MISS`
- Reload the page
- Second request should show `HIT`
- **Save screenshot as:** `task10_cache_miss.png` — browser dev tools showing X-Cache-Status:  MISS on first request. 
- **Save screenshot as:** `task10_cache_hit.png` — browser dev tools showing X-Cache-Status: HIT on subsequent request.

5. Verify cache directory:
```bash
ls -la /var/cache/nginx/
```
- **Save screenshot as:** `task10_cache_directory.png` — terminal showing cache directory contents.

**Screenshots Required:**
- `task10_nginx_conf_cache.png`
- `task10_nginx_restart.png`
- `task10_cache_miss.png`
- `task10_cache_hit.png`
- `task10_cache_directory.png`

---

## Cleanup

1. Exit SSH session:
```bash
exit
```

2. Destroy all resources:
```bash
terraform destroy
```
- Type `yes` when prompted for confirmation. 
- **Save screenshot as:** `cleanup_destroy_prompt.png` — terminal showing terraform destroy prompt. 
- **Save screenshot as:** `cleanup_destroy_complete.png` — terraform destroy completion output.

3. Verify state files: 
```bash
cat terraform.tfstate
```
- **Save screenshot as:** `cleanup_state_empty.png` — showing empty terraform. tfstate.

4. List all project files:
```bash
tree
# or
ls -la
```
- **Save screenshot as:** `cleanup_final_files.png` — showing final project structure.

**Screenshots Required:**
- `cleanup_destroy_prompt.png`
- `cleanup_destroy_complete.png`
- `cleanup_state_empty.png`
- `cleanup_final_files.png`

---

## Submission

Create and push a repository named: 

`CC_<YourName>_<YourRollNumber>/Lab12`

Repository structure: 

```
Lab12/
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
  entry-script.sh
  apache.sh
  . gitignore
  screenshots/                  # include ALL screenshots listed in this lab (optional)
  Lab12.md                      # this lab manual
  Lab12_solution. docx           # lab solution in MS Word
  Lab12_solution.pdf            # lab solution in PDF
```

Important: Do NOT commit . pem files, AWS credentials, or terraform. tfstate/terraform.tfstate.backup.  Make sure . gitignore includes these files. 

Create `.gitignore`:
```
.terraform/*
*.tfstate
*.tfstate.*
*.tfvars
*.pem
.terraform.lock.hcl
```

---

## Notes & Tips

- Always work inside the Codespace (GH CLI) for this lab. 
- Do not commit private keys, secrets, or state files. 
- Use `terraform plan` to preview changes before applying.
- Make sure to capture all screenshots at the appropriate steps.
- Pay attention to public IPs — they change with each apply.
- When editing Nginx config, be careful with syntax — test with `sudo nginx -t` before restarting.
- The X-Cache-Status header helps verify caching is working. 
- In load balancing, refresh the page several times to see distribution. 
- Backup servers only activate when primary servers are unavailable.

Good luck — follow steps carefully, capture all required screenshots, and push your Lab12 repository to GitHub as `CC_<YourName>_<YourRollNumber>/Lab12`.

---

## Summary of Tasks

| Task | Description | Key Concepts |
|------|-------------|--------------|
| 0 | Lab Setup | GitHub Codespaces, GH CLI |
| 1 | Organize Terraform files | Code organization, best practices |
| 2 | Remote-exec provisioner | SSH provisioning, remote execution |
| 3 | File & local-exec provisioners | File transfer, local commands |
| 4 | Subnet module | Terraform modules, code reusability |
| 5 | Webserver module | Module composition, outputs |
| 6 | HTTPS configuration | SSL/TLS, self-signed certificates |
| 7 | Reverse proxy | Nginx proxy_pass, backend routing |
| 8 | Load balancing | Traffic distribution, round-robin |
| 9 | High availability | Backup servers, failover |
| 10 | Caching | Performance optimization, cache headers |

---
