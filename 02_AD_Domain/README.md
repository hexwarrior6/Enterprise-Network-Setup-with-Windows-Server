# Chapter 2: Installing and Configuring Active Directory Domain Services  
> This chapter will guide you through the process of installing and configuring **Active Directory Domain Services (AD DS)** on Windows Server 2022, and joining two Windows 10 virtual machines to the same domain.  
> The DNS service will be automatically installed along with AD DS, so no additional configuration is required.

---

## Assign Static IP Addresses to Both Domain Controllers

Setting static IP addresses for domain controllers is essential to ensure proper operation of DNS and AD services in an enterprise network environment.

### Steps:

1. Open `Control Panel` -> `Network and Internet` -> `Network and Sharing Center` -> `Change adapter settings`  
   Right-click the current local connection -> `Properties`

   ![img_21.png](images/img_21.png)

2. In the pop-up window, double-click `Internet Protocol Version 4 (TCP/IPv4)` and configure the following settings:

    | Device | IP Address      | Subnet Mask       | Default Gateway   | Preferred DNS | Alternate DNS |
    |--------|-----------------|-------------------|-------------------|---------------|----------------|
    | DC01   | `192.168.1.100` | `255.255.255.0`   | `192.168.1.101`   | Self          | DC02           |
    | DC02   | `192.168.1.101` | `255.255.255.0`   | `192.168.1.100`   | Self          | DC01           |
    | PC01   | `192.168.1.120` | `255.255.255.0`   | `192.168.1.100`   | DC01           | DC02           |
    | PC02   | `192.168.1.121` | `255.255.255.0`   | `192.168.1.100`   | DC01           | DC02           |

   ![img_22.png](images/img_22.png)

3. Click **OK** to save the settings, then open **Command Prompt** and enter the following command to verify the IP address configuration:

   ```cmd
   ipconfig
   ```

   ![img_23.png](images/img_23.png)

4. If the settings do not take effect, try disabling and re-enabling the network adapter:
   - Return to the "Change adapter settings" interface
   - Select the current network adapter
   - Click -> `Disable` -> `Enable`

   ![img_24.png](images/img_24.png)

---

## Install AD Domain Services (DC01)

1. Open `Server Manager` on DC01  
   Click `Manage` -> `Add Roles and Features` from the top menu

   ![img_1.png](images/img_1.png)

2. In the **Add Roles and Features Wizard**, keep the installation type as default and click `Next`

   ![img_2.png](images/img_2.png)

3. Keep the server selection as default and click `Next`

   ![img_3.png](images/img_3.png)

4. On the **Server Roles** page, check `Active Directory Domain Services`  
   Click `Add Features` when prompted

   ![img_4.png](images/img_4.png)

5. Keep the features selection as default and click `Next`

   ![img_5.png](images/img_5.png)

6. Leave the AD DS settings as default and continue clicking `Next`

   ![img_6.png](images/img_6.png)

7. Confirm your selections and click `Install`

   ![img_7.png](images/img_7.png)

8. After installation completes, a prompt appears saying **Promote this server to a domain controller** – click the link to continue

   ![img_8.png](images/img_8.png)

---

## Configure the Primary AD Domain Controller (DC01)

1. Enter the new domain name: `bread-makers.nz`, then click `Next`

   ![img_9.png](images/img_9.png)

2. Set the DSRM password (used for directory recovery), then click `Next`

   ![img_10.png](images/img_10.png)

3. Leave DNS settings as default and click `Next`

   ![img_11.png](images/img_11.png)

4. The domain name will be auto-filled, leave it as is and click `Next`

   ![img_12.png](images/img_12.png)

5. Leave the paths as default and click `Next`

   ![img_13.png](images/img_13.png)

6. Review the installation information and click `Next`

   ![img_14.png](images/img_14.png)

7. Once the prerequisite checks complete, click `Install`

   ![img_15.png](images/img_15.png)

8. After installation finishes, the system will automatically restart – click `Close` to confirm the reboot

   ![img_16.png](images/img_16.png)

9. After rebooting, log in using the domain administrator account

   ![img_17.png](images/img_17.png)

10. After logging in, you can see that the AD Domain Services have been successfully installed via Server Manager

   ![img_18.png](images/img_18.png)

---

## Configure the Secondary AD Domain Controller (DC02)

> The installation steps for the AD DS role are the same as for DC01 – refer to the previous section.

1. Click `Add a domain controller to an existing domain`, enter the domain name `bread-makers.nz`, and click `Next`

   ![img_19.png](images/img_19.png)

   > Note: You can view the domain administrator username on DC01:
   >
   > ![img_20.png](images/img_20.png)

2. Enter the domain administrator password and click `OK`. After verification, click `Next`

   ![img_25.png](images/img_25.png)

3. Set the DSRM password and click `Next`

   ![img_26.png](images/img_26.png)

4. Leave DNS settings as default and click `Next`

   ![img_27.png](images/img_27.png)

5. Leave additional options as default and click `Next`

   ![img_28.png](images/img_28.png)

6. Leave the path settings as default and click `Next`

   ![img_29.png](images/img_29.png)

7. Confirm the installation settings and click `Next`

   ![img_30.png](images/img_30.png)

8. Once the prerequisite checks complete, click `Install`

   ![img_31.png](images/img_31.png)

9. After installation finishes, the system will automatically restart – log in using the domain administrator account after reboot

   ![img_32.png](images/img_32.png)

10. After logging in, open `Server Manager` -> `Tools` -> `Active Directory Users and Computers` on any domain controller. You should now see both domain controllers listed under the `bread-makers.nz` domain

   ![img_33.png](images/img_33.png)

---

## Summary

In this chapter, we completed the following tasks:

- Assigned static IP addresses to all devices
- Installed and configured the primary domain controller (DC01)
- Installed and joined the secondary domain controller (DC02) to the domain

In the next chapter, we will continue by setting up the **DHCP service** to allow clients to automatically obtain IP addresses.