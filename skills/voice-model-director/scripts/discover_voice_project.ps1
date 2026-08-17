param(
    [string]$StartPath = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'
$roots = [System.Collections.Generic.List[string]]::new()

function Add-Candidate([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return }
    try { $resolved = (Resolve-Path -LiteralPath $Path).Path } catch { return }
    if (-not $roots.Contains($resolved)) { $roots.Add($resolved) }
}

Add-Candidate $StartPath
if ($env:VOICE_MODEL_PROJECT_ROOT) { Add-Candidate $env:VOICE_MODEL_PROJECT_ROOT }

$cursor = Get-Item -LiteralPath $StartPath
while ($cursor) {
    Add-Candidate $cursor.FullName
    $cursor = $cursor.Parent
}

$results = foreach ($root in $roots) {
    $voiceJson = Join-Path $root 'ai_tts_maker\voice.json'
    $gptSoVits = Join-Path $root 'GPT_SoVITS'
    $packagedScript = Join-Path $root 'ai_tts_maker\scripts\synthesize.ps1'
    if ((Test-Path -LiteralPath $voiceJson) -or (Test-Path -LiteralPath $gptSoVits)) {
        [pscustomobject]@{
            Root = $root
            VoiceConfig = if (Test-Path -LiteralPath $voiceJson) { $voiceJson } else { $null }
            Synthesizer = if (Test-Path -LiteralPath $packagedScript) { $packagedScript } else { $null }
            GPTSoVITS = if (Test-Path -LiteralPath $gptSoVits) { $gptSoVits } else { $null }
        }
    }
}

if (-not $results) {
    Write-Error 'No compatible local voice project found in the workspace, its parents, or VOICE_MODEL_PROJECT_ROOT.'
}

$results | ConvertTo-Json -Depth 3
