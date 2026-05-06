# run-unit-tests.ps1

Write-Host "[*] Booting Unit Test Pipeline..." -ForegroundColor Cyan
Write-Host "[*] Executing Jest Test Suite..." -ForegroundColor Yellow

npx jest --passWithNoTests --silent

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n[ERROR] One or more unit tests failed. Math or logic is broken! Pipeline halted." -ForegroundColor Red
    exit 1
}

Write-Host "`n[SUCCESS] All Unit Tests Passed! Core logic is verified." -ForegroundColor Green