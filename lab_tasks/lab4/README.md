# 🧠 Lab 4 – Linux Remote & Forensic Operations  
**Name:** Reena Qureshi  
**Reg No:** 2023-BSE-052  
**Section:** V-B  

---

## 🔹 Task 1: Remote Access Verification (Cyber Login Check)

**Objective:**  
Establish a secure SSH connection to the Ubuntu VM and verify identity.

**Commands Used:**
```bash
ssh reenaqureshi@<ip-address>
whoami
pwd
hostname
```

**Summary:**  
Successfully connected to the Ubuntu server remotely, verified user identity, and confirmed host authenticity.

---

## 🔹 Task 2: Filesystem Inspection for Forensic Evidence

**Objective:**  
Inspect system directories to locate potential malicious files and collect OS details.

**Commands Used:**
```bash
ls -la /
cat /etc/os-release
ls -la /bin /sbin /usr /opt /etc /dev /var /tmp
ls -la ~
nano Q2_report.md
```

**Summary:**  
Explored the root directory, gathered OS version info, examined system-critical directories, and created a Markdown report summarizing binary locations.

---

## 🔹 Task 3: Evidence Handling & File Operations

**Objective:**  
Simulate secure file handling and workspace setup for forensic evidence.

**Commands Used:**
```bash
mkdir -p ~/workspace/analysis
cd ~/workspace/analysis
touch report.txt data.txt .hidden.txt
cp report.txt report_backup.txt
mv report_backup.txt report_final.txt
rm report_final.txt
cp -r ~/workspace ~/workspace_backup
history
```

**Summary:**  
Created a structured workspace, managed files securely, created backups, deleted redundant copies, and documented actions using command history.

---

## 🔹 Task 4: System Profiling and Process Monitoring

**Objective:**  
Collect system resource and process information for investigation.

**Commands Used:**
```bash
uname -a
top
df -h
free -h
ps aux
```

**Summary:**  
Gathered kernel, CPU, memory, and disk information. Identified running processes and confirmed normal system operation with no suspicious activity.

---

## 🔹 Task 5: System info, resources & processes

**Objective:**  
Collect system information (kernel, CPU, memory, disk) and list processes for analysis.

**Commands Used & Expected Outputs to Capture:**
```bash
# Kernel & OS info
uname -a                # -> save as uname.png

# CPU details (ensure model name visible)
cat /proc/cpuinfo       # -> save as cpuinfo.png

# Memory usage
free -h                 # -> save as meminfo.png

# Disk usage
df -h                   # -> save as diskinfo.png

# OS release information
cat /etc/os-release     # -> save as os-release.png

# Processes (show top lines of ps output)
ps aux                  # -> save as processes.png
```

**Summary:**  
Collected and documented kernel, CPU, memory, and disk information and listed active processes for forensic and performance review.

---

## 🔹 Task 6: User Account Audit & Privilege Escalation Simulation

**Objective:**  
Simulate user creation, verify privileges, and review authentication logs for forensic analysis. (Do NOT add the user to sudoers.)

**Commands Used:**
```bash
sudo adduser lab4user
getent passwd lab4user
su - lab4user
sudo whoami
exit
sudo cat /var/log/auth.log | grep lab4user
sudo deluser --remove-home lab4user   # optional cleanup
```

**Summary:**  
Created and verified a non-root user, tested administrative restrictions (expected sudo denial), checked authentication logs for user activity, and removed the user post-audit if needed.

---

## 🔹 Bonus Task: Demo Script Execution

**Objective:**  
Create and execute a simple shell script for automation practice.

**Script (run-demo.sh):**
```bash
#!/bin/bash
echo "Lab 4 demo: current user is $(whoami)"
echo "Current time: $(date)"
uptime
free -h
```

**Commands Used:**
```bash
nano ~/lab4/workspace/run-demo.sh
chmod +x ~/lab4/workspace/run-demo.sh
~/lab4/workspace/run-demo.sh
sudo ~/lab4/workspace/run-demo.sh   # optional
```

**Summary:**  
Executed a script displaying current user, time, uptime and memory usage.

---

# 🧾 Evaluation Questions

## Q1 — Remote Access Verification (Cyber Login Check)
**Commands:**
```bash
ssh reenaqureshi@<ip-address>
whoami
pwd
hostname
```
**Goal:** Show remote SSH login, confirm user and host.

---

## Q2 — Filesystem Inspection for Forensic Evidence
**Commands:**
```bash
ls -la /
cat /etc/os-release
ls -la /bin /sbin /usr /opt /etc /dev /var /tmp
ls -la ~
nano Q2_report.md
```
**Goal:** Document filesystem layout, OS version, hidden files and create a short report.

---

