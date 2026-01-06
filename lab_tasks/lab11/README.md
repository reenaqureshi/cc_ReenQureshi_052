# 🧪 Lab 11 – GH CLI Codespaces + AWS + Terraform: Variables, Collections, Sensitivity & EC2 Provisioning

Estimated Duration: 3 hours  
Instructions: Complete all tasks using a GitHub Codespace (Linux environment) created and authenticated with the GitHub CLI. Create a repository named `Lab11`. When finished, push your work to a repository named `CC_<student_Name>_<student_roll_number>/Lab11`.

IMPORTANT: All steps that require GH CLI / Codespace MUST be performed inside the Codespace environment. Do not authenticate GH CLI outside the Codespace shell.

---

## 🎯 Objective

In this lab you will:

- Use GH CLI to work inside a Codespace.
- Create and modify Terraform files inside the Codespace.
- Practice Terraform variables of many kinds (string, map, object, list/tuple/set, any, null).
- Practice variable precedence: default, environment TF_VAR, terraform.tfvars, -var.
- Work with sensitive and ephemeral variables and examine terraform state behavior.
- Create VPC, Subnet, Routing, Security Group and EC2 instance + user_data on AWS.
- Use AWS CLI inside Codespace to query resources (subnet ids).
- Avoid committing secrets (use .gitignore).
- Produce required screenshots for verification.

---

## Task List
In this lab you will:

- [Task 0 - Lab Setup (Codespace & GH CLI)](#task-0-lab-setup-codespace--gh-cli)
- [Task 1 — Provider & Basic variable (variable precedence)](#task-1--provider--basic-variable-variable-precedence)
- [Task 2 — Variable validation & sensitive / ephemeral variables](#task-2--variable-validation--sensitive--ephemeral-variables)
- [Task 3 — Project-level variables, locals, and outputs](#task-3--project-level-variables-locals-and-outputs)
- [Task 4 — Maps and Objects](#task-4--maps-and-objects)
- [Task 5 — Collections: list, tuple, set & mutation via locals](#task-5--collections-list-tuple-set--mutation-via-locals)
- [Task 6 — Null, any type & dynamic values](#task-6--null-any-type--dynamic-values)
- [Task 7 — Git ignore](#task-7--git-ignore)
- [Task 8 — Clean-up then build real infra (VPC, Subnet, IGW, routing, default route table)](#task-8--clean-up-then-build-real-infra-vpc-subnet-igw-routing-default-route-table)
- [Task 9 — Security Group, key pair, EC2 instance, user_data & nginx](#task-9--security-group-key-pair-ec2-instance-user_data--nginx)
- [Cleanup — Destroy resources & verify state](#cleanup)
- [Submission](#submission)

---

## Task 0 Lab Setup (Codespace & GH CLI)

All actions below should be executed inside the Codespace shell.

Create Codespace & connect:
```bash
# create or open codespace via GH CLI (example)
gh repo create CC_<YourName>_<YourRollNumber>/Lab11 --public
gh codespace create --repo <user_name>/Lab11
gh codespace list
gh codespace ssh -c <your_codespace_name>
```
- **Save screenshot as:** `taskA_codespace_create_and_list.png` — output showing repo creation/codespace list.
- **Save screenshot as:** `taskA_codespace_ssh_connected.png` — terminal inside the Codespace shell after ssh.

**Screenshots Required:**
- `taskA_codespace_create_and_list.png`
- `taskA_codespace_ssh_connected.png`

---

## Task 1 — Provider & Basic variable (variable precedence)

1. In Codespace create `main.tf`:
```bash
touch main.tf
```
- **Save screenshot as:** `task1_touch_main_tf.png` — terminal showing touch main.tf.

2. Edit `main.tf` and add provider:
```hcl
provider "aws" {
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
}
```
- **Save screenshot as:** `task1_main_tf_provider.png` — editor showing provider block saved in main.tf.

3. Initialize:
```bash
terraform init
```
- **Save screenshot as:** `task1_terraform_init.png` — terraform init output.

4. Define a variable and output:
```hcl
variable "subnet_cidr_block" {
  type = string
}

output "subnet_cidr_block_output" {
  value = var.subnet_cidr_block
}
```
- **Save screenshot as:** `task1_variable_and_output_added.png` — main.tf showing variable and output blocks.

5. Run apply (first time without defaults):
```bash
terraform apply -auto-approve
# it will prompt for the value of subnet_cidr_block
```
- **Save screenshot as:** `task1_apply_prompt_for_var.png` — terminal showing terraform prompting for variable input.

6. Add a default to the variable:
```hcl
variable "subnet_cidr_block" {
  type    = string
  default = "10.0.0.0/24"
}
```
Run:
```bash
terraform apply -auto-approve
# will use default without prompting
```
- **Save screenshot as:** `task1_apply_with_default.png` — apply output showing default used.

7. Export environment variable in Codespace shell:
```bash
export TF_VAR_subnet_cidr_block=10.0.20.0/24
terraform apply -auto-approve
# output should show environment value
```
- **Save screenshot as:** `task1_env_var_set_and_apply.png` — terminal showing export and apply using TF_VAR value.

8. Create terraform.tfvars overriding values:
```bash
touch terraform.tfvars
# inside terraform.tfvars:
subnet_cidr_block = "10.0.30.0/24"
terraform apply -auto-approve
# terraform.tfvars has priority over default and env
```
- **Save screenshot as:** `task1_terraform_tfvars_and_apply.png` — cat terraform.tfvars and apply output showing its value used.

9. Override with -var:
```bash
terraform apply -auto-approve -var "subnet_cidr_block=10.0.40.0/24"
# -var is highest precedence
```
- **Save screenshot as:** `task1_var_override_with_dash_var.png` — command and apply showing -var value used.

10. Show and unset env var:
```bash
printenv | grep TF_VAR_
unset TF_VAR_subnet_cidr_block
printenv | grep TF_VAR_
```
- **Save screenshot as:** `task1_printenv_tf_var_and_unset.png` — showing TF_VAR present and then removed.

**Screenshots Required:**
- `task1_touch_main_tf.png`
- `task1_main_tf_provider.png`
- `task1_terraform_init.png`
- `task1_variable_and_output_added.png`
- `task1_apply_prompt_for_var.png`
- `task1_apply_with_default.png`
- `task1_env_var_set_and_apply.png`
- `task1_terraform_tfvars_and_apply.png`
- `task1_var_override_with_dash_var.png`
- `task1_printenv_tf_var_and_unset.png`

---

## Task 2 — Variable validation & sensitive / ephemeral variables

1. Replace `subnet_cidr_block` variable with this (validation included):
```hcl
variable "subnet_cidr_block" {
  type        = string
  default     = ""
  description = "CIDR block to assign to the application subnet"
  sensitive   = false
  nullable    = false
  ephemeral   = false

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]+$", var.subnet_cidr_block))
    error_message = "The subnet_cidr_block must be a valid CIDR notation string, such as 10.0.0.0/24."
  }
}
```
- **Save screenshot as:** `task2_subnet_variable_with_validation.png` — main.tf showing validation block.

2. Test validation failure:
```bash
terraform apply -auto-approve -var "subnet_cidr_block=10.0.0"
# should show validation error
```
- **Save screenshot as:** `task2_subnet_validation_error.png` — terminal showing validation error message.

3. Create a sensitive variable `api_session_token` and output (sensitive):
```hcl
variable "api_session_token" {
  type        = string
  default     = ""
  description = "Short‑lived API session token used during apply operations"
  sensitive   = true
  nullable    = false
  ephemeral   = false

  validation {
    condition     = can(regex("^[A-Za-z0-9-_]{20,}$", var.api_session_token))
    error_message = "The API session token must be at least 20 characters and contain only letters, numbers, hyphens, or underscores."
  }
}

output "api_session_token_output" {
  value     = var.api_session_token
  sensitive = true
}
```
- **Save screenshot as:** `task2_api_token_variable_added.png` — main.tf showing api_session_token and sensitive output.

4. Run with -var to observe sensitive output behavior:
```bash
terraform apply -auto-approve -var "api_session_token=my_API_session_Token"
# output will be marked sensitive; check terraform.tfstate for outputs
```
- **Save screenshot as:** `task2_api_token_apply_sensitive.png` — apply output showing sensitive output masked and/or noted.

5. Check terraform.state for the sensitive output:
- You should find an outputs section similar to:
```json
"api_session_token_output": {
  "value": "my_API_session_Token",
  "type": "string",
  "sensitive": true
}
```
- **Save screenshot as:** `task2_check_terraform_state_api_token.png` — showing terraform.tfstate outputs containing "api_session_token_output" with sensitive = true.

6. Make variable ephemeral to hide from state:
```hcl
variable "api_session_token" {
  ...
  ephemeral = true
  ...
}
```
- **Save screenshot as:** `task2_api_token_ephemeral_error.png` — terminal showing error or behavior when trying to output ephemeral variable.

7. Set default to test local default:
```hcl
variable "api_session_token" {
  default = "my_API_session_Token"
  sensitive = true
  ephemeral = false
  ...
}
terraform apply -auto-approve
# works and stored in state (but output remains sensitive)
```
- **Save screenshot as:** `task2_api_token_default_apply.png` — apply output showing default sensitive value accepted.

**Screenshots Required:**
- `task2_subnet_variable_with_validation.png`
- `task2_subnet_validation_error.png`
- `task2_api_token_variable_added.png`
- `task2_api_token_apply_sensitive.png`
- `task2_check_terraform_state_api_token.png`
- `task2_api_token_ephemeral_error.png`
- `task2_api_token_default_apply.png`

---

## Task 3 — Project-level variables, locals, and outputs

1. Add variables to `main.tf`:
```hcl
variable "environment" {}
variable "project_name" {}
variable "primary_subnet_id" {}
variable "subnet_count" {}
variable "monitoring" {}
```
- **Save screenshot as:** `task3_variables_added.png` — main.tf showing new variables.

2. Populate `terraform.tfvars` *after* discovering actual subnet id for availability zone `me-central-1a`:
```bash
aws ec2 describe-subnets \
  --filters "Name=availability-zone,Values=me-central-1a" \
  --query "Subnets[].SubnetId" \
  --output text
```
Set values in terraform.tfvars:
```hcl
environment = "dev"
project_name = "lab_work"
primary_subnet_id = "<subnet-id-of-me-central-1a>"
subnet_count = 3
monitoring = true
```
- **Save screenshot as:** `task3_terraform_tfvars_populated.png` — terraform.tfvars content and aws describe-subnets output showing subnet id.

3. Create `locals.tf` with:
```hcl
locals {
  resource_name = "${var.project_name}-${var.environment}"
  primary_public_subnet = var.primary_subnet_id
  subnet_count          = var.subnet_count
  is_production         = var.environment == "prod"
  monitoring_enabled    = var.monitoring || local.is_production
}
```
- **Save screenshot as:** `task3_locals_tf_created.png` — locals.tf content saved.

4. Add outputs to `main.tf`:
```hcl
output "resource_name" {
  value = local.resource_name
}
output "primary_public_subnet" {
  value = local.primary_public_subnet
}
output "subnet_count" {
  value = local.subnet_count
}
output "is_production" {
  value = local.is_production
}
output "monitoring_enabled" {
  value = local.monitoring_enabled
}
```
- Run:
```bash
terraform apply -auto-approve
# will show all the output values
```
- **Save screenshot as:** `task3_outputs_apply.png` — terraform apply output showing these outputs.

**Screenshots Required:**
- `task3_variables_added.png`
- `task3_terraform_tfvars_populated.png`
- `task3_locals_tf_created.png`
- `task3_outputs_apply.png`

---

## Task 4 — Maps and Objects

1. Map variable in `main.tf`:
```hcl
variable "tags" {
  type = map(string)
}

output "tags" {
  value = var.tags
}
```
- **Save screenshot as:** `task4_tags_variable_added.png` — main.tf showing tags variable and output.

2. In `terraform.tfvars`:
```hcl
tags = {
  Environment = "dev"
  Project     = "sample-app"
  Owner       = "platform-team"
}
```
Run:
```bash
terraform apply -auto-approve
# check tags output
```
- **Save screenshot as:** `task4_tags_output.png` — apply output showing tags returned.

3. Define object variable:
```hcl
variable "server_config" {
  type = object({
    name            = string
    instance_type   = string
    monitoring      = bool
    storage_gb      = number
    backup_enabled  = bool
  })
}

output "server_config" {
  value = var.server_config
}
```
In `terraform.tfvars`:
```hcl
server_config = {
  name            = "web-server"
  instance_type   = "t3.micro"
  monitoring      = true
  storage_gb      = 20
  backup_enabled  = false
}
```
- **Save screenshot as:** `task4_server_config_output.png` — apply output showing server_config object.

**Screenshots Required:**
- `task4_tags_variable_added.png`
- `task4_tags_output.png`
- `task4_server_config_output.png`


---

## Task 5 — Collections: list, tuple, set & mutation via locals
In this task you will define collection variables (list, tuple, set), observe their behavior, then perform mutations via locals and compare results.

| Feature         | List | Tuple | Set |
|-----------------|:----:|:-----:|:---:|
| Order preserved | ✅   | ✅    | ❌  |
| Allows duplicates | ✅ | ✅    | ❌  |
| Mixed types     | ❌   | ✅    | ❌  |
| Fixed size      | ❌   | ✅    | ❌  |
| Mutable         | ✅   | ❌    | ✅  |
| Best for        | **Flexible sequences** | **Structured records** | **Unique collections** |


1. In `main.tf` define:
```hcl
variable "server_names" {
  type = list(string)
  default = ["web-2", "web-1", "web-2"]
}

variable "server_metadata" {
  type = tuple([string, number, bool])
  default = ["web-1", 4, true]
}

variable "availability_zones" {
  type = set(string)
  default = ["me-central-1b", "me-central-1a", "me-central-1b"]
}

output "compare_collections" {
  value = {
    list_example  = var.server_names
    tuple_example = var.server_metadata
    set_example   = var.availability_zones
  }
}
```
- **Save screenshot as:** `task5_collections_defined.png` — main.tf showing collection variables and output.

2. Run:
```bash
terraform apply -auto-approve
```
Observe the output — note ordering, duplicates, and that sets are displayed without duplicates and order is not guaranteed.
- **Save screenshot as:** `task5_compare_collections.png` — apply output comparing of collections.

3. In `locals.tf` add mutations:
Create or edit locals.tf and add the following locals to demonstrate mutation behavior. Note: tuples are immutable in Terraform's type system, but many operations convert them to lists for evaluation.
```hcl
locals {
  mutated_list  = setunion(var.server_names, ["web-3"])
  mutated_tuple = setunion(var.server_metadata, ["web-2"])
  mutated_set   = setunion(var.availability_zones, ["me-central-1c"])
}
```
- **Save screenshot as:** `task5_locals_mutations.png` — locals.tf showing mutated values.

4. Add comparison output in `main.tf`:
```hcl
output "mutation_comparison" {
  value = {
    original_tuple = var.server_metadata
    mutated_tuple  = local.mutated_tuple
  }
}
```
Run:
```bash
terraform apply -auto-approve
```
Observe the difference between the original tuple and the mutated result. Note that Terraform may represent the mutated tuple as a list and the ordering/duplicates behavior will reflect setunion semantics.

- **Save screenshot as:** `task5_mutation_comparison.png` — apply output comparing original and mutated tuple.

Notes: Tuples are converted to lists for many operations; observe ordering and duplicate behavior.

**Screenshots Required:**
- `task5_collections_defined.png`
- `task5_compare_collections.png`
- `task5_locals_mutations.png`
- `task5_mutation_comparison.png`

---

## Task 6 — Null, any type & dynamic values

1. Null variable:
```hcl
variable "optional_tag" {
  type        = string
  description = "A tag that may or may not be provided"
  default     = null
}
```
- **Save screenshot as:** `task6_optional_tag_variable.png` — main.tf showing optional_tag variable.

2. Merge tags in `locals.tf`:
```hcl
locals {
  server_tags = merge(
    { Name = "web-server" },
    var.optional_tag != null ? { Custom = var.optional_tag } : {}
  )
}
```
- **Save screenshot as:** `task6_locals_merge.png` — locals.tf showing merge logic.

3. Output:
```hcl
output "optional_tag" {
  value = local.server_tags
}
```
Run:
```bash
terraform apply -auto-approve
```
- **Save screenshot as:** `task6_optional_tag_no_value.png` — apply output with no optional_tag set.

4. Add in terraform.tfvars:
```hcl
optional_tag = "dev"
```
```bash
terraform apply -auto-approve
# observe that Custom tag appears
```

- **Save screenshot as:** `task6_optional_tag_with_value.png` — apply output after setting optional_tag in terraform.tfvars.

5. Any type variable:
```hcl
variable "dynamic_value" {
  type        = any
  description = "A variable that can accept any data type"
  default     = null
}

output "value_received" {
  value = var.dynamic_value
}
```

6. Now test the dynamic (any) variable with different types. For each change, update terraform.tfvars with the specified value and run terraform apply -auto-approve, then capture the output.

a) String
- In terraform.tfvars:
```hcl
dynamic_value = "hello"
```
- Run:
```bash
terraform apply -auto-approve
```
- **Save screenshot as:** `task6_dynamic_value_string.png` — apply output when dynamic_value = "hello".

b) Number
- Change terraform.tfvars:
```hcl
dynamic_value = 42
```
- Run:
```bash
terraform apply -auto-approve
```
- **Save screenshot as:** `task6_dynamic_value_number.png` — apply output when dynamic_value = 42.

c) List
- Change terraform.tfvars:
```hcl
dynamic_value = ["a", "b", "c"]
```
- Run:
```bash
terraform apply -auto-approve
```
- **Save screenshot as:** `task6_dynamic_value_list.png` — apply output when dynamic_value is a list.

d) Map / Object
- Change terraform.tfvars:
```hcl
dynamic_value = {
  name = "server"
  cpu  = 4
}
```
- Run:
```bash
terraform apply -auto-approve
```
- **Save screenshot as:** `task6_dynamic_value_map.png` — apply output when dynamic_value is a map/object.

e) Null
- Change terraform.tfvars:
```hcl
dynamic_value = null
```
- Run:
```bash
terraform apply -auto-approve
```
- **Save screenshot as:** `task6_dynamic_value_null.png` — apply output when dynamic_value = null.

**Screenshots Required:**
- `task6_optional_tag_variable.png`
- `task6_locals_merge.png`
- `task6_optional_tag_no_value.png`
- `task6_optional_tag_with_value.png`
- `task6_dynamic_value_string.png`
- `task6_dynamic_value_number.png`
- `task6_dynamic_value_list.png`
- `task6_dynamic_value_map.png`
- `task6_dynamic_value_null.png`

---

## Task 7 — Git ignore

Create `.gitignore`:
```bash
touch .gitignore
```
Add entries:
```
.terraform/*
*.tfstate
*.tfstate.*
*.tfvars
*.pem
```
- **Save screenshot as:** `task7_gitignore_created.png` — .gitignore file content showing entries.

Note: This prevents secrets and state files from being accidentally committed.

**Screenshots Required:**
- `task7_gitignore_created.png`

---
## Task 8 — Clean-up then build real infra (VPC, Subnet, IGW, routing, default route table)

In this task you will clean previous example values and build a simple VPC + Subnet, attach an Internet Gateway, and configure routing (first with a custom route table and association, then switch to the default route table).

Perform all commands inside your Codespace shell.

1. Clean previous files
- Remove all variable assignments from `terraform.tfvars` (empty the file or delete it).
- Remove all content from `locals.tf` (delete or empty the file).
- Replace `main.tf` contents with only the provider block below (start fresh).

Provider block to put in `main.tf`:
```hcl
provider "aws" {
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
}
```
- **Save screenshot as:** `task8_clean_files.png` — showing cleaned terraform.tfvars, locals.tf, and main.tf.

2. Define variables in main.tf
Add these variable declarations to `main.tf` (below the provider block):
```hcl
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "availability_zone" {}
variable "env_prefix" {}
```
- **Save screenshot as:** `task8_variables_recreated.png` — main.tf showing the four variables added.

3. Create VPC in main.tf
Add the VPC resource to `main.tf`:
```hcl
resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
     Name = "${var.env_prefix}-vpc"
  }
}
```
- **Save screenshot as:** `task8_vpc_resources_added.png` — main.tf showing aws_vpc resource (after adding VPC).

4. Create Subnet in the VPC
Add the subnet resource to `main.tf`:
```hcl
resource "aws_subnet" "myapp_subnet_1" {
  vpc_id            = aws_vpc.myapp_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
     Name = "${var.env_prefix}-subnet-1"
  }
}
```
- **Save screenshot as:** `task8_subnet_resources_added.png` — main.tf showing aws_subnet resource (after adding subnet).

5. Populate terraform.tfvars
In `terraform.tfvars` add:
```hcl
vpc_cidr_block     = "10.0.0.0/16"
subnet_cidr_block  = "10.0.10.0/24"
availability_zone  = "me-central-1a"
env_prefix         = "dev"
```
- **Save screenshot as:** `task8_terraform_tfvars_vpc_values.png` — terraform.tfvars content showing the values added.

6. Apply to create VPC and Subnet
Initialize (if needed) and apply:
```bash
terraform init
terraform apply -auto-approve
```
Verify in AWS Console that the VPC and Subnet were created.
- **Save screenshot as:** `task8_vpc_subnet_apply.png` — terraform apply output showing VPC and subnet creation on AWS console screenshot.

7. Create Internet Gateway and Route Table (custom)
Add the Internet Gateway and a custom Route Table to `main.tf`:
```hcl
resource "aws_internet_gateway" "myapp_igw" {
  vpc_id = aws_vpc.myapp_vpc.id
  tags = {
     Name = "${var.env_prefix}-igw"
  }
}

resource "aws_route_table" "myapp_route_table" {
  vpc_id = aws_vpc.myapp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
  }

  tags = {
     Name = "${var.env_prefix}-rt"
  }
}
```
- **Save screenshot as:** `task8_igw_route_table_before_apply.png` — AWS console showing IGW and route table resources (before apply).

Apply:
```bash
terraform apply -auto-approve
```
Verify IGW and route table in AWS Console.
- **Save screenshot as:** `task8_igw_route_table_after_apply.png` — terraform apply output showing IGW and route table creation on AWS console.

8. Associate the Route Table with the Subnet
Add the association resource to `main.tf`:
```hcl
resource "aws_route_table_association" "a_rtb_subnet" {
  subnet_id      = aws_subnet.myapp_subnet_1.id
  route_table_id = aws_route_table.myapp_route_table.id
}
```
Apply:
```bash
terraform apply -auto-approve
```
Verify association in AWS Console (Subnet → Route Table).
- **Save screenshot as:** `task8_association_apply.png` — terraform apply output showing association creation.

9. Switch to default route table (use VPC default route table)
Now remove (or comment out) the custom route table and association resources from `main.tf`:
- Remove the `aws_route_table` "myapp_route_table" block.
- Remove the `aws_route_table_association` "a_rtb_subnet" block.

Then add this resource to update the default route table with a route to the IGW:
```hcl
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
```
- **Save screenshot as:** `task8_default_route_table.png` — main.tf showing aws_default_route_table resource (after change).

Apply:
```bash
terraform apply -auto-approve
```
Verify in AWS Console that the VPC's default route table has the 0.0.0.0/0 → IGW route and that the custom route table (if previously created) is no longer in use.
- **Save screenshot as:** `task8_default_route_table_apply.png` — terraform apply output showing default route table update.



**Screenshots Required:**
- `task8_clean_files.png`
- `task8_variables_recreated.png`
- `task8_vpc_resources_added.png`
- `task8_subnet_resources_added.png`
- `task8_terraform_tfvars_vpc_values.png`
- `task8_vpc_subnet_apply.png`
- `task8_igw_route_table_before_apply.png`
- `task8_igw_route_table_after_apply.png`
- `task8_association_apply.png`
- `task8_default_route_table.png`
- `task8_default_route_table_apply.png`

---


## Task 9 — Security Group, Key Pair, EC2 Instance, user_data & nginx

This task walks you through creating a security group, creating an EC2 key pair, launching an EC2 instance, verifying SSH access, and installing nginx via user_data (inline and from a script). Perform all commands from your Codespace shell.

1. Add variables to main.tf
Add these variables to your `main.tf`:
```hcl
variable "my_ip" {}

```
- **Save screenshot as:** `task9_my_ip_variable_added.png` — main.tf showing my_ip and other variables added.

2. Get your public IP and set terraform.tfvars 
From the Codespace shell:
```bash
curl icanhazip.com
```
Copy the IP and add to `terraform.tfvars`:
```hcl
my_ip = "<your_ip>/32"
instance_type = "t3.micro"
availability_zone = "me-central-1a"   # or your chosen AZ
env_prefix = "dev"
```
- **Save screenshot as:** `task9_public_ip_curl.png` — terminal showing curl icanhazip.com and terraform.tfvars edited with my_ip.

3. Create the Security Group (main.tf)
Add this resource to `main.tf`:
```hcl
resource "aws_default_security_group" "myapp_sg" {
  vpc_id      = aws_vpc.myapp_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}
```
- **Save screenshot as:** `task9_security_group_apply.png` — main.tf showing security group resource (before apply).

Run apply:
```bash
terraform apply -auto-approve
```
- **Save screenshot as:** `task9_security_group_apply.png` — terminal showing terraform apply output for security group (after apply) and verify in AWS Console.

4. Create an AWS key pair and save locally
Create a key pair and store the private key in your Codespace. Do NOT commit the `.pem` file.
```bash
aws ec2 create-key-pair \
  --key-name MyED25519Key \
  --key-type ed25519 \
  --key-format pem \
  --query 'KeyMaterial' \
  --output text > MyED25519Key.pem

chmod 600 MyED25519Key.pem
```
- **Save screenshot as:** `task9_keypair_created_and_saved.png` — terminal showing key creation and MyED25519Key.pem saved.

Ensure `.gitignore` contains:
```
*.pem
```
- **Save screenshot as:** `task9_keypair_created_and_saved.png` — .gitignore showing `*.pem` entry.

5. Add EC2 instance resource (initial)
Add the instance resource to `main.tf` (initially using the created key name):
```hcl
resource "aws_instance" "myapp-server" {
  ami                         = "ami-05524d6658fcf35b6" # Amazon Linux 2023
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.myapp_subnet_1.id
  security_groups             = [aws_default_security_group.default_sg.id]
  availability_zone           = var.availability_zone
  associate_public_ip_address = true
  key_name                    = "MyED25519Key"

  tags = {
    Name = "${var.env_prefix}-ec2-instance"
  }
}

output "aws_instance_public_ip" {
  value = aws_instance.myapp-server.public_ip
}
```
- **Save screenshot as:** `task9_instance_type_set.png` — main.tf showing instance_type variable and aws_instance resource (before apply).

Run:
```bash
terraform apply -auto-approve
```
- **Save screenshot as:** `task9_ec2_apply_and_public_ip.png` — terraform apply output showing EC2 created and public IP (or `terraform output`).

6. SSH into the instance (using MyED25519Key)
From the Codespace:
```bash
ssh -i MyED25519Key.pem ec2-user@<public-ip>
# verify commands, then exit
exit
```
- **Save screenshot as:** `task9_ssh_into_ec2.png` — terminal showing successful SSH session using MyED25519Key.pem.

7. Generate a local SSH keypair and register it in AWS via Terraform
On your Codespace, generate an SSH key pair (accept defaults or specify path):
```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
```
- **Save screenshot as:** `task9_ssh_keypair_and_ssh.png` — terminal showing ssh-keygen output and files in ~/.ssh.

Add a Terraform resource in `main.tf` to register the public key:
```hcl
resource "aws_key_pair" "ssh_key" {
  key_name   = "serverkey"
  public_key = file("~/.ssh/id_ed25519.pub")
}
```
Update the EC2 resource to use the Terraform-managed key:
```hcl
resource "aws_instance" "myapp-server" {
   ...
# replace key_name = "MyED25519Key" with:
key_name = aws_key_pair.ssh_key.key_name
   ...
}
```
- **Save screenshot as:** `task9_ssh_keypair_and_ssh.png` — main.tf showing aws_key_pair resource and updated aws_instance key_name.

Run:
```bash
terraform apply -auto-approve
```
- **Save screenshot as:** `task9_ec2_apply_and_public_ip.png` — terraform apply output showing EC2 updated to use new key (and any changes).

8. SSH using the newly registered key
Now SSH with your generated private key (the default ssh client will pick up `~/.ssh/id_ed25519`):
```bash
ssh ec2-user@<public-ip>
```
Verify login works.
- **Save screenshot as:** `task9_ssh_keypair_and_ssh.png` — terminal showing SSH session using the generated key.

9. Install nginx via inline user_data
Modify the `aws_instance` resource to include inline `user_data`:
```hcl
resource "aws_instance" "myapp-server" {
   ...
  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y nginx
                systemctl start nginx
                systemctl enable nginx
              EOF
  tags = {
    Name = "${var.env_prefix}-ec2-instance"
  }  
}
```
Apply:
```bash
terraform apply -auto-approve
```
SSH in and run:
```bash
curl localhost
```
Open `http://<public-ip>` in a browser — you should see the nginx default page.
- **Save screenshot as:** `task9_nginx_local_curl.png` — curl localhost inside the EC2 instance showing nginx response.
- **Save screenshot as:** `task9_nginx_browser_page.png` — browser showing nginx default page at http://<public-ip>.

10. Use an external script for user_data
Create a script file in the Codespace:
```bash
cat > entry-script.sh <<'EOF'
#!/bin/bash
yum update -y
yum install -y nginx
systemctl start nginx
systemctl enable nginx
EOF
```
- **Save screenshot as:** `task9_nginx_local_curl.png` — entry-script.sh created and permissions set.

Update `aws_instance` to use the file:
```hcl
resource "aws_instance" "myapp-server" {
   ...
user_data = file("entry-script.sh")
  tags = {
    Name = "${var.env_prefix}-ec2-instance"
  }  
}
```
Apply:
```bash
terraform apply -auto-approve
```
Reload the browser at `http://<public-ip>` to confirm nginx is served.
- **Save screenshot as:** `task9_nginx_browser_page.png` — browser showing nginx page after using entry-script.sh.

**Screenshots Required:**
- `task9_my_ip_variable_added.png`
- `task9_public_ip_curl.png`
- `task9_security_group_apply.png`
- `task9_keypair_created_and_saved.png`
- `task9_instance_type_set.png`
- `task9_ec2_apply_and_public_ip.png`
- `task9_ssh_into_ec2.png`
- `task9_ssh_keypair_and_ssh.png`
- `task9_nginx_local_curl.png`
- `task9_nginx_browser_page.png`


---

## Cleanup

1. Destroy all resources:
```bash
terraform destroy -auto-approve
```
- **Save screenshot as:** `cleanup_destroy.png` — terraform destroy output showing resources deleted.

2. Verify state files:
```bash
cat terraform.tfstate
cat terraform.tfstate.backup
```
- **Save screenshot as:** `cleanup_state_files.png` — showing terraform.tfstate and terraform.tfstate.backup contents (ensure no secrets are exposed).

3. Ensure no sensitive files are committed. If any private keys or credentials were accidentally committed — rotate them immediately.
- **Save screenshot as:** `cleanup_verify_no_secrets.png` — git status and .gitignore confirming no .pem, .tfstate, or credentials are staged.

**Screenshots Required:**
- cleanup_destroy.png
- cleanup_state_files.png
- cleanup_verify_no_secrets.png
---
## Submission

Create and push a repository named:

`CC_<YourName>_<YourRollNumber>/Lab11`

Repository structure:

```
Lab10/
  workspace/                    # any files you created in the Codespace (optional)
  screenshots/                  # include ALL screenshots listed in this lab (optional)
  Lab11.md                      # this lab manual (this file)
  Lab11_solution.docx           # lab solution in MS Word
  Lab11_solution.pdf            # lab solution in PDF
```

Important: Do NOT commit .pem files, AWS credentials, or terraform.tfstate/terraform.tfstate.backup. Make sure .gitignore has been created and includes these files.

---

## Notes & Tips

- Always work inside the Codespace (GH CLI) for this lab.
- Do not commit private keys, secrets, or state files.
- When testing sensitive/ephemeral variables — observe terraform state file and outputs to learn how Terraform records values.
- Use `terraform plan` to preview changes before applying if you want to avoid extra resources or charges.
- If you accidentally commit secrets, remove them from history and rotate keys immediately.

Good luck — follow steps carefully, capture the screenshots named above after each step, and push your Lab11 repository to GitHub as `CC_<YourName>_<YourRollNumber>/Lab11`.
