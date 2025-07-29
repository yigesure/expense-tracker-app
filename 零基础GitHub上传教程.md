# 🚀 零基础GitHub上传教程

本教程专为零基础用户设计，手把手教您将Flutter记账应用上传到GitHub并自动生成APK文件。

## 📋 准备工作

### 1. 注册GitHub账户

1. **访问GitHub官网**
   - 打开浏览器，访问：https://github.com
   - 点击右上角的 `Sign up` 按钮

2. **填写注册信息**
   - **Username（用户名）**：选择一个唯一的用户名，如：`zhangsan2024`
   - **Email（邮箱）**：输入您的邮箱地址
   - **Password（密码）**：设置一个强密码
   - 点击 `Create account` 创建账户

3. **验证邮箱**
   - 查看您的邮箱，点击GitHub发送的验证链接
   - 完成邮箱验证

### 2. 安装Git软件

1. **下载Git**
   - 访问：https://git-scm.com/download/windows
   - 下载Windows版本的Git

2. **安装Git**
   - 双击下载的安装包
   - 一路点击 `Next`，使用默认设置即可
   - 安装完成后，右键桌面应该能看到 `Git Bash Here` 选项

3. **配置Git**
   ```bash
   # 打开Git Bash，输入以下命令（替换为您的信息）
   git config --global user.name "您的姓名"
   git config --global user.email "您的邮箱@example.com"
   ```

## 🔧 第一步：创建GitHub仓库

### 1. 登录GitHub

- 打开 https://github.com
- 输入用户名和密码登录

### 2. 创建新仓库

1. **点击创建按钮**
   - 登录后，点击右上角的 `+` 号
   - 选择 `New repository`

2. **填写仓库信息**
   - **Repository name（仓库名）**：输入 `expense-tracker-app`
   - **Description（描述）**：输入 `Flutter移动端记账应用`
   - **Public/Private**：选择 `Private`（推荐，保护您的代码）
   - **不要勾选** `Add a README file`
   - **不要勾选** `Add .gitignore`
   - **不要勾选** `Choose a license`

3. **创建仓库**
   - 点击绿色的 `Create repository` 按钮
   - 记住显示的仓库地址，类似：`https://github.com/您的用户名/expense-tracker-app.git`

## 📁 第二步：准备项目文件

### 1. 打开项目文件夹

- 打开文件管理器
- 导航到：`C:\Users\23828\Desktop\6666\expense_tracker_app`
- 在这个文件夹中右键，选择 `Git Bash Here`

### 2. 初始化Git仓库

在Git Bash中输入以下命令：

```bash
# 初始化Git仓库
git init

# 添加远程仓库（替换为您的仓库地址）
git remote add origin https://github.com/您的用户名/expense-tracker-app.git

# 设置默认分支名
git branch -M main
```

**重要提示**：将上面的 `您的用户名` 替换为您实际的GitHub用户名！

## 🔐 第三步：生成签名密钥

### 1. 运行密钥生成脚本

在Git Bash中输入：

```bash
# 运行PowerShell脚本生成密钥
powershell -ExecutionPolicy Bypass -File scripts/setup-keystore.ps1
```

### 2. 按提示输入信息

脚本会要求您输入以下信息：

- **密钥库密码**：输入一个强密码，如：`MyApp123456`
- **密钥密码**：可以与密钥库密码相同
- **组织名称**：输入您的名字或公司名，如：`张三`
- **组织单位**：输入部门名，如：`开发部`
- **城市**：输入您的城市，如：`北京`
- **省份**：输入您的省份，如：`北京市`
- **国家代码**：输入 `CN`

### 3. 保存密钥信息

脚本执行完成后会生成一个 `github-secrets.txt` 文件，里面包含了需要添加到GitHub的密钥信息。

**重要**：请妥善保管这个文件，不要泄露给他人！

## 📤 第四步：上传代码到GitHub

### 1. 添加所有文件

在Git Bash中输入：

```bash
# 添加所有文件到Git
git add .

# 提交代码
git commit -m "🎉 初始提交：Flutter记账应用完整项目"
```

### 2. 推送到GitHub

```bash
# 推送代码到GitHub
git push -u origin main
```

**如果遇到认证问题**，GitHub可能会弹出登录窗口，输入您的GitHub用户名和密码即可。

### 3. 验证上传成功

- 刷新您的GitHub仓库页面
- 应该能看到所有项目文件都已上传

## 🔑 第五步：配置GitHub Secrets

### 1. 进入仓库设置

1. 在GitHub仓库页面，点击 `Settings`（设置）
2. 在左侧菜单中找到 `Secrets and variables`
3. 点击 `Actions`

### 2. 添加Secrets

点击 `New repository secret` 按钮，需要添加4个secrets：

#### Secret 1: KEYSTORE_BASE64
- **Name**: `KEYSTORE_BASE64`
- **Secret**: 从 `github-secrets.txt` 文件中复制 `KEYSTORE_BASE64=` 后面的长字符串
- 点击 `Add secret`

#### Secret 2: KEYSTORE_PASSWORD
- **Name**: `KEYSTORE_PASSWORD`
- **Secret**: 您之前设置的密钥库密码
- 点击 `Add secret`

