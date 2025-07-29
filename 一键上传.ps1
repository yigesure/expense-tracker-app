# Flutter记账应用一键上传脚本
# 使用方法：在PowerShell中执行 .\一键上传.ps1

Write-Host "🚀 Flutter记账应用一键上传脚本" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

# 检查Git是否安装
Write-Host "📋 检查Git环境..." -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host "✅ Git已安装: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git未安装，请先安装Git:" -ForegroundColor Red
    Write-Host "   下载地址: https://git-scm.com/download/windows" -ForegroundColor Yellow
    Write-Host "   安装完成后重新运行此脚本" -ForegroundColor Yellow
    Read-Host "按任意键退出"
    exit
}

# 获取用户信息
Write-Host "`n📝 配置用户信息..." -ForegroundColor Yellow
$username = Read-Host "请输入您的GitHub用户名"
$email = Read-Host "请输入您的GitHub邮箱"
$repoName = Read-Host "请输入仓库名称 (默认: expense-tracker-app)" 
if ([string]::IsNullOrEmpty($repoName)) {
    $repoName = "expense-tracker-app"
}

# 配置Git用户信息
Write-Host "`n⚙️ 配置Git用户信息..." -ForegroundColor Yellow
git config --global user.name "$username"
git config --global user.email "$email"
Write-Host "✅ Git用户信息配置完成" -ForegroundColor Green

# 初始化Git仓库
Write-Host "`n📦 初始化Git仓库..." -ForegroundColor Yellow
if (Test-Path ".git") {
    Write-Host "⚠️ Git仓库已存在，跳过初始化" -ForegroundColor Yellow
} else {
    git init
    Write-Host "✅ Git仓库初始化完成" -ForegroundColor Green
}

# 添加远程仓库
Write-Host "`n🔗 配置远程仓库..." -ForegroundColor Yellow
$remoteUrl = "https://github.com/$username/$repoName.git"
try {
    git remote add origin $remoteUrl
    Write-Host "✅ 远程仓库配置完成: $remoteUrl" -ForegroundColor Green
} catch {
    Write-Host "⚠️ 远程仓库可能已存在，尝试更新..." -ForegroundColor Yellow
    git remote set-url origin $remoteUrl
    Write-Host "✅ 远程仓库更新完成" -ForegroundColor Green
}

# 设置主分支
Write-Host "`n🌿 设置主分支..." -ForegroundColor Yellow
git branch -M main
Write-Host "✅ 主分支设置完成" -ForegroundColor Green

# 添加文件
Write-Host "`n📁 添加项目文件..." -ForegroundColor Yellow
git add .
Write-Host "✅ 文件添加完成" -ForegroundColor Green

# 提交代码
Write-Host "`n💾 提交代码..." -ForegroundColor Yellow
$commitMessage = "🎉 初始提交：Flutter记账应用 - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git commit -m "$commitMessage"
Write-Host "✅ 代码提交完成" -ForegroundColor Green

# 推送到GitHub
Write-Host "`n🚀 推送到GitHub..." -ForegroundColor Yellow
Write-Host "⚠️ 如果是第一次推送，可能需要输入GitHub用户名和密码" -ForegroundColor Yellow
try {
    git push -u origin main
    Write-Host "✅ 代码推送成功！" -ForegroundColor Green
} catch {
    Write-Host "❌ 推送失败，可能的原因：" -ForegroundColor Red
    Write-Host "   1. 仓库不存在，请先在GitHub创建仓库" -ForegroundColor Yellow
    Write-Host "   2. 用户名或密码错误" -ForegroundColor Yellow
    Write-Host "   3. 网络连接问题" -ForegroundColor Yellow
    Read-Host "按任意键退出"
    exit
}

# 生成签名密钥
Write-Host "`n🔐 生成签名密钥..." -ForegroundColor Yellow
$generateKey = Read-Host "是否生成APK签名密钥？(y/n，默认y)"
if ($generateKey -ne "n") {
    if (Test-Path "scripts/setup-keystore.ps1") {
        Write-Host "正在生成密钥，请按提示操作..." -ForegroundColor Yellow
        powershell -ExecutionPolicy Bypass -File scripts/setup-keystore.ps1
    } else {
        Write-Host "⚠️ 密钥生成脚本不存在，请手动配置" -ForegroundColor Yellow
    }
}

# 完成提示
Write-Host "`n🎉 上传完成！" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host "📍 下一步操作：" -ForegroundColor Yellow
Write-Host "   1. 访问您的GitHub仓库: https://github.com/$username/$repoName" -ForegroundColor Cyan
Write-Host "   2. 在仓库设置中配置Secrets（如果生成了密钥）" -ForegroundColor Cyan
Write-Host "   3. 查看Actions页面的自动构建进度" -ForegroundColor Cyan
Write-Host "   4. 构建完成后在Releases页面下载APK" -ForegroundColor Cyan
Write-Host "`n📱 APK文件将在几分钟后自动生成！" -ForegroundColor Green

Read-Host "`n按任意键退出"