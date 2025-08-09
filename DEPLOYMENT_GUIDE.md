# 部署指南 - 个人记账助手

## 🚀 快速部署

### 前置要求
- Flutter SDK 3.16.0+
- Android Studio / VS Code
- Git
- Java 11+

### 一键部署
```bash
# 克隆项目
git clone <repository-url>
cd expense-tracker-app-main

# 安装依赖
flutter pub get

# 运行构建脚本
./scripts/build.sh
```

## 📱 Android发布

### 1. 生成签名密钥
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. 配置签名
创建 `android/key.properties`:
```properties
storePassword=<密码>
keyPassword=<密钥密码>
keyAlias=upload
storeFile=<密钥文件路径>
```

### 3. 构建发布版本
```bash
# 构建APK
flutter build apk --release --split-per-abi

# 构建App Bundle (推荐)
flutter build appbundle --release
```

### 4. 发布到Google Play
1. 上传AAB文件到Google Play Console
2. 填写应用信息和截图
3. 设置定价和分发
4. 提交审核

## 🌐 Web部署

### 构建Web版本
```bash
flutter build web --release
```

### 部署到GitHub Pages
```bash
# 推送到gh-pages分支
git subtree push --prefix build/web origin gh-pages
```

### 部署到其他平台
- **Netlify**: 拖拽 `build/web` 文件夹
- **Vercel**: 连接GitHub仓库
- **Firebase Hosting**: `firebase deploy`

## 🔄 CI/CD自动化

### GitHub Actions配置
已配置的工作流程：
- 代码质量检查
- 自动化测试
- 构建验证
- 自动发布

### 环境变量设置
在GitHub仓库设置中添加：
```
SIGNING_KEY: <Base64编码的签名密钥>
ALIAS: upload
KEY_STORE_PASSWORD: <密钥库密码>
KEY_PASSWORD: <密钥密码>
```

## 📊 监控和分析

### 性能监控
- Firebase Performance Monitoring
- Crashlytics崩溃报告
- Google Analytics用户行为

### 质量监控
- 代码覆盖率报告
- 静态分析结果
- 安全漏洞扫描

## 🔧 环境配置

### 开发环境
```bash
# 检查Flutter环境
flutter doctor

# 运行开发服务器
flutter run
```

### 生产环境
```bash
# 性能分析构建
flutter build apk --release --analyze-size

# 内存泄漏检测
flutter run --profile
```

## 📋 发布检查清单

### 代码质量
- [ ] 所有测试通过
- [ ] 代码覆盖率 > 80%
- [ ] 静态分析无错误
- [ ] 性能测试通过

### 功能验证
- [ ] 核心功能正常
- [ ] 用户界面完整
- [ ] 数据持久化正常
- [ ] 错误处理完善

### 安全检查
- [ ] 敏感信息已移除
- [ ] 权限配置正确
- [ ] 数据加密启用
- [ ] 网络安全配置

### 兼容性测试
- [ ] 多设备适配
- [ ] 不同Android版本
- [ ] 网络环境测试
- [ ] 离线功能验证

## 🚨 故障排除

### 常见问题
1. **构建失败**
   - 检查Flutter版本
   - 清理缓存: `flutter clean`
   - 重新获取依赖: `flutter pub get`

2. **签名错误**
   - 验证密钥文件路径
   - 检查密码配置
   - 确认密钥别名

3. **测试失败**
   - 检查测试环境
   - 更新测试数据
   - 验证模拟器配置

### 调试工具
```bash
# 详细日志
flutter run --verbose

# 性能分析
flutter run --profile

# 调试信息
flutter analyze --verbose
```

## 📈 版本管理

### 版本号规则
- 主版本.次版本.修订版本+构建号
- 例: 1.2.3+45

### 发布流程
1. 功能开发完成
2. 代码审查通过
3. 测试验证完成
4. 版本号更新
5. 构建发布版本
6. 部署到生产环境
7. 监控和反馈

## 🎯 性能优化

### 构建优化
- 启用代码混淆
- 资源压缩
- 多架构支持
- 增量构建

### 运行时优化
- 内存管理
- 异步操作
- 缓存策略
- 网络优化

---
*最后更新: 2025年8月9日*