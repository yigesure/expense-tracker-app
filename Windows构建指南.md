# 🪟 Windows系统构建指南

本指南专门针对Windows系统用户，提供完整的Flutter应用构建和发布流程。

## 📋 环境准备

### 1. 安装必要软件

#### Java Development Kit (JDK)
```powershell
# 检查是否已安装Java
java -version

# 如果未安装，请下载安装JDK 11或更高版本
# 下载地址: https://www.oracle.com/java/technologies/downloads/
```

#### Flutter SDK
```powershell
# 检查Flutter安装
flutter --version
flutter doctor

# 如果未安装，请访问: https://flutter.dev/docs/get-started/install/windows
```

#### Android Studio
- 下载地址: https://developer.android.com/studio
- 安装Android SDK和构建工具

### 2. 环境变量配置

确保以下路径已添加到系统PATH环境变量：
- Flutter SDK的bin目录
- Java JDK的bin目录
- Android SDK的platform-tools目录

## 🔐 生成签名密钥

### 使用PowerShell脚本生成

```powershell
# 在项目根目录执行
.\scripts\setup-keystore.ps1
```

### 手动生成（可选）

```powershell
# 创建密钥库
keytool -genkey -v -keystore android/app/upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000

# 查看密钥库信息
keytool -list -v -keystore android/app/upload-keystore.jks
```

## 🚀 构建应用

### 使用PowerShell脚本构建

```powershell
# 构建APK文件
.\scripts\build-release.ps1

# 构建App Bundle
.\scripts\build-release.ps1 -BuildType appbundle

# 构建两种格式
.\scripts\build-release.ps1 -BuildType both

# 不分架构构建
.\scripts\build-release.ps1 -SplitPerAbi:$false

# 不混淆构建
.\scripts\build-release.ps1 -Obfuscate:$false
```

### 手动构建命令

```powershell
# 清理项目
flutter clean
flutter pub get

# 代码分析
flutter analyze

# 运行测试
flutter test

# 构建APK（分架构）
flutter build apk --release --split-per-abi

# 构建APK（通用版本）
flutter build apk --release

# 构建App Bundle
flutter build appbundle --release

# 带混淆的构建
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

## 📁 构建产物说明

### APK文件位置
```
build/app/outputs/flutter-apk/
├── app-arm64-v8a-release.apk      # 64位ARM设备
├── app-armeabi-v7a-release.apk    # 32位ARM设备
├── app-x86_64-release.apk         # x86_64设备
└── app-release.apk                # 通用版本（较大）
```

### App Bundle文件位置
```
build/app/outputs/bundle/release/
└── app-release.aab                # Google Play发布用
```

### 调试符号文件
```
build/app/outputs/symbols/         # 崩溃分析用
```

## 🔧 常见问题解决

### 1. PowerShell执行策略

如果无法执行PowerShell脚本：

```powershell
# 查看当前执行策略
Get-ExecutionPolicy

# 临时允许执行脚本
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 执行完成后恢复（可选）
Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope CurrentUser
```

### 2. Java环境问题

```powershell
# 检查Java安装
java -version
javac -version

# 检查JAVA_HOME环境变量
echo $env:JAVA_HOME

# 如果未设置，添加环境变量
[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-11.0.x", "User")
```

### 3. Android SDK问题

```powershell
# 检查Android SDK路径
echo $env:ANDROID_HOME

# 设置Android SDK路径
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Users\用户名\AppData\Local\Android\Sdk", "User")
```

### 4. Flutter Doctor检查

```powershell
# 检查Flutter环境
flutter doctor -v

# 接受Android许可证
flutter doctor --android-licenses
```

### 5. 构建错误处理

#### Gradle构建失败
```powershell
# 清理Gradle缓存
cd android
.\gradlew clean

# 返回项目根目录重新构建
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

#### 内存不足错误
在 `android/gradle.properties` 中添加：
```properties
org.gradle.jvmargs=-Xmx4g -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
```

#### 网络连接问题
```powershell
# 使用国内镜像
$env:PUB_HOSTED_URL="https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"

# 重新获取依赖
flutter pub get
```

## 📱 测试APK文件

### 1. 在模拟器中测试

```powershell
# 启动模拟器
flutter emulators --launch <emulator_id>

# 安装APK
flutter install --release
```

### 2. 在真机上测试

```powershell
# 连接设备并启用USB调试
adb devices

# 安装APK到设备
adb install build/app/outputs/flutter-apk/app-release.apk

# 或安装特定架构版本
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

### 3. 性能测试

```powershell
# 构建profile版本进行性能测试
flutter build apk --profile

# 运行性能分析
flutter run --profile
```

## 🔄 自动化构建

### 1. 批处理脚本

创建 `build.bat` 文件：

```batch
@echo off
echo 开始构建Flutter应用...

flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release --split-per-abi

echo 构建完成！
pause
```

### 2. 任务计划程序

使用Windows任务计划程序设置定时构建：

1. 打开"任务计划程序"
2. 创建基本任务
3. 设置触发器（如每日构建）
4. 设置操作为运行PowerShell脚本

### 3. GitHub Actions

参考项目中的 `.github/workflows/build-apk.yml` 文件，实现云端自动构建。

## 📊 构建优化

### 1. 减小APK大小

```powershell
# 启用代码混淆
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

# 分架构构建
flutter build apk --release --split-per-abi

# 移除未使用的资源
flutter build apk --release --tree-shake-icons
```

### 2. 构建速度优化

在 `android/gradle.properties` 中添加：

```properties
# 启用Gradle守护进程
org.gradle.daemon=true

# 并行构建
org.gradle.parallel=true

# 配置构建缓存
org.gradle.caching=true

# 增加内存分配
org.gradle.jvmargs=-Xmx4g
```

### 3. 依赖管理

```powershell
# 更新依赖
flutter pub upgrade

# 检查过时依赖
flutter pub outdated

# 分析依赖大小
flutter build apk --analyze-size
```

## 📝 构建日志

### 1. 启用详细日志

```powershell
# 详细构建日志
flutter build apk --release -v

# Gradle详细日志
cd android
.\gradlew assembleRelease --info
```

### 2. 日志文件保存

```powershell
# 保存构建日志到文件
flutter build apk --release -v > build-log.txt 2>&1
```

## 🎯 最佳实践

### 1. 版本管理

- 每次发布前更新 `pubspec.yaml` 中的版本号
- 使用Git标签标记发布版本
- 维护详细的变更日志

### 2. 质量保证

- 构建前运行所有测试
- 使用代码分析工具检查代码质量
- 在多种设备上测试APK

### 3. 安全考虑

- 妥善保管签名密钥
- 不要将密钥文件提交到版本控制
- 定期备份密钥文件

---

🎉 **恭喜！** 您已经掌握了在Windows系统上构建Flutter应用的完整流程。现在可以开始构建您的应用了！

## 📞 获取帮助

如果遇到问题，可以：

1. 查看Flutter官方文档
2. 运行 `flutter doctor` 检查环境
3. 查看构建日志中的错误信息
4. 在项目Issues中提问

**下一步**: 开始构建您的第一个Release版本APK！