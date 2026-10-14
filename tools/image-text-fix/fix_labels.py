"""AI 이미지의 깨진 글씨를 지우고, 진짜 폰트로 다시 써 넣는 도구.

사용법:
    python fix_labels.py labels.json

labels.json 에 적힌 순서대로
  1) erase  : 지울 영역(글씨가 있던 자리)을 주변 배경으로 메우고
  2) labels : 새 글씨를 원하는 위치에 깔끔하게 써 넣습니다.
"""

import json
import sys
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageFont


def load_config(path):
    path = Path(path)
    config = json.loads(path.read_text(encoding="utf-8"))
    # 설정 파일 안의 상대 경로는 설정 파일이 있는 폴더를 기준으로 계산
    config["_base"] = path.parent
    return config


def resolve(config, p):
    p = Path(p)
    return p if p.is_absolute() else config["_base"] / p


def erase_regions(rgb, regions, radius):
    """사각형 영역을 주변 배경으로 자연스럽게 메운다 (OpenCV inpaint)."""
    mask = np.zeros(rgb.shape[:2], np.uint8)
    for r in regions:
        x0, y0, x1, y1 = r["box"]
        mask[y0:y1, x0:x1] = 255
    mask = cv2.dilate(mask, np.ones((5, 5), np.uint8))
    return cv2.inpaint(rgb, mask, radius, cv2.INPAINT_TELEA)


def clone_regions(rgb, regions):
    """도장 툴처럼, 근처의 깨끗한 부분을 복사해 덮는다 (제품 표면 위 로고 지우기용)."""
    out = rgb.astype(np.float32)
    for r in regions:
        x0, y0, x1, y1 = r["box"]
        dx, dy = r["from_offset"]
        patch = rgb[y0 + dy:y1 + dy, x0 + dx:x1 + dx].astype(np.float32)
        # 가장자리를 부드럽게 섞어서 붙인 티가 나지 않게
        alpha = np.zeros((y1 - y0, x1 - x0), np.float32)
        f = r.get("feather", 4)
        alpha[f:-f, f:-f] = 1
        alpha = cv2.GaussianBlur(alpha, (0, 0), f / 2)[..., None]
        out[y0:y1, x0:x1] = patch * alpha + out[y0:y1, x0:x1] * (1 - alpha)
    return out.clip(0, 255).astype(np.uint8)


def draw_labels(img, labels, fonts):
    draw = ImageDraw.Draw(img)
    for lab in labels:
        font = ImageFont.truetype(str(fonts[lab.get("font", "label")]), lab["size"])
        anchor = lab.get("anchor", "mt")  # mt = 가운데 위 기준
        draw.text(
            (lab["x"], lab["y"]),
            lab["text"],
            font=font,
            fill=lab.get("color", "#222222"),
            anchor=anchor,
            spacing=lab.get("line_spacing", 4),
            align="left" if anchor.startswith("l") else "center",
        )
    return img


def main():
    if len(sys.argv) != 2:
        print("사용법: python fix_labels.py labels.json")
        sys.exit(1)

    config = load_config(sys.argv[1])
    fonts = {name: resolve(config, p) for name, p in config["fonts"].items()}
    for name, p in fonts.items():
        if not p.exists():
            sys.exit(f"폰트 파일이 없어요: {p}  (README.md 의 '폰트 준비' 참고)")

    src = resolve(config, config["input"])
    rgb = np.asarray(Image.open(src).convert("RGB"))
    rgb = erase_regions(rgb, config.get("erase", []), config.get("inpaint_radius", 9))
    rgb = clone_regions(rgb, config.get("clone", []))

    img = draw_labels(Image.fromarray(rgb), config.get("labels", []), fonts)

    out = resolve(config, config["output"])
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out, quality=95)
    print(f"완료: {out}")


if __name__ == "__main__":
    main()
