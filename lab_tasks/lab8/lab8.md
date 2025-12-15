# 🧪 Lab 8 – AWS: Account Setup, IAM, VPC Inventory, EC2, Docker & Gitea

Estimated Duration: 3 hours  
Instructions: Complete all tasks using your Windows host machine and a web browser (Mozilla Firefox or Google Chrome). Create a repository named `Lab8`. When finished, push your work to a repository named `CC_<student_Name>_<student_roll_number>/Lab8`.

---

## 🎯 Objective

In this lab you will:

- Create and verify an AWS root account (personal + paid) and enable the UAE region (me-central-1).
- Create IAM users with console access and Administrator permissions, download the .csv credential file, and log in as IAM users.
- Inspect VPC resources in the UAE region.
- Launch an EC2 instance (Amazon Linux, t2.micro), configure security groups and an ED25519 key pair, SSH into the instance from your Windows host.
- Install Docker and Docker Compose on the EC2 instance, deploy Gitea using a docker-compose file from the provided GitHub repo, and open the Gitea web UI.
- Practice cleaning up AWS resources to avoid charges.

Important safety note: You will enter real payment information to create a paid AWS account. Be aware of potential costs. Terminate and delete resources (EC2, EBS, security groups, snapshots, IAM users) when you finish to avoid charges.

---

## 🧩 Prerequisites

- Windows host machine with a web browser (Firefox or Chrome).
- An internet connection and the ability to receive SMS for phone verification.
- Basic familiarity with SSH from Windows (PowerShell, Windows Terminal, or Git Bash).
- A text editor on Windows for storing your Key Pair (.pem) securely.
- A GitHub account (optional—only if you want to push code from instance to GitHub).

Notes on screenshots and evidence:
- Group related commands and outputs into single screenshots where appropriate (for example: multiple export commands shown together; multiple grep outputs shown together).
- Do NOT include private credentials in screenshots (do not show passwords or secret keys). You may show the signin URL and console screens, but redact or avoid displaying passwords.
---

## 📋 Task List

- [Task 1: Create AWS root account and enable UAE (me-central-1)](#task-1--create-an-aws-account-and-enable-uae-me-central-1)
- [Task 2: Create IAM Admin user → create Lab8User and verify logins](#task-2--create-iam-admin-and-lab8user-with-console-access)
- [Task 3: Inspect VPC resources in UAE region](#task-3--inspect-vpc-resources-in-uae-me-central-1)
- [Task 4: Launch EC2, SSH, install Docker & Docker Compose, deploy Gitea](#task-4--launch-ec2-ssh-install-docker--docker-compose-deploy-gitea)
- [Cleanup: Remove resources to avoid charges](#cleanup--remove-resources-to-avoid-charges)
- [Submission](#submission)
- [Checklist](#checklist)


---

## Task 1 — Create an AWS account and enable UAE (me-central-1)

Goal: Register a new AWS root account and enable the UAE me-central-1 region.

Do these steps in order and capture a screenshot immediately after each numbered step. Place screenshots in Lab8/screenshots/.

### Steps and required screenshots:

1. Open your browser and go to: [AWS Signup](https://signin.aws.amazon.com/signup?request_type=register)  
![aws-signup](images/2..png)
   - Save screenshot as: `task1_open_signup_page.png` — browser showing the signup page.

2. Complete registration (Account type: Personal, Plan: AWS Paid Plan), fill contact, billing (credit card) and phone details, complete verification. After successful registration capture:  
   - Save screenshot as: `task1_signed_up_confirmation.png` — registration success/confirmation page or payment confirmation (do NOT include credit card full details).

3. Sign in as the root user (root email). Immediately capture:  
   - Save screenshot as: `task1_root_signed_in.png` — AWS Console Home after root login (top bar with root email/account alias visible).

4. From the Console, open the region selector and enable UAE (me-central-1), then switch to me-central-1. Capture the change:
![me-central-1](images/1.png)
   - Save screenshot as: `task1_enable_region_me-central-1.png` — region selector showing me-central-1 selected.

5. Task 1 summary screenshot (combine evidence):  
![me-central-1_active](images/3.png)
   - Save screenshot as: `task1_summary.png` — single screenshot showing root console header (root email/account alias) and region set to me-central-1.

Screenshots Required:
- `task1_open_signup_page.png`
- `task1_signed_up_confirmation.png`
- `task1_root_signed_in.png`
- `task1_enable_region_me-central-1.png`
- `task1_summary.png`

Important: Record your root login email, but never share your root password. Clean up resources after the lab.

---

## Task 2 — Create IAM Admin and Lab8User with console access

Goal: Create an IAM user named Admin (console access + AdministratorAccess policy), download the .csv, logout root, then login as the IAM Admin and create Lab8User with same permissions.

Do these steps in order and capture a screenshot immediately after each numbered step/substep. Place screenshots in Lab8/screenshots/.

### Steps and required screenshots:

1. Open IAM via Console search (Alt+S → "IAM").  
![IAM](images/4.png)

   - Save screenshot as: `task2_open_iam_console.png` — IAM console landing page (region me-central-1 visible).

2. Create the Admin user: IAM → Users → Create user. Fill:
![create_user](images/5.png)
   - Username: Admin
   - Provide user access to the AWS Management Console
   - Set console password (autogenerate or set)
   ![user-details](images/6.png)
   - Attach policies directly → AdministratorAccess  
   ![set-user-permission](images/7.png)
   ![review-user-details](images/8.png)
   ![view-created-user](images/9.png)
   Capture the completion screen when user is created:  
   - Save screenshot as: `task2_admin_create_confirmation.png` — IAM "Create user" success screen showing Admin (do NOT include password).

3. Download the Admin .csv and show its presence on your Windows host (do not display the password text):  
   - Save screenshot as: `task2_admin_csv_and_signin_url.png` — Windows File Explorer showing the downloaded CSV filename and/or a cropped view of the CSV showing only the Sign-in URL and username (redact the password if visible).

4. Sign out of root, then sign in using the Admin account (use the signin URL from the .csv). Capture after successful Admin login:  
   - Save screenshot as: `task2_admin_console_after_login.png` — Admin user console home.

5. While logged in as Admin, create Lab8User:
   - IAM → Users → Create user
   - Username: Lab8User
   - Provide user access to the AWS Management Console
   - Attach AdministratorAccess policy  
   Capture the create-user success screen:  
   - Save screenshot as: `task2_create_lab8user_and_csv.png` — Lab8User create confirmation and CSV download prompt (do NOT include password).

6. Download/save the Lab8User CSV on your Windows host (do not show password).  
   - Save screenshot as: `task2_lab8user_csv_saved.png` — File Explorer showing the Lab8User CSV filename (cropped to exclude sensitive content).

7. Logout Admin and login as Lab8User (use the Lab8User signin URL and credentials). Capture after login:  
   - Save screenshot as: `task2_lab8user_logged_in.png` — Lab8User console home.

8. Task 2 summary (combine evidence):  
   - Save screenshot as: `task2_summary.png` — IAM Users list showing both Admin and Lab8User present (region me-central-1 visible).

Screenshots Required:
- `task2_open_iam_console.png`
- `task2_admin_create_confirmation.png`
- `task2_admin_csv_and_signin_url.png`
- `task2_admin_console_after_login.png`
- `task2_create_lab8user_and_csv.png`
- `task2_lab8user_csv_saved.png`
- `task2_lab8user_logged_in.png`
- `task2_summary.png`

Notes:
- Keep the .csv files private. Only include signin URL and console screens in submission—do not include password text in screenshots.

---

## Task 3 — Inspect VPC resources (in UAE me-central-1)

Goal: In the VPC console list the counts of specific resources.

Do these steps in order and capture a screenshot immediately after viewing each page. Place screenshots in Lab8/screenshots/.

### Steps and required screenshots:

1. Open VPC console (Alt+S → "VPC") while region is me-central-1.  
![VPC](images/10.png)
![vpc-me-central-1](images/11.png)
   - Save screenshot as: `task3_open_vpc_console.png` — VPC console landing page (region visible).

2. View VPCs list. Capture:  
   - Save screenshot as: `task3_vpcs_list.png` — VPCs list view (show default VPC if present).

3. View Subnets list. Capture:  
   - Save screenshot as: `task3_subnets_list.png` — Subnets list view (show at least 3 default subnets if present).

4. View Route Tables list. Capture:  
   - Save screenshot as: `task3_route_tables_list.png` — Route Tables list view.

5. View Network ACLs list. Capture:  
   - Save screenshot as: `task3_network_acls_list.png` — Network ACLs list view.

6. Task 3 summary (combine evidence):  
   - Save screenshot as: `task3_summary.png` — a single screenshot showing the VPC console left navigation and counts or multiple open tabs/windows tiled to show each resource's list (region me-central-1 visible).

Screenshots Required:
- `task3_open_vpc_console.png`
- `task3_vpcs_list.png`
- `task3_subnets_list.png`
- `task3_route_tables_list.png`
- `task3_network_acls_list.png`
- `task3_summary.png`

In each screenshot show the console top bar with region set to me-central-1.

---

## Task 4 — Launch EC2, SSH, install Docker & Docker Compose, deploy Gitea

Goal: Launch an EC2 instance named Lab8Machine, configure security group Lab8SecurityGroup allowing SSH from your IP, create an ED25519 key pair Lab8Key (.pem), SSH from Windows host, install Docker & Docker Compose, create compose.yaml from the repository, run docker compose up -d, allow inbound TCP port 3000, and open Gitea UI.

### Steps and required screenshots:

1. Open EC2 Console (Alt+S → "EC2") (me-central-1).  
![EC2](images/12.png)
   - Save screenshot as: `task4_open_ec2_console.png` — EC2 console landing page with region visible.
![launch-instance](images/13.png)
2. Instance Launch configuration (during review before launching). Configure:
   - Name: Lab8Machine
   ![name-ec2](images/14.png)
   - AMI: Amazon Linux 2
   ![image-ec2](images/15.png)
   - Instance type: t3.micro
   ![t2-micro-ec2](images/16.png)
   - Security group: Create Lab8SecurityGroup with SSH from My IP
   ![security-group-ec2](images/17.png)
   - Storage: default
   ![storage-ec2](images/18.png)
   - Key pair: Create Lab8Key (ED25519, .pem) and download the .pem file to your Windows host  
   ![key-pair-ec2](images/19.png)
   Capture the final review page and the key download prompt:  
   - Save screenshot as: `task4_launch_instance_config.png` — final review page showing instance name, AMI, type, security group, key pair.
   - Save screenshot as: `task4_keypair_download.png` — Windows File Explorer showing Lab8Key.pem downloaded (do NOT open .pem contents).

3. After launch, EC2 Instances list showing Lab8Machine in "running" state and public IPv4 visible. 
![public-ip-ec2](images/20.png)
   - Save screenshot as: `task4_instance_running_console.png` — Instances table with Lab8Machine running and Public IPv4.

4. On Windows host, run SSH using the downloaded .pem (PowerShell/Git Bash/Windows Terminal):  
   ```bash
   ssh -i <path>/Lab8Key.pem ec2-user@<public-IP>
   ```  
   Capture the SSH command and successful shell prompt on the EC2 instance:  
   - Save screenshot as: `task4_ssh_from_windows_to_ec2.png` — PowerShell showing ssh command and EC2 shell (do NOT show private key contents).

5. Run the install commands on the EC2 shell:

   ```bash
   sudo yum update -y
   sudo yum install -y docker
   sudo mkdir -p /usr/local/lib/docker/cli-plugins
   sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
   sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
   sudo systemctl start docker
   ```
   Capture the terminal showing these commands run and successful outputs:  
   - Save screenshot as: `task4_ec2_install_docker_compose_started.png` — outputs of update/install and systemctl start.

6. Create/edit compose.yaml on the EC2 instance (sudo vim compose.yaml) and paste content from the repo: [Gitea](https://github.com/WaqasSaleem97/Gitea) . While pasting, capture the editor content:  
      - Save screenshot as: `task4_vim_compose_yaml_paste.png` — vim editor showing compose.yaml contents while pasted.

7. Save and verify file exists:  
      - Save screenshot as: `task4_compose_yaml_saved_ls.png` — ls -l showing compose.yaml present.

8. Add ec2-user to docker group, show groups before re-login, exit and reconnect, show groups after reconnect:

   ```bash
   groups    # user does not docker permission
   sudo usermod -aG docker $USER
   groups    # before re-login
   exit
   # Reconnect
   ssh -i <path>/Lab8Key.pem ec2-user@<public-IP>
   groups    # after re-login (should include docker)
   ```
   - Save screenshot as: `task4_usermod_and_groups_before_after.png` — show usermod command, groups output before exit, reconnect sequence, and groups output after (docker included).

9. Run docker compose up -d from the directory with compose.yaml:

   ```bash
   docker compose up -d
   ```
   - Save screenshot as: `task4_docker_compose_up.png` — output of docker compose up -d showing containers starting.

10. Edit the security group Lab8SecurityGroup inbound rules in the EC2 console: add Custom TCP rule port 3000 source 0.0.0.0/0 and save. Capture the inbound rules after saving:  
      - Save screenshot as: `task4_security_group_allow_3000.png` — security group inbound rules list showing SSH from My IP and Custom TCP 3000 anywhere.

11. From your Windows browser navigate to: http://Public-IP:3000 — capture the Gitea setup/install page:  
      - Save screenshot as: `task4_gitea_install_page.png` — Gitea installation page in browser.

12. Complete initial Gitea setup (create admin user, create a repo) and capture Gitea showing the created repository:  
      - Save screenshot as: `task4_gitea_create_repo.png` — Gitea UI showing the created repository.

13. Task 4 summary (combine evidence)  
      - Save screenshot as: `task4_summary.png` — single screenshot (or tiled screenshot) showing: EC2 Instances list with Lab8Machine running and public IP, security group inbound rules showing SSH and port 3000, and browser tab open to Gitea UI or repo list.

Screenshots Required:
- `task4_open_ec2_console.png`
- `task4_launch_instance_config.png`
- `task4_keypair_download.png`
- `task4_instance_running_console.png`
- `task4_ssh_from_windows_to_ec2.png`
- `task4_ec2_install_docker_compose_started.png`
- `task4_vim_compose_yaml_paste.png`
- `task4_compose_yaml_saved_ls.png`
- `task4_usermod_and_groups_before_after.png`
- `task4_docker_compose_up.png`
- `task4_security_group_allow_3000.png`
- `task4_gitea_install_page.png`
- `task4_gitea_create_repo.png`
- `task4_summary.png`

Notes:
- If http://Public-IP:3000 does not load, check instance status, docker compose logs, and security group inbound rules.
- If you used different ports or file paths, document them in your Lab8 writeup.

---

## Cleanup — Remove resources to avoid charges

After verification, terminate and delete everything you created. Capture screenshots immediately after each cleanup step.

Cleanup steps and required screenshots:

1. Terminate the EC2 instance Lab8Machine.  
   - Save screenshot as: `cleanup_terminate_instance.png` — EC2 terminate instance confirmation.

2. Delete associated EBS volumes and snapshots (if any).  
   - Save screenshot as: `cleanup_delete_volumes_snapshots.png` — confirmation or list showing volumes/snapshots deleted.

3. Delete security group Lab8SecurityGroup and key pair Lab8Key from the EC2 console (after instances terminated).  
   - Save screenshot as: `cleanup_delete_security_group_and_keypair.png` — deletion confirmation(s) (show key pair list and security group list after deletion).

4. Delete IAM users Lab8User and any access keys.  
   - Save screenshot as: `cleanup_iam_users_deleted.png` — IAM Users list showing Lab8User no longer present (or a deletion confirmation).

5. Final cleanup summary (show billing or resource groups with no active resources if possible).  
   - Save screenshot as: `cleanup_summary.png` — AWS console Billing/Resource Groups showing no active resources or no recent charges (if available).

Screenshots Required:
- `cleanup_terminate_instance.png`
- `cleanup_delete_volumes_snapshots.png`
- `cleanup_delete_security_group_and_keypair.png`
- `cleanup_iam_users_deleted.png`
- `cleanup_summary.png`

Important: Keep any local .pem file secure; if you prefer, securely delete local copies after the lab.

---

## Submission

Create a repository `CC_<YourName>_<YourRollNumber>/Lab8` with:

```
Lab8/
  workspace/                    # any files you created on the instance (optional)
  screenshots/                  # include ALL screenshots listed in this lab (optional)
  Lab8.md                       # this lab manual (this file)
  Lab8_solution.docx            # lab solution in MS Word
  Lab8_solution.pdf             # lab solution in PDF
```

Important: upload ALL screenshots listed in Tasks 1–4 and Cleanup. Filenames must match exactly.

---

## Checklist

- [ ] Task 1: Created AWS root account, enabled me-central-1. (screenshots: `task1_open_signup_page.png`, `task1_signed_up_confirmation.png`, `task1_root_signed_in.png`, `task1_enable_region_me-central-1.png`, `task1_summary.png`)
- [ ] Task 2: Created IAM Admin, downloaded .csv, logged in, created Lab8User (`task2_open_iam_console.png`, `task2_admin_create_confirmation.png`, `task2_admin_csv_and_signin_url.png`, `task2_admin_console_after_login.png`, `task2_create_lab8user_and_csv.png`, `task2_lab8user_csv_saved.png`, `task2_lab8user_logged_in.png`, `task2_summary.png`)
- [ ] Task 3: Inspected VPC resources in UAE (`task3_open_vpc_console.png`, `task3_vpcs_list.png`, `task3_subnets_list.png`, `task3_route_tables_list.png`, `task3_network_acls_list.png`, `task3_summary.png`)
- [ ] Task 4: Launched EC2 Lab8Machine, created Lab8Key (.pem), SSH into instance, installed Docker & Docker Compose, created compose.yaml from repo link, ran docker compose up -d, allowed inbound port 3000, opened Gitea and created repo (`task4_open_ec2_console.png`, `task4_launch_instance_config.png`, `task4_keypair_download.png`, `task4_instance_running_console.png`, `task4_ssh_from_windows_to_ec2.png`, `task4_ec2_install_docker_compose_started.png`, `task4_vim_compose_yaml_paste.png`, `task4_compose_yaml_saved_ls.png`, `task4_usermod_and_groups_before_after.png`, `task4_docker_compose_up.png`, `task4_security_group_allow_3000.png`, `task4_gitea_install_page.png`, `task4_gitea_create_repo.png`, `task4_summary.png`)
- [ ] Cleanup: terminated instance, deleted security group, key pair, IAM users (`cleanup_terminate_instance.png`, `cleanup_delete_volumes_snapshots.png`, `cleanup_delete_security_group_and_keypair.png`, `cleanup_iam_users_deleted.png`, `cleanup_summary.png`)
- [ ] Created and pushed `CC_<YourName>_<YourRollNumber>/Lab8` with Lab8.md and ALL screenshots

---

## Troubleshooting & Tips

- ED25519 key pair: save the downloaded Lab8Key.pem securely and set strict permissions on Windows. When using OpenSSH on Windows, you may need to place the .pem somewhere accessible and reference it with the -i flag.
- If ssh complains about permissions on PEM on Windows, use the Windows OpenSSH client (PowerShell) which accepts the .pem file.
- If docker compose binary path differs on Amazon Linux, verify the path: /usr/local/lib/docker/cli-plugins/docker-compose and ensure it is executable.
- If port 3000 still fails after adding the security group rule, ensure no OS-level firewall (iptables) is blocking the port in the instance.
- Always terminate and delete resources you no longer need.
