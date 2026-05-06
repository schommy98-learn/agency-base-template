# run-pipeline.ps1

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "INITIATING DISCFINDER MASTER PIPELINE" -ForegroundColor Cyan
Write-Host "=================================================`n" -ForegroundColor Cyan

# Define the stages
$stages = @(
    @{ Name = "Static Analysis"; Script = ".\run-checks.ps1" },
    @{ Name = "Unit Tests"; Script = ".\run-unit-tests.ps1" },
    @{ Name = "Security & Health"; Script = ".\run-security-scans.ps1" },
    @{ Name = "Artifact Build"; Script = ".\run-build.ps1" },
    @{ Name = "E2E UI Tests"; Script = ".\run-e2e-tests.ps1" }
)

$stopwatch = [Diagnostics.Stopwatch]::StartNew()

foreach ($stage in $stages) {
    Write-Host ">>> STARTING STAGE: $($stage.Name)" -ForegroundColor Magenta
    
    # Execute the script
    Invoke-Expression $stage.Script
    
    # Fail fast if the script exited with an error
    if ($LASTEXITCODE -ne 0) {
        $stopwatch.Stop()
        Write-Host "`n[FATAL] Pipeline failed at stage: $($stage.Name)!" -ForegroundColor Red
        Write-Host "Total Execution Time: $($stopwatch.Elapsed.ToString('mm\:ss'))" -ForegroundColor Gray
        exit 1
    }
    Write-Host "<<< STAGE COMPLETED: $($stage.Name)`n" -ForegroundColor Magenta
}

$stopwatch.Stop()
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "PIPELINE SUCCESS! DISCFINDER IS READY FOR RELEASE." -ForegroundColor Green
Write-Host "Total Execution Time: $($stopwatch.Elapsed.ToString('mm\:ss'))" -ForegroundColor Gray
Write-Host "=================================================" -ForegroundColor Cyan