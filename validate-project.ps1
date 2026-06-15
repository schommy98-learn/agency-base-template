[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Invoke-ValidationStep {
param(
[Parameter(Mandatory = $true)]
[string]$Name,

[Parameter(Mandatory = $true)]
[scriptblock]$Command

)

Write-Host ""
Write-Host "=== $Name ===" -ForegroundColor Cyan

& $Command

if ($LASTEXITCODE -ne 0) {
Write-Host ""
Write-Host "[FAILED] $Name" -ForegroundColor Red
exit $LASTEXITCODE
}

Write-Host "[PASSED] $Name" -ForegroundColor Green
}

Write-Host "Agency Base Template Validation" -ForegroundColor Cyan

Invoke-ValidationStep -Name "Node Version" -Command {
node --version
}

Invoke-ValidationStep -Name "Expo Dependency Alignment" -Command {
npx expo install --check
}

Invoke-ValidationStep -Name "Expo Doctor" -Command {
npx --yes expo-doctor@latest
}

Invoke-ValidationStep -Name "TypeScript" -Command {
npx tsc --noEmit
}

Invoke-ValidationStep -Name "ESLint" -Command {
npm run lint
}

Invoke-ValidationStep -Name "Jest" -Command {
npm test
}

Write-Host ""
Write-Host "=== TEMPLATE VALIDATION PASSED ===" -ForegroundColor Green