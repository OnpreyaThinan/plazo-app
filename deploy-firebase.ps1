# Firebase Deploy Script for Plazo App

Write-Host "=== Firebase Deployment Guide ===" -ForegroundColor Cyan
Write-Host ""

# Check Firebase CLI
try {
    $firebaseVersion = firebase --version 2>&1
    Write-Host "✓ Firebase CLI found: $firebaseVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Firebase CLI not installed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Installing Firebase CLI..." -ForegroundColor Yellow
    npm install -g firebase-tools
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "Please install Node.js first from: https://nodejs.org/" -ForegroundColor Yellow
        Write-Host "Then run: npm install -g firebase-tools" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""
Write-Host "Step 1: Login to Firebase" -ForegroundColor Cyan
firebase login

Write-Host ""
Write-Host "Step 2: Initialize Firebase (if not already done)" -ForegroundColor Cyan
Write-Host "Select your Firebase project or create a new one" -ForegroundColor Yellow
# firebase init hosting

Write-Host ""
Write-Host "Step 3: Update .firebaserc with your project ID" -ForegroundColor Cyan
Write-Host "Edit .firebaserc and replace 'your-firebase-project-id' with your actual project ID" -ForegroundColor Yellow

Write-Host ""
Write-Host "Step 4: Build latest Flutter web" -ForegroundColor Cyan
flutter build web --release
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Flutter web build failed. Fix build errors, then deploy again." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 5: Deploy to Firebase Hosting" -ForegroundColor Cyan
firebase deploy --only hosting

Write-Host ""
Write-Host "✓ Deployment complete!" -ForegroundColor Green
Write-Host "Your app should be live at: https://your-project-id.web.app" -ForegroundColor Cyan
