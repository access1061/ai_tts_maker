param(
    [Parameter(Mandatory = $true)]
    [string]$GPTSoVITSRoot
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$gsvRoot = (Resolve-Path -LiteralPath $GPTSoVITSRoot).Path
$python = Join-Path $gsvRoot 'runtime\python.exe'
if (-not (Test-Path -LiteralPath $python)) { $python = 'python' }

$source = Join-Path $repoRoot 'training\fern_tts_clean'
$target = Join-Path $gsvRoot 'logs\fern_tts_clean'
New-Item -ItemType Directory -Force -Path $target | Out-Null
Copy-Item -Path (Join-Path $source '*') -Destination $target -Recurse -Force

Push-Location $gsvRoot
try {
    & $python -s 'GPT_SoVITS/s2_train.py' --config 'logs/fern_tts_clean/train_s2.json'
    if ($LASTEXITCODE -ne 0) { throw "SoVITS training failed: $LASTEXITCODE" }

    $env:_CUDA_VISIBLE_DEVICES = '0'
    $env:hz = '25hz'
    & $python -s 'GPT_SoVITS/s1_train.py' --config_file 'logs/fern_tts_clean/train_s1.yaml'
    if ($LASTEXITCODE -ne 0) { throw "GPT training failed: $LASTEXITCODE" }
}
finally {
    Pop-Location
}

Write-Host 'Training complete.'
Write-Host "GPT:    $gsvRoot\GPT_weights_v2Pro\fern_tts_clean-e10.ckpt"
Write-Host "SoVITS: $gsvRoot\SoVITS_weights_v2Pro\fern_tts_clean_e8_s800.pth"
