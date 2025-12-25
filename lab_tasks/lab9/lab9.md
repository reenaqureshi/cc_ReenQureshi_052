# 🧪 Lab 9 – Codespaces + AWS: GH CLI (Codespaces), AWS CLI, EC2, IAM, Security Groups, Filters & Queries

Estimated Duration: 3 hours  
Instructions: Complete all tasks using a GitHub Codespace (Linux environment) created with the GitHub CLI. Create a repository named `Lab9`. When finished, push your work to a repository named `CC_<student_Name>_<student_roll_number>/Lab9`.

IMPORTANT: For this lab you MUST use the GitHub CLI and Codespaces as shown in Task 1. Do not perform the GH CLI authentication steps outside the Codespace environment.

---

## 🎯 Objective

In this lab you will:

- Install and authenticate GitHub CLI in your Codespace, create and connect to a Codespace.
- Install and configure the AWS CLI in the Codespace.
- Create and manage EC2 security groups, key pairs, run/stop/start/terminate EC2 instances.
- Inspect VPC resources and practice AWS describe/filter/query commands.
- Create IAM groups/users, assign policies, create access keys and test environment-variable authentication from the Codespace.
- Use AWS CLI queries and filters to extract useful information.

Security note: Do NOT publish or commit any AWS credentials, private keys, or GitHub tokens. Redact secret values in screenshots. If you must store keys locally, keep them secure and delete when the lab is finished.

---

## 📋 Task List

