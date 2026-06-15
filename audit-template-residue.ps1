[CmdletBinding()]
param(
    [string[]]$Terms = @("Claude", "Anthropic"),
    [string[]]$AdditionalTerms = @(),
    [string]$ReportFile = "TemplateResidueReport.txt"
)

$ErrorActionPreference = "Stop"

$RootPath = (Get-Location).Path
$ReportPath = Join-Path $RootPath $ReportFile
$AllTerms = @($Terms + $AdditionalTerms | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)

$ExcludeFolders = @(
    "node_modules",
    ".expo",
    ".git",
    ".metro-cache",
    ".cache",
    ".next",
    ".turbo",
    ".eas",
    "dist",
    "build",
    "web-build",
    "coverage",
    "Pods",
    "DerivedData"
)

$TextExtensions = @(
    ".ts",
    ".tsx",
    ".js",
    ".jsx",
    ".mjs",
    ".cjs",
    ".json",
    ".md",
    ".txt",
    ".ps1",
    ".sh",
    ".yml",
    ".yaml",
    ".toml",
    ".sql",
    ".xml"
)

$TextExactFiles = @(
    ".clinerules",
    ".clineignore",
    ".gitignore",
    "AGENTS.md",
    "CLAUDE.md",
    "Dockerfile"
)

function Get-RelativePath {
    param([string]$FullPath)

    $NormalizedRoot = $RootPath.TrimEnd([char[]]"\/")
    $Prefix = $NormalizedRoot + [System.IO.Path]::DirectorySeparatorChar

    if ($FullPath.StartsWith($Prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $FullPath.Substring($Prefix.Length)
    }

    return $FullPath
}

function Get-AuditFiles {
    param([string]$Directory)

    foreach ($Item in Get-ChildItem -LiteralPath $Directory -Force -ErrorAction SilentlyContinue) {
        if ($Item.PSIsContainer) {
            if ($ExcludeFolders -contains $Item.Name) {
                continue
            }

            Get-AuditFiles -Directory $Item.FullName
            continue
        }

        if ($Item.FullName -eq $ReportPath) {
            continue
        }

        [PSCustomObject]@{
            File = $Item
            RelativePath = Get-RelativePath -FullPath $Item.FullName
        }
    }
}

$Files = @(Get-AuditFiles -Directory $RootPath | Sort-Object RelativePath)
$NameMatches = @()
$ContentMatches = @()
$MojibakeMatches = @()
$DebugMarkerMatches = @()
$EmptyCodeOrConfigFiles = @()

foreach ($Candidate in $Files) {
    foreach ($Term in $AllTerms) {
        if ($Candidate.RelativePath.IndexOf($Term, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            $NameMatches += [PSCustomObject]@{
                Path = $Candidate.RelativePath
                Term = $Term
            }
        }
    }

    $IsTextFile =
        ($TextExactFiles -contains $Candidate.File.Name) -or
        ($TextExtensions -contains $Candidate.File.Extension.ToLowerInvariant())

    if (-not $IsTextFile) {
        continue
    }

    if ($Candidate.File.Length -eq 0) {
        $EmptyCodeOrConfigFiles += $Candidate.RelativePath
        continue
    }

    try {
        $Lines = Get-Content -LiteralPath $Candidate.File.FullName -ErrorAction Stop
    }
    catch {
        continue
    }

    for ($Index = 0; $Index -lt $Lines.Count; $Index++) {
        $LineNumber = $Index + 1
        $Line = [string]$Lines[$Index]

        foreach ($Term in $AllTerms) {
            if ($Line.IndexOf($Term, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                $ContentMatches += [PSCustomObject]@{
                    Path = $Candidate.RelativePath
                    Line = $LineNumber
                    Term = $Term
                    Text = $Line.Trim()
                }
            }
        }

        if (
            $Line.Contains("â") -or
            $Line.Contains("ðŸ") -or
            $Line.Contains("Â") -or
            $Line.Contains("ï¸")
        ) {
            $MojibakeMatches += [PSCustomObject]@{
                Path = $Candidate.RelativePath
                Line = $LineNumber
                Text = $Line.Trim()
            }
        }

        if (
            $Line.Contains("<---") -or
            $Line.Contains("ADD THIS HERE") -or
            $Line.Contains("RIGHT HERE")
        ) {
            $DebugMarkerMatches += [PSCustomObject]@{
                Path = $Candidate.RelativePath
                Line = $LineNumber
                Text = $Line.Trim()
            }
        }
    }
}

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$Writer = New-Object System.IO.StreamWriter($ReportPath, $false, $Utf8NoBom)

try {
    $Writer.WriteLine("=== TEMPLATE RESIDUE AUDIT ===")
    $Writer.WriteLine("Generated UTC: $([DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ'))")
    $Writer.WriteLine("Root folder: $RootPath")
    $Writer.WriteLine("Terms: $($AllTerms -join ', ')")
    $Writer.WriteLine("")

    $Writer.WriteLine("=== FILE OR FOLDER NAME MATCHES ===")
    if ($NameMatches.Count -eq 0) {
        $Writer.WriteLine("None")
    }
    else {
        foreach ($Match in $NameMatches) {
            $Writer.WriteLine("$($Match.Path) | term: $($Match.Term)")
        }
    }

    $Writer.WriteLine("")
    $Writer.WriteLine("=== FILE CONTENT MATCHES ===")
    if ($ContentMatches.Count -eq 0) {
        $Writer.WriteLine("None")
    }
    else {
        foreach ($Match in $ContentMatches) {
            $Writer.WriteLine("$($Match.Path):$($Match.Line) | $($Match.Term) | $($Match.Text)")
        }
    }

    $Writer.WriteLine("")
    $Writer.WriteLine("=== POSSIBLE MOJIBAKE ===")
    if ($MojibakeMatches.Count -eq 0) {
        $Writer.WriteLine("None")
    }
    else {
        foreach ($Match in $MojibakeMatches) {
            $Writer.WriteLine("$($Match.Path):$($Match.Line) | $($Match.Text)")
        }
    }

    $Writer.WriteLine("")
    $Writer.WriteLine("=== LEFTOVER EDITING MARKERS ===")
    if ($DebugMarkerMatches.Count -eq 0) {
        $Writer.WriteLine("None")
    }
    else {
        foreach ($Match in $DebugMarkerMatches) {
            $Writer.WriteLine("$($Match.Path):$($Match.Line) | $($Match.Text)")
        }
    }

    $Writer.WriteLine("")
    $Writer.WriteLine("=== EMPTY CODE OR CONFIG FILES ===")
    if ($EmptyCodeOrConfigFiles.Count -eq 0) {
        $Writer.WriteLine("None")
    }
    else {
        foreach ($Path in $EmptyCodeOrConfigFiles) {
            $Writer.WriteLine($Path)
        }
    }
}
finally {
    $Writer.Dispose()
}

Write-Host "Audit complete: $ReportPath"
Write-Host "Name matches: $($NameMatches.Count)"
Write-Host "Content matches: $($ContentMatches.Count)"
Write-Host "Possible mojibake matches: $($MojibakeMatches.Count)"
Write-Host "Editing markers: $($DebugMarkerMatches.Count)"
Write-Host "Empty code/config files: $($EmptyCodeOrConfigFiles.Count)"
