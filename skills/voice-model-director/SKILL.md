---
name: voice-model-director
description: Analyze scripts and scenarios, select an authorized local GPT-SoVITS voice model, generate clean voiceovers, and verify timing and audio quality. Use when the user asks to create, synthesize, render, revise, or direct a voice, TTS, narration, monologue, anime-style line, character voiceover, lookbook short voice, Japanese voice, or mentions a locally trained voice/model such as fern_tts_clean. Also use when Codex should inspect the current project for voice checkpoints and reference audio before claiming that no voice model exists.
---

# Voice Model Director

Turn a supplied script into a finished local voiceover. Inspect the current project first, infer performance direction from the scenario, use an authorized model already placed in scope, and deliver a verified audio file.

## Core workflow

1. Inspect the current workspace before looking in global skill folders. Run `scripts/discover_voice_project.ps1` when available. Otherwise search for `voice.json`, `GPT_weights*`, `SoVITS_weights*`, `*.ckpt`, `*.pth`, reference audio, inference scripts, and prior outputs.
2. Read project-local documentation and configuration. Prefer a packaged synthesizer such as `ai_tts_maker/scripts/synthesize.ps1` and its `voice.json` over reconstructing an inference command.
3. Analyze the request into language, target duration, character archetype, pitch, pace, intensity, pauses, emphasis, ending, microphone distance, and required output format. Make reasonable choices without pausing for confirmation when the brief is sufficient.
4. Create a concise direction note under the project, normally `refer/YYYY-MM-DD/tts-direction-{slug}.md`. Preserve the exact spoken text separately from acting notes. For Japanese, retain the Japanese script as the synthesis input; use readings only for QA.
5. Select a model by semantic fit and explicit user intent. Prefer the highest validated checkpoint pair for the selected model. In the known `C:\ai` layout, prefer `fern_tts_clean-e10.ckpt` with `fern_tts_clean_e8_s800.pth`, the clean `final32k` reference audio, and its matching Japanese reference transcript.
6. Generate to a new file in `output/` or the packaged project's configured output folder. Never overwrite a user file unless explicitly requested. Keep the raw render and create a separately named clean/final render when post-processing changes it.
7. Match timing with natural pauses first. If needed, use small tempo adjustments and silence padding; avoid large pitch or tempo shifts that damage identity and articulation. For multi-sentence acting, generate clauses separately when that gives better control, then join them with intentional silence.
8. Verify with `ffprobe` or an equivalent tool: duration, codec, sample rate, channel count, file size, and absence of clipping or accidental truncation. Listen or inspect the waveform when an audio-capable tool is available. Confirm that all requested lines are present.
9. Deliver a clickable path to the final file and report duration and format. Mention the raw file only when useful.

## Performance analysis

- Treat punctuation as acting structure, not merely text segmentation.
- Convert requests such as “pause before でも,” “subtly satisfied,” or “slow the final sentence” into explicit clause boundaries and pause durations.
- Keep emotional instructions restrained and measurable. Example: calm low female voice, 0.92x conversational pace, 25% emotion, 0.25-second pre-clause pause, 0.5-second tail.
- For a fixed short duration, prioritize intelligibility. If the script cannot naturally fit, produce the closest clean version and clearly report the actual duration instead of silently rushing or deleting text.

## Model and consent guardrails

- Use only models and reference recordings the user placed in scope or is authorized to use.
- Do not infer authorization from a filename alone when provenance is unclear. Inspect accompanying notes; ask only when proceeding would create a meaningful rights or consent risk.
- Do not present an output as the official performance of a real person, actor, or copyrighted character. Describe it using the project's model name or neutral voice characteristics.
- Do not upload checkpoints, reference recordings, or generated voice files to Git unless the user explicitly requests it and confirms they may distribute them. The skill itself must remain portable and weight-free.

## Portable environments

Read `references/project-layout.md` when the project is not the known `C:\ai` layout, when installing from Git, or when model discovery fails. Use `VOICE_MODEL_PROJECT_ROOT` as an optional cross-environment hint; never assume a Windows-only path on another machine.

## Failure handling

- If CUDA inference fails, inspect the error and retry on CPU only when practical; disclose the slower path.
- If the bundled runtime cannot import a module, use the project's documented launcher or Python environment rather than installing packages immediately.
- If no model exists, report exactly what was searched and what files are needed. Do not confuse image-generation skills with voice models.
- Preserve logs for failed renders under the project's temporary/log directory and do not claim completion without a valid audio file.
