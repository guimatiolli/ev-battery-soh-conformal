$ErrorActionPreference = "Stop"
Set-Location -LiteralPath $PSScriptRoot

$manifestPath = Join-Path $PSScriptRoot "SHA256SUMS.json"
if (-not (Test-Path -LiteralPath $manifestPath)) {
    throw "SHA256SUMS.json não encontrado."
}

$manifest = Get-Content -Raw -Encoding UTF8 -LiteralPath $manifestPath | ConvertFrom-Json
$failures = @()
foreach ($entry in $manifest.files) {
    $path = Join-Path $PSScriptRoot $entry.path
    if (-not (Test-Path -LiteralPath $path)) {
        $failures += "AUSENTE: $($entry.path)"
        continue
    }
    $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLowerInvariant()
    if ($actual -ne $entry.sha256) {
        $failures += "HASH_DIFERENTE: $($entry.path)"
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    throw "PACKAGE_INVALID"
}

Write-Host "PACKAGE_OK ($($manifest.files.Count) arquivos verificados)"
