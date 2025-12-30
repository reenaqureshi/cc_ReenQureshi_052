# Assignment 2 - Multi-Tier Web Infrastructure with Terraform & Nginx
## Name : Reena Qureshi(052)
## Section : V-B
## Architecture Overview

```markdown
┌─────────────────────────────────────────────────┐
│                  Internet                       │
└─────────────────┬───────────────────────────────┘
                  │
                  │ HTTPS (443)
                  │ HTTP (80)
                  ▼
         ┌────────────────────┐
         │   Nginx Server     │
         │  (Load Balancer)   │
         │   - SSL/TLS        │
         │   - Caching        │
         │   - Reverse Proxy  │
         └────────┬───────────┘
                  │
      ┌───────────┼───────────┐
      │           │           │
      ▼           ▼           ▼
   ┌─────┐     ┌─────┐     ┌─────┐
   │Web-1│     │Web-2│     │Web-3│
   │     │     │     │     │(BKP)│
   └─────┘     └─────┘     └─────┘
   Primary     Primary     Backup
```

## Project Structure

```
Assignment2/
├── main.tf
├── variables.tf
├── outputs.tf
├── locals.tf
├── terraform.tfvars.example
├── .gitignore
├── modules/
│   ├── networking/
│   ├── security/
│   └── webserver/
├── scripts/
│   ├── nginx-setup.sh
│   └── apache-setup.sh
└── README.md
```

## Technical Components

- **Terraform Modules**: Modularized infrastructure code for Networking, Security, and Web Servers.
- **Nginx (Reverse Proxy & Load Balancer)**: Handles SSL termination, caching, and distribution of requests between backend servers.
- **Apache Web Servers**: Three backend servers (web-1, web-2 as active; web-3 as backup).
- **Security Groups**: Granular control over ingress and egress traffic.
- **SSL/TLS**: Self-signed certificates generated automatically on Nginx server.
- **Caching**: Nginx configured to cache backend responses for improved performance.

## Deployment Instructions

### Prerequisites
1. Installed **Terraform**.
2. **AWS CLI** configured with appropriate credentials.
3. SSH Key Pair generated (e.g., `ssh-keygen -t ed25519`).

### Steps
1. **Clone the project** (or create the directory structure).
2. **Configure Variables**:
   - Copy `terraform.tfvars.example` to `terraform.tfvars`.
   - Update values for `vpc_cidr_block`, `subnet_cidr_block`, and key paths.
3. **Initialize Terraform**:
   ```bash
   terraform init
   ```
4. **Validate and Plan**:
   ```bash
   terraform validate
   terraform plan
   ```
5. **Apply Configuration**:
   ```bash
   terraform apply -auto-approve
   ```

## Post-Deployment Configuration

After deployment, follow these steps to activate the load balancer:

1. **SSH into Nginx server**:
   ```bash
   ssh ec2-user@<nginx-public-ip>
   ```
2. **Update Backend IPs**:
   Edit `/etc/nginx/nginx.conf` and replace the placeholder IPs in the `upstream backend_servers` block with the private IPs of your backend servers.
   ```nginx
   upstream backend_servers {
       server <web-1-private-ip>:80;
       server <web-2-private-ip>:80;
       server <web-3-private-ip>:80 backup;
   }
   ```
3. **Test and Restart Nginx**:
   ```bash
   sudo nginx -t
   sudo systemctl restart nginx
   ```

## Testing Results Verification

- **Load Balancing**: Refresh the page to see Hostname alternate between web-1 and web-2.
- **High Availability**: Stop Apache on web-1 and web-2 to see web-3 (backup) take over.
- **Caching**: Check response headers for `X-Cache-Status: HIT`.

## Cleanup

To avoid AWS costs, destroy the infrastructure when finished:
```bash
terraform destroy -auto-approve
```

