# Chapter 1: Creating Virtual Machines Using Hyper-V
> This tutorial will guide you through the process of creating virtual machines using Hyper-V and installing Windows Server 2022 and Windows 10.

## 1. Enabling Hyper-V

### Step 1: Enable the Hyper-V Feature
Hyper-V is a virtualization platform in Windows used to create and manage virtual machines. First, ensure that Hyper-V is enabled in your system.

#### Steps:
1. **Search for and open "Turn Windows features on or off"**  
   Type `Windows Features` in the Windows search bar, then select "Open".

   ![img_1.png](images/img_1.png)

2. **Check the box for Hyper-V**  
   In the window that appears, locate and check `Hyper-V`, then click "OK".

   ![img_2.png](images/img_2.png)

3. **Restart your computer**  
   You will be prompted that a restart is required to apply changes. After restarting, Hyper-V will be fully enabled.

4. **Open Hyper-V Manager**  
   After rebooting, search for and open "Hyper-V Manager" from the Start menu.

   ![img_3.png](images/img_3.png)

---

## 2. Download ISO Images

When setting up an enterprise network environment, we'll need ISO image files for Windows Server 2022 and Windows 10. Below are the download links (Note: If these links are no longer valid, please visit Microsoft's official website for the latest download addresses):

- **Windows Server 2022 ISO**  
  [Download Windows Server 2022](https://www.microsoft.com/evalcenter/download-windows-server-2022)  

- **Windows 10 ISO**  
  [Download Windows 10 ISO](https://www.microsoft.com/software-download/windows10ISO)  

**Notes**:
- If you cannot access the above links directly, try obtaining the images through Microsoft’s official download center or other trusted sources.
- Ensure that the downloaded ISOs are legitimate and genuine to avoid installation and licensing issues later on.

---

## 3. Create a Virtual Switch

A virtual switch is essential for communication between virtual machines and between virtual machines and the host machine. We need to create a virtual switch of the Internal type.

#### Steps:
1. **Open Hyper-V Manager**  
   In Hyper-V Manager, click "Actions" -> "Virtual Switch Manager" on the right-hand side.

2. **Create a new virtual switch**  
   In the window that appears, click "New virtual network switch", select "Internal", and click "Create Virtual Switch".

   ![img_13.png](images/img_13.png)

3. **Configure the switch name**  
   Enter a name for the switch, such as `Bread-Makers.nz`, then click "OK".

   ![img_14.png](images/img_14.png)

**Explanation**:
- The internal network type is suitable for communication between virtual machines but does not connect to the physical network.
- The switch name can be customized according to your needs, but it is recommended to use a meaningful name for easy identification.

---

## 4. Create Virtual Machines

Next, we will create two Windows Server 2022 virtual machines (DC01 and DC02) and two Windows 10 virtual machines (PC01 and PC02). Here are the detailed steps:

### Step 1: Create the first virtual machine (DC01)
1. **Click "New" -> "Virtual Machine"**  
   In Hyper-V Manager, click "New" on the left side, then select "Virtual Machine".

   ![img_4.png](images/img_4.png)

2. **Set the virtual machine name and storage location**  
   Enter a name for the virtual machine (e.g., `DC01`) and choose a location for storing the VM files.

   ![img_5.png](images/img_5.png)

3. **Keep the default generation setting**  
   Usually, keeping the default generation is fine.

   ![img_6.png](images/img_6.png)

4. **Set the virtual machine memory**  
   The default memory settings are typically reasonable and can be adjusted based on actual needs.

   ![img_7.png](images/img_7.png)

5. **Select network connection**  
   Under the "Connection" option, select the previously created virtual switch (e.g., `Bread-Makers.nz`).

   ![img_8.png](images/img_8.png)

6. **Set the virtual hard disk size**  
   It is recommended to allocate 40GB of disk space for the virtual machine (30–40GB is sufficient; adjust based on requirements).

   ![img_9.png](images/img_9.png)

7. **Select the ISO image file**  
   Under the "Installation options", select the previously downloaded Windows Server 2022 ISO file.

   ![img_10.png](images/img_10.png)

8. **Complete the virtual machine creation**  
   Confirm everything is correct, then click "Finish".

   ![img_11.png](images/img_11.png)

9. **Repeat the steps to create additional virtual machines**  
   Follow the same steps to create another Windows Server 2022 virtual machine (DC02) and two Windows 10 virtual machines (PC01 and PC02). If resources are limited, you may choose to create only one Windows 10 virtual machine.

   ![img_15.png](images/img_15.png)

---

## 5. Install Operating Systems

### 5.1 Installing Windows Server 2022

#### Step 1: Start the virtual machine
1. **Double-click DC01 and start the VM**  
   On the first boot, press and hold the `Spacebar` to avoid error prompts.

   ![img_16.png](images/img_16.png)

   **Common Issue**: If you don't press the `Spacebar`, you might encounter the following error message:

   ![img_17.png](images/img_17.png)

   If this occurs, shut down the VM, restart it, and continue holding the `Spacebar` until you reach the installation interface.

   ![img_18.png](images/img_18.png)

2. **Enter the installation interface**  
   Press the `Enter` key to enter the Windows Server 2022 installation interface.

   ![img_19.png](images/img_19.png)

#### Step 2: Language and license agreement setup
3. **Confirm language version and proceed**  
   Select the appropriate language version, then click "Next".

   ![img_20.png](images/img_20.png)

4. **Click "Install Now"**  
   Proceed to the installation mode selection screen.

   ![img_21.png](images/img_21.png)

5. **Select the graphical interface version**  
   Choose the "Graphical Interface Version" for easier operations.

   ![img_22.png](images/img_22.png)

6. **Accept the license agreement and proceed**  
   Read and accept the license terms, then click "Next".

   ![img_23.png](images/img_23.png)

#### Step 3: Installation mode and disk selection
7. **Select the installation mode**  
   For testing purposes, choose the "Clean Install" mode.

   ![img_24.png](images/img_24.png)

8. **Choose the disk location for installation**  
   Typically, the default partition settings are acceptable.

   ![img_25.png](images/img_25.png)

#### Step 4: Wait for installation to complete
9. **Wait for the installation process to finish**  
   This step may take several minutes—please be patient.

   ![img_26.png](images/img_26.png)

#### Step 5: Set the administrator account
10. **Set a strong password for the administrator account**  
    Make sure the password is secure and not too simple.

    ![img_27.png](images/img_27.png)

11. **Log in to the system**  
    Use the administrator account you just set up to log in.

    ![img_28.png](images/img_28.png)

#### Step 6: Change the computer name
12. **Change the computer name**  
    Open "Server Manager" -> "Local Server", click on "Computer Name", change the name to `DC01` or `DC02`, and click "OK". You will be prompted to restart—click "Restart Now".

    ![img_52.png](images/img_52.png)
    ![img_53.png](images/img_53.png)

13. **Re-login after the restart**  
    After the restart, log back into the system and confirm that the computer name has been successfully changed.

    ![img_54.png](images/img_54.png)

---

### 5.2 Installing Windows 10

#### Step 1: Start the virtual machine
1. **Double-click PC01 and start the VM**  
   Similarly, press and hold the `Spacebar` during the first boot.

   ![img_29.png](images/img_29.png)

#### Step 2: Language and license agreement setup
2. **Confirm language version and proceed**  
   Select the appropriate language version, then click "Next".

   ![img_29.png](images/img_29.png)

3. **Click "Install Now"**  
   Proceed to the installation mode selection screen.

   ![img_30.png](images/img_30.png)

4. **Click "I don’t have a product key"**  
   Choose this option if you do not have a product key.

   ![img_31.png](images/img_31.png)

5. **Select Windows 10 Pro**  
   Choose the appropriate edition (e.g., Pro).

   ![img_32.png](images/img_32.png)

6. **Accept the license agreement and proceed**  
   Read and accept the license terms, then click "Next".

   ![img_33.png](images/img_33.png)

#### Step 3: Installation mode and disk selection
7. **Select the installation mode**  
   For testing purposes, choose the "Clean Install" mode.

   ![img_34.png](images/img_34.png)

8. **Choose the disk location for installation**  
   Typically, the default partition settings are acceptable.

   ![img_35.png](images/img_35.png)

#### Step 4: Wait for installation to complete
9. **Wait for the installation process to finish**  
   This step may take several minutes—please be patient.

   ![img_36.png](images/img_36.png)

#### Step 5: OOBE page setup
10. **Select region and click "Yes"**  
    On the OOBE page, select the appropriate region.

    ![img_37.png](images/img_37.png)

11. **Select keyboard layout and click "Yes"**  
    Choose the desired keyboard layout.

    ![img_38.png](images/img_38.png)

12. **Skip additional keyboard layouts**  
    If you don't need additional keyboard layouts, click "Skip".

    ![img_39.png](images/img_39.png)

13. **Select network connection**  
    If there is no internet connection available, choose "I don’t have a network connection".

    ![img_40.png](images/img_40.png)

14. **Select restricted mode installation**  
    Choose "Continue with restricted mode" without connecting to the internet.

    ![img_41.png](images/img_41.png)

#### Step 6: Create a local account
15. **Create a username and password**  
    Enter a username and password, and set up security questions.

    ![img_42.png](images/img_42.png)
    ![img_43.png](images/img_43.png)
    ![img_44.png](images/img_44.png)

#### Step 7: Privacy settings and Cortana
16. **Disable all privacy settings and accept**  
    You can disable all privacy settings if desired.

    ![img_45.png](images/img_45.png)

17. **Do not enable Cortana**  
    Click "Not now".

    ![img_46.png](images/img_46.png)

#### Step 8: Log in to the system
18. **Enter your password and log in**  
    Use the account you set up earlier to log in.

    ![img_47.png](images/img_47.png)

#### Step 9: Change the computer name
19. **Change the computer name**  
    Search for "Advanced System Settings", go to the "Computer Name" tab, change the name to `PC01` or `PC02`, and click "OK". You will be prompted to restart—click "Restart Now".

    ![img_48.png](images/img_48.png)
    ![img_49.png](images/img_49.png)
    ![img_50.png](images/img_50.png)

20. **Re-login after the restart**  
    After the restart, log back into the system and confirm that the computer name has been successfully changed.

    ![img_51.png](images/img_51.png)

---

## Summary

This chapter covered how to enable Hyper-V, download ISO images, create a virtual switch, create virtual machines, and install operating systems. With these steps completed, we have laid the foundation for our test environment. In the next chapters, we will move on to more advanced configurations, such as Active Directory Domain Services (AD DS), DHCP, DFS, and more.