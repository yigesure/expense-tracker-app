# 🔧 GitHub仓库设置指南

本指南将帮助您将Flutter记账应用代码推送到GitHub仓库，并配置自动构建功能。

## 📋 准备工作

### 1. 创建GitHub仓库

1. **登录GitHub**
   - 访问 [github.com](https://github.com)
   - 登录您的GitHub账户

2. **创建新仓库**
   - 点击右上角的 `+` 号
   - 选择 `New repository`
   - 填写仓库信息：
     - **Repository name**: `expense-tracker-app`
     - **Description**: `现代化Flutter移动端记账应用`
     - **Visibility**: `Public` 或 `Private`（推荐Private）
     - **Initialize**: 不要勾选任何初始化选项
   - 点击 `Create repository`

### 2. 本地Git配置

```bash
# 在项目根目录执行
cd expense_tracker_app

# 初始化Git仓库（如果还没有）
git init

# 添加远程仓库（替换为您的仓库地址）
git remote add origin https://github.com/your-username/expense-tracker-app.git

# 设置默认分支
git branch -M main
```

## 🚀 推送代码到GitHub

### 1. 提交代码

```bash
# 添加所有文件到暂存区
git add .

# 提交代码
git commit -m "🎉 初始提交：Flutter记账应用完整项目"

# 推送到GitHub
git push -u origin main
```

### 2. 验证推送结果

1. 刷新GitHub仓库页面
2. 确认所有文件都已上传
3. 检查README.md是否正确显示

## 🔐 配置GitHub Secrets

### 1. 生成签名密钥

在项目根目录执行：

```bash
# 给脚本执行权限
chmod +x scripts/setup-keystore.sh

# 运行密钥生成脚本
./scripts/setup-keystore.sh
```

脚本执行完成后，会显示需要添加到GitHub Secrets的信息。

### 2. 添加Secrets到GitHub

1. **进入仓库设置**
   - 在GitHub仓库页面点击 `Settings`
   - 在左侧菜单选择 `Secrets and variables` → `Actions`

2. **添加以下Secrets**：

   点击 `New repository secret` 按钮，逐个添加：

   | Secret名称 | 获取方法 |
   |-----------|---------|
   | `KEYSTORE_BASE64` | 脚本输出的Base64字符串 |
   | `KEYSTORE_PASSWORD` | 创建密钥库时输入的密码 |
   | `KEY_PASSWORD` | 创建密钥时输入的密码 |
   | `KEY_ALIAS` | 创建密钥时输入的别名 |

3. **验证Secrets配置**
   - 确保所有4个Secrets都已添加
   - 检查名称拼写是否正确

## ⚡ 触发首次构建

### 方法一：推送代码触发

```bash
# 对代码做一个小修改（比如更新README）
echo "# 自动构建测试" >> README.md

# 提交并推送
git add README.md
git commit -m "🔧 测试自动构建功能"
git push origin main
```

### 方法二：手动触发

1. 进入GitHub仓库的 `Actions` 页面
2. 选择 `构建Android APK` 工作流
3. 点击 `Run workflow`
4. 选择 `main` 分支和 `release` 构建类型
5. 点击 `Run workflow` 确认

## 📱 下载构建的APK

### 构建完成后：

1. **从Actions下载**：
   - 进入 `Actions` 页面
   - 点击最新的构建记录
   - 在 `Artifacts` 部分下载 `apk-builds`

2. **从Releases下载**（main分支自动发布）：
   - 进入仓库的 `Releases` 页面
   - 下载最新版本的APK文件

## 🔍 验证构建成功

### 检查构建状态

1. **Actions页面**：
   - 绿色✅表示构建成功
   - 红色❌表示构建失败

2. **构建产物**：
   - 成功构建会生成多个APK文件
   - 文件大小通常在15-30MB之间

3. **Release页面**：
   - main分支构建成功会自动创建Release
   - 包含版本信息和下载链接

## 🛠️ 常见问题解决

### 1. 推送失败

**问题**: `Permission denied` 或认证失败

**解决方案**:
```bash
# 使用Personal Access Token
git remote set-url origin https://your-token@github.com/your-username/expense-tracker-app.git

# 或使用SSH（需要配置SSH密钥）
git remote set-url origin git@github.com:your-username/expense-tracker-app.git
```

### 2. 构建失败

**问题**: GitHub Actions构建失败

**解决方案**:
1. 检查Secrets配置是否正确
2. 查看构建日志中的错误信息
3. 确认密钥库文件格式正确

### 3. APK无法安装

**问题**: 下载的APK无法在手机上安装

**解决方案**:
1. 确保手机允许安装未知来源应用
2. 检查APK文件是否完整下载
3. 尝试不同架构的APK文件

## 📊 仓库管理建议

### 1. 分支策略

```bash
# 创建开发分支
git checkout -b develop
git push -u origin develop

# 创建功能分支
git checkout -b feature/new-feature
```

### 2. 提交规范

使用语义化提交信息：

```bash
git commit -m "✨ feat: 添加新的统计图表功能"
git commit -m "🐛 fix: 修复余额计算错误"
git commit -m "📝 docs: 更新README文档"
git commit -m "🎨 style: 优化UI界面布局"
```

### 3. 版本管理

```bash
# 创建版本标签
git tag -a v1.0.0 -m "发布版本 1.0.0"
git push origin v1.0.0
```

## 🔒 安全建议

1. **私有仓库**: 建议使用私有仓库保护代码
2. **访问控制**: 限制仓库协作者权限
3. **密钥安全**: 定期更换签名密钥
4. **代码审查**: 启用分支保护和代码审查

## 📈 监控和维护

### 1. 构建监控

- 关注构建成功率
- 定期检查依赖更新
- 监控APK文件大小变化

### 2. 定期维护

- 更新Flutter SDK版本
- 升级依赖包版本
- 清理无用的构建产物

---

🎉 **恭喜！** 您已经成功设置了完整的GitHub仓库和自动构建系统。现在可以享受自动化的开发流程了！

## 📞 获取帮助

如果遇到问题，可以：

1. 查看GitHub Actions构建日志
2. 参考项目中的其他文档
3. 在仓库Issues中提问
4. 查看Flutter官方文档

**下一步**: 开始开发新功能，每次推送代码都会自动构建APK！