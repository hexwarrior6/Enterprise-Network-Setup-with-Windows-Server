# 第五章：AD 用户与组管理 + PowerShell 自动化

> 在企业环境中，用户账户和权限管理是 Active Directory 的核心任务之一。本章我们将介绍如何在 AD 中创建组织单位（OU）、用户和组，并使用 PowerShell 实现自动化用户创建和文件夹配置。

---

## AD 用户和组管理

1. 打开 `服务器管理器` -> 点击顶部菜单中的 `工具` -> 选择 `Active Directory 用户和计算机`

2. 右键当前域名（例如 `bread-makers.nz`）-> 选择 `新建` -> `组织单元`  
   ![img_1.png](images/img_1.png)

3. 输入新组织单元名称，如 `bread-makers corp`，点击 `确定`  
   ![img_2.png](images/img_2.png)

4. 在 `bread-makers corp` 下再次右键 -> `新建` -> `组织单元`，添加 `Bake Department`（烘焙部门）

5. 在 `Bake Department` 下右键 -> `新建` -> `用户`，输入用户名 `Bob`，点击 `下一步`  
   ![img_3.png](images/img_3.png)

6. 设置密码（注意密码复杂度要求），可以取消勾选“用户下次登录时须更改密码”，点击 `下一步`  
   ![img_4.png](images/img_4.png)

7. 确认信息后点击 `完成`  
   ![img_5.png](images/img_5.png)

8. 在 `bread-makers corp` 中再次右键 -> `新建` -> `组`，将组名设为 `Baker`，点击 `确认`  
   ![img_6.png](images/img_6.png)

9. 双击打开 `Baker` 组，在 `成员` 选项卡中点击 `添加`，选择 `Bake Department` 中的 `Bob`，点击 `确定`  
   ![img_7.png](images/img_7.png)

10. 按照以下结构继续添加其他部门和组：

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

11. 将所有子组（baker、IT staff、personnel）添加至 `all bread-makers staff` 组中  
    ![img_8.png](images/img_8.png)

✅ **提示**：建议使用“嵌套组”的方式管理权限，这样可以简化后续策略分配。

---

## 域用户登录

1. 打开 `PC01`，使用本地账户登录  
   ![img_10.png](images/img_10.png)

