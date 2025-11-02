# Cloud Computing – Lab #6: Linux Users, Groups, Permissions, Pipes, and Bash Scripting  

**Name:** Reena Qureshi  
**Registration No.:** 2023-BSE-052  
**Subject:** Cloud Computing  

---

This lab focused on advanced Linux administration and shell scripting skills. All 14 tasks were performed on the same Ubuntu Server VM used in Lab 5, covering practical operations such as user and group configuration, permission management, text filtering with pipes and redirections, and shell scripting fundamentals.

All seven tasks were successfully completed, verified, and documented in the attached PDF report containing terminal outputs and screenshots.

---

### **EXAM EVALUATION QUESTIONS Overview**

1. **Group Management and Membership**  
   Created groups *g1*, *g2*, and *g3*; configured **examuser**’s primary and supplementary groups; verified changes using `id` and `/etc/group`.  

2. **Ownership and Permission Management**  
   Created `workspace/secret.txt`, changed ownership with `chown` and `chgrp`, and demonstrated both symbolic and numeric permission changes.  

3. **Pipes, Grep, and Redirection Practice**  
   Used `grep` and `journalctl` to filter log entries containing “error” or “fail”; redirected results to a log file using overwrite (`>`) and append (`>>`) modes; viewed output via `less`.  

4. **Script – Variables, Command Substitution, and File Checks**  
   Built `setup.sh` incrementally to demonstrate variables, command substitution, and directory/file existence checks with creation logic.  

5. **Script – Comparisons and String Tests**  
   Extended the script to include numeric and string comparison operators (`-eq`, `-ne`, `-gt`, `-lt`, `=`, `!=`, `-z`) and showed both true/false cases.  

6. **Script – For Loop and Argument Handling**  
   Implemented a `for` loop iterating over `"$@"` to print all script arguments, demonstrating correct handling of single and quoted multi-word arguments.  

7. **Script – While Loop Summation and Functions**  
   Created an interactive `while` loop that sums input numbers until “q” is entered, and a function that returns the sum of two numeric arguments.  

---

### **Submission Summary**

- All seven tasks were executed successfully and verified with screenshots.  
- Complete evidence (commands + outputs + screenshots) is included in the attached PDF report.  
- Repository: **CC_ReenaQureshi_2023BSE052/Lab6**
