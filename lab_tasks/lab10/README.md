# 🧪 Lab 10 – GH CLI Codespaces + AWS + Terraform: CLI Automation of VPC/Subnet Creation

Estimated Duration: 3 hours  
Instructions: Complete all tasks using a GitHub Codespace (Linux environment) created and authenticated with the GitHub CLI. Create a repository named `Lab10`. When finished, push your work to a repository named `CC_<student_Name>_<student_roll_number>/Lab10`.

**IMPORTANT**: You MUST use GitHub CLI and Codespaces as outlined in Task 1. Do not perform CLI authentication outside the Codespace environment.

---

## 🎯 Objective

In this lab you will:

- Install and authenticate GitHub CLI in your Codespace.
- Install and configure AWS CLI inside the Codespace.
- Install and verify Terraform CLI via Codespace.
- Use Terraform to provision AWS VPC and subnets, manipulate resources, and use outputs.
- Practice robust CLI resource manipulation (create/modify/destroy) and state investigation.
- Use queries, tags, and outputs for reporting infrastructure attributes.
- Learn state file management and resource tracking via Terraform and AWS CLI.
- Prepare screenshots and evidence for all steps.

---

## 📋 Task List

- [Task 1: GH CLI installation, authentication, Codespaces (in Codespace)](#task-1--github-cli-codespace-setup-authentication)
- [Task 2: AWS CLI install/configure, Terraform install & verify, create main.tf provider block](#task-2--install-aws-cli-terraform-cli-provider-setup)
- [Task 3: VPC/Subnet resource creation via Terraform, verification with CLI filters](#task-3--vpc-subnet-creation-initialization-verification)
- [Task 4: Data sources, targeted destroy/refresh/apply, resource tagging](#task-4--datasource-targeted-destroy-tags)
- [Task 5: State file inspection, backup handling, terraform state commands](#task-5--state-file-inspection-commands)
- [Task 6: Terraform output blocks: return values (id, arn, attributes)](#task-6--terraform-outputs--attributes-reporting)
- [Cleanup: Remove all resources, inspect state files](#cleanup--delete-resources-state-verification)
- [Submission: Prepare repository CC_<YourName>_<YourRollNumber>/Lab10 with required screenshots & docs](#submission)

---

## Task 1 — GitHub CLI Codespace Setup & Authentication

Goal: Install GH CLI (if not present), authenticate for Codespace use, and connect into the Codespace shell **(all steps inside Codespace unless noted)**.

1. Install GitHub CLI:
    ```powershell
    winget install --id GitHub.cli
    ```
    - **Save screenshot as:** `task1_gh_install.png` — terminal showing the winget install command output.

2. Authenticate GH CLI for Codespaces:
    ```bash
    gh auth login -s codespace
    ```
    - When prompted, generate a **GitHub access token (classic)**. Set scopes to: `admin:org`, `codespace`, `repo`.
    - **Save screenshot as:** `task1_gh_auth_login.png` — screenshot of gh auth login confirmation (redact token).

3. List available codespaces:
    ```bash
    gh codespace list
    ```
    - **Save screenshot as:** `task1_codespace_list.png` — output showing the codespace name.

4. Connect to a codespace via SSH:
    ```bash
    gh codespace ssh -c <name_of_codespace>
    ```
    - **Save screenshot as:** `task1_codespace_ssh_connected.png` — terminal inside the Codespace shell after ssh.

**Screenshots Required:**
- `task1_gh_install.png`
- `task1_gh_auth_login.png`
- `task1_codespace_list.png`
- `task1_codespace_ssh_connected.png`

---

## Task 2 — Install AWS CLI, Terraform CLI, Provider Setup

Goal: Install AWS CLI (if not present) & Terraform CLI inside Codespace; configure initial Terraform provider.

### A. Install AWS CLI (Skip if already installed)

1. In Codespace shell, install AWS CLI:
    ```bash
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    aws --version
    ```
    - **Save screenshot as:** `task2_aws_install_and_version.png` — show AWS CLI installation and version output.

2. Configure AWS CLI:
    ```bash
    aws configure
    ```
    - **Save screenshot as:** `task2_aws_configure_and_files.png` — show aws configure prompt (redact secret values).
    - Then check config files:
    ```bash
    cat ~/.aws/credentials
    cat ~/.aws/config
    ```
    - **Save screenshot as:** `task2_aws_configure_and_files.png` — output of cat commands (redact secret keys if visible).

3. Verify AWS CLI connectivity:
    ```bash
    aws sts get-caller-identity
    ```
    - **Save screenshot as:** `task2_aws_get_caller_identity.png` — output of aws sts get-caller-identity.

### B. Install Terraform CLI

1. Install Terraform CLI:
    ```bash
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update
    sudo apt install terraform
    which terraform
    terraform --version
    ```
    - **Save screenshot as:** `task2_terraform_install_and_version.png` — terraform installation and version check output.

### C. Provider Configuration (`main.tf`)

- Create `main.tf` using Vim:
    ```bash
    vim main.tf
    ```
    - **Save screenshot as:** `task2_provider_file_creation.png` — creation/editing of main.tf.

- Inside `main.tf`, write:
    ```hcl
    provider "aws" {
      shared_config_files      = ["~/.aws/config"]
      shared_credentials_files = ["~/.aws/credentials"]
    }
    ```
    - **Save screenshot as:** `task2_provider_block.png` — final content saved in main.tf.

- Save and quit: Press ESC then `:wq`
    - **Save screenshot as:** `task2_vim_save_main_tf.png` — Vim save confirmation (optional).

- Initialize Terraform:
    ```bash
    terraform init
    ```
    - **Save screenshot as:** `task2_terraform_init_output.png` — terraform init output.
- Show contents of `.terraform.lock.hcl`:
    ```bash
    cat .terraform.lock.hcl
    ```
    - **Save screenshot as:** `task2_terraform_lock_hcl.png` — output of `.terraform.lock.hcl`.
- Show contents of `.terraform/` directory:
    ```bash
    ls .terraform/
    ```
    - **Save screenshot as:** `task2_terraform_dir_ls.png` — output of `ls .terraform/`.

**Screenshots Required:**
- `task2_aws_install_and_version.png`
- `task2_aws_configure_and_files.png`
- `task2_aws_get_caller_identity.png`
- `task2_terraform_install_and_version.png`
- `task2_provider_file_creation.png`
- `task2_provider_block.png`
- `task2_vim_save_main_tf.png`
- `task2_terraform_init_output.png`
- `task2_terraform_lock_hcl.png`
- `task2_terraform_dir_ls.png`

---

## Task 3 — VPC/Subnet Creation, Initialization, Verification

Goal: Use Terraform to create VPC & Subnet resources, verify via CLI.

1. Edit `main.tf` to add:
    ```hcl
    resource "aws_vpc" "development_vpc" {
      cidr_block = "10.0.0.0/16"
    }

    resource "aws_subnet" "dev_subnet_1" {
      vpc_id     = aws_vpc.development_vpc.id
      cidr_block = "10.0.10.0/24"
      availability_zone = "me-central-1a"
    }
    ```
    - Use `vim main.tf`, edit and insert code.
    - **Save screenshot as:** `task3_main_tf_resource_add.png` — new resources added and visible in main.tf.

2. Run:
    ```bash
    terraform apply
    ```
    - Type `yes` when prompted.
    - **Save screenshot as:** `task3_terraform_apply_vpc_subnet.png` — output showing successful apply and resources creation.

3. Verify resources using AWS CLI:

    - Run:
      ```bash
      aws ec2 describe-subnets --filter "Name=subnet-id,Values=<subnet-id>"
      ```
      - **Save screenshot as:** `task3_aws_cli_verify_subnet.png` — output of describe-subnets command.

    - Run:
      ```bash
      aws ec2 describe-vpcs --filter "Name=vpc-id,Values=<vpc-id>"
      ```
      - **Save screenshot as:** `task3_aws_cli_verify_vpc.png` — output of describe-vpcs command.

**Screenshots Required:**
- `task3_main_tf_resource_add.png`
- `task3_terraform_apply_vpc_subnet.png`
- `task3_aws_cli_verify_subnet.png`
- `task3_aws_cli_verify_vpc.png`

---

## Task 4 — Data Source, Targeted Destroy, Tags

### A. Data Source & Resource Creation

1. Add to `main.tf`:
    ```hcl
    data "aws_vpc" "existing_vpc" {
      default = true
    }

    resource "aws_subnet" "dev_subnet_1_existing" {
      vpc_id     = data.aws_vpc.existing_vpc.id
      cidr_block = "172.31.48.0/24"
      availability_zone = "me-central-1a"
    }
    ```
    - Use vim to edit and insert code.
    - **Save screenshot as:** `task4_main_tf_datasource_resource_add.png` — main.tf with datasource and resource added.

2. Apply configuration:
    ```bash
    terraform apply
    ```
    - Confirm only the new subnet is created.
    - **Save screenshot as:** `task4_terraform_apply_datasource_resource.png` — terraform output of resource creation.

### B. Targeted Destroy & Refresh

1. Destroy only one resource:
    ```bash
    terraform destroy -target=aws_subnet.dev_subnet_1_existing
    ```
    - **Save screenshot as:** `task4_terraform_destroy_targeted.png` — targeted destroy output.

2. Refresh state:
    ```bash
    terraform refresh
    ```
    - **Save screenshot as:** `task4_terraform_refresh_state.png` — terraform refresh output.

3. Re-apply configuration:
    ```bash
    terraform apply
    ```
    - **Save screenshot as:** `task4_terraform_apply_after_refresh.png` — terraform apply after refresh.

4. Destroy all resources:
    ```bash
    terraform destroy
    ```
    - **Save screenshot as:** `task4_terraform_destroy_all.png` — full destroy output.

5. Plan configuration:
    ```bash
    terraform plan
    ```
    - **Save screenshot as:** `task4_terraform_plan_output.png` — terraform plan showing next changes.

6. Apply again:
    ```bash
    terraform apply
    ```
    - **Save screenshot as:** `task4_terraform_apply_after_destroy.png` — output showing resources recreated.

### C. Tagging Resources

1. Modify `main.tf` to add tags:
    ```hcl
    resource "aws_vpc" "development_vpc" {
      cidr_block = "10.0.0.0/16"
      tags = {
         Name: "development"
         vpc_env = "dev"
      }
    }

    resource "aws_subnet" "dev_subnet_1" {
      vpc_id     = aws_vpc.development_vpc.id
      cidr_block = "10.0.10.0/24"
      availability_zone = "me-central-1a"
      tags = {
         Name: "subnet-1-dev"
      }
    }

    resource "aws_subnet" "dev_subnet_1_existing" {
      vpc_id     = data.aws_vpc.existing_vpc.id
      cidr_block = "172.31.48.0/24"
      availability_zone = "me-central-1a"
      tags = {
         Name: "subnet-1-default"
      }
    }
    ```
    - Use vim to update tags.
    - **Save screenshot as:** `task4_main_tf_tagging.png` — main.tf with tags added.

2. Run:
    ```bash
    terraform refresh
    terraform apply -auto-approve
    ```
    - **Save screenshot as:** `task4_terraform_apply_tagging.png` — output showing tags applied.

3. Remove `vpc_env = "dev"` tag from `development_vpc` resource, re-plan/apply:
    - **Save screenshot as:** `task4_terraform_plan_remove_tag.png` — plan output showing tag removal.
    - **Save screenshot as:** `task4_terraform_apply_remove_tag.png` — apply output showing tag deleted.

**Screenshots Required:**
- `task4_main_tf_datasource_resource_add.png`
- `task4_terraform_apply_datasource_resource.png`
- `task4_terraform_destroy_targeted.png`
- `task4_terraform_refresh_state.png`
- `task4_terraform_apply_after_refresh.png`
- `task4_terraform_destroy_all.png`
- `task4_terraform_plan_output.png`
- `task4_terraform_apply_after_destroy.png`
- `task4_main_tf_tagging.png`
- `task4_terraform_apply_tagging.png`
- `task4_terraform_plan_remove_tag.png`
- `task4_terraform_apply_remove_tag.png`

---

## Task 5 — State File Inspection & Terraform State Commands

1. Destroy all resources:
    ```bash
    terraform destroy
    ```
    - **Save screenshot as:** `task5_terraform_destroy.png` — destroy output.

2. Inspect state files after destroy:

    - Run:
      ```bash
      cat terraform.tfstate
      ```
      - **Save screenshot as:** `task5_terraform_state_file_empty.png` — output showing terraform.tfstate is empty after destroy.

    - Run:
      ```bash
      cat terraform.tfstate.backup
      ```
      - **Save screenshot as:** `task5_terraform_state_backup_prev.png` — output showing backup file with previous resources.

3. Recreate resources:
    ```bash
    terraform apply
    ```
    - **Save screenshot as:** `task5_terraform_apply_recreated.png` — apply output, resources recreated.

4. View state files:

    - Run:
      ```bash
      cat terraform.tfstate
      ```
      - **Save screenshot as:** `task5_terraform_state_file_populated.png` — output showing populated terraform.tfstate after restore.

    - Run:
      ```bash
      cat terraform.tfstate.backup
      ```
      - **Save screenshot as:** `task5_terraform_state_backup_empty.png` — output showing backup file empty after restore.

5. List resources:
    ```bash
    terraform state list
    ```
    - **Save screenshot as:** `task5_terraform_state_list.png` — terraform state list output.

6. Show full attributes:
    ```bash
    terraform state show <resource-name>
    ```
    - **Save screenshot as:** `task5_terraform_state_show_resource.png` — state show output for one resource.

7. Note: Do **NOT** run the following (for information only):
    ```
    terraform state rm <resource-name>
    ```
    - Mentioned for knowledge — do not run.

**Screenshots Required:**
- `task5_terraform_destroy.png`
- `task5_terraform_state_file_empty.png`
- `task5_terraform_state_backup_prev.png`
- `task5_terraform_apply_recreated.png`
- `task5_terraform_state_file_populated.png`
- `task5_terraform_state_backup_empty.png`
- `task5_terraform_state_list.png`
- `task5_terraform_state_show_resource.png`

---

## Task 6 — Terraform Outputs & Attributes Reporting

1. Add outputs in `main.tf`:
    ```hcl
    output "dev-vpc-id" {
      value = aws_vpc.development_vpc.id
    }
    output "dev-subnet-id" {
      value = aws_subnet.dev_subnet_1.id
    }
    output "dev-vpc-arn" {
      value = aws_vpc.development_vpc.arn
    }
    output "dev-subnet-arn" {
      value = aws_subnet.dev_subnet_1.arn
    }
    ```
    - **Save screenshot as:** `task6_terraform_outputs_basic.png` — output values for ids and arns after apply.

**Return ALL of the following output attributes from your VPC and Subnet resources:**
- a) `cidr_block`
- b) `region`
- c) `tags.Name`
- d) `tags_all`

Expand output section in `main.tf` accordingly:
```hcl
output "dev-vpc-cidr_block" {
  value = aws_vpc.development_vpc.cidr_block
}
output "dev-vpc-region" {
  value = aws_vpc.development_vpc.region
}
output "dev-vpc-tags_name" {
  value = aws_vpc.development_vpc.tags["Name"]
}
output "dev-vpc-tags_all" {
  value = aws_vpc.development_vpc.tags_all
}
output "dev-subnet-cidr_block" {
  value = aws_subnet.dev_subnet_1.cidr_block
}
output "dev-subnet-region" {
  value = aws_subnet.dev_subnet_1.availability_zone
}
output "dev-subnet-tags_name" {
  value = aws_subnet.dev_subnet_1.tags["Name"]
}
output "dev-subnet-tags_all" {
  value = aws_subnet.dev_subnet_1.tags_all
}
```
Run `terraform apply` and record outputs.

- **Save screenshot as:** `task6_expanded_outputs.png` — output values for each required attribute after apply.

**Screenshots Required:**
- `task6_terraform_outputs_basic.png`
- `task6_expanded_outputs.png`

---

## Cleanup — Delete Resources & State Verification

1. Destroy all resources:  
    ```bash
    terraform destroy
    ```
    - **Save screenshot as:** `cleanup_destroy_resources.png` — destroy output.

2. Inspect state files:
    ```bash
    cat terraform.tfstate
    cat terraform.tfstate.backup
    ```
    - **Save screenshot as:** `cleanup_state_files.png` — outputs showing file contents after clean-up.

3. Reapply then compare state and backup files to see differences.

**Screenshots Required:**
- `cleanup_destroy_resources.png`
- `cleanup_state_files.png`

---

## Submission

Create and push a repository named:

`CC_<YourName>_<YourRollNumber>/Lab10`

Repository structure:

```
Lab10/
  workspace/                    # any files you created in the Codespace (optional)
  screenshots/                  # include ALL screenshots listed in this lab (optional)
  Lab10.md                      # this lab manual (this file)
  Lab10_solution.docx           # lab solution in MS Word
  Lab10_solution.pdf            # lab solution in PDF
```

Required file to commit and push: `Lab10.md` and solution documents (Word/PDF) with all required screenshots. **DO NOT** include .pem/.aws/credentials/access keys in your repository.

---

## Troubleshooting & Tips

- Never commit private keys or credentials to Git. If accidentally committed, rotate keys immediately.
- Follow proper steps for resource tagging, attribute extraction, and state file examination.
- Remove resources promptly to avoid charges.

---

Good luck — complete each step carefully, **save the required screenshots explicitly as named**, and submit your Lab10 repository as instructed.