2. 打开命令提示符，运行以下命令检查网络设置是否正确：
   ```cmd
   ipconfig
   ```
   如果 IP 地址未指向域控制器，请参考 [## 固定两台域控制器的 IP 地址](../02_AD_Domain/README_zh-hans.md) 进行网络配置  
   ![img_11.png](images/img_11.png)

3. 搜索并打开 `高级系统设置` -> 点击 `计算机名` 旁边的 `更改`  
   输入域名 `bread-makers.nz`，点击 `确定`，然后输入域管理员账号和密码  
   ![img_12.png](images/img_12.png)

4. 成功加入域后，计算机会提示重启，点击 `确定` 并立即重启  
   ![img_13.png](images/img_13.png)
   ![img_14.png](images/img_14.png)
   ![img_15.png](images/img_15.png)

5. 重启完成后点击 `使用其他账户`，输入 Bob 的域账户信息进行登录  
   ![img_16.png](images/img_16.png)

   > ⚠️ 若出现“登录到远程计算机失败”的提示，可尝试先用本地账户登录一次再注销，重新登录域账户（虚拟机会刷新连接，可能是 Hyper-V 的连接问题）  
   > ![img_22.png](images/img_22.png)

6. 登录成功后，点击 `开始` 菜单 -> 用户头像 -> `更改账户设置`，确认当前是以域账户身份登录  
   ![img_17.png](images/img_17.png)

7. 打开资源管理器，在地址栏输入 `\\bread-makers.nz`，可以看到之前配置的 DFS 共享文件夹  
   ![img_18.png](images/img_18.png)

8. 可以对 `bread-makers DFS` 文件夹进行映射操作：右键 -> `映射网络驱动器`  
   ![img_19.png](images/img_19.png)

9. 设置盘符（默认为 Z:），点击 `完成`，即可在资源管理器中看到映射成功的共享文件夹  
   ![img_20.png](images/img_20.png)
   ![img_21.png](images/img_21.png)

---

## 设置文件共享权限

> 在这一步中，我们将设置文件夹权限，确保不同部门只能访问自己对应的目录。

1. 对根目录 `bread-makers DFS` 设置所有员工读取权限，并删除不必要的权限项，只保留 `all bread-makers staff` 和 `Administrator` 组  
   ![img_9.png](images/img_9.png)
   ![img_33.png](images/img_33.png)

2. 对 `Bake Department` 文件夹设置 `baker` 组的读权限  
   ![img_23.png](images/img_23.png)

3. 同理，为其他文件夹设置对应权限：

| 文件夹                    | 权限组                    |
|------------------------|------------------------|
| Bake Department        | baker                  |
| Information Department | IT staff               |
| Personnel Department   | personnel              |
| Share Files            | all bread-makers staff |

✅ **验证步骤**：

- 注销当前用户并重新登录，刷新权限策略
- 使用 Bob 登录后，尝试访问 `bread-makers DFS` 文件夹，应只能查看 `Bake Department` 内容，无法访问其他部门文件夹，且只有读权限

![img_24.png](images/img_24.png)

---

## 自动化用户创建及组策略、用户文件夹创建

> 为了提高效率，我们可以使用 PowerShell 脚本来批量创建用户、设置组成员关系，并自动创建用户个人文件夹。

### 准备工作

在执行脚本前，请先在共享文件夹中创建一个名为 `UserHomes` 的文件夹，并设置以下权限：

1. **取消继承权限**  
   ![img_27.png](images/img_27.png)

2. **添加 `all bread-makers staff` 组的“当前文件夹”读权限**  
   ![img_28.png](images/img_28.png)

---

### PowerShell 脚本示例

你可以根据需求选择以下任意一种脚本：

#### ✅ 简易版本（手动创建单个用户）
- 脚本路径：`scripts/Create-NewUser.ps1`
- [Create-NewUser.ps1](scripts/Create-NewUser.ps1)

#### ✅ CSV 批量版本（从 CSV 导入用户列表）
- 脚本路径：`scripts/Create-ADUser-Batch.ps1`
- [Create-ADUser-Batch.ps1](scripts/Create-ADUser-Batch.ps1)
- 示例 CSV 格式如下：

```csv
Username,FullName,Password,Department
David,Dave Smith,P@ssw0rd123,Personnel Department
Eve,Eve Johnson,P@ssw0rd456,Bake Department
Frank,Frank White,P@ssw0rd789,Information Department
```

#### ✅ GUI 版本（支持单个或批量创建）
- 脚本路径：`scripts/Create-ADUser-GUI.ps1`
- [Create-ADUser-GUI.ps1](scripts/Create-ADUser-GUI.ps1)

##### 使用说明：
1. 右键脚本 -> `用 PowerShell 运行`  
   ![img_25.png](images/img_25.png)

2. 填写用户信息并点击 `创建用户`  
   ![img_26.png](images/img_26.png)

3. 创建完成后会在下方显示运行结果  
   ![img_29.png](images/img_29.png)

4. 此时可尝试登录新创建的用户，验证是否能正常访问  
   ![img_30.png](images/img_30.png)

5. 登录后打开资源管理器，确认 `bread-makers DFS` 已映射为 Z: 盘  
   ![img_31.png](images/img_31.png)

6. 打开 DFS 文件夹，确认 `UserHomes` 中已创建用户专属文件夹，并具有正确的权限  
   ![img_32.png](images/img_32.png)

---

## 总结

在本章中，我们完成了以下任务：

- 在 AD 中创建了组织单位、用户和组结构
- 将客户端加入域，并使用域账户登录
- 配置了 DFS 文件夹的访问权限，实现按部门限制访问
- 使用 PowerShell 实现用户自动化创建、组策略分配和用户文件夹生成