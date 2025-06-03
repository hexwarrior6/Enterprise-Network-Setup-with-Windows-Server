English | [简体中文](README_zh-hans.md)

# Enterprise Network Setup with Windows Server

<p align="center">
    <a href="https://github.com/hexwarrior6/Enterprise-Network-Setup-with-Windows-Server"><img alt="Github repo" src="https://img.shields.io/github/last-commit/hexwarrior6/Enterprise-Network-Setup-with-Windows-Server?logo=github"></a>
    <a href="https://gitee.com/HexWarrior6/enterprise-network-setup-with-windows-server"><img alt="Gitee repo" src="https://img.shields.io/badge/Gitee-repo-red?logo=gitee"></a>
    <a href="https://blog.csdn.net/qq_46300059/article/details/148394749"><img alt="CSDN reading count" src="https://img.shields.io/badge/dynamic/regex?url=https%3A%2F%2Fblog.csdn.net%2Fqq_46300059%2Farticle%2Fdetails%2F148394749&search=%E9%98%85%E8%AF%BB%E9%87%8F%5CD*(%5Cd%2B)&logo=csdn&logoColor=black&label=CSDN&color=red"></a>
    <a href="https://github.com/hexwarrior6/Enterprise-Network-Setup-with-Windows-Server/blob/master/LICENSE"><img alt="license" src="https://img.shields.io/github/license/hexwarrior6/Enterprise-Network-Setup-with-Windows-Server.svg?color=blue"></a>
</p>

---

A comprehensive lab guide for building a full-scale enterprise network environment using:

- 💻 **Windows 10/11 Pro**
  - 🤖 **Hyper-V**
    - 💻 **DC01** (Windows Server 2022)
    - 💻 **DC02** (Windows Server 2022)
    - 💻 **PC01** (Windows 10)
    - 💻 **PC02** (Windows 10) *(Optional)*

```mermaid
graph TB
    subgraph Domain Controller 01
        DC01[AD, DNS, DHCP]
    end

    subgraph Domain Controller 02
        DC02[AD, DNS, DHCP]
    end

    subgraph Virtual Switch
        VS[Virtual Switch]
    end

    subgraph PC 01
        PC01[Client]
    end

    subgraph PC 02
        PC02[Client]
    end

    DC01 -- "Network Connection" --> VS
    DC02 -- "Network Connection" --> VS
    PC01 -- "Network Connection" --> VS
    PC02 -- "Network Connection" --> VS

    style VS fill:#eef,stroke:#333,stroke-width:2px
    style DC01 fill:#f9f,stroke:#333,stroke-width:2px
    style DC02 fill:#f9f,stroke:#333,stroke-width:2px
    style PC01 fill:#efe,stroke:#333,stroke-width:2px
    style PC02 fill:#efe,stroke:#333,stroke-width:2px
```

This project walks you through the entire process of setting up a simulated enterprise network from scratch, including domain services, user management, file sharing, and automation via PowerShell.

---

## 📚 Table of Contents

1. [Requirements & Prerequisites](#requirements--prerequisites)
2. [Getting Started](#getting-started)
3. [Chapters](#chapters)
4. [Contributing / Feedback](#contributing--feedback)

---

## Requirements & Prerequisites

- Windows 10 Pro or later (to enable Hyper-V)
- At least 16GB RAM (32GB recommended)
- Hyper-V enabled
- ISO files for Windows Server 2022 and Windows 10
  - [Windows Server 2022 ISO](https://www.microsoft.com/evalcenter/download-windows-server-2022)
  - [Windows 10 ISO](https://www.microsoft.com/software-download/windows10ISO)
- Basic knowledge of networking and Windows Server

---

## Getting Started

1. Enable Hyper-V on your Windows 10 machine
2. Download Windows Server 2022 ISO and Window 10 ISO
3. Follow the guides in each folder in order

---

## Chapters

| Chapter | Topic                                                                                      |
|---------|--------------------------------------------------------------------------------------------|
| 01      | 🖥️ [Virtual Machine Setup using Hyper-V](01_VM_Setup/README.md)                           |
| 02      | 🔐 [Active Directory Domain Services (AD DS) Setup](02_AD_Domain/README.md)                |
| 03      | 📡 [DHCP Server Configuration](03_DHCP_Server/README.md)                                   |
| 04      | 📁 [DFS (Distributed File System) for File Sharing](04_DFS_File_Sharing/README.md)         |
| 05      | 👥 [AD User & Group Management + PowerShell Automation](05_Auto_User_Management/README.md) |

---

## Contributing / Feedback

Feel free to open issues or pull requests if you have suggestions, corrections, or want to contribute additional chapters!
