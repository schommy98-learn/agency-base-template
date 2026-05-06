# run-e2e-tests.ps1

Write-Host "[*] Booting E2E Testing Pipeline..." -ForegroundColor Cyan

$env:ANDROID_HOME = "D:\DevCaches\Android\Sdk"
$EmulatorPath = "$env:ANDROID_HOME\emulator\emulator.exe"
$AdbPath = "$env:ANDROID_HOME\platform-tools\adb.exe"
$ApkPath = "android\app\build\outputs\apk\release\app-release.apk"
$LocalMaestro = "$env:USERPROFILE\.maestro\bin\maestro.bat"

# --- 1. VERIFY EMULATOR STATE ---
Write-Host "[*] Phase 1: Checking Emulator State..." -ForegroundColor Yellow
$devices = & $AdbPath devices
if ($devices -notmatch "emulator-") {
    Write-Host "    Starting Android Emulator (Pixel_6)..." -ForegroundColor Gray
    Start-Process -FilePath $EmulatorPath -ArgumentList "-avd Pixel_6 -no-snapshot-load -no-skin" -WindowStyle Hidden
    do { Start-Sleep -Seconds 2 } until ((& $AdbPath shell getprop sys.boot_completed 2>&1) -match "1")
}

# --- 2. INSTALL THE ARTIFACT ---
Write-Host "`n[*] Phase 2: Installing Release APK..." -ForegroundColor Yellow
& $AdbPath install -r $ApkPath

# --- 3. RUN MAESTRO ---
Write-Host "`n[*] Phase 3: Executing Maestro Test Suite..." -ForegroundColor Yellow

$TestDirectory = ".maestro/journeys/"
$TestFiles = Get-ChildItem -Path $TestDirectory -Filter *.yaml -Recurse -ErrorAction SilentlyContinue

if ($TestFiles.Count -gt 0) {
    & $LocalMaestro test $TestDirectory --format html --output test-report.html

    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n[ERROR] One or more E2E tests failed! Check test-report.html for details. Pipeline halted." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "`n[SKIPPED] No Maestro .yaml files found in $TestDirectory. Skipping E2E phase." -ForegroundColor DarkYellow
}

Write-Host "`n[SUCCESS] All E2E Tests Passed (or safely skipped)! Pipeline is fully green." -ForegroundColor Green