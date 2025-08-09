#!/bin/bash

# Flutter项目构建脚本
set -e

echo "🚀 开始构建Flutter项目..."

# 检查Flutter环境
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter未安装或未添加到PATH"
    exit 1
fi

echo "📋 Flutter版本信息:"
flutter --version

# 清理项目
echo "🧹 清理项目..."
flutter clean

# 获取依赖
echo "📦 获取依赖..."
flutter pub get

# 代码生成
echo "🔧 运行代码生成..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# 代码分析
echo "🔍 代码分析..."
flutter analyze

# 运行测试
echo "🧪 运行单元测试..."
flutter test --coverage

# 生成测试报告
echo "📊 生成测试覆盖率报告..."
if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    echo "✅ 测试覆盖率报告已生成: coverage/html/index.html"
fi

# 构建APK
echo "📱 构建Android APK..."
flutter build apk --release --split-per-abi

# 构建App Bundle
echo "📦 构建Android App Bundle..."
flutter build appbundle --release

# 构建Web版本
echo "🌐 构建Web版本..."
flutter build web --release

echo "✅ 构建完成!"
echo ""
echo "📁 构建产物位置:"
echo "  - APK: build/app/outputs/flutter-apk/"
echo "  - AAB: build/app/outputs/bundle/release/"
echo "  - Web: build/web/"
echo "  - 测试覆盖率: coverage/html/"