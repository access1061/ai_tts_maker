# AI TTS Maker — Clean v2Pro Voice Kit

> GPT-SoVITS v2Pro 기반의 고품질 음성 합성 및 재학습(Fine-tuning)을 위한 CLI 워크플로우 킷입니다.  
> 본 저장소는 32kHz 클린 오디오 리퍼런스(`fern_tts_clean`), 사전 전처리 완료된 학습 데이터(HuBERT, VAD, 텍스트 얼라인먼트, 스피커 임베딩), 사전 학습된 v2Pro 모델 가중치, 그리고 자동화 CLI 스크립트(`synthesize.ps1`, `synthesize.py`, `train.ps1`)를 포함합니다.

---

## 📋 목차 (Table of Contents)

1. [특징 (Features)](#-특징-features)
2. [저장소 구조 (Repository Structure)](#-저장소-구조-repository-structure)
3. [사전 준비 (Prerequisites)](#-사전-준비-prerequisites)
4. [음성 합성 사용법 (Voice Synthesis)](#-음성-합성-사용법-voice-synthesis)
   - [PowerShell 인터페이스 (`synthesize.ps1`)](#powershell-인터페이스-synthesizeps1)
   - [Python 직접 실행 (`synthesize.py`)](#python-직접-실행-synthesizepy)
   - [다국어 합성 예시](#다국어-합성-예시)
5. [음성 프로필 설정 (`voice.json`)](#-음성-프로필-설정-voicejson)
6. [CLI 모델 재학습 (Model Retraining)](#-cli-모델-재학습-model-retraining)
   - [재학습 실행 (`train.ps1`)](#재학습-실행-trainps1)
   - [학습 하이퍼파라미터 커스텀](#학습-하이퍼파라미터-커스텀)
   - [재학습 가중치 적용 방법](#재학습-가중치-적용-방법)
7. [문제 해결 및 FAQ (Troubleshooting)](#-문제-해결-및-faq-troubleshooting)
8. [윤리적 사용 지침 (Ethical Guidelines)](#-윤리적-사용-지침-ethical-guidelines)

---

## ✨ 특징 (Features)

- **Zero-Shot / Few-Shot 고품질 음성 합성**: 사전 학습된 GPT-SoVITS v2Pro 기반 모델로 적은 양의 단일 화자 음성 데이터로도 높은 유사도의 음성 합성 지원.
- **사전 전처리 데이터 포함**: 슬라이싱, ASR, HuBERT 피처 추출(`4-cnhubert`), 32kHz 리샘플링(`5-wav32k`), 스피커 임베딩(`7-sv_cn`), 의미론적 토큰(`6-name2semantic.tsv`)이 이미 완료되어 있어 데이터 전처리 과정 없이 즉시 파인튜닝 가능.
- **Git LFS 모델 버전 관리**: 10 epoch 학습된 GPT 가중치 및 8 epoch/800 steps 학습된 SoVITS 가중치를 LFS로 안전하게 전달.
- **Windows / Linux 지원 CLI 스크립트**: PowerShell 및 Python 파이프라인으로 CLI 원클릭 학습 및 생성 가능.
- **다국어 (Multi-lingual) 지원**: 한국어(`ko`), 일본어(`ja`), 영어(`en`), 중국어(`zh`), 광둥어(`yue`), 자동 감지(`auto`) 지원.

---

## 📁 저장소 구조 (Repository Structure)

```text
ai_tts_maker/
├── models/                         # v2Pro 모델 가중치 (Git LFS)
│   ├── fern_tts_clean-e10.ckpt     # GPT (Text2Semantic) v2Pro 체크포인트 (10 Epochs)
│   └── fern_tts_clean_e8_s800.pth  # SoVITS (VITS Decoder) v2Pro 체크포인트 (8 Epochs)
├── refer/                          # 클린 학습 및 파인튜닝용 오디오 리퍼런스
│   └── fern_tts_clean/             # 32kHz Clean Reference WAV 파일들 (fern.wav ~ fern4.wav)
├── training/                       # 파인튜닝용 전처리 완료 데이터셋 & 설정 파일
│   └── fern_tts_clean/
│       ├── 2-name2text.txt         # 텍스트 및 발음 기호 음절 정렬 데이터
│       ├── 6-name2semantic.tsv     # HuBERT 의미론적(Semantic) 피처 추출 데이터
│       ├── 4-cnhubert/             # CN-HuBERT 텐서 덤프 (.pt)
│       ├── 5-wav32k/               # 32kHz 변환 및 정제 완료된 오디오 (.wav)
│       ├── 7-sv_cn/                # 스피커 검증(Speaker Verification) 임베딩 (.pt)
│       ├── train_s1.yaml           # Stage 1 (GPT) 파인튜닝 설정 (Epochs, Batch Size 등)
│       └── train_s2.json           # Stage 2 (SoVITS) 파인튜닝 설정
├── scripts/                        # 실행 파이프라인 CLI 스크립트
│   ├── synthesize.ps1              # PowerShell용 합성 매개변수 Wrapper
│   ├── synthesize.py               # GPT-SoVITS 파이프라인 호출 Python 스크립트
│   └── train.ps1                   # 데이터 자동 복사 및 Stage 1/2 자동 학습 스크립트
├── skills/                         # AI 디렉터 및 학습/합성 도구 스킬 킷
│   └── voice-model-director/       # Voice Model Director 스킬 (설정 탐색, 디렉팅 및 실행)
│       ├── SKILL.md                # 스킬 정의 및 워크플로우 가이드
│       ├── agents/openai.yaml      # 에이전트 인터페이스 설정
│       ├── references/             # 프로젝트 레이아웃 참조 문서
│       └── scripts/                # 프로젝트 및 환경 자동 탐색 스크립트
├── output/                         # 샘플 테스트 출력 음성 (fern_tts_clean_test.wav 등)
├── generated/                      # CLI 실행 시 기본 생성 결과 저장 폴더
├── voice.json                      # 모델 가중치, 리퍼런스 오디오 경로 및 기본 텍스트 프로필
├── .gitattributes                  # Git LFS 추적 설정 (*.pth, *.ckpt, *.pt 등)
└── README.md                       # 저장소 안내 문서
```

---

## 🛠️ 사전 준비 (Prerequisites)

### 1. Git LFS 설치 및 저장소 받기

대용량 모델 가중치(`.ckpt`, `.pth`)와 텐서 데이터가 포함되어 있으므로 **Git LFS**가 필요합니다.

```bash
# Git LFS 설치 (최초 1회)
git lfs install

# 저장소 클론 및 대용량 파일 다운로드
git clone https://github.com/access1061/ai_tts_maker.git
cd ai_tts_maker
git lfs pull
```

### 2. GPT-SoVITS 환경 준비

이 킷은 별도로 설치된 [GPT-SoVITS](https://github.com/RVC-Boss/GPT-SoVITS) 메인 메인 코어 저장소 또는 **Windows 원클릭 통합 패키지**가 필요합니다.
- Windows 통합 패키지 설치 시: 루트 폴더 내 `runtime\python.exe`를 자동으로 감지하여 실행합니다.
- Anaconda / Standalone Python 환경 시: PyTorch (CUDA 지원 권장) 및 GPT-SoVITS 의존성 패키지가 설치된 환경을 사용합니다.

---

## 🔊 음성 합성 사용법 (Voice Synthesis)

### PowerShell 인터페이스 (`synthesize.ps1`)

Windows PowerShell 환경에서 스크립트를 통해 손쉽게 음성을 생성할 수 있습니다.

> 💡 **참고**: PowerShell 스크립트 실행 정책 제한(`PSSecurityException`) 발생 시 `-ExecutionPolicy Bypass` 옵션을 추가하여 실행하세요.

```powershell
# 기본 실행 (일본어)
powershell -ExecutionPolicy Bypass -File .\scripts\synthesize.ps1 `
  -GPTSoVITSRoot 'C:\path\to\GPT-SoVITS' `
  -Text 'こんにちは。今日もいい天気ですね。' `
  -TextLang ja `
  -Output 'generated\hello_ja.wav'

# 한국어 음성 생성
powershell -ExecutionPolicy Bypass -File .\scripts\synthesize.ps1 `
  -GPTSoVITSRoot 'C:\path\to\GPT-SoVITS' `
  -Text '안녕하세요! 오늘 날씨가 참 좋네요.' `
  -TextLang ko `
  -Output 'generated\hello_ko.wav'

# CPU 모드로 실행 (GPU 미사용 시)
powershell -ExecutionPolicy Bypass -File .\scripts\synthesize.ps1 `
  -GPTSoVITSRoot 'C:\path\to\GPT-SoVITS' `
  -Text 'Hello, this is a clean TTS test.' `
  -TextLang en `
  -Output 'generated\hello_en.wav' `
  -Device cpu
```

#### `synthesize.ps1` 매개변수 안내

| 매개변수 | 필수 여부 | 기본값 | 설명 |
|---|:---:|---|---|
| `-GPTSoVITSRoot` | **필수** | - | GPT-SoVITS가 설치된 루트 디렉터리 경로 |
| `-Text` | **필수** | - | 음성으로 변환할 목표 텍스트 문장 |
| `-TextLang` | 선택 | `ja` | 텍스트 언어 코드 (`ko`, `ja`, `en`, `zh`, `yue`, `auto`) |
| `-Output` | 선택 | `generated/output.wav` | 생성될 오디오 파일 (.wav) 저장 경로 |
| `-Device` | 선택 | `cuda` | 연산 장치 지정 (`cuda` 연산 GPU 권장, 또는 `cpu`) |

---

### Python 직접 실행 (`synthesize.py`)

Python 코맨드라인에서 직접 파이썬 스크립트를 호출할 수 있습니다.

```bash
# GPT-SoVITS의 runtime python으로 직접 실행 (Windows 통합 패키지 예시)
C:\path\to\GPT-SoVITS\runtime\python.exe scripts/synthesize.py \
  --gpt-sovits-root "C:\path\to\GPT-SoVITS" \
  --text "안녕하세요, 파이썬 CLI 생성 테스트입니다." \
  --text-lang ko \
  --output generated/output_python.wav \
  --device cuda
```

#### CLI 아규먼트 명세

- `--gpt-sovits-root` (Path, 필수): GPT-SoVITS 메인 디렉터리 경로.
- `--text` (str, 필수): 합성하고자 하는 문자열.
- `--text-lang` (str, 기본값: `ja`): 목표 언어 코드 (`zh`, `en`, `ja`, `ko`, `yue`, `auto`).
- `--output` (Path, 기본값: `generated/output.wav`): 저장 파일 경로.
- `--device` (str, 기본값: `cuda`): 연산 장치 (`cuda` 또는 `cpu`).

---

## ⚙️ 음성 프로필 설정 (`voice.json`)

저장소 루트의 `voice.json` 파일은 음성 합성 시 사용할 모델 가중치 및 프롬프트 오디오/텍스트 정보를 관리합니다.

```json
{
  "name": "fern_tts_clean",
  "version": "v2Pro",
  "gpt_model": "models/fern_tts_clean-e10.ckpt",
  "sovits_model": "models/fern_tts_clean_e8_s800.pth",
  "reference_audio": "refer/fern_tts_clean/fern.wav",
  "reference_language": "ja",
  "reference_text": "これだと一週間暮らせるかどうかですね。まったく、無駄遣いばかりするからですよ。"
}
```

### 필드 구성 설명

- `name`: 음성 프로필 고유 이름.
- `version`: GPT-SoVITS 버전을 지정하며, 본 킷은 `v2Pro` 버전을 사용합니다.
- `gpt_model`: GPT 체크포인트 경로 (상대 경로).
- `sovits_model`: SoVITS 가중치 파일 경로 (상대 경로).
- `reference_audio`: 톤과 억양 복제를 위해 전달되는 기준 프롬프트 오디오 경로 (32kHz 권장).
- `reference_language`: 기준 오디오에 발화된 언어 코드 (`ja`, `ko`, `en`, `zh` 등).
- `reference_text`: 기준 오디오의 정확한 대사 스크립트.

> 💡 **사용자 정의 커스텀 가중치 적용**:
> 모델 재학습 후 생성된 새 가중치 파일(`.ckpt`, `.pth`)을 `models/`에 복사하고 `voice.json` 내 `gpt_model` 및 `sovits_model` 경로를 수정하면 바로 새 모델로 변경됩니다.

---

## 🚀 CLI 모델 재학습 (Model Retraining)

전처리 데이터가 이미 `training/fern_tts_clean/`에 완벽히 구성되어 있으므로, 추가적인 오디오 분할이나 ASR(음성인식) 과정 없이 클릭 한 번으로 파인튜닝을 수행할 수 있습니다.

### 재학습 실행 (`train.ps1`)

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\train.ps1 -GPTSoVITSRoot 'C:\path\to\GPT-SoVITS'
```

#### 작동 순서 (Workflow)

1. **데이터 동기화**: `training/fern_tts_clean` 폴더의 모든 전처리 파일(`4-cnhubert`, `5-wav32k`, `7-sv_cn`, `2-name2text.txt`, `6-name2semantic.tsv`)을 GPT-SoVITS의 `logs/fern_tts_clean/`으로 자동으로 복사합니다.
2. **Stage 2 (SoVITS VITS Decoder 파인튜닝)**: `s2_train.py`를 실행하여 8 epoch 동안 학습을 진행합니다.
3. **Stage 1 (GPT Text2Semantic 파인튜닝)**: `s1_train.py`를 실행하여 10 epoch 동안 학습을 진행합니다.
4. **결과물 생성**: 완료된 가중치는 GPT-SoVITS 폴더 하위에 저장됩니다.
   - GPT 가중치: `<GPTSoVITSRoot>\GPT_weights_v2Pro\fern_tts_clean-e10.ckpt`
   - SoVITS 가중치: `<GPTSoVITSRoot>\SoVITS_weights_v2Pro\fern_tts_clean_e8_s800.pth`

---

### 학습 하이퍼파라미터 커스텀

학습 횟수, 배치 크기, 학습률(Learning Rate) 등 하이퍼파라미터를 변경하려면 아래 파일을 수정하세요.

#### 1. Stage 1 GPT 설정 (`training/fern_tts_clean/train_s1.yaml`)

- `train.epochs`: GPT 학습 총 에포크 수 (기본값: `10`)
- `train.batch_size`: 배치 크기 (기본값: `1`, VRAM 부족 시 `1` 유지 권장)
- `train.save_every_n_epoch`: 저장 주기 (기본값: `5`)
- `optimizer.lr`: 학습률 (기본값: `0.01`)

#### 2. Stage 2 SoVITS 설정 (`training/fern_tts_clean/train_s2.json`)

- `train.epochs`: SoVITS 학습 총 에포크 수 (기본값: `8`)
- `train.batch_size`: 배치 크기 (기본값: `1`)
- `train.save_every_epoch`: 저장 주기 (기본값: `4`)
- `train.learning_rate`: 학습률 (기본값: `0.0001`)

---

### 재학습 가중치 적용 방법

재학습이 완료된 후 새 가중치를 이 저장소에 반영하려면 다음과 같이 조치합니다.

1. 생성된 가중치 파일 두 개를 `models/` 디렉터리로 복사합니다.
2. `voice.json` 파일의 `gpt_model` 및 `sovits_model` 경로를 새 가중치 파일 이름으로 업데이트합니다.
3. `synthesize.ps1`을 실행하여 새로 파인튜닝된 모델로 합성되는지 확인합니다.

---

## ❓ 문제 해결 및 FAQ (Troubleshooting)

### Q1. PowerShell에서 스크립트 실행 정책 오류가 발생합니다.
> **오류 메시지**: `.\scripts\synthesize.ps1 : 이 시스템에서 스크립트를 실행할 수 없으므로...`  
> **해결책**: PowerShell 실행 시 `-ExecutionPolicy Bypass` 플래그를 명시하세요.
> ```powershell
> powershell -ExecutionPolicy Bypass -File .\scripts\synthesize.ps1 -GPTSoVITSRoot 'C:\ai' -Text '테스트'
> ```

### Q2. Git LFS 가중치 파일 크기가 1KB로 표시되고 동작하지 않습니다.
> **원인**: `git lfs pull`이 수행되지 않고 Git LFS 포인터 단일 텍스트 파일만 다운로드된 경우입니다.  
> **해결책**:
> ```bash
> git lfs install
> git lfs pull
> ```

### Q3. Windows 콘솔에서 인코딩(한글/일어 문입력) 깨짐 현상이 발생합니다.
> **해결책**: PowerShell 또는 명령 프롬프트 환경 변수로 UTF-8을 강제합니다.
> ```powershell
> $env:PYTHONUTF8 = '1'
> ```

### Q4. GPU VRAM 메모리 부족(CUDA Out of Memory) 에러가 발생합니다.
> **해결책**:
> 1. `synthesize.ps1` 실행 시 `-Device cpu` 옵션을 지정하여 CPU 모드로 전환합니다.
> 2. 학습 중 OOM 발생 시 `train_s1.yaml` 및 `train_s2.json`의 `batch_size`를 `1`로 낮추고 `num_workers`를 조절하세요.

---

## 🔒 윤리적 사용 지침 (Ethical Guidelines)

- 본 저장소에 수록된 음성 데이터, 템플릿, 사전 학습 모델 가중치는 **권리자의 명시적 허가 범위 내에서만 사용**되어야 합니다.
- 동의 없는 타인의 음성 복제, 사칭(Impersonation), 기만적 콘텐츠 생성, 음해 및 불법적인 용도로의 사용을 엄격히 금지합니다.
- AI 음성 합성 기술을 활용하여 제작된 오디오 콘텐츠 공개 시 AI로 생성되었음을 명확히 표시하는 것을 권장합니다.
