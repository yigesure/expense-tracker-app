#!/bin/bash

# 密钥库设置脚本
# 用于生成Android签名密钥

set -e

echo "🔐 Android签名密钥设置"

# 检查是否已存在密钥库
if [ -f "android/app/keystore.jks" ]; then
    echo "⚠️  密钥库已存在，是否要重新生成？(y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ 取消操作"
        exit 0
    fi
fi

# 获取密钥信息
echo "请输入以下信息："
read -p "密钥库密码: " -s KEYSTORE_PASSWORD
echo
read -p "密钥密码: " -s KEY_PASSWORD
echo
read -p "密钥别名: " KEY_ALIAS
read -p "您的姓名: " DNAME_CN
read -p "组织单位: " DNAME_OU
read -p "组织: " DNAME_O
read -p "城市: " DNAME_L
read -p "省份: " DNAME_ST
read -p "国家代码 (CN): " DNAME_C

# 设置默认值
DNAME_C=${DNAME_C:-CN}

# 生成密钥库
echo "🔧 生成密钥库..."
keytool -genkey -v \
    -keystore android/app/keystore.jks \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias "$KEY_ALIAS" \
    -storepass "$KEYSTORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "CN=$DNAME_CN, OU=$DNAME_OU, O=$DNAME_O, L=$DNAME_L, ST=$DNAME_ST, C=$DNAME_C"

# 创建密钥属性文件
echo "📝 创建密钥属性文件..."
cat > android/key.properties << EOF
storePassword=$KEYSTORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=keystore.jks
EOF

echo "✅ 密钥库设置完成！"
echo "📁 密钥库文件: android/app/keystore.jks"
echo "📁 密钥属性文件: android/key.properties"
echo ""
echo "⚠️  重要提醒："
echo "1. 请妥善保管密钥库文件和密码"
echo "2. 不要将密钥库文件提交到版本控制系统"
echo "3. 建议将密钥库文件备份到安全位置"
echo ""
echo "🔒 GitHub Secrets 设置："
echo "KEYSTORE_BASE64: $(base64 -w 0 android/app/keystore.jks)"
echo "KEYSTORE_PASSWORD: $KEYSTORE_PASSWORD"
echo "KEY_PASSWORD: $KEY_PASSWORD"
echo "KEY_ALIAS: $KEY_ALIAS"