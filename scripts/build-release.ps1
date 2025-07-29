# PowerShell脚本：构建Flutter应用Release版本
# 适用于Windows系统

param(
    [string]$BuildType = "apk",  # apk, appbundle, or both
    [switch]$SplitPerAbi = $true,
    [switch]$Obfuscate = $true,
    [switch]$SplitDebugInfo = $true
)

Write-Host "🚀 开始构建Flutter应用Release版本..." -ForegroundColor Green

# 检查Flutter环境
try {
    $flutterVersion = flutter --version | Select-String "Flutter"
    Write-Host "✅ Flutter环境检查通过" -ForegroundColor Green
    Write-Host $flutterVersion -ForegroundColor Gray
} catch {
    Write-Host "❌ 错误: 未找到Flutter环境，请先安装Flutter SDK" -ForegroundColor Red
    Write-Host "下载地址: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}

# 检查项目结构
if (!(Test-Path "pubspec.yaml")) {
    Write-Host "❌ 错误: 当前目录不是Flutter项目根目录" -ForegroundColor Red
    exit 1
}

# 检查密钥库文件
$keystorePath = "android/app/upload-keystore.jks"
$keyPropertiesPath = "android/key.properties"

if (!(Test-Path $keystorePath)) {
    Write-Host "⚠️  警告: 未找到签名密钥库文件" -ForegroundColor Yellow
    Write-Host "请先运行: .\scripts\setup-keystore.ps1" -ForegroundColor Yellow
    
    $continue = Read-Host "是否继续使用debug签名构建? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 1
    }
}

# 清理项目
Write-Host "`n🧹 清理项目..." -ForegroundColor Yellow
flutter clean
flutter pub get

Write-Host "✅ 项目清理完成" -ForegroundColor Green

# 代码分析
Write-Host "`n🔍 运行代码分析..." -ForegroundColor Yellow
$analyzeResult = flutter analyze
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  代码分析发现问题，是否继续构建?" -ForegroundColor Yellow
    $continue = Read-Host "继续构建? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 1
    }
}

# 运行测试
Write-Host "`n🧪 运行测试..." -ForegroundColor Yellow
$testResult = flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  测试失败，是否继续构建?" -ForegroundColor Yellow
    $continue = Read-Host "继续构建? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 1
    }
}

# 构建参数
$buildArgs = @("build")

if ($BuildType -eq "apk" -or $BuildType -eq "both") {
    $buildArgs += "apk"
} elseif ($BuildType -eq "appbundle") {
    $buildArgs += "appbundle"
}

$buildArgs += "--release"

if ($SplitPerAbi -and ($BuildType -eq "apk" -or $BuildType -eq "both")) {
    $buildArgs += "--split-per-abi"
}

if ($Obfuscate) {
    $buildArgs += "--obfuscate"
}

if ($SplitDebugInfo) {
    $buildArgs += "--split-debug-info=build/app/outputs/symbols"
}

# 构建APK
if ($BuildType -eq "apk" -or $BuildType -eq "both") {
    Write-Host "`n📱 构建APK文件..." -ForegroundColor Yellow
    
    $apkBuildArgs = $buildArgs -replace "appbundle", "apk"
    $buildCommand = "flutter " + ($apkBuildArgs -join " ")
    
    Write-Host "执行命令: $buildCommand" -ForegroundColor Gray
    
    try {
        Invoke-Expression $buildCommand
        Write-Host "✅ APK构建成功!" -ForegroundColor Green
        
        # 显示APK文件信息
        $apkPath = "build/app/outputs/flutter-apk"
        if (Test-Path $apkPath) {
            Write-Host "`n📦 生成的APK文件:" -ForegroundColor Cyan
            Get-ChildItem $apkPath -Filter "*.apk" | ForEach-Object {
                $size = [math]::Round($_.Length / 1MB, 2)
                Write-Host "  📄 $($_.Name) (${size}MB)" -ForegroundColor White
            }
        }
    } catch {
        Write-Host "❌ APK构建失败: $_" -ForegroundColor Red
        exit 1
    }
}

# 构建App Bundle
if ($BuildType -eq "appbundle" -or $BuildType -eq "both") {
    Write-Host "`n📦 构建App Bundle文件..." -ForegroundColor Yellow
    
    $bundleBuildArgs = $buildArgs -replace "apk", "appbundle"
    $buildCommand = "flutter " + ($bundleBuildArgs -join " ")
    
    Write-Host "执行命令: $buildCommand" -ForegroundColor Gray
    
    try {
        Invoke-Expression $buildCommand
        Write-Host "✅ App Bundle构建成功!" -ForegroundColor Green
        
        # 显示Bundle文件信息
        $bundlePath = "build/app/outputs/bundle/release"
        if (Test-Path $bundlePath) {
            Write-Host "`n📦 生成的Bundle文件:" -ForegroundColor Cyan
            Get-ChildItem $bundlePath -Filter "*.aab" | ForEach-Object {
                $size = [math]::Round($_.Length / 1MB, 2)
                Write-Host "  📄 $($_.Name) (${size}MB)" -ForegroundColor White
            }
        }
    } catch {
        Write-Host "❌ App Bundle构建失败: $_" -ForegroundColor Red
        exit 1
    }
}

# 构建完成总结
Write-Host "`n" + "="*50 -ForegroundColor Green
Write-Host "🎉 构建完成!" -ForegroundColor Green
Write-Host "="*50 -ForegroundColor Green

Write-Host "`n📍 构建产物位置:" -ForegroundColor Cyan
if ($BuildType -eq "apk" -or $BuildType -eq "both") {
    Write-Host "  APK文件: build/app/outputs/flutter-apk/" -ForegroundColor White
}
if ($BuildType -eq "appbundle" -or $BuildType -eq "both") {
    Write-Host "  Bundle文件: build/app/outputs/bundle/release/" -ForegroundColor White
}

if ($SplitDebugInfo) {
    Write-Host "  调试符号: build/app/outputs/symbols/" -ForegroundColor White
}

Write-Host "`n📝 下一步:" -ForegroundColor Yellow
Write-Host "  1. 测试APK文件在真机上的运行情况" -ForegroundColor White
Write-Host "  2. 如需发布到应用商店，使用App Bundle文件" -ForegroundColor White
Write-Host "  3. 保存调试符号文件用于崩溃分析" -ForegroundColor White

Write-Host "`n✨ 构建脚本执行完成!" -ForegroundColor Green