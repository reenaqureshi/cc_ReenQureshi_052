# Cloud Computing - Lab #3: Advanced Git Operations  

**Name:** Reena Qureshi  
**Registration No.:** 2023-BSE-052  
**Subject:** Cloud Computing  

---

This lab demonstrates advanced Git operations, including resolving conflicts, managing tracked files, resetting history, stashing changes, and working with hosted Git environments such as Gitea and GitHub Pages.

---

### **Task 1: Handling Local and Remote Commit Conflicts (Pull vs Pull --rebase)**  
This task explored what happens when both local and remote repositories contain new commits, and how to resolve them using merge and rebase.

1. **Local Commit and Push Rejection**  
A local change was committed and push was rejected since the remote had new changes.

```bash
$ git commit -m "Local update to README"
# [main 7ac53e1] Local update to README
$ git push origin main
# ! [rejected] main -> main (fetch first)
# hint: Updates were rejected because the remote contains work that you do not have locally.
