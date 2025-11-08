# Cloud Computing – Lab #7: Environment Variables and Firewall Configuration

**Name:** Reena Qureshi  
**Registration No.:** 2023-BSE-052  
**Subject:** Cloud Computing  

---

This lab focused on practical Linux system administration involving **environment variables**, **shell configuration persistence**, and **basic firewall management using UFW**. The exercises demonstrated temporary and permanent variable handling, as well as network traffic control through ICMP rules.

All evaluation questions were successfully completed, tested, and documented with verified terminal outputs.

---

### **EXAM EVALUATION QUESTIONS Overview**

---

#### **Q1: Quick Environment Audit**

Explored the current Linux environment by listing all system variables using `printenv`.  
Filtered and displayed key variables such as `PATH`, `LANG`, and `PWD` to understand their roles in controlling command search paths, localization, and working directories.

**Key Commands:**

```bash
printenv
printenv PATH
printenv LANG
printenv PWD

```
#### **Q2:  Short-lived Student Info**
Showed how temporary environment variables behave (session-scoped).
#### **Q3: Make It Sticky (Persistence Check for Student Info)**
Demonstrated persistence of environment variables across sessions via shell configuration.
#### **Q4: Firewall Rules: Block and Restore Ping (ICMP)**
Demonstrate you can block ping (ICMP echo) traffic using ufw and then re-allow it; show effect from a client.
---
