# AI 이미지 글씨 교체 도구

클립파이 같은 이미지 AI로 만든 그림에서 **깨진 한글 글씨를 지우고, 진짜 폰트로 깔끔하게 다시 써 넣는** 도구예요.

```
input/vacuum.webp  ──(글씨 지우기 → 새 글씨 쓰기)──▶  output/vacuum_fixed.png
```

## 1. 처음 한 번만 준비하기

**① 프로그램 설치** (터미널에 입력)

```bash
pip install pillow numpy opencv-python-headless
```

**② 폰트 준비**

무료 한글 폰트 [Pretendard](https://github.com/orioncactus/pretendard/releases)를 내려받아
`fonts/` 폴더에 `Pretendard-Medium.otf` 파일을 넣어 주세요.
(압축을 풀면 `public/static/` 폴더 안에 있어요.)

## 2. 실행하기

이 폴더(`tools/image-text-fix`)에서:

```bash
python fix_labels.py labels.json
```

`완료: output/vacuum_fixed.png` 가 나오면 성공이에요.

## 3. 다른 이미지에 쓰려면 — `labels.json` 고치기

| 항목 | 뜻 |
|---|---|
| `input` / `output` | 원본 이미지 / 결과 이미지 경로 |
| `erase` | 지울 사각형 영역. `[왼쪽x, 위쪽y, 오른쪽x, 아래쪽y]` (픽셀 단위) |
| `clone` | 제품 위 로고처럼 배경이 복잡한 곳은 근처 부분을 복사해 덮어요. `from_offset: [가로, 세로]` 만큼 떨어진 곳을 복사 |
| `labels` | 새로 쓸 글씨. `x`, `y` 는 글씨의 **가운데-위** 위치, `size` 는 글씨 크기 |

> 💡 좌표 찾는 법: 그림판(윈도우)이나 미리보기(맥)에서 마우스를 올리면 화면 아래에 x, y 숫자가 보여요.

글씨 색을 바꾸려면 라벨에 `"color": "#FFFFFF"` 처럼 추가하면 돼요.
