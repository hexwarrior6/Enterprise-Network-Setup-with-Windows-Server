# Chapter 3: Configuring the DHCP Server

> In this chapter, we will configure the **DHCP service** to automatically assign IP addresses to clients and implement **DHCP failover**, simplifying network management and enabling a highly available network environment.

---

## Install the DHCP Role

1. Open `Server Manager` on DC01  
   Click `Manage` -> `Add Roles and Features` from the top menu

   ![img_1.png](images/img_1.png)

2. In the **Add Roles and Features Wizard**, select `Server Roles` from the left menu and check `DHCP Server`.  
   When prompted, click `Add Features`, then continue clicking `Next`

   ![img_2.png](images/img_2.png)

3. On the confirmation page, click `Install` to begin installing the DHCP role

   ![img_3.png](images/img_3.png)

4. After installation completes, click `Complete DHCP Configuration` to continue with post-install setup

   ![img_4.png](images/img_4.png)

---

## Configure the DHCP Server

1. On the `DHCP Configuration Wizard` page, click `Next`

   ![img_5.png](images/img_5.png)

2. Leave settings as default and click `Commit` to complete basic configuration

   ![img_6.png](images/img_6.png)

3. After configuration, click `Close` to proceed to the next step

   ![img_7.png](images/img_7.png)

---

## Configure Primary DHCP Scope (DC01)

1. From the server console, open `Tools` -> `DHCP`

   ![img_8.png](images/img_8.png)

2. Right-click on `IPv4` and select `New Scope` to open the **New Scope Wizard**

   ![img_9.png](images/img_9.png)

3. Enter a scope name such as `bread-makers DHCP`, then click `Next`

   ![img_11.png](images/img_11.png)

4. Set the IP address range:
   - Start IP: `192.168.1.100`
   - End IP: `192.168.1.200`  
   Click `Next`

   ![img_12.png](images/img_12.png)

5. Set the exclusion range:
   - Start IP: `192.168.1.100`
   - End IP: `192.168.1.110`  
   (This range is reserved for servers and other static devices)  
   Click `Add` to include it in exclusions, then click `Next`

   ![img_13.png](images/img_13.png)

6. Keep the lease duration at the default (8 hours), click `Next`

   ![img_14.png](images/img_14.png)

7. Choose whether to configure DHCP options now – click `Next`

   ![img_15.png](images/img_15.png)

8. Set the router (default gateway):
   - Add both domain controller IPs as default gateways:
     - `192.168.1.100` (DC01)
     - `192.168.1.101` (DC02)  
   Click `Next`

   ![img_16.png](images/img_16.png)

9. Keep the domain name and DNS server settings as default, click `Next`

   ![img_17.png](images/img_17.png)

10. Keep WINS server settings as default, click `Next`

    ![img_18.png](images/img_18.png)

11. Select to activate the DHCP scope, click `Next`

    ![img_19.png](images/img_19.png)

12. The wizard is complete – click `Finish` to finish configuration

    ![img_20.png](images/img_20.png)

✅ **Verification Step**:

In the `DHCP` management interface, expand `bread-makers DHCP` -> `Address Pool`. You should see the successfully created IP range: `192.168.1.100 - 192.168.1.200`.

![img_21.png](images/img_21.png)

---

## Configure DHCP Failover (DC01)

> Before completing this section, ensure that the DHCP server role has already been installed on DC02. Refer to the earlier steps:
> - [Install DHCP Role](#install-the-dhcp-role)
> - [Configure the DHCP Server](#configure-the-dhcp-server)

1. On DC01, open `Tools` -> `DHCP`

   ![img_22.png](images/img_22.png)

2. Right-click on `IPv4` and select `Configure Failover` to open the **Configure Failover Wizard**

   ![img_23.png](images/img_23.png)

3. Since there's only one DHCP scope currently, it will be selected automatically – click `Next`

   ![img_24.png](images/img_24.png)

4. On the "Select Partner Server" page, click `Add Server` -> `Browse`, and enter `DC02`  
   Click `Check` to verify all tabs are green, then click `Next`

   ![img_25.png](images/img_25.png)

5. Set a shared secret (recommended to use a strong password) for secure communication, then click `Next`

   ![img_26.png](images/img_26.png)

6. Review the configuration summary and click `Finish` to complete the wizard

   ![img_27.png](images/img_27.png)

✅ **Verification Step**:

On DC02, open the `DHCP` manager and expand `bread-makers DHCP` -> `Address Pool`. You should see the synchronized IP range `192.168.1.100 - 192.168.1.200`, confirming that failover has been successfully configured.

![img_28.png](images/img_28.png)

---

## Summary

In this chapter, we completed the following tasks:

- Installed and configured the DHCP server on DC01
- Created a DHCP scope with an IP pool and exclusion range
- Set up DHCP failover on DC02 to achieve high availability

In the next chapter, we will explore how to set up **DFS (Distributed File System)** to enable enterprise-level file sharing and storage management.