#### Secret 3: KEY_PASSWORD
- **Name**: `KEY_PASSWORD`
- **Secret**: 您之前设置的密钥密码
- 点击 `Add secret`

#### Secret 4: KEY_ALIAS
- **Name**: `KEY_ALIAS`
- **Secret**: `upload`（固定值）
- 点击 `Add secret`

### 3. 验证Secrets配置

确保您已经添加了所有4个secrets，名称拼写完全正确。

## 🚀 第六步：触发自动构建

### 方法一：推送代码触发（推荐）

在Git Bash中输入：

```bash
# 创建一个小修改来触发构建
echo "# 自动构建测试" >> README.md

# 提交修改
git add README.md
git commit -m "🔧 触发自动构建"

# 推送到GitHub
git push origin main
```

### 方法二：手动触发

1. 在GitHub仓库页面，点击 `Actions`
2. 选择 `构建Android APK` 工作流
3. 点击 `Run workflow`
4. 选择 `main` 分支
5. 点击绿色的 `Run workflow` 按钮

## 📱 第七步：下载APK文件

### 1. 等待构建完成

- 在 `Actions` 页面可以看到构建进度
- 绿色✅表示构建成功
- 红色❌表示构建失败
- 构建通常需要5-10分钟

### 2. 下载APK文件

构建成功后有两种下载方式：

#### 方式一：从Actions下载
1. 点击最新的构建记录
2. 滚动到页面底部的 `Artifacts` 部分
3. 点击 `apk-builds` 下载压缩包
4. 解压后可以看到多个APK文件

#### 方式二：从Releases下载
1. 在仓库主页点击 `Releases`
2. 下载最新版本的APK文件

### 3. APK文件说明

下载的压缩包中包含多个APK文件：

- `记账应用-v1.0.0-release.apk` - 通用版本（推荐）
- `记账应用-v1.0.0-arm64-v8a-release.apk` - 64位ARM设备
- `记账应用-v1.0.0-armeabi-v7a-release.apk` - 32位ARM设备
- `记账应用-v1.0.0-x86_64-release.apk` - x86_64设备

**建议**：优先使用通用版本，如果文件太大可以选择对应架构的版本。

## 📲 第八步：安装APK到手机

### 1. 传输APK到手机

- 通过USB数据线连接手机
- 将APK文件复制到手机存储中

### 2. 安装APK

1. **允许安装未知来源应用**
   - 打开手机设置
   - 找到"安全"或"应用管理"
   - 开启"允许安装未知来源应用"

2. **安装应用**
   - 在手机文件管理器中找到APK文件
   - 点击APK文件
   - 按提示完成安装

3. **运行应用**
   - 安装完成后点击"打开"
   - 或在桌面找到应用图标点击运行

## 🔄 后续使用

### 每次修改代码后

1. **提交修改**
   ```bash
   git add .
   git commit -m "✨ 添加新功能"
   git push origin main
   ```

2. **自动构建**
   - 推送后会自动触发构建
   - 等待构建完成后下载新的APK

### 版本管理

1. **更新版本号**
   - 修改 `pubspec.yaml` 中的版本号
   - 如：`version: 1.0.1+2`

2. **创建版本标签**
   ```bash
   git tag -a v1.0.1 -m "发布版本 1.0.1"
   git push origin v1.0.1
   ```

## ❗ 常见问题解决

### 问题1：推送失败，提示认证错误

**解决方案**：
1. 生成Personal Access Token
   - GitHub设置 → Developer settings → Personal access tokens
   - 生成新token，勾选repo权限
2. 使用token作为密码
   ```bash
   git remote set-url origin https://您的用户名:您的token@github.com/您的用户名/expense-tracker-app.git
   ```

### 问题2：构建失败

**解决方案**：
1. 检查Secrets配置是否正确
2. 查看Actions页面的错误日志
3. 确认密钥文件格式正确

### 问题3：APK无法安装

**解决方案**：
1. 确保手机允许安装未知来源应用
2. 检查APK文件是否完整下载
3. 尝试不同架构的APK文件

### 问题4：找不到Git Bash

**解决方案**：
1. 重新安装Git软件
2. 或使用Windows命令提示符（CMD）
3. 或使用PowerShell

## 📞 获取帮助

如果遇到问题：

1. **查看错误信息**：仔细阅读错误提示
2. **检查网络连接**：确保网络正常
3. **重试操作**：有时网络问题会导致失败
4. **查看文档**：参考项目中的其他文档
5. **寻求帮助**：在GitHub Issues中提问

## 🎉 恭喜完成！

您已经成功：

✅ 创建了GitHub账户和仓库  
✅ 上传了Flutter项目代码  
✅ 配置了自动构建系统  
✅ 生成了可安装的APK文件  
✅ 学会了版本管理流程  

现在您可以：
- 🔄 修改代码并自动构建新版本
- 📱 分享APK文件给朋友使用
- 🚀 继续开发新功能
- 📊 通过GitHub管理项目版本

**下一步**：开始使用您的记账应用，或者继续开发新功能！

---

💡 **小贴士**：建议将这个教程保存下来，以后需要时可以随时查看。