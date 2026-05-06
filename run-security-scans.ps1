# run-security-scans.ps1

Write-Host "[*] Booting Security & Project Health Pipeline..." -ForegroundColor Cyan

# --- 1. NPM VULNERABILITY AUDIT ---
Write-Host "[*] Phase 1: Checking NPM dependencies for High/Critical vulnerabilities..." -ForegroundColor Yellow
npm audit --audit-level=high

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n[ERROR] High or Critical vulnerabilities found in dependencies! Pipeline halted." -ForegroundColor Red
    exit 1
}
Write-Host "[SUCCESS] No High/Critical vulnerabilities found. Supply chain is secure." -ForegroundColor Green

# --- 2. EXPO DOCTOR HEALTH CHECK ---
Write-Host "`n[*] Phase 2: Validating React Native & Expo dependency alignment..." -ForegroundColor Yellow
npx --yes expo-doctor

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n[ERROR] Expo Doctor found project configuration or versioning issues! Pipeline halted." -ForegroundColor Red
    exit 1
}
Write-Host "`n[SUCCESS] Expo project configuration is perfectly aligned." -ForegroundColor Green