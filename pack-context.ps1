[CmdletBinding()]
param(
    [string]$ProjectName = (Split-Path -Leaf (Get-Location)),
    [string]$OutputFile = "",
    [int]$MaxFileSizeKB = 512,
    [switch]$IncludeNative
)

$ErrorActionPreference = "Stop"

$RootPath = (Get-Location).Path
$SafeProjectName = ($ProjectName -replace "[^A-Za-z0-9_-]", "")

if ([string]::IsNullOrWhiteSpace($SafeProjectName)) {
    $SafeProjectName = "Project"
}

if ([string]::IsNullOrWhiteSpace($OutputFile)) {
    $OutputFile = "${SafeProjectName}Context.txt"
}

$OutputPath = Join-Path $RootPath $OutputFile

# Folders that are generated, very large, binary-heavy, or not useful in routine AI context.
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
    "DerivedData",
    "artifacts",
    "test-results",
    "playwright-report",
    "maestro-results",
    "GhostBackups"
)

if (-not $IncludeNative) {
    $ExcludeFolders += @("android", "ios")
}

# Large, generated, binary, secret-bearing, or duplicate files.
$ExcludeExactFiles = @(
    $OutputFile,
    "package-lock.json",
    "yarn.lock",
    "pnpm-lock.yaml",
    "bun.lock",
    "bun.lockb",
    ".DS_Store",
    "google-services.json",
    "GoogleService-Info.plist",
    "credentials.json",
    ".npmrc"
)

$ExcludeFilePatterns = @(
    "*.db",
    "*.db-shm",
    "*.db-wal",
    "*.sqlite",
    "*.sqlite3",
    "*.sqlite-shm",
    "*.sqlite-wal",
    "*.apk",
    "*.aab",
    "*.ipa",
    "*.app",
    "*.exe",
    "*.dll",
    "*.so",
    "*.dylib",
    "*.zip",
    "*.tar",
    "*.gz",
    "*.7z",
    "*.png",
    "*.jpg",
    "*.jpeg",
    "*.gif",
    "*.webp",
    "*.ico",
    "*.pdf",
    "*.mp3",
    "*.mp4",
    "*.mov",
    "*.wav",
    "*.ttf",
    "*.otf",
    "*.woff",
    "*.woff2",
    "*.jks",
    "*.keystore",
    "*.p8",
    "*.p12",
    "*.pem",
    "*.key",
    "*.mobileprovision",
    "*.log",
    "*.tsbuildinfo",
    "*.map"
)

# Source, configuration, documentation, migrations, tests, and automation.
$IncludeExtensions = @(
    ".ts",
    ".tsx",
    ".js",
    ".jsx",
    ".mjs",
    ".cjs",
    ".json",
    ".md",
    ".sql",
    ".ps1",
    ".sh",
    ".yml",
    ".yaml",
    ".toml",
    ".graphql",
    ".gql",
    ".css",
    ".scss",
    ".html",
    ".xml"
)

# Important extensionless or dotfiles that are otherwise missed by extension filtering.
$IncludeExactFiles = @(
    ".clinerules",
    ".clineignore",
    ".gitignore",
    "AGENTS.md",
    "CLAUDE.md",
    "Dockerfile",
    "LICENSE"
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

function Test-ExcludedFile {
    param([System.IO.FileInfo]$File)

    if ($ExcludeExactFiles -contains $File.Name) {
        return $true
    }

    if ($File.Name -like ".env*") {
        return $true
    }

    foreach ($Pattern in $ExcludeFilePatterns) {
        if ($File.Name -like $Pattern) {
            return $true
        }
    }

    return $false
}

function Test-IncludedFile {
    param([System.IO.FileInfo]$File)

    if ($IncludeExactFiles -contains $File.Name) {
        return $true
    }

    return $IncludeExtensions -contains $File.Extension.ToLowerInvariant()
}

function Get-ProjectFiles {
    param([string]$Directory)

    foreach ($Item in Get-ChildItem -LiteralPath $Directory -Force -ErrorAction SilentlyContinue) {
        if ($Item.PSIsContainer) {
            if ($ExcludeFolders -contains $Item.Name) {
                continue
            }

            Get-ProjectFiles -Directory $Item.FullName
            continue
        }

        if ($Item.FullName -eq $OutputPath) {
            continue
        }

        if (Test-ExcludedFile -File $Item) {
            continue
        }

        if (-not (Test-IncludedFile -File $Item)) {
            continue
        }

        [PSCustomObject]@{
            File = $Item
            RelativePath = Get-RelativePath -FullPath $Item.FullName
        }
    }
}

Write-Host "Gathering project context for $ProjectName..."

$AllCandidates = @(Get-ProjectFiles -Directory $RootPath | Sort-Object RelativePath)
$IncludedFiles = @()
$SkippedLargeFiles = @()

foreach ($Candidate in $AllCandidates) {
    if ($Candidate.File.Length -gt ($MaxFileSizeKB * 1KB)) {
        $SkippedLargeFiles += $Candidate
        continue
    }

    $IncludedFiles += $Candidate
}

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$Writer = New-Object System.IO.StreamWriter($OutputPath, $false, $Utf8NoBom)

try {
    $Writer.WriteLine("=== PROJECT CONTEXT ===")
    $Writer.WriteLine("Project: $ProjectName")
    $Writer.WriteLine("Generated UTC: $([DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ'))")
    $Writer.WriteLine("Root folder: $RootPath")
    $Writer.WriteLine("Included files: $($IncludedFiles.Count)")
    $Writer.WriteLine("Maximum file size: $MaxFileSizeKB KB")
    $Writer.WriteLine("Native folders included: $($IncludeNative.IsPresent)")
    $Writer.WriteLine("")
    $Writer.WriteLine("IMPORTANT: Review this file for secrets before uploading it to any AI service.")
    $Writer.WriteLine("")

    $Writer.WriteLine("=== PROJECT ARCHITECTURE ===")
    foreach ($Candidate in $IncludedFiles) {
        $Writer.WriteLine($Candidate.RelativePath)
    }

    if ($SkippedLargeFiles.Count -gt 0) {
        $Writer.WriteLine("")
        $Writer.WriteLine("=== SKIPPED LARGE FILES ===")
        foreach ($Candidate in $SkippedLargeFiles) {
            $SizeKB = [Math]::Round($Candidate.File.Length / 1KB, 1)
            $Writer.WriteLine("$($Candidate.RelativePath) ($SizeKB KB)")
        }
    }

    $Writer.WriteLine("")
    $Writer.WriteLine("=== FILE CONTENTS ===")

    foreach ($Candidate in $IncludedFiles) {
        Write-Host "Packing: $($Candidate.RelativePath)"
        $Writer.WriteLine("")
        $Writer.WriteLine("=== $($Candidate.RelativePath) ===")

        try {
            $Content = [System.IO.File]::ReadAllText($Candidate.File.FullName)
            $Writer.WriteLine($Content)
        }
        catch {
            $Writer.WriteLine("[PACK ERROR: $($_.Exception.Message)]")
        }
    }
}
finally {
    $Writer.Dispose()
}

$OutputSizeKB = [Math]::Round((Get-Item -LiteralPath $OutputPath).Length / 1KB, 1)

Write-Host ""
Write-Host "Done."
Write-Host "Output: $OutputPath"
Write-Host "Files packed: $($IncludedFiles.Count)"
Write-Host "Large files skipped: $($SkippedLargeFiles.Count)"
Write-Host "Context size: $OutputSizeKB KB"
Write-Host ""
Write-Host "Review the context file for secrets before uploading it."
