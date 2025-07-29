# 📱 个人记账助手

一款现代化的Flutter移动端记账应用，支持智能分类、语音输入、数据统计等功能。

## ✨ 主要功能

- 📊 **仪表板**：直观显示收支情况和余额变化
- 📈 **统计分析**：多维度数据分析和图表展示
- 🤖 **AI助手**：智能分类和语音识别记账
- 📅 **日历视图**：按日期查看和管理交易记录
- ⚙️ **个性化设置**：主题、货币、分类等自定义配置

## 🚀 快速开始

### 环境要求

- Flutter SDK >= 3.19.0
- Dart SDK >= 3.1.0
- Android SDK >= 21 (Android 5.0)
- Java 17+

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/your-username/expense_tracker_app.git
   cd expense_tracker_app
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行代码生成**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **运行应用**
   ```bash
   flutter run
   ```

## 📦 构建发布版

### 自动构建（推荐）

项目配置了GitHub Actions自动构建，推送代码到main分支即可触发：

1. **设置GitHub Secrets**（首次需要）：
   - `KEYSTORE_BASE64`: 密钥库文件的Base64编码
   - `KEYSTORE_PASSWORD`: 密钥库密码
   - `KEY_PASSWORD`: 密钥密码
   - `KEY_ALIAS`: 密钥别名

2. **推送代码触发构建**：
   ```bash
   git push origin main
   ```

3. **下载APK**：
   - 在GitHub Actions页面下载构建产物
   - 或在Releases页面下载发布版本

### 手动构建

1. **生成签名密钥**（首次需要）：
   ```bash
   chmod +x scripts/setup-keystore.sh
   ./scripts/setup-keystore.sh
   ```

2. **构建APK**：
   ```bash
   chmod +x scripts/build-release.sh
   ./scripts/build-release.sh
   ```

## 🏗️ 项目结构

```
lib/
├── core/                   # 核心功能
│   ├── models/            # 数据模型
│   ├── providers/         # 状态管理
│   ├── theme/            # 主题配置
│   ├── widgets/          # 通用组件
│   └── navigation/       # 路由配置
├── features/              # 功能模块
│   ├── dashboard/        # 仪表板
│   ├── statistics/       # 统计分析
│   ├── ai_assistant/     # AI助手
│   ├── calendar/         # 日历视图
│   ├── settings/         # 设置
│   └── main/            # 主页面
└── main.dart             # 应用入口
```

## 🔧 技术栈

- **框架**: Flutter 3.19.0
- **语言**: Dart 3.1.0
- **状态管理**: Riverpod
- **本地存储**: Hive + SQLite
- **图表**: FL Chart
- **图标**: Fluent UI Icons
- **动画**: Lottie + Animations
- **语音识别**: Speech to Text

## 📱 支持平台

- ✅ Android 5.0+ (API 21+)
- ✅ iOS 12.0+（需要额外配置）

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系方式

- 项目链接: [https://github.com/your-username/expense_tracker_app](https://github.com/your-username/expense_tracker_app)
- 问题反馈: [Issues](https://github.com/your-username/expense_tracker_app/issues)

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者和设计师！

---

⭐ 如果这个项目对你有帮助，请给它一个星标！