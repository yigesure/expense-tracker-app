# PowerShell脚本：生成Android签名密钥库
# 适用于Windows系统

Write-Host "🔐 开始生成Android签名密钥库..." -ForegroundColor Green

# 检查Java环境
try {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "✅ Java环境检查通过: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ 错误: 未找到Java环境，请先安装JDK" -ForegroundColor Red
    Write-Host "下载地址: https://www.oracle.com/java/technologies/downloads/" -ForegroundColor Yellow
    exit 1
}

# 设置密钥库参数
$keystorePath = "android/app/upload-keystore.jks"
$keyAlias = "upload"

Write-Host "`n📝 请输入密钥库信息:" -ForegroundColor Cyan

# 获取用户输入
$keystorePassword = Read-Host "密钥库密码 (建议使用强密码)"
$keyPassword = Read-Host "密钥密码 (可以与密钥库密码相同)"
$organizationName = Read-Host "组织名称 (例如: 个人开发者)"
$organizationUnit = Read-Host "组织单位 (例如: 开发部门)"
$city = Read-Host "城市 (例如: 北京)"
$state = Read-Host "省份 (例如: 北京市)"
$country = Read-Host "国家代码 (例如: CN)"

# 创建android/app目录（如果不存在）
if (!(Test-Path "android/app")) {
    New-Item -ItemType Directory -Path "android/app" -Force
    Write-Host "✅ 创建android/app目录" -ForegroundColor Green
}

# 生成密钥库
Write-Host "`n🔨 正在生成密钥库..." -ForegroundColor Yellow

$keytoolCommand = @"
keytool -genkey -v -keystore $keystorePath -alias $keyAlias -keyalg RSA -keysize 2048 -validity 10000 -storepass $keystorePassword -keypass $keyPassword -dname "CN=$organizationName, OU=$organizationUnit, L=$city, ST=$state, C=$country"
"@

try {
    Invoke-Expression $keytoolCommand
    Write-Host "✅ 密钥库生成成功!" -ForegroundColor Green
} catch {
    Write-Host "❌ 密钥库生成失败: $_" -ForegroundColor Red
    exit 1
}

# 验证密钥库
if (Test-Path $keystorePath) {
    Write-Host "✅ 密钥库文件已创建: $keystorePath" -ForegroundColor Green
    
    # 显示密钥库信息
    Write-Host "`n📋 密钥库信息:" -ForegroundColor Cyan
    keytool -list -v -keystore $keystorePath -storepass $keystorePassword
} else {
    Write-Host "❌ 密钥库文件未找到" -ForegroundColor Red
    exit 1
}

# 生成Base64编码
Write-Host "`n🔄 正在生成Base64编码..." -ForegroundColor Yellow

try {
    $keystoreBytes = [System.IO.File]::ReadAllBytes($keystorePath)
    $keystoreBase64 = [System.Convert]::ToBase64String($keystoreBytes)
    
    Write-Host "✅ Base64编码生成成功!" -ForegroundColor Green
} catch {
    Write-Host "❌ Base64编码生成失败: $_" -ForegroundColor Red
    exit 1
}

# 创建key.properties文件
$keyPropertiesContent = @"
storePassword=$keystorePassword
keyPassword=$keyPassword
keyAlias=$keyAlias
storeFile=upload-keystore.jks
"@

$keyPropertiesPath = "android/key.properties"
$keyPropertiesContent | Out-File -FilePath $keyPropertiesPath -Encoding UTF8

Write-Host "✅ 创建key.properties文件: $keyPropertiesPath" -ForegroundColor Green

# 显示GitHub Secrets配置信息
Write-Host "`n" + "="*60 -ForegroundColor Cyan
Write-Host "🔐 GitHub Secrets 配置信息" -ForegroundColor Cyan
Write-Host "="*60 -ForegroundColor Cyan

Write-Host "`n请在GitHub仓库设置中添加以下Secrets:" -ForegroundColor Yellow
Write-Host "`n1. KEYSTORE_BASE64:" -ForegroundColor White
Write-Host $keystoreBase64 -ForegroundColor Gray

Write-Host "`n2. KEYSTORE_PASSWORD:" -ForegroundColor White
Write-Host $keystorePassword -ForegroundColor Gray

Write-Host "`n3. KEY_PASSWORD:" -ForegroundColor White
Write-Host $keyPassword -ForegroundColor Gray

Write-Host "`n4. KEY_ALIAS:" -ForegroundColor White
Write-Host $keyAlias -ForegroundColor Gray

Write-Host "`n" + "="*60 -ForegroundColor Cyan

# 保存配置信息到文件
$secretsInfo = @"
# GitHub Secrets 配置信息
# 请将以下信息添加到GitHub仓库的Secrets中

KEYSTORE_BASE64=$keystoreBase64

KEYSTORE_PASSWORD=$keystorePassword

KEY_PASSWORD=$keyPassword

KEY_ALIAS=$keyAlias

# 配置步骤:
# 1. 进入GitHub仓库页面
# 2. 点击Settings -> Secrets and variables -> Actions
# 3. 点击New repository secret
# 4. 逐个添加上述4个secrets

# 注意: 请妥善保管这些信息，不要泄露给他人
"@

$secretsInfo | Out-File -FilePath "github-secrets.txt" -Encoding UTF8
Write-Host "💾 配置信息已保存到: github-secrets.txt" -ForegroundColor Green

Write-Host "`n🎉 密钥库设置完成!" -ForegroundColor Green
Write-Host "📝 下一步: 将Secrets信息添加到GitHub仓库设置中" -ForegroundColor Yellow
Write-Host "📖 详细步骤请参考: GitHub仓库设置指南.md" -ForegroundColor Yellow