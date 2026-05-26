# deploy_testers.ps1
# This script builds both apps using size-reduction flags and automatically pushes them to Firebase App Distribution.

$ErrorActionPreference = "Stop"

$flutter = "C:\Users\Admin\Downloads\flutter_windows_3.32.0-stable\flutter\bin\flutter.bat"
$firebase = "firebase.cmd"

# Extracted from google-services.json
$userAppId = "1:300732475377:android:da6a2254c66435fb778650"
$providerAppId = "1:300732475377:android:4d1c4c3dea48927f778650"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " Pequire - Automated Testing Deployment " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Check if Firebase CLI is installed
try {
    & $firebase --version | Out-Null
} catch {
    Write-Host "`n[ERROR] Firebase CLI not found." -ForegroundColor Red
    Write-Host "Please run 'npm install -g firebase-tools' in your terminal." -ForegroundColor Yellow
    exit 1
}

# Skip prompt for automated run
$releaseNotes = "Fixed Provider Search, UPI flow, and Firebase bugs"

# -------------------------------------------------------------------------
# 1. USER APP DEPLOYMENT
# -------------------------------------------------------------------------
Write-Host "`n---> Building User App (Size Reduced - 64-bit)..." -ForegroundColor Yellow
cd .\User_app
& $flutter build apk --release --split-per-abi
if ($LASTEXITCODE -ne 0) { Write-Host "User App build failed!" -ForegroundColor Red; exit 1 }

$userApkPath = "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"
Write-Host "---> Uploading User App to Firebase..." -ForegroundColor Yellow
& $firebase appdistribution:distribute $userApkPath --app $userAppId --release-notes "$releaseNotes" --groups "user-app-testing"
cd ..


# -------------------------------------------------------------------------
# 2. PROVIDER APP DEPLOYMENT
# -------------------------------------------------------------------------
Write-Host "`n---> Building Provider App (Size Reduced - 64-bit)..." -ForegroundColor Yellow
cd .\Provider_App
& $flutter build apk --release --split-per-abi
if ($LASTEXITCODE -ne 0) { Write-Host "Provider App build failed!" -ForegroundColor Red; exit 1 }

$providerApkPath = "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"
Write-Host "---> Uploading Provider App to Firebase..." -ForegroundColor Yellow
& $firebase appdistribution:distribute $providerApkPath --app $providerAppId --release-notes "$releaseNotes" --groups "sps-app-testing"
cd ..

Write-Host "`n=============================================" -ForegroundColor Green
Write-Host " SUCCESS! Apps uploaded to Firebase. " -ForegroundColor Green
Write-Host " Testers will receive an email/notification!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
