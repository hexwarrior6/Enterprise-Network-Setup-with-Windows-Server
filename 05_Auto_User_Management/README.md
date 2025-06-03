# Chapter 5: AD User and Group Management + PowerShell Automation

> In enterprise environments, user account and permission management are among the core tasks of Active Directory. In this chapter, we will explore how to create **Organizational Units (OUs)**, users, and groups in AD, and use **PowerShell** to automate user creation and folder configuration.

---

## AD User and Group Management

1. Open `Server Manager` -> Click `Tools` from the top menu -> Select `Active Directory Users and Computers`

2. Right-click your domain name (e.g., `bread-makers.nz`) -> Select `New` -> `Organizational Unit`  
   ![img_1.png](images/img_1.png)

3. Enter a new OU name such as `bread-makers corp`, then click `OK`  
   ![img_2.png](images/img_2.png)

4. Under `bread-makers corp`, right-click again -> `New` -> `Organizational Unit`, and add `Bake Department`

5. Under `Bake Department`, right-click -> `New` -> `User`, enter username `Bob`, then click `Next`  
   ![img_3.png](images/img_3.png)

6. Set a password (ensure it meets complexity requirements), and optionally uncheck “User must change password at next logon”  
   Click `Next`  
   ![img_4.png](images/img_4.png)

7. Confirm details and click `Finish`  
   ![img_5.png](images/img_5.png)

8. Back under `bread-makers corp`, right-click -> `New` -> `Group`, name it `Baker`, and click `OK`  
   ![img_6.png](images/img_6.png)

9. Double-click the `Baker` group, go to the `Members` tab, click `Add`, select `Bob` from `Bake Department`, then click `OK`  
   ![img_7.png](images/img_7.png)

10. Continue adding other departments and groups based on the following structure:

```mermaid
graph TD
    A[Bread-Makers Corp] --> K[all bread-makers staff]
    
    K --> B[Bake Department]
    K --> C[Information Department]
    K --> D[Personnel Department]
    
    B --> E[baker Group]
    C --> F[IT staff Group]
    D --> G[personnel Group]
    
    E --> H[Bob]
    F --> I[Alice]
    G --> J[Charlie]
```

11. Add all subgroups (`baker`, `IT staff`, `personnel`) into the `all bread-makers staff` group  
    ![img_8.png](images/img_8.png)

✅ **Tip**: It is recommended to use **nested groups** for permission management, which simplifies future policy assignments.

---

## Domain User Login

1. Power on `PC01` and log in using a local account  
   ![img_10.png](images/img_10.png)