- [Task 1: Install GH CLI, authenticate for Codespaces and create/connect to a Codespace (in Codespace environment)](#task-1--github-cli-codespace-setup-and-authentication)
- [Task 2: Install AWS CLI in Codespace and configure it](#task-2--install-aws-cli-inside-the-codespace-and-configure-it)
- [Task 3: Create and update EC2 security group rules (use Codespace public IP)](#task-3--create-security-group-and-add-ingress-rules-using-codespace-ip)
- [Task 4: Create EC2 key pair, launch instance, fix SSH permissions, SSH from Codespace (or forward) and test connectivity](#task-4--create-a-key-pair-describe-key-pairs-and-launch-ec2-instance)
- [Task 5: Inspect AWS resources (describe-*) commands](#task-5--understand-aws-describe--commands)
- [Task 6: Create IAM group and user, attach policies, create console login and access keys](#task-6--iam-create-group-user-attach-policies-create-console-login--keys)
- [Task 7: Practice describe-instances filters and queries](#task-7--filters-query-with-filters-to-find-instances-and-their-attributes)
- [Task 8: Query outputs and format them for reporting](#task-8--use---query-to-format-outputs-for-reporting)
- [Cleanup: Remove resources to avoid charges](#cleanup--remove-resources-to-avoid-charges)
- [Submission: Prepare repository `CC_<YourName>_<YourRollNumber>/Lab9` with Lab9.md and evidence](#submission)

---

## Task 1 — GitHub CLI, Codespace setup and authentication

Goal: Install GH CLI (if not already present), authenticate with GitHub, create a Codespace, and connect to it. All work for the rest of the lab must be done inside the Codespace.

Steps (do these from your local machine shell first, then run codespace commands):

1. (Local desktop) Install GitHub CLI (Windows example via winget):
   ```powershell
   winget install --id GitHub.cli
   ```
   - Save screenshot as: `task1_gh_install.png` — terminal showing the winget install command output.

2. (Local) Authenticate GH CLI for Codespaces:
   ```bash
   gh auth login -s codespace
   ```
   - When prompted, generate a GitHub Access Token (classic) in the browser with the following Token scopes:
     - admin:org
     - codespace
     - repo
   - Copy the token into the GH CLI prompt to complete login.
   - Save screenshot as: `task1_gh_auth_login.png` — screenshot of gh auth login confirmation (redact token).

   Note: If your organization enforces SSO or device MFA, follow the organization's flow.

3. (Local) List available Codespaces (optional verification):
   ```bash
   gh codespace list
   ```
   - Save screenshot as: `task1_codespace_list.png` — `gh codespace list` output (show codespace name).

4. (Local) Create or connect to a Codespace. To create a new codespace from the current repo:
   ```bash
   gh codespace create --repo <owner>/<repo> --branch main --machine basicLinux32gb
   ```
   Or to open an existing codespace:
   ```bash
   gh codespace ssh -c <name_of_codespace>
   ```
   - After connecting via gh codespace ssh, you will be inside a Linux shell that the rest of this lab assumes.
   - Save screenshot as: `task1_codespace_ssh_connected.png` — terminal inside the Codespace shell after `gh codespace ssh -c <name>`.

Important: ALL remaining steps must be executed from inside the Codespace shell (unless specifically noted). Continue from the Codespace prompt.

Screenshots Required:
- `task1_gh_install.png`
- `task1_gh_auth_login.png`
- `task1_codespace_list.png`
- `task1_codespace_ssh_connected.png`

---

## Task 2 — Install AWS CLI inside the Codespace and configure it

Goal: Install the AWS CLI in the Codespace and configure it to interact with your AWS account.

Inside the Codespace shell run:

1. Download and install AWS CLI:
   ```bash
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   ```
   - Save screenshot as: `task2_aws_install_and_version.png` — terminal showing the download/unzip/install output.

2. Verify installation:
   ```bash
   aws --version
   ```
   - Save screenshot as: `task2_aws_install_and_version.png` — include aws --version output (same file as install output is acceptable).

3. Configure the AWS CLI (you will provide Access Key ID and Secret Access Key for a user with permissions, or use root/IAM user you prepared for the lab):
   ```bash
   aws configure
   ```
   - Enter:
     - AWS Access Key ID
     - AWS Secret Access Key
     - Default region name (e.g., me-central-1)
     - Default output format (e.g., json)
   - Save screenshot as: `task2_aws_configure_and_files.png` — show aws configure prompt (redact secret values if visible).

4. Verify credentials/config files:
   ```bash
   cat ~/.aws/credentials
   cat ~/.aws/config
   ```
   - Save screenshot as: `task2_aws_configure_and_files.png` — output of cat commands (redact secrets).

5. Verify connectivity (you should see a JSON result showing your caller identity):
   ```bash
   aws sts get-caller-identity
   ```
   Expected output (example):
   ```json
   {
       "UserId": "EXAMPLEUSERID1234567890",
       "Account": "123456789012",
       "Arn": "arn:aws:iam::123456789012:user/ExampleUser"
   }
   ```
   - Save screenshot as: `task2_aws_get_caller_identity.png` — aws sts get-caller-identity output.

Screenshots Required:
- `task2_aws_install_and_version.png`
- `task2_aws_configure_and_files.png`
- `task2_aws_get_caller_identity.png`

---

## Task 3 — Create security group and add ingress rules using Codespace IP

Goal: Create an EC2 security group, inspect it, add an SSH rule for your Codespace public IP, and verify.

Steps (run in the Codespace shell):

1. Create a security group (substitute your VPC id):
   ```bash
   aws ec2 create-security-group --group-name 'MySecurityGroup' \
     --description 'My Security Group' \
     --vpc-id 'vpc-EXAMPLE1234567890'
   ```
   This command returns a security group id, for example `sg-EXAMPLE1234567890`.
   - Save screenshot as: `task3_create_security_group_output.png` — output of create-security-group.

2. Inspect the security group (initially ingress will be empty or default):
   ```bash
   aws ec2 describe-security-groups --group-ids sg-EXAMPLE1234567890
   ```
   - Save screenshot as: `task3_describe_sg_before_ingress.png` — describe-security-groups before adding rules.

3. Get your Codespace public IP (from inside the Codespace):
   ```bash
   curl icanhazip.com
   ```
   - Save screenshot as: `task3_codespace_public_ip.png` — output of curl icanhazip.com.

4. Authorize SSH inbound on port 22 from your Codespace IP:
   ```bash
   aws ec2 authorize-security-group-ingress \
     --group-id sg-EXAMPLE1234567890 \
     --protocol tcp \
     --port 22 \
     --cidr <XXX.XXX.XXX.XXX>/32
   ```
   - Save screenshot as: `task3_authorize_ssh_and_describe.png` — authorize-security-group-ingress for SSH and subsequent describe output.

5. Verify ingress rule appears:
   ```bash
   aws ec2 describe-security-groups --group-ids sg-EXAMPLE1234567890
   ```
   - Save screenshot as: `task3_authorize_ssh_and_describe.png` — describe output showing SSH ingress (same file as previous step is acceptable).

6. Add an HTTP rule (port 80) using ip-permissions JSON:
   ```bash
   aws ec2 authorize-security-group-ingress \
     --group-id 'sg-EXAMPLE1234567890' \
     --ip-permissions '{"FromPort":80,"ToPort":80,"IpProtocol":"tcp","IpRanges":[{"CidrIp":"<XXX.XXX.XXX.XXX>/32"}]}'
   ```
   - Save screenshot as: `task3_authorize_http_and_describe.png` — HTTP ip-permissions command and response.

7. Verify both ingress rules are present:
   ```bash
   aws ec2 describe-security-groups --group-ids sg-EXAMPLE1234567890
   ```
   - Save screenshot as: `task3_describe_sg_final.png` — final describe showing both ingress rules.

Screenshots Required:
- `task3_create_security_group_output.png`
- `task3_describe_sg_before_ingress.png`
- `task3_codespace_public_ip.png`
- `task3_authorize_ssh_and_describe.png`
- `task3_authorize_http_and_describe.png`
- `task3_describe_sg_final.png`

Notes:
- Replace sg-EXAMPLE... and vpc-EXAMPLE... with actual ids returned in your account.
---

## Task 4 — Create a key pair, describe key pairs, and launch EC2 instance

Goal: Create an ED25519 key pair, view it, and launch an EC2 instance using the key pair and the security group created earlier.

Steps:

1. Create the key pair and save the PEM file into the Codespace workspace:
   ```bash
   aws ec2 create-key-pair \
     --key-name MyED25519Key \
     --key-type ed25519 \
     --key-format pem \
     --query 'KeyMaterial' \
     --output text > MyED25519Key.pem
   ```
   - Save screenshot as: `task4_create_keypair_output.png` — output of create-key-pair and `ls -l MyED25519Key.pem`.

2. View created key pairs:
   ```bash
   aws ec2 describe-key-pairs
   ```
   - Save screenshot as: `task4_describe_keypairs.png` — describe-key-pairs output.

3. (Do not) Delete key pair:
   ```bash
   aws ec2 delete-key-pair --key-name MyED25519Key # Info: shows how to delete
   ```
   - Save screenshot as: `task4_delete_keypair_optional.png` — output of delete-key-pair (if performed).

4. Launch an EC2 instance (example values — replace IDs with ones from your account/region):
   ```bash
   aws ec2 run-instances \
     --image-id ami-05e66df2bafcb7dea \
     --count 1 \
     --instance-type t3.micro \
     --key-name MyED25519Key \
     --security-group-ids sg-EXAMPLE1234567890 \
     --subnet-id subnet-EXAMPLE1234567890 \
     --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=MyServer}]"
   ```
   - Save screenshot as: `task4_run_instances_output.png` — run-instances output with instance id.

5. Get the public IP address of your instance:
   ```bash
   aws ec2 describe-instances \
     --query "Reservations[*].Instances[*].[InstanceId,PublicIpAddress]" \
     --output table
   ```
   - Save screenshot as: `task4_describe_instances_public_ip.png` — describe-instances table with public IP.

6. Attempt SSH into the instance from the Codespace or from a machine whose IP is allowed in the security group:
   ```bash
   ssh -i MyED25519Key.pem ec2-user@<public-ip-address>
   ```
   - If you see the error:
     ```
     Permissions 0644 for 'MyED25519Key.pem' are too open.It is required that your private key files are NOT accessible by others.
     ```
     fix permissions:
     ```bash
     chmod 400 MyED25519Key.pem
     ssh -i MyED25519Key.pem ec2-user@<public-ip-address>
     ```
   - Save screenshot as: `task4_ssh_permission_error_and_fix.png` — show permission error and chmod 400 then successful SSH (redact sensitive details).

7. Stop, start and (optionally) terminate the instance:
   ```bash
   aws ec2 stop-instances --instance-ids i-EXAMPLE1234567890
   aws ec2 start-instances --instance-ids i-EXAMPLE1234567890
   aws ec2 terminate-instances --instance-ids i-EXAMPLE1234567890 # Don't run this command
   ```
   - Save screenshot as: `task4_stop_start_terminate_commands.png` — outputs for stop/start/terminate.

Screenshots Required:
- `task4_create_keypair_output.png`
- `task4_describe_keypairs.png`
- `task4_delete_keypair_optional.png`
- `task4_run_instances_output.png`
- `task4_describe_instances_public_ip.png`
- `task4_ssh_permission_error_and_fix.png`
- `task4_stop_start_terminate_commands.png`

---

## Task 5 — Understand AWS describe-* commands

Goal: Use describe commands to list and inspect AWS resources.

Run and understand these commands (run each, then capture screenshot immediately after):

```bash
aws ec2 describe-security-groups
```
- Save screenshot as: `task5_describe_security_groups.png` — output of describe-security-groups.

```bash
aws ec2 describe-vpcs
```
- Save screenshot as: `task5_describe_vpcs.png` — output of describe-vpcs.

```bash
aws ec2 describe-subnets
```
- Save screenshot as: `task5_describe_subnets.png` — output of describe-subnets.

```bash
aws ec2 describe-instances
```
- Save screenshot as: `task5_describe_instances.png` — output of describe-instances.

```bash
aws ec2 describe-regions
```
- Save screenshot as: `task5_describe_regions.png` — output of describe-regions.

```bash
aws ec2 describe-availability-zones
```
- Save screenshot as: `task5_describe_availability_zones.png` — output of describe-availability-zones.

Screenshots Required:
- `task5_describe_security_groups.png`
- `task5_describe_vpcs.png`
- `task5_describe_subnets.png`
- `task5_describe_instances.png`
- `task5_describe_regions.png`
- `task5_describe_availability_zones.png`

---

## Task 6 — IAM: create group, user, attach policies, create console login & keys

Goal: Practice managing IAM via CLI: create group and user, attach policies, add user to group, create login profile, attach/detach change-password policy, create access keys, and test access via environment variables.

Commands and immediate screenshot request after each step:

1. Create group:
   ```bash
   aws iam create-group --group-name MyGroupCli
   ```
   - Save screenshot as: `task6_create_group_and_user.png` — create-group output.

2. Get group details:
   ```bash
   aws iam get-group --group-name MyGroupCli
   ```
   - Save screenshot as: `task6_create_group_and_user.png` — get-group output.

3. Create user:
   ```bash
   aws iam create-user --user-name MyUserCli
   ```
   - Save screenshot as: `task6_create_group_and_user.png` — create-user output.

4. Get user details:
   ```bash
   aws iam get-user --user-name MyUserCli
   ```
   - Save screenshot as: `task6_create_group_and_user.png` — get-user output.

5. Add user to group:
   ```bash
   aws iam add-user-to-group --user-name MyUserCli --group-name MyGroupCli
   ```
   - Save screenshot as: `task6_add_user_to_group_and_verify.png` — add-user-to-group and verify with get-group.

6. See group again:
   ```bash
   aws iam get-group --group-name MyGroupCli
   ```
   - Save screenshot as: `task6_add_user_to_group_and_verify.png` — get-group showing user present.

7. List policies that mention EC2:
   ```bash
   aws iam list-policies \
     --query "Policies[?contains(PolicyName, 'EC2')].{Name:PolicyName}" \
     --output text
   ```
   - Save screenshot as: `task6_policy_list_and_attach.png` — policy list output.

8. Get ARN for AmazonEC2FullAccess (example query):
   ```bash
   aws iam list-policies --query 'Policies[?PolicyName==`AmazonEC2FullAccess`].{Name:PolicyName, ARN:Arn}' --output table
   ```
   - Save screenshot as: `task6_policy_list_and_attach.png` — ARN query output.

9. Attach policy to group (use the ARN you retrieved):
   ```bash
   aws iam attach-group-policy \
     --group-name MyGroupCli \
     --policy-arn arn:aws:iam::aws:policy/EXAMPLEPolicyName
   ```
   - Save screenshot as: `task6_policy_list_and_attach.png` — attach-group-policy output.

10. List attached policies for the group:
    ```bash
    aws iam list-attached-group-policies --group-name MyGroupCli
    ```
    - Save screenshot as: `task6_policy_list_and_attach.png` — list-attached-group-policies output.

11. Create a console login profile for the user:
    ```bash
    aws iam create-login-profile \
      --user-name MyUserCli \
      --password <PASSWORD_VALUE> \
      --password-reset-required
    ```
    - Save screenshot as: `task6_create_login_profile_and_signin.png` — create-login-profile output (do not show password).

12. If the user cannot change password, attach IAMUserChangePassword to the group temporarily:
    ```bash
    aws iam attach-group-policy --group-name MyGroupCli --policy-arn arn:aws:iam::aws:policy/IAMUserChangePassword
    ```
    After the user logs in and resets password, detach that policy:
    ```bash
    aws iam detach-group-policy --group-name MyGroupCli --policy-arn arn:aws:iam::aws:policy/IAMUserChangePassword
    ```
    - Save screenshot as: `task6_create_login_profile_and_signin.png` — attach/detach outputs and a screenshot showing the user login (redact password).

13. Create access keys for the user (save AccessKeyId and SecretAccessKey securely):
    ```bash
    aws iam create-access-key --user-name MyUserCli
    ```
    - Save screenshot as: `task6_create_access_key_output.png` — create-access-key output (redact keys).

14. List access keys:
    ```bash
    aws iam list-access-keys --user-name MyUserCli
    ```
    - Save screenshot as: `task6_create_access_key_output.png` — list-access-keys output.

15. (Don't) Delete access key:
    ```bash
    aws iam delete-access-key --user-name MyUserCli --access-key-id <AccessKeyId> # Don't run this command
    ```
    - Save screenshot as: `task6_create_access_key_output.png` — delete-access-key output (if performed).

16. Use environment variables to authenticate as that user in the Codespace:
    ```bash
    export AWS_ACCESS_KEY_ID=<YOUR_ACCESS_KEY_ID>
    export AWS_SECRET_ACCESS_KEY=<YOUR_SECRET_ACCESS_KEY>
    printenv | grep AWS_
    aws iam get-user --user-name MyUserCli   # may fail if no permissions
    exit   # to clear exports
    ```
    - Save screenshot as: `task6_env_exports_and_get_user_error.png` — show env exports and any AccessDenied error (if occurs).
    - After clearing or switching credentials, repeat get-user and save:
      - Save screenshot as: `task6_after_logout_and_get_user_success.png` — successful get-user output under appropriate credentials.

Screenshots Required:
- `task6_create_group_and_user.png`
- `task6_add_user_to_group_and_verify.png`
- `task6_policy_list_and_attach.png`
- `task6_create_login_profile_and_signin.png`
- `task6_create_access_key_output.png`
- `task6_env_exports_and_get_user_error.png`
- `task6_after_logout_and_get_user_success.png`

Notes:
- Do NOT put sensitive keys into committed files. Remove environment variables after testing.

---

## Task 7 — Filters: query with filters to find instances and their attributes

Goal: Use filters and queries to list specific instances and attributes.

Examples (run each and take a screenshot immediately after):

```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=MyServer" \
  --query "Reservations[*].Instances[*].PublicIpAddress" \
  --output text
```
- Save screenshot as: `task7_filter_by_tag_public_ip.png` — output of the filter by tag showing public IP.

```bash
aws ec2 describe-instances \
  --filters "Name=instance-type,Values=t3.micro" \
  --query "Reservations[].Instances[].InstanceId" \
  --output table
```
- Save screenshot as: `task7_filter_by_instance_type.png` — output listing instance IDs.

```bash
aws ec2 describe-instances \
  --filters "Name=subnet-id,Values=subnet-0600df5fa8ce60857" \
  --query "Reservations[*].Instances[*].InstanceId" \
  --output table
```
- Save screenshot as: `task7_filter_by_subnet.png` — output for subnet filter.

```bash
aws ec2 describe-instances \
  --filters "Name=vpc-id,Values=vpc-06be85cd81b657192" \
  --query "Reservations[*].Instances[*].InstanceId" \
  --output table
```
- Save screenshot as: `task7_filter_by_vpc.png` — output for VPC filter.

Screenshots Required:
- `task7_filter_by_tag_public_ip.png`
- `task7_filter_by_instance_type.png`
- `task7_filter_by_subnet.png`
- `task7_filter_by_vpc.png`

---

## Task 8 — Use --query to format outputs for reporting

Goal: Extract useful fields in table format for reporting.

Examples (run each and take a screenshot immediately after):

```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=MyServer" \
  --query "Reservations[*].Instances[*].[InstanceId,PublicIpAddress,Tags[?Key=='Name'].Value|[0]]" \
  --output table
```
- Save screenshot as: `task8_query_table_instances_name_ip.png` — table showing InstanceId, PublicIpAddress, Name.

```bash
aws ec2 describe-instances \
  --query "Reservations[*].Instances[*].[InstanceId,State.Name]" \
  --output table
```
- Save screenshot as: `task8_query_table_instance_state.png` — table showing InstanceId and State.

```bash
aws ec2 describe-instances \
  --query "Reservations[*].Instances[*].[InstanceId,InstanceType,Placement.AvailabilityZone]" \
  --output table
```
- Save screenshot as: `task8_query_table_instance_type_az.png` — table showing InstanceId, InstanceType, AvailabilityZone.

Screenshots Required:
- `task8_query_table_instances_name_ip.png`
- `task8_query_table_instance_state.png`
- `task8_query_table_instance_type_az.png`

---

## Cleanup — Remove resources to avoid charges

After verification, terminate and delete everything you created in AWS. Capture screenshots for each step.

Cleanup steps and required screenshots (take each screenshot immediately after running the command):

1. Terminate instances:
   ```bash
   aws ec2 terminate-instances --instance-ids i-EXAMPLE1234567890
   ```
   - Save screenshot as: `cleanup_terminate_instance.png` — terminate-instances output/confirmation.

2. Delete EBS volumes & snapshots (if any):
   - Save screenshot as: `cleanup_delete_volumes_snapshots.png` — confirmation or listing showing volumes/snapshots deleted.

3. Delete security group and key pair:
   ```bash
   aws ec2 delete-security-group --group-id sg-EXAMPLE1234567890
   aws ec2 delete-key-pair --key-name MyED25519Key
   ```
   - Save screenshot as: `cleanup_delete_security_group_and_keypair.png` — deletion confirmation(s).

4. Remove IAM users, access keys, groups:
   ```bash
   aws iam delete-access-key --user-name MyUserCli --access-key-id <AccessKeyId>
   aws iam delete-login-profile --user-name MyUserCli
   aws iam remove-user-from-group --user-name MyUserCli --group-name MyGroupCli
   aws iam delete-user --user-name MyUserCli
   aws iam detach-group-policy --group-name MyGroupCli --policy-arn arn:aws:iam::aws:policy/EXAMPLEPolicyName
   aws iam delete-group --group-name MyGroupCli
   ```
   - Save screenshot as: `cleanup_iam_users_deleted.png` — IAM deletion commands and confirmation.

5. Final verification (billing/resource groups):
   - Save screenshot as: `cleanup_summary.png` — final console verification (billing/resource groups) showing no active resources if possible.

Screenshots Required:
- `cleanup_terminate_instance.png`
- `cleanup_delete_volumes_snapshots.png`
- `cleanup_delete_security_group_and_keypair.png`
- `cleanup_iam_users_deleted.png`
- `cleanup_summary.png`

Important: Double-check the AWS console to ensure resources are removed and you are not being billed.

---

## Submission

Create and push a repository named:

CC_<YourName>_<YourRollNumber>/Lab9

Repository structure:

```
Lab9/
  workspace/                    # any files you created in the Codespace (optional)
  screenshots/                  # include ALL screenshots listed in this lab (optional)
  Lab9.md                       # this lab manual (this file)
  Lab9_solution.docx            # lab solution in MS Word
  Lab9_solution.pdf             # lab solution in PDF
```

Required file to commit and push: Lab9.md (this file) and the word file containing all required images. DO NOT include any .pem, .aws/credentials files, or access keys in the repository.

Submission checklist (update as you complete):
- [ ] Task 1: GitHub CLI + Codespace (screenshots listed)
- [ ] Task 2: AWS CLI install & configure (screenshots listed)
- [ ] Task 3: Security group creation & ingress rules (screenshots listed)
- [ ] Task 4: Key pair, EC2 launch, SSH (screenshots listed)
- [ ] Task 5: describe-* commands (screenshots listed)
- [ ] Task 6: IAM group/user/policies/keys (screenshots listed)
- [ ] Task 7: Filters (screenshots listed)
- [ ] Task 8: Query outputs (screenshots listed)
- [ ] Cleanup: All resources terminated and deleted

---

## Troubleshooting & Tips

- Never commit private keys or credentials to Git. If accidentally committed, rotate keys immediately.
- If ssh complains about PEM permissions, run `chmod 400 MyED25519Key.pem`.
- Use `aws ec2 describe-instances --filters` and `--query` to produce concise reports.
- If ports do not respond, check both AWS security groups and the instance's OS firewall (iptables/firewalld).
- Remove resources promptly to avoid charges.

---

Good luck — complete each step carefully, capture the required screenshots, and submit the Lab9 repository `CC_<YourName>_<YourRollNumber>/Lab9` with Lab9.md and evidence.
