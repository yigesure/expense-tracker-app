#!/bin/bash

# Flutter记账应用构建脚本
# 用于本地构建发布版APK

set -e

echo "🚀 开始构建Flutter记账应用..."

# 检查Flutter环境
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter未安装或未添加到PATH"
    exit 1
fi

# 清理之前的构建
echo "🧹 清理之前的构建..."
flutter clean

# 获取依赖
echo "📦 获取依赖..."
flutter pub get

# 代码生成
echo "🔧 运行代码生成..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# 运行测试
echo "🧪 运行测试..."
flutter test

# 代码分析
echo "🔍 运行代码分析..."
flutter analyze

# 构建APK
echo "📱 构建APK..."
flutter build apk --release --split-per-abi

# 显示构建结果
echo "✅ 构建完成！"
echo "📁 APK文件位置："
ls -la build/app/outputs/flutter-apk/

# 计算文件大小
echo "📊 APK文件大小："
du -h build/app/outputs/flutter-apk/*.apk

echo "🎉 构建成功完成！"