## Q3 — Evidence Handling & File Operations
**Commands:**
```bash
mkdir -p ~/forensics/sandbox
cd ~/forensics/sandbox
nano notes.txt
nano data.txt
nano .hidden.txt
cp notes.txt notes_backup.txt
mv notes_backup.txt notes_final.txt
rm notes_final.txt
cp -r ~/forensics ~/forensics_backup
history
```
**Goal:** Create sandbox, files (including hidden), backup, rename, delete and record history.

---

## Q4 — System Profiling & Process Monitoring
**Commands:**
```bash
uname -a
cat /proc/cpuinfo
free -h
df -h
ps aux
```
**Goal:** Gather OS/kernel, CPU, memory, disk and process list for investigation.

---

## Q5 — User Account Audit & Privilege Escalation Simulation
**Commands:**
```bash
sudo adduser lab4user
getent passwd lab4user
su - lab4user
sudo whoami
exit
sudo cat /var/log/auth.log | grep lab4user
sudo deluser --remove-home lab4user
```
**Goal:** Create and test a non-root user, check logs for authentication attempts, then cleanup.

---

## 📁 Folder Structure
```
workspace/
│
├── README.md
├── Q2_report.md
├── main.py
├── .env
├── run-demo.sh
│
└── screenshots/
    ├── uname.png
    ├── cpuinfo.png
    ├── meminfo.p# 🧪 Lab 4 – Virtualization & Linux Fundamentals
**Name:** Reena Qureshi  
**Reg No:** 2023-BSE-052  
**Section:** V-B  

---

## 🎯 Objective
This lab focuses on hands-on virtualization and Linux fundamentals using the existing Ubuntu Server VM.  
By completing this lab, you will be able to:
- Inspect VM resources and networking settings in VMware Workstation.  
- Explore the Linux filesystem hierarchy and hidden (dot) files.  
- Use basic Linux CLI commands to navigate and manipulate files.  
- Collect system information and monitor processes.  
- Create and verify non-root user accounts.  
- (Bonus) Create and run a small shell script.

---

## 🧩 Prerequisites
- Ubuntu Server VM from Lab 1 installed in VMware Workstation.  
- Host machine with VMware Workstation available.  
- SSH access to the VM from the host terminal.  
- Text editor available inside the VM (e.g., nano or vim).

---

## 🔹 Task 1 – Verify VM Resources in VMware
**Steps:**
1. Open VMware Workstation and locate your existing Ubuntu Server VM.  
2. Inspect and note:
   - VM name  
   - RAM  
   - CPU  
   - Disk size  
   - Network adapter type  

**Expected Output:** Screenshot of VM settings showing resources (saved as `vm_settings.png`).

---

## 🔹 Task 2 – Start VM and Log In
**Steps:**
1. Start the VM in VMware Workstation.  
2. From your host terminal (PowerShell or Git Bash), connect via SSH:
   ```bash
   ssh reenaqureshi@<vm-ip-address>
   ```
3. After login, verify:
   ```bash
   whoami
   pwd
   ```
**Expected Output:** Screenshot of both commands showing username and working directory (`whoami_pwd.png`).

---

## 🔹 Task 3 – Filesystem Exploration and Dot Files
**Steps:**
1. List root directory contents:
   ```bash
   ls -la /
   ```
2. Inspect key directories:
   ```bash
   ls -la /bin
   ls -la /sbin
   ls -la /usr
   ls -la /opt
   ls -la /etc
   ls -la /dev
   ls -la /var
   ls -la /tmp
   ```
3. Show hidden files in home directory:
   ```bash
   ls -la ~
   ```
4. Create a Markdown file describing differences between `/bin`, `/usr/bin`, and `/usr/local/bin`:
   ```bash
   nano ~/answers.md
   ```
   Example content:
   ```
   /bin – core commands for basic system functions.
   /usr/bin – general user programs installed by system packages.
   /usr/local/bin – manually installed or custom-built user programs.
   ```

---

## 🔹 Task 4 – Essential CLI Tasks (Navigation and File Operations)
**Steps:**
1. Create workspace and navigate:
   ```bash
   mkdir -p ~/lab4/workspace/python_project
   cd ~/lab4/workspace/python_project
   pwd
   ```
2. Create files using nano:
   ```bash
   nano README.md        # Add: Lab 4 README
   nano main.py          # Add: print("hello lab4")
   nano .env             # Add: ENV=lab4
   ```
3. Verify files:
   ```bash
   ls -la
   ```
4. File operations:
   ```bash
   cp README.md README.copy.md
   mv README.copy.md README.dev.md
   rm README.dev.md
   mkdir -p ~/lab4/workspace/java_app
   cp -r ~/lab4/workspace/python_project ~/lab4/workspace/java_app_copy
   ls -la ~/lab4/workspace
   ```
5. Show command history and demonstrate tab completion:
   ```bash
   history
   ```

---

## 🔹 Task 5 – System Information, Resources & Processes
**Steps:**
1. Kernel and OS details:
   ```bash
   uname -a
   ```
2. CPU information:
   ```bash
   cat /proc/cpuinfo
   ```
3. Memory usage:
   ```bash
   free -h
   ```
4. Disk usage:
   ```bash
   df -h
   ```
5. OS release information:
   ```bash
   cat /etc/os-release
   ```
6. Process list:
   ```bash
   ps aux
   ```

---

## 🔹 Task 6 – Users and Account Verification (No Sudo Group Change)
**Steps:**
1. Create a new user:
   ```bash
   sudo adduser lab4user
   ```
2. Verify user record:
   ```bash
   getent passwd lab4user
   ```
3. Switch to new user:
   ```bash
   su - lab4user
   ```
4. Test sudo restriction (expected failure):
   ```bash
   sudo whoami
   ```
5. Return to original user:
   ```bash
   exit
   ```
6. (Optional) Remove the user:
   ```bash
   sudo deluser --remove-home lab4user
   ```

---

## 🔹 Bonus Task 7 – Demo Script
**Steps:**
1. Create the script:
   ```bash
   nano ~/lab4/workspace/run-demo.sh
   ```
   Script content:
   ```bash
   #!/bin/bash
   echo "Lab 4 demo: current user is $(whoami)"
   echo "Current time: $(date)"
   uptime
   free -h
   ```
2. Make executable and run:
   ```bash
   chmod +x ~/lab4/workspace/run-demo.sh
   ~/lab4/workspace/run-demo.sh
   sudo ~/lab4/workspace/run-demo.sh   # optional
   ```

---

# 🧾 Exam Evaluation Questions

## Q1 – Remote Access Verification
**Objective:** Verify secure connection to Ubuntu VM.  
**Commands:**
```bash
ssh reenaqureshi@<vm-ip-address>
whoami
pwd
hostname
```

---

## Q2 – Filesystem Inspection for Forensic Evidence
**Objective:** Explore and record filesystem structure.  
**Commands:**
```bash
ls -la /
cat /etc/os-release
ls -la /bin /sbin /usr /opt /etc /dev /var /tmp
ls -la ~
nano Q2_report.md
```

---

## Q3 – Evidence Handling & File Operations
**Objective:** Simulate secure file handling in sandbox environment.  
**Commands:**
```bash
mkdir -p ~/forensics/sandbox
cd ~/forensics/sandbox
touch file1.txt file2.txt .hiddenfile
cp file1.txt file1_backup.txt
mv file1_backup.txt file1_final.txt
rm file1_final.txt
cp -r ~/forensics ~/forensics_backup
history
```

---

## Q4 – System Profiling & Process Monitoring
**Objective:** Identify system performance and active processes.  
**Commands:**
```bash
uname -a
cat /proc/cpuinfo
free -h
df -h
ps aux
```

---

## Q5 – User Account Audit & Privilege Escalation Simulation
**Objective:** Simulate user creation and privilege verification.  
**Commands:**
```bash
sudo adduser lab4user
getent passwd lab4user
su - lab4user
sudo whoami
exit
sudo cat /var/log/auth.log | grep lab4user
sudo deluser --remove-home lab4user
```

---

## 📁 Folder Structure
```
Lab4/
│
├── README.md
├── answers.md
├── Q2_report.md
├── workspace/
│   ├── python_project/
│   │   ├── README.md
│   │   ├── main.py
│   │   └── .env
│   ├── java_app/
│   └── java_app_copy/
│
└── screenshots/
    ├── vm_settings.png
    ├── whoami_pwd.png
    ├── uname.png
    ├── cpuinfo.png
    ├── meminfo.png
    ├── diskinfo.png
    ├── os-release.png
    ├── processes.png
    ├── adduser_lab4user.png
    ├── lab4user_passwd.png
    ├── su_lab4user.png
    ├── sudo_whoami.png
    └── exit_back.png
```

---

## ✅ Lab Summary
- Verified VM configuration in VMware Workstation.  
- Connected to Ubuntu VM using SSH from host terminal.  
- Explored filesystem and hidden files.  
- Practiced core Linux navigation and file management.  
- Collected kernel, CPU, memory, disk, and process info.  
- Created and tested a non-root user without sudo privileges.  
- (Bonus) Created and executed a demo shell script.

---

**Submitted by:**  
_Reena Qureshi_  
**Reg No:** 2023-BSE-052  
**Section:** V-B  
ng
    ├── diskinfo.png
    ├── os-release.png
    ├── processes.png
    └── (other screenshots per tasks)
```

---

## ✅ Lab Summary
In this lab I performed remote SSH verification, explored filesystem layout and hidden files, executed core Linux CLI tasks for file handling, gathered system profiling data, created and audited user accounts without granting sudo privileges, and optionally wrote and executed a demo script for automation practice.

**Submitted by:**  
Reena Qureshi — 2023-BSE-052 — Section V-B
