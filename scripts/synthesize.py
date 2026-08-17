import argparse
import json
import os
import sys
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(description="Generate clean speech with the bundled GPT-SoVITS voice.")
    parser.add_argument("--gpt-sovits-root", required=True, type=Path)
    parser.add_argument("--text", required=True)
    parser.add_argument("--text-lang", default="ja", choices=["zh", "en", "ja", "ko", "yue", "auto"])
    parser.add_argument("--output", type=Path, default=Path("generated/output.wav"))
    parser.add_argument("--device", default="cuda", choices=["cuda", "cpu"])
    return parser.parse_args()


def main():
    args = parse_args()
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    repo_root = Path(__file__).resolve().parents[1]
    gsv_root = args.gpt_sovits_root.resolve()
    metadata = json.loads((repo_root / "voice.json").read_text(encoding="utf-8"))

    os.chdir(gsv_root)
    sys.path.insert(0, str(gsv_root))
    sys.path.insert(0, str(gsv_root / "GPT_SoVITS"))

    import soundfile as sf
    from GPT_SoVITS.TTS_infer_pack.TTS import TTS, TTS_Config

    config = TTS_Config(str(gsv_root / "GPT_SoVITS/configs/tts_infer.yaml"))
    config.device = args.device
    config.is_half = args.device == "cuda"
    config.version = metadata["version"]
    config.t2s_weights_path = str((repo_root / metadata["gpt_model"]).resolve())
    config.vits_weights_path = str((repo_root / metadata["sovits_model"]).resolve())

    pipeline = TTS(config)
    request = {
        "text": args.text,
        "text_lang": args.text_lang,
        "ref_audio_path": str((repo_root / metadata["reference_audio"]).resolve()),
        "prompt_text": metadata["reference_text"],
        "prompt_lang": metadata["reference_language"],
        "text_split_method": "cut5",
        "batch_size": 1,
        "seed": -1,
        "parallel_infer": True,
    }
    sample_rate, audio = next(pipeline.run(request))
    output = (repo_root / args.output).resolve() if not args.output.is_absolute() else args.output
    output.parent.mkdir(parents=True, exist_ok=True)
    sf.write(output, audio, sample_rate)
    print(f"Saved: {output}")


if __name__ == "__main__":
    main()
