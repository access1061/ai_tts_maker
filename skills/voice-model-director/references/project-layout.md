# Portable project layout

The skill contains no model weights or reference voices. A compatible project should expose either a packaged synthesizer or the GPT-SoVITS components below.

## Preferred packaged layout

```text
project-root/
  ai_tts_maker/
    voice.json
    scripts/synthesize.ps1
    scripts/synthesize.py
    models/*.ckpt
    models/*.pth
    refer/**/*.wav
  output/
```

Run the packaged PowerShell wrapper from the project root:

```powershell
& ./ai_tts_maker/scripts/synthesize.ps1 `
  -GPTSoVITSRoot . `
  -Text $spokenText `
  -TextLang ja `
  -Output 'output/render.wav' `
  -Device cuda
```

Read `voice.json` before running it. Resolve every referenced path and confirm the files exist.

## Native GPT-SoVITS layout

Look for these together:

```text
GPT_SoVITS/
GPT_weights*/model.ckpt
SoVITS_weights*/model.pth
refer/**/*.wav
api.py or api_v2.py or GPT_SoVITS/inference_cli.py
```

Prefer an existing project command or recent successful log because GPT-SoVITS CLI/API parameters vary by version. Verify that the GPT and SoVITS checkpoints belong to the same model/version.

## Cross-environment discovery

1. Use the current working directory.
2. Use the nearest parent containing `voice.json` or `GPT_SoVITS`.
3. Use the `VOICE_MODEL_PROJECT_ROOT` environment variable when set.
4. Search only user-provided workspace roots. Do not scan an entire drive by default.

## Git packaging

Commit only the skill directory: `SKILL.md`, `agents/openai.yaml`, `scripts/`, and `references/`. Keep checkpoints, audio references, outputs, logs, caches, and temporary files outside the skill. Install from a Git repository using Codex's skill installer or copy the skill directory into the local Codex skills folder.
