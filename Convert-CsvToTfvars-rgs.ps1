param(
    [Parameter(Mandatory = $false)]
    [string]$CsvPath = ".\resource_groups.csv",

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".\environment\preprod\terraform.tfvars"
)

$ErrorActionPreference = "Stop"

Write-Host "Reading CSV file: $CsvPath"

if (-not (Test-Path $CsvPath)) {
    throw "CSV file not found: $CsvPath"
}

$rows = Import-Csv -Path $CsvPath

if (-not $rows) {
    throw "CSV file is empty: $CsvPath"
}

$requiredColumns = @("rg_name", "location")
$csvColumns = $rows[0].PSObject.Properties.Name

foreach ($column in $requiredColumns) {
    if ($column -notin $csvColumns) {
        throw "Required column '$column' is missing from CSV."
    }
}

$lines = @()
$lines += "rgs = {"

$index = 1

foreach ($row in $rows) {
    $name = ($row.rg_name).Trim()
    $location = ($row.location).Trim()

    if ([string]::IsNullOrWhiteSpace($name)) {
        throw "One of the CSV rows has an empty rg_name."
    }

    if ([string]::IsNullOrWhiteSpace($location)) {
        throw "Location is empty for Resource Group '$name'."
    }

    $safeName = $name.Replace('"', '\"')
    $safeLocation = $location.Replace('"', '\"')
    $key = "rg{0:D2}" -f $index

    $lines += "  `"$key`" = {"
    $lines += "    name     = `"$safeName`""
    $lines += "    location = `"$safeLocation`""
    $lines += "  }"

    $index++
}

$lines += "}"

$outputDirectory = Split-Path -Parent $OutputPath

if ($outputDirectory -and -not (Test-Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}

Set-Content -Path $OutputPath -Value $lines -Encoding UTF8

Write-Host ""
Write-Host "terraform.tfvars generated successfully."
Write-Host "Output: $OutputPath"
Write-Host "Total Resource Groups: $($rows.Count)"
Write-Host ""
Write-Host "Generated tfvars:"
Get-Content $OutputPath
