$OutputFile = "DiscFinderContext.txt"

# 1. Aggressive Folder Exclusions (Prevents the text file from being 50MB)
$ExcludeFolders = @(
    'node_modules', '.expo', '.git', 'ios', 'android', 
    'bin', 'gen', 'mir', 'internal-mir', 'Data', 'assets', 'GhostBackups'
)

# 2. Aggressive File Exclusions (Lock files and configs that waste tokens)
$ExcludeFiles = @(
    'package-lock.json', 'yarn.lock', 'package.json', 'eas.json'
)

# 3. Targeted Source Code Extensions (React Native + Potential Hardware Scripts)
$IncludeExtensions = @('*.tsx', '*.ts', '*.js', '*.mc', '*.xml', '*.jungle')

Write-Host "Gathering DiscFinder project files..."
Write-Output "=== DISCFINDER PROJECT ARCHITECTURE ===" | Out-File -FilePath $OutputFile

# Get all source files, filtering out the excluded folders AND files
$files = Get-ChildItem -Path . -Recurse -Include $IncludeExtensions | Where-Object {
    $path = $_.FullName
    $name = $_.Name
    $exclude = $false
    
    foreach ($folder in $ExcludeFolders) {
        # Match exactly surrounded by slashes to avoid partial matches
        if ($path -match "\\$folder\\") {
            $exclude = $true
            break
        }
    }
    
    if ($ExcludeFiles -contains $name) {
        $exclude = $true
    }

    return -not $exclude
}

# Print a clean list of files as our architecture tree
$files | ForEach-Object { $_.FullName.Replace($PWD.Path + '\', '') } | Out-File -FilePath $OutputFile -Append

Write-Output "`n=== FILE CONTENTS ===" | Out-File -FilePath $OutputFile -Append

# Read and append the content of each file
foreach ($file in $files) {
    Write-Host "Packing: $($file.Name)"
    Write-Output "`n=== $($file.FullName.Replace($PWD.Path + '\', '')) ===" | Out-File -FilePath $OutputFile -Append
    Get-Content $file.FullName | Out-File -FilePath $OutputFile -Append
}

Write-Host "Done! Project packed successfully into $OutputFile"