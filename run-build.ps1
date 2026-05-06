# run-build.ps1

Write-Host "[*] Booting Artifact Build Pipeline..." -ForegroundColor Cyan

# Ensure native directories exist before attempting to build
if (-not (Test-Path "android")) {
    Write-Host "[*] Native Android directory missing. Running prebuild..." -ForegroundColor Yellow
    npx expo prebuild -p android
}

Write-Host "[*] Phase 1: Compiling Android Release APK via Gradle..." -ForegroundColor Yellow

# 1. Move into the Android directory
Push-Location android

# 2. Run the Gradle Wrapper to build the release artifact
.\gradlew assembleRelease

# 3. Capture the success/fail code
$gradleExitCode = $LASTEXITCODE

# 4. Return to the main project folder
Pop-Location

if ($gradleExitCode -ne 0) {
    Write-Host "`n[ERROR] Gradle build failed! Check the logs above. Pipeline halted." -ForegroundColor Red
    exit 1
}

# 5. Verify the artifact actually exists
$apkPath = "android\app\build\outputs\apk\release\app-release.apk"

if (Test-Path $apkPath) {
    Write-Host "`n[SUCCESS] Build complete! Production-ready APK generated at: $apkPath" -ForegroundColor Green
} else {
    Write-Host "`n[ERROR] Build reported success, but the APK file could not be found." -ForegroundColor Red
    exit 1
}