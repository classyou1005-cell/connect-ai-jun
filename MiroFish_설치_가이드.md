# MiroFish 설치 & 사용 가이드 (초보자용)

> 공식 저장소: https://github.com/666ghj/MiroFish
> 한국어 번역판: https://github.com/ByeongkiJeong/MiroFish-Ko
> 온라인 데모 (설치 없이 구경하기): https://666ghj.github.io/mirofish-demo/

---

## 1. MiroFish란? (한 줄 정의)

**"AI 캐릭터 수천 명이 사는 가상 세계를 만들어, 어떤 일이 일어날지 미리 시뮬레이션해 보는 예측 엔진"** 입니다.

- 뉴스, 보고서, 소설 같은 **자료(시드)** 를 올리면
- AI가 그 안의 인물·관계를 뽑아 **가상 세계**를 만들고
- 성격과 기억을 가진 **AI 에이전트들이 서로 대화·행동**하게 한 뒤
- 그 결과를 **예측 보고서**로 정리해 줍니다.

예시
- "이 정책을 발표하면 여론이 어떻게 흘러갈까?"
- "이 소설의 결말은 어떻게 될까?"
- "이 제품 출시 소식에 사람들은 어떻게 반응할까?"

### 작동 순서 (5단계)

| 단계 | 하는 일 | 쉽게 말하면 |
|---|---|---|
| 1. 그래프 구축 | 자료에서 핵심 정보 추출, 기억 저장 | 자료를 읽고 정리 |
| 2. 환경 구성 | 인물·관계 추출, 캐릭터 성격 생성 | 등장인물 만들기 |
| 3. 시뮬레이션 | 에이전트들이 병렬로 상호작용 | 가상 세계 돌리기 |
| 4. 보고서 생성 | ReportAgent가 결과 분석 | 결과 보고서 받기 |
| 5. 심층 대화 | 가상 세계 속 아무 캐릭터와 채팅 | 캐릭터에게 직접 물어보기 |

---

## 2. 준비물

### 2-1. 프로그램 3개 (내 컴퓨터에 설치)

| 프로그램 | 버전 | 용도 | 설치 확인 명령어 |
|---|---|---|---|
| **Node.js** | 18 이상 | 화면(프론트엔드) 실행 | `node -v` |
| **Python** | 3.11 또는 3.12 (3.13은 안 됨!) | 두뇌(백엔드) 실행 | `python --version` |
| **uv** | 최신 | 파이썬 패키지 관리자 | `uv --version` |

설치 방법
- Node.js: https://nodejs.org 에서 **LTS** 버전 다운로드 → 설치
- Python: https://www.python.org/downloads/ 에서 **3.12.x** 다운로드
  - 윈도우는 설치 첫 화면에서 **"Add python.exe to PATH" 체크** 필수
- uv:
  - 윈도우 (PowerShell): `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`
  - 맥/리눅스 (터미널): `curl -LsSf https://astral.sh/uv/install.sh | sh`
- Git (저장소 다운로드용): https://git-scm.com

> 설치 후에는 **터미널을 껐다가 다시 켜야** 명령어가 인식됩니다.

### 2-2. API 키 2개 (인터넷에서 발급)

| 키 이름 | 어디서 | 비용 |
|---|---|---|
| **LLM API 키** | OpenAI 형식을 지원하는 AI 서비스 아무거나 (공식 추천: 알리바바 百炼 qwen-plus → https://bailian.console.aliyun.com/) | 사용량만큼 과금 ⚠️ |
| **Zep API 키** | https://app.getzep.com/ (AI 기억 저장소) | 월 무료 한도로 간단 사용 가능 |

> ⚠️ **비용 주의**: 에이전트가 많고 라운드가 길수록 AI 호출이 폭증합니다.
> 처음엔 반드시 **40라운드 미만**으로 작게 테스트하세요.

---

## 3. 설치 (방법 A: 소스코드 — 공식 추천)

터미널(윈도우는 PowerShell)을 열고 한 줄씩 입력하세요.

### ① 저장소 내려받기
```bash
git clone https://github.com/666ghj/MiroFish.git
cd MiroFish
```

### ② 설정 파일 만들기
```bash
# 맥/리눅스
cp .env.example .env
# 윈도우 PowerShell
copy .env.example .env
```

### ③ `.env` 파일에 API 키 입력
`.env` 파일을 메모장/VS Code로 열어 아래처럼 채웁니다.

```env
# AI 모델 설정 (OpenAI 형식이면 무엇이든 가능)
LLM_API_KEY=발급받은_LLM_키
LLM_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
LLM_MODEL_NAME=qwen-plus

# 기억 저장소
ZEP_API_KEY=발급받은_Zep_키
```

다른 AI 서비스를 쓰고 싶다면 `LLM_BASE_URL`, `LLM_MODEL_NAME` 만 바꾸면 됩니다.
예) OpenAI를 쓰는 경우
```env
LLM_BASE_URL=https://api.openai.com/v1
LLM_MODEL_NAME=gpt-4o-mini
```

> `.env.example` 아래쪽의 `LLM_BOOST_...` 항목(가속용, 선택)은
> **쓰지 않을 거면 줄 자체를 지우세요.** 값이 비어 있으면 오류가 날 수 있습니다.
>
> 🔒 `.env` 파일은 비밀번호와 같습니다. 절대 GitHub에 올리거나 남에게 보내지 마세요.

### ④ 필요한 부품 한 번에 설치
```bash
npm run setup:all
```
(화면용 Node 패키지 + 두뇌용 Python 패키지를 자동으로 설치합니다. 몇 분 걸려요.)

### ⑤ 실행
```bash
npm run dev
```

브라우저에서 접속
- 화면: **http://localhost:3000**
- (참고) 백엔드 API: http://localhost:5001

끄려면 터미널에서 `Ctrl + C`.

---

## 4. 설치 (방법 B: Docker — 명령어 2줄)

[Docker Desktop](https://www.docker.com/products/docker-desktop/)이 설치되어 있다면 더 간단합니다.

```bash
git clone https://github.com/666ghj/MiroFish.git
cd MiroFish
cp .env.example .env      # 그리고 .env에 API 키 입력 (위 ③과 동일)
docker compose up -d
```

→ http://localhost:3000 접속. 끄기: `docker compose down`

---

## 5. 사용법

1. http://localhost:3000 접속
2. **시드 자료 업로드**: 뉴스 기사, 분석 보고서, 소설 텍스트 등
3. **예측 요청을 자연어로 입력**
   예) "이 발표 이후 2주간 온라인 여론이 어떻게 변할지 예측해줘"
4. 단계별 진행 지켜보기: 그래프 구축 → 캐릭터 생성 → 시뮬레이션
   (처음엔 라운드 수를 작게!)
5. **예측 보고서** 확인
6. 궁금한 점은 보고서 에이전트나 **가상 세계 속 캐릭터에게 직접 채팅**으로 질문

### 활용 아이디어 (자동화 관점)
- 콘텐츠/마케팅: 영상·블로그 주제에 대한 반응 미리 시뮬레이션
- 제품 기획: 신제품 발표문을 넣고 고객 반응 예측
- 창작: 소설·시나리오 결말 추론

---

## 6. 자주 막히는 문제

| 증상 | 해결 |
|---|---|
| `node`/`python`/`uv` 명령을 찾을 수 없음 | 설치 후 터미널 재시작. 윈도우 Python은 PATH 체크 여부 확인 |
| Python 버전 오류 | 3.11 또는 3.12 사용 (3.13 이상 X) |
| 3000/5001 포트 사용 중 | 다른 프로그램 종료 후 재실행 |
| API 관련 오류 (401 등) | `.env`의 키 오타, 앞뒤 공백, 따옴표 확인 |
| 요금이 너무 많이 나옴 | 라운드 수·에이전트 수 줄이기, 저렴한 모델 사용 |

---

## 7. 라이선스 메모

MiroFish는 **AGPL-3.0** 라이선스입니다. 개인 학습·사용은 자유롭지만,
수정해서 **웹 서비스로 남에게 제공**하면 수정한 소스코드도 공개해야 합니다.