2. Open Command Prompt and run the following command to verify network settings:
   ```cmd
   ipconfig
   ```
   If the IP address does not point to the domain controller, refer to [## Fix Static IP Addresses for Both Domain Controllers](../02_AD_Domain/README.md) to reconfigure the network  
   ![img_11.png](images/img_11.png)

3. Search for and open `Advanced System Settings` -> Click `Change` next to `Computer Name`  
   Enter the domain name `bread-makers.nz`, click `OK`, and input the domain administrator credentials  
   ![img_12.png](images/img_12.png)

4. After successfully joining the domain, the system will prompt you to restart – click `OK` and restart immediately  
   ![img_13.png](images/img_13.png)
   ![img_14.png](images/img_14.png)
   ![img_15.png](images/img_15.png)

5. After rebooting, click `Sign in with another account` and enter Bob's domain account information to log in  
   ![img_16.png](images/img_16.png)

   > ⚠️ If you receive an error saying "Log on to remote computer failed", try logging in with a local account once, then sign out and try the domain login again (this may be due to Hyper-V connection delay)  
   > ![img_22.png](images/img_22.png)

6. After successful login, click the Start menu -> Profile icon -> `Change account settings` to confirm you're logged in as a domain user  
   ![img_17.png](images/img_17.png)

7. Open File Explorer and type `\\bread-makers.nz` in the address bar to access the previously configured DFS shared folder  
   ![img_18.png](images/img_18.png)

8. You can map the `bread-makers DFS` folder as a network drive: Right-click -> `Map network drive`  
   ![img_19.png](images/img_19.png)

9. Choose a drive letter (default is Z:), click `Finish`, and the mapped folder will appear in File Explorer  
   ![img_20.png](images/img_20.png)
   ![img_21.png](images/img_21.png)

---

## Configure File Sharing Permissions

> In this step, we will set folder permissions to ensure that only authorized departments can access their corresponding directories.

1. Set read permissions for all employees on the root directory `bread-makers DFS`, and remove unnecessary permissions—only keep `all bread-makers staff` and `Administrator` groups  
   ![img_9.png](images/img_9.png)
   ![img_33.png](images/img_33.png)

2. Set read permissions for the `Bake Department` folder specifically for the `baker` group  
   ![img_23.png](images/img_23.png)

3. Similarly, configure permissions for other folders:

| Folder                    | Permission Group         |
|--------------------------|--------------------------|
| Bake Department          | baker                    |
| Information Department   | IT staff                 |
| Personnel Department     | personnel                |
| Share Files              | all bread-makers staff   |

✅ **Verification Steps**:

- Log off and back in to refresh group policies
- After logging in as Bob, navigate to the `bread-makers DFS` folder — you should only see contents under `Bake Department` and have read-only access

![img_24.png](images/img_24.png)

---

## Automating User Creation, Group Policy Assignment & User Folder Setup

> To improve efficiency, we can use PowerShell scripts to batch-create users, assign them to groups, and automatically generate personal folders.

### Prerequisites

Before running the script, create a folder named `UserHomes` inside the shared folder and set the following permissions:

1. **Disable inherited permissions**  
   ![img_27.png](images/img_27.png)

2. **Grant the `all bread-makers staff` group “Read” access to this folder only**  
   ![img_28.png](images/img_28.png)

---

### PowerShell Script Examples

You can choose any of the following scripts depending on your needs:

#### ✅ Basic Version (Manual Single User Creation)
- Script path: `scripts/Create-NewUser.ps1`
- [Create-NewUser.ps1](scripts/Create-NewUser.ps1)

#### ✅ CSV Batch Version (Import Users from CSV)
- Script path: `scripts/Create-ADUser-Batch.ps1`
- [Create-ADUser-Batch.ps1](scripts/Create-ADUser-Batch.ps1)
- Example CSV format:

```csv
Username,FullName,Password,Department
David,Dave Smith,P@ssw0rd123,Personnel Department
Eve,Eve Johnson,P@ssw0rd456,Bake Department
Frank,Frank White,P@ssw0rd789,Information Department
```

#### ✅ GUI Version (Supports Single or Batch Creation)
- Script path: `scripts/Create-ADUser-GUI.ps1`
- [Create-ADUser-GUI.ps1](scripts/Create-ADUser-GUI.ps1)

##### Usage Instructions:
1. Right-click the script -> `Run with PowerShell`  
   ![img_25.png](images/img_25.png)

2. Fill in user details and click `Create User`  
   ![img_26.png](images/img_26.png)

3. After creation, the result will be displayed below  
   ![img_29.png](images/img_29.png)

4. Try logging in with the newly created user to verify access  
   ![img_30.png](images/img_30.png)

5. After logging in, open File Explorer and confirm that `bread-makers DFS` is mapped as the Z: drive  
   ![img_31.png](images/img_31.png)

6. Navigate to the DFS folder and verify that a dedicated user folder has been created under `UserHomes` with correct permissions  
   ![img_32.png](images/img_32.png)

---

## Summary

In this chapter, we completed the following tasks:

- Created Organizational Units, users, and group structures in Active Directory
- Joined client machines to the domain and performed domain-based logins
- Configured DFS folder permissions to restrict access by department
- Used PowerShell scripts to automate user creation, group assignment, and personal folder setup

In the next chapter, we will continue with **Group Policy Management**, setting up centralized policies to enforce security and desktop configurations across the domain.