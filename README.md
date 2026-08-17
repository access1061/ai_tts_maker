# AI TTS Maker — clean v2Pro voice

GPT-SoVITS v2Pro로 학습한 `fern_tts_clean` 음성을 CLI에서 재학습하거나 바로 합성하기 위한 최소 작업 저장소입니다. 학습에 사용한 clean reference 4개, 재학습용 전처리 결과, 최종 가중치, clean 생성 예시를 포함합니다.

> 본 저장소의 음성과 모델은 권리자의 허가를 받은 범위에서만 사용하세요. 특정 인물 사칭, 기만 또는 동의 없는 배포에 사용하지 마세요.

## 포함 파일

- `models/`: 최종 GPT/SoVITS v2Pro 가중치 (Git LFS)
- `refer/fern_tts_clean/`: 32 kHz clean 학습 reference 4개
- `training/fern_tts_clean/`: 전처리된 학습 데이터와 재현용 설정
- `output/fern_tts_clean_test.wav`: clean TTS 생성 결과 예시
- `voice.json`: 기본 reference 문장과 모델 경로
- `scripts/`: 재학습 및 합성 CLI

대용량 원본 영상/음원, 보컬 분리 중간물, optimizer checkpoint와 TensorBoard 로그는 재실행에 필요하지 않아 제외했습니다.

## 준비

1. Git LFS가 설치된 Git으로 이 저장소를 받습니다.

```powershell
git lfs install
git clone https://github.com/access1061/ai_tts_maker.git
cd ai_tts_maker
git lfs pull
```

2. 별도로 [GPT-SoVITS](https://github.com/RVC-Boss/GPT-SoVITS)를 설치하고 v2Pro pretrained models까지 준비합니다. Windows 통합 패키지라면 그 폴더의 `runtime/python.exe`를 자동으로 사용합니다.

## 바로 음성 생성

PowerShell에서 GPT-SoVITS 설치 경로와 합성 문장을 지정합니다.

```powershell
.\scripts\synthesize.ps1 `
  -GPTSoVITSRoot 'C:\path\to\GPT-SoVITS' `
  -Text 'おはようございます。今日はいい天気ですね。' `
  -TextLang ja `
  -Output 'generated\hello.wav'
```

CPU만 사용할 때는 `-Device cpu`를 추가합니다. 한국어 문장은 `-TextLang ko`, 영어는 `-TextLang en`을 사용합니다. 기본 reference는 `voice.json`과 `refer/fern_tts_clean/fern.wav`입니다.

Python으로 직접 실행할 수도 있습니다.

```powershell
C:\path\to\GPT-SoVITS\runtime\python.exe scripts\synthesize.py `
  --gpt-sovits-root 'C:\path\to\GPT-SoVITS' `
  --text 'こんにちは。' --text-lang ja --output generated\hello.wav
```

## CLI 재학습

포함된 전처리 데이터를 GPT-SoVITS의 `logs/fern_tts_clean`으로 복사한 뒤 SoVITS 8 epoch와 GPT 10 epoch를 순서대로 학습합니다.

```powershell
.\scripts\train.ps1 -GPTSoVITSRoot 'C:\path\to\GPT-SoVITS'
```

학습 결과는 GPT-SoVITS 설치 폴더 아래에 생성됩니다.

```text
GPT_weights_v2Pro/fern_tts_clean-e10.ckpt
SoVITS_weights_v2Pro/fern_tts_clean_e8_s800.pth
```

기본 설정은 CUDA GPU 0, mixed precision, batch size 1입니다. VRAM이나 학습 횟수를 바꾸려면 `training/fern_tts_clean/train_s1.yaml`과 `train_s2.json`을 수정한 후 다시 실행하세요.

## reference와 결과 확인

- 대표 reference: `refer/fern_tts_clean/fern.wav`
- 나머지 학습 reference: `fern2.wav`, `fern3.wav`, `fern4.wav`
- 생성 예시: `output/fern_tts_clean_test.wav`

학습 데이터 언어는 일본어(`JA`)이며, reference 문장은 `voice.json`에 UTF-8로 기록되어 있습니다.
