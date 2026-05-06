# run-checks.ps1

Write-Host "[*] Booting Static Analysis Pipeline..." -ForegroundColor Cyan

# --- 1. TYPESCRIPT TYPE CHECKING ---
Write-Host "[*] Phase 1: TypeScript Validation (tsc --noEmit)..." -ForegroundColor Yellow
npx tsc --noEmit
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] TypeScript found type errors. Please fix them before continuing." -ForegroundColor Red
    exit 1
}
Write-Host "[SUCCESS] TypeScript compilation passes cleanly." -ForegroundColor Green

# --- 2. ESLINT CODE QUALITY ---
Write-Host "`n[*] Phase 2: ESLint Validation..." -ForegroundColor Yellow
npx eslint . --max-warnings 100
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] ESLint found errors or exceeded the 100-warning limit. Pipeline halted." -ForegroundColor Red
    exit 1
}
Write-Host "[SUCCESS] ESLint passes cleanly (under warning threshold)." -ForegroundColor Green