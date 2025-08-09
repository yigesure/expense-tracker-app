# 智能记账应用 - Expense Tracker App

一款现代化的Flutter移动端个人记账应用，支持智能自然语言记账和AI助手功能。

## 🚀 功能特性

### 核心功能
- ✅ **智能记账**: 支持自然语言输入，如"午饭30元，公交2元"
- ✅ **AI智能助手**: 完整的聊天界面，提供理财建议和消费分析
- ✅ **数据可视化**: 消费趋势图表和分类统计
- ✅ **多格式导出**: 支持CSV、JSON、PDF格式数据导出
- ✅ **日历视图**: 月度消费记录和报告生成
- ✅ **设置管理**: 完整的用户偏好和安全设置

### 技术特性
- 🎯 **状态管理**: 基于Riverpod的响应式状态管理
- 💾 **本地存储**: Hive数据库，支持离线使用
- 🎨 **现代UI**: Material Design 3设计语言
- 🔒 **安全性**: 数据加密和输入验证
- 📱 **多平台**: Android、iOS、Web支持

## 🛠️ 技术栈

- **框架**: Flutter 3.16.0+
- **状态管理**: Riverpod
- **数据库**: Hive
- **UI组件**: Material Design 3
- **图表**: FL Chart
- **动画**: Lottie, Animations
- **测试**: Flutter Test, Integration Test

## 📦 安装和运行

### 环境要求
- Flutter SDK 3.16.0+
- Dart SDK 3.1.0+
- Android Studio / VS Code
- Java 11+ (Android构建)

### 快速开始

1. **克隆项目**
```bash
git clone https://github.com/your-username/expense-tracker-app.git
cd expense-tracker-app
```

2. **安装依赖**
```bash
flutter pub get
```

3. **运行应用**
```bash
# 调试模式
flutter run

# 发布模式
flutter run --release
```

### 构建发布版本

#### Android APK
```bash
flutter build apk --release
```

#### Android App Bundle
```bash
flutter build appbundle --release
```

#### Web版本
```bash
flutter build web --release
```

## 🧪 测试

### 运行所有测试
```bash
flutter test
```

### 运行集成测试
```bash
flutter test integration_test/
```

### 代码分析
```bash
flutter analyze
```

## 📊 项目结构

```
lib/
├── core/                   # 核心功能
│   ├── models/            # 数据模型
│   ├── services/          # 业务服务
│   ├── providers/         # 状态管理
│   └── theme/             # 主题配置
├── features/              # 功能模块
│   ├── dashboard/         # 仪表板
│   ├── statistics/        # 统计分析
│   ├── calendar/          # 日历视图
│   ├── ai_assistant/      # AI助手
│   ├── transaction/       # 交易管理
│   └── settings/          # 设置
└── main.dart              # 应用入口
```

## 🔧 配置说明

### Android签名配置
创建 `android/key.properties` 文件：
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=path/to/your/keystore.jks
```

### 环境变量
创建 `.env` 文件：
```env
API_BASE_URL=https://api.example.com
DEBUG_MODE=false
```

## 🚀 CI/CD 部署

项目配置了GitHub Actions自动化构建和部署：

- **自动测试**: 每次提交自动运行测试
- **多平台构建**: 自动构建Android APK/AAB和Web版本
- **自动发布**: 主分支提交自动创建GitHub Release

### 手动部署到Codemagic

1. 连接GitHub仓库到Codemagic
2. 配置构建设置：
   - Flutter版本: 3.16.0
   - 构建模式: Release
   - 目标平台: Android
3. 添加环境变量和签名配置
4. 启动构建

## 📱 功能演示

### 智能记账
```
输入: "午饭30元，公交2元，咖啡15元"
输出: 自动解析为3条交易记录，智能分类
```

### AI助手对话
- 消费查询: "今天花了多少钱？"
- 理财建议: "有什么省钱建议？"
- 习惯分析: "我的消费习惯怎么样？"

## 🐛 问题排查

### 常见构建问题

1. **Gradle构建失败**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

2. **依赖冲突**
```bash
flutter pub deps
flutter pub upgrade
```

3. **Android签名问题**
- 检查 `key.properties` 文件路径
- 确认keystore文件存在
- 验证密码正确性

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🤝 贡献

欢迎提交Issue和Pull Request！

1. Fork项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开Pull Request

## 📞 联系方式

- 项目链接: [https://github.com/your-username/expense-tracker-app](https://github.com/your-username/expense-tracker-app)
- 问题反馈: [Issues](https://github.com/your-username/expense-tracker-app/issues)

## 🎯 路线图

- [ ] 云端数据同步
- [ ] 多账户支持
- [ ] 预算管理功能
- [ ] 投资记录功能
- [ ] 多语言支持
- [ ] 深色模式
- [ ] 桌面端应用

---

**开发团队**: CodeBuddy Team  
**最后更新**: 2024年1月