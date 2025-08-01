# PowerShell Script: Generate Android Signing Keystore
# For Windows System

Write-Host "🔐 Starting Android keystore generation..." -ForegroundColor Green

# Check Java environment
try {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "✅ Java environment check passed: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Java environment not found, please install JDK first" -ForegroundColor Red
    Write-Host "Download URL: https://www.oracle.com/java/technologies/downloads/" -ForegroundColor Yellow
    exit 1
}

# Set keystore parameters
$keystorePath = "android/app/upload-keystore.jks"
$keyAlias = "upload"

Write-Host "`n📝 Please enter keystore information:" -ForegroundColor Cyan

# Get user input
$keystorePassword = Read-Host "Keystore password (recommend using strong password)"
$keyPassword = Read-Host "Key password (can be same as keystore password)"
$organizationName = Read-Host "Organization name (e.g.: Personal Developer)"
$organizationUnit = Read-Host "Organization unit (e.g.: Development Department)"
$city = Read-Host "City (e.g.: Beijing)"
$state = Read-Host "State (e.g.: Beijing)"
$country = Read-Host "Country code (e.g.: CN)"

# Create android/app directory if not exists
if (!(Test-Path "android/app")) {
    New-Item -ItemType Directory -Path "android/app" -Force
    Write-Host "✅ Created android/app directory" -ForegroundColor Green
}

# Generate keystore
Write-Host "`n🔨 Generating keystore..." -ForegroundColor Yellow

$keytoolCommand = @"
keytool -genkey -v -keystore $keystorePath -alias $keyAlias -keyalg RSA -keysize 2048 -validity 10000 -storepass $keystorePassword -keypass $keyPassword -dname "CN=$organizationName, OU=$organizationUnit, L=$city, ST=$state, C=$country"
"@

try {
    Invoke-Expression $keytoolCommand
    Write-Host "✅ Keystore generated successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Keystore generation failed: $_" -ForegroundColor Red
    exit 1
}

# Verify keystore
if (Test-Path $keystorePath) {
    Write-Host "✅ Keystore file created: $keystorePath" -ForegroundColor Green
    
    # Display keystore information
    Write-Host "`n📋 Keystore information:" -ForegroundColor Cyan
    keytool -list -v -keystore $keystorePath -storepass $keystorePassword
} else {
    Write-Host "❌ Keystore file not found" -ForegroundColor Red
    exit 1
}

# Generate Base64 encoding
Write-Host "`n🔄 Generating Base64 encoding..." -ForegroundColor Yellow

try {
    $keystoreBytes = [System.IO.File]::ReadAllBytes($keystorePath)
    $keystoreBase64 = [System.Convert]::ToBase64String($keystoreBytes)
    
    Write-Host "✅ Base64 encoding generated successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Base64 encoding generation failed: $_" -ForegroundColor Red
    exit 1
}

# Create key.properties file
$keyPropertiesContent = @"
storePassword=$keystorePassword
keyPassword=$keyPassword
keyAlias=$keyAlias
storeFile=upload-keystore.jks
"@

$keyPropertiesPath = "android/key.properties"
$keyPropertiesContent | Out-File -FilePath $keyPropertiesPath -Encoding UTF8

Write-Host "✅ Created key.properties file: $keyPropertiesPath" -ForegroundColor Green

# Display GitHub Secrets configuration information
Write-Host "`n" + "="*60 -ForegroundColor Cyan
Write-Host "🔐 GitHub Secrets Configuration Information" -ForegroundColor Cyan
Write-Host "="*60 -ForegroundColor Cyan

Write-Host "`nPlease add the following Secrets in GitHub repository settings:" -ForegroundColor Yellow
Write-Host "`n1. KEYSTORE_BASE64:" -ForegroundColor White
Write-Host $keystoreBase64 -ForegroundColor Gray

Write-Host "`n2. KEYSTORE_PASSWORD:" -ForegroundColor White
Write-Host $keystorePassword -ForegroundColor Gray

Write-Host "`n3. KEY_PASSWORD:" -ForegroundColor White
Write-Host $keyPassword -ForegroundColor Gray

Write-Host "`n4. KEY_ALIAS:" -ForegroundColor White
Write-Host $keyAlias -ForegroundColor Gray

Write-Host "`n" + "="*60 -ForegroundColor Cyan

# Save configuration information to file
$secretsInfo = @"
# GitHub Secrets Configuration Information
# Please add the following information to GitHub repository Secrets

KEYSTORE_BASE64=$keystoreBase64

KEYSTORE_PASSWORD=$keystorePassword

KEY_PASSWORD=$keyPassword

KEY_ALIAS=$keyAlias

# Configuration steps:
# 1. Go to GitHub repository page
# 2. Click Settings -> Secrets and variables -> Actions
# 3. Click New repository secret
# 4. Add the above 4 secrets one by one

# Note: Please keep this information safe and do not leak it to others
"@

$secretsInfo | Out-File -FilePath "github-secrets.txt" -Encoding UTF8
Write-Host "💾 Configuration information saved to: github-secrets.txt" -ForegroundColor Green

Write-Host "`n🎉 Keystore setup completed!" -ForegroundColor Green
Write-Host "📝 Next step: Add Secrets information to GitHub repository settings" -ForegroundColor Yellow
Write-Host "📖 For detailed steps, please refer to: GitHub Repository Setup Guide.md" -ForegroundColor Yellow