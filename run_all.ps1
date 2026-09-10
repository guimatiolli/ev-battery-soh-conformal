param(
    [string]$EnvironmentName = "soh_gpu",
    [switch]$SkipHashCheck
)

$ErrorActionPreference = "Stop"
Set-Location -LiteralPath $PSScriptRoot

if (-not $SkipHashCheck) {
    & "$PSScriptRoot\verify_package.ps1"
}

if (-not (Get-Command conda -ErrorAction SilentlyContinue)) {
    throw "Conda não foi encontrado no PATH. Abra o Anaconda Prompt ou inicialize o Conda no PowerShell."
}

$configDir = Join-Path $PSScriptRoot ".jupyter_config_runtime"
$runtimeDir = Join-Path $PSScriptRoot ".jupyter_runtime"
$dataDir = Join-Path $PSScriptRoot ".jupyter_data_runtime"
New-Item -ItemType Directory -Force -Path $configDir, $runtimeDir, $dataDir, (Join-Path $PSScriptRoot "outputs") | Out-Null
$env:JUPYTER_CONFIG_DIR = $configDir
$env:JUPYTER_RUNTIME_DIR = $runtimeDir
$env:JUPYTER_DATA_DIR = $dataDir
$env:PYTHONIOENCODING = "utf-8"

$jobs = @(
    @{ Input = "01_SOH_V2_COM_MILEAGE.ipynb"; Output = "01_SOH_V2_COM_MILEAGE_EXECUTADO.ipynb" },
    @{ Input = "02_SOH_V2_SEM_MILEAGE.ipynb"; Output = "02_SOH_V2_SEM_MILEAGE_EXECUTADO.ipynb" }
)

foreach ($job in $jobs) {
    Write-Host "Executando $($job.Input)..."
    conda run --no-capture-output -n $EnvironmentName python -m jupyter nbconvert `
        --to notebook `
        --execute $job.Input `
        --output $job.Output `
        --output-dir outputs `
        --ExecutePreprocessor.timeout=-1 `
        --ExecutePreprocessor.kernel_name=python3
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao executar $($job.Input)."
    }
}

Write-Host "PIPELINE_COMPLETE"
