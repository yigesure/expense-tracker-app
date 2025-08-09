#!/bin/bash

# Git提交脚本 - 修复构建问题并提交到GitHub

echo "🔧 开始提交构建修复..."

# 检查Git状态
if ! git status &>/dev/null; then
    echo "❌ 错误: 当前目录不是Git仓库"
    exit 1
fi

# 添加所有修改的文件
echo "📁 添加修改的文件..."
git add .

# 检查是否有文件需要提交
if git diff --cached --quiet; then
    echo "ℹ️  没有文件需要提交"
    exit 0
fi

# 提交修改
echo "💾 提交修改..."
git commit -m "🔧 修复Android构建配置

- 修复android/app/build.gradle语法错误
- 简化构建配置，移除复杂的优化选项
- 添加ProGuard规则文件
- 更新GitHub Actions工作流
- 添加完整的项目文档
- 确保Gradle构建兼容性

修复内容:
✅ 移除导致语法错误的复杂配置
✅ 简化signingConfigs和buildTypes
✅ 添加必要的ProGuard规则
✅ 更新CI/CD配置
✅ 完善项目文档和部署指南"

# 推送到远程仓库
echo "🚀 推送到GitHub..."
if git push origin main 2>/dev/null || git push origin master 2>/dev/null; then
    echo "✅ 成功推送到GitHub!"
    echo ""
    echo "🎉 构建修复完成!"
    echo "📱 现在可以在Codemagic中重新构建项目"
    echo ""
    echo "构建步骤:"
    echo "1. 登录Codemagic控制台"
    echo "2. 选择项目并启动新构建"
    echo "3. 构建应该成功完成"
    echo ""
    echo "如果仍有问题，请检查:"
    echo "- Flutter版本是否为3.16.0+"
    echo "- Java版本是否为11+"
    echo "- 签名配置是否正确"
else
    echo "❌ 推送失败，请检查网络连接和权限"
    echo "手动推送命令:"
    echo "git push origin main"
    echo "或"
    echo "git push origin master"
    exit 1
fi