param(
    [Parameter(Mandatory = $true)] [string]$GPTSoVITSRoot,
    [Parameter(Mandatory = $true)] [string]$Text,
    [string]$TextLang = 'ja',
    [string]$Output = 'generated/output.wav',
    [ValidateSet('cuda', 'cpu')] [string]$Device = 'cuda'
)

$ErrorActionPreference = 'Stop'
$gsvRoot = (Resolve-Path -LiteralPath $GPTSoVITSRoot).Path
$python = Join-Path $gsvRoot 'runtime\python.exe'
if (-not (Test-Path -LiteralPath $python)) { $python = 'python' }
$env:PYTHONUTF8 = '1'

& $python (Join-Path $PSScriptRoot 'synthesize.py') `
    --gpt-sovits-root $gsvRoot `
    --text $Text `
    --text-lang $TextLang `
    --output $Output `
    --device $Device
if ($LASTEXITCODE -ne 0) { throw "Synthesis failed: $LASTEXITCODE" }
