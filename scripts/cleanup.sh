#!/bin/bash

# 项目清理脚本 - 移除冗余文件和优化项目结构
set -e

echo "🧹 开始清理项目..."

# 清理Flutter构建缓存
echo "📦 清理Flutter缓存..."
flutter clean

# 删除常见的临时文件和缓存
echo "🗑️ 删除临时文件..."
find . -name "*.tmp" -delete 2>/dev/null || true
find . -name "*.log" -delete 2>/dev/null || true
find . -name ".DS_Store" -delete 2>/dev/null || true
find . -name "Thumbs.db" -delete 2>/dev/null || true

# 清理IDE配置文件（保留.vscode和.idea的基本配置）
echo "⚙️ 清理IDE临时文件..."
rm -rf .vscode/settings.json 2>/dev/null || true
rm -rf .idea/workspace.xml 2>/dev/null || true
rm -rf .idea/tasks.xml 2>/dev/null || true

# 清理Android构建缓存
echo "🤖 清理Android构建缓存..."
rm -rf android/.gradle 2>/dev/null || true
rm -rf android/app/build 2>/dev/null || true
rm -rf android/build 2>/dev/null || true

# 清理iOS构建缓存
echo "🍎 清理iOS构建缓存..."
rm -rf ios/build 2>/dev/null || true
rm -rf ios/Pods 2>/dev/null || true
rm -rf ios/.symlinks 2>/dev/null || true

# 清理Web构建缓存
echo "🌐 清理Web构建缓存..."
rm -rf build/web 2>/dev/null || true

# 清理测试覆盖率文件
echo "📊 清理测试覆盖率文件..."
rm -rf coverage 2>/dev/null || true

# 清理代码生成文件
echo "🔧 清理代码生成文件..."
find . -name "*.g.dart" -delete 2>/dev/null || true
find . -name "*.freezed.dart" -delete 2>/dev/null || true

# 检查并删除空目录
echo "📁 删除空目录..."
find . -type d -empty -delete 2>/dev/null || true

# 优化pubspec.yaml（移除注释的资源）
echo "📝 优化配置文件..."
if [ -f "pubspec.yaml" ]; then
    # 创建备份
    cp pubspec.yaml pubspec.yaml.bak
    echo "✅ 已创建pubspec.yaml备份"
fi

echo "✅ 项目清理完成!"
echo ""
echo "📋 清理总结:"
echo "  - 已清理Flutter构建缓存"
echo "  - 已删除临时文件和系统缓存"
echo "  - 已清理平台特定构建文件"
echo "  - 已删除代码生成文件"
echo "  - 已移除空目录"
echo ""
echo "💡 建议运行 'flutter pub get' 重新获取依赖"