#!/usr/bin/env python3
"""Generate MusicTeacherStudio raster assets for the asset catalog.

The app deliberately avoids stock imagery. These generated assets give the
brand a consistent premium notebook/music-studio feel and keep the App Store
package reproducible.
"""

from __future__ import annotations

import json
import math
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "MusicTeacherStudio" / "Resources" / "Assets.xcassets"

INDIGO = (79, 40, 218)
VIOLET = (109, 40, 217)
GOLD = (245, 158, 11)
GOLD_LIGHT = (251, 191, 36)
SURFACE = (250, 250, 247)
INK = (24, 24, 27)


def font(size: int, weight: str = "regular") -> ImageFont.FreeTypeFont:
    candidates = [
        "/System/Library/Fonts/Apple Symbols.ttf",
        "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial Unicode.ttf",
    ]
    if weight == "bold":
        candidates.insert(0, "/System/Library/Fonts/Supplemental/Arial Bold.ttf")
    for path in candidates:
        if Path(path).exists():
            return ImageFont.truetype(path, size=size)
    return ImageFont.load_default()


def gradient(size: tuple[int, int], start: tuple[int, int, int], end: tuple[int, int, int], vertical: bool = False) -> Image.Image:
    w, h = size
    img = Image.new("RGB", size)
    px = img.load()
    denom = max(1, h - 1 if vertical else w - 1)
    for y in range(h):
        for x in range(w):
            t = (y if vertical else (x + y) / 2) / denom
            t = max(0.0, min(1.0, t))
            px[x, y] = tuple(int(start[i] * (1 - t) + end[i] * t) for i in range(3))
    return img


def add_grain(img: Image.Image, amount: int = 14) -> Image.Image:
    rng = random.Random(36)
    noise = Image.new("L", img.size)
    data = [128 + rng.randint(-amount, amount) for _ in range(img.size[0] * img.size[1])]
    noise.putdata(data)
    overlay = Image.merge("RGB", (noise, noise, noise)).filter(ImageFilter.GaussianBlur(0.4))
    return Image.blend(img.convert("RGB"), overlay, 0.08)


def save_png(img: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path, "PNG", optimize=True)


def write_imageset(name: str, image_name: str = "image.png") -> Path:
    directory = ASSETS / f"{name}.imageset"
    directory.mkdir(parents=True, exist_ok=True)
    (directory / "Contents.json").write_text(
        json.dumps(
            {
                "images": [
                    {
                        "idiom": "universal",
                        "filename": image_name,
                        "scale": "1x",
                    }
                ],
                "info": {"author": "xcode", "version": 1},
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    return directory / image_name


def rounded_rectangle_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size[0], size[1]), radius=radius, fill=255)
    return mask


def create_app_icon() -> None:
    size = 1024
    img = add_grain(gradient((size, size), INDIGO, VIOLET))
    draw = ImageDraw.Draw(img, "RGBA")

    # Soft embossed pulse mark.
    for i, alpha in enumerate([28, 20, 14]):
        draw.arc((685 - i * 22, 124 - i * 22, 930 + i * 22, 370 + i * 22), 210, 330, fill=(255, 255, 255, alpha), width=10)

    # Notebook shadow and cover.
    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow, "RGBA")
    sdraw.rounded_rectangle((248, 232, 780, 828), radius=76, fill=(0, 0, 0, 75))
    shadow = shadow.filter(ImageFilter.GaussianBlur(32))
    img = Image.alpha_composite(img.convert("RGBA"), shadow)
    draw = ImageDraw.Draw(img, "RGBA")
    draw.rounded_rectangle((214, 186, 746, 784), radius=72, fill=(252, 248, 232, 245))
    draw.rounded_rectangle((244, 218, 704, 744), radius=50, outline=(79, 40, 218, 55), width=5)
    draw.line((304, 188, 304, 782), fill=(222, 202, 149, 170), width=8)
    for y in range(288, 704, 68):
        draw.line((344, y, 646, y), fill=(79, 40, 218, 48), width=4)

    # Gold tuning fork.
    draw.rounded_rectangle((672, 248, 724, 690), radius=26, fill=GOLD + (255,))
    draw.rounded_rectangle((624, 238, 672, 438), radius=24, fill=GOLD_LIGHT + (255,))
    draw.rounded_rectangle((724, 238, 772, 438), radius=24, fill=GOLD_LIGHT + (255,))
    draw.ellipse((632, 644, 764, 776), fill=(255, 255, 255, 34), outline=GOLD_LIGHT + (210,), width=9)

    clef_font = font(330)
    clef = "𝄞"
    bbox = draw.textbbox((0, 0), clef, font=clef_font)
    draw.text((372 - (bbox[2] - bbox[0]) / 2, 508 - (bbox[3] - bbox[1]) / 2), clef, font=clef_font, fill=(79, 40, 218, 190))

    icon_dir = ASSETS / "AppIcon.appiconset"
    icon_dir.mkdir(parents=True, exist_ok=True)
    save_png(img.convert("RGB"), icon_dir / "icon-1024.png")
    (icon_dir / "Contents.json").write_text(
        json.dumps(
            {
                "images": [
                    {
                        "idiom": "universal",
                        "platform": "ios",
                        "size": "1024x1024",
                        "filename": "icon-1024.png",
                    }
                ],
                "info": {"author": "xcode", "version": 1},
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )


def transparent_canvas(size: int = 1080) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    return img, ImageDraw.Draw(img, "RGBA")


def draw_card(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], fill=(255, 252, 238, 245), outline=(79, 40, 218, 70)) -> None:
    draw.rounded_rectangle(box, radius=44, fill=fill, outline=outline, width=4)


def save_onboarding(name: str, variant: str) -> None:
    img, draw = transparent_canvas()
    draw.ellipse((170, 170, 910, 910), fill=(79, 40, 218, 22))
    draw.ellipse((245, 250, 860, 860), fill=(245, 158, 11, 22))

    if variant == "capture":
        draw_card(draw, (230, 260, 850, 740))
        for y in [350, 430, 510, 590]:
            draw.line((330, y, 740, y), fill=(79, 40, 218, 62), width=8)
        draw.rounded_rectangle((270, 300, 390, 420), radius=34, fill=GOLD + (235,))
        draw.line((302, 364, 338, 402), fill=(255, 255, 255, 255), width=18)
        draw.line((338, 402, 372, 326), fill=(255, 255, 255, 255), width=18)
        draw.ellipse((645, 190, 832, 377), outline=(79, 40, 218, 130), width=18)
        draw.line((738, 280, 738, 224), fill=(79, 40, 218, 150), width=12)
        draw.line((738, 280, 788, 316), fill=(79, 40, 218, 150), width=12)
    elif variant == "ai":
        for offset in [58, 0]:
            draw.rounded_rectangle((260 + offset, 380 - offset, 815 + offset, 676 - offset), radius=42, fill=(255, 252, 238, 242), outline=(79, 40, 218, 55), width=4)
            draw.line((280 + offset, 410 - offset, 535 + offset, 540 - offset), fill=(79, 40, 218, 38), width=5)
            draw.line((795 + offset, 410 - offset, 535 + offset, 540 - offset), fill=(79, 40, 218, 38), width=5)
        draw.line((380, 665, 730, 315), fill=GOLD + (250,), width=24)
        draw.polygon([(730, 315), (805, 260), (775, 350)], fill=GOLD_LIGHT + (255,))
        for x, y in [(260, 270), (824, 745), (760, 230), (330, 780)]:
            draw.ellipse((x, y, x + 26, y + 26), fill=GOLD_LIGHT + (200,))
    elif variant == "chart":
        draw_card(draw, (230, 270, 850, 750))
        for y in [385, 475, 565, 655]:
            draw.line((300, y, 780, y), fill=(79, 40, 218, 45), width=5)
        bars = [(340, 600, 70), (450, 520, 150), (560, 450, 220), (670, 365, 305)]
        for x, top, h in bars:
            color = GOLD_LIGHT + (245,) if x == 670 else INDIGO + (210,)
            draw.rounded_rectangle((x, top, x + 64, 670), radius=22, fill=color)
        draw.arc((210, 176, 420, 386), 95, 280, fill=(79, 40, 218, 88), width=14)
        draw.line((315, 386, 315, 456), fill=(79, 40, 218, 88), width=12)
    elif variant == "pro":
        draw_card(draw, (255, 420, 825, 760))
        draw.line((320, 535, 760, 535), fill=(79, 40, 218, 46), width=8)
        draw.line((320, 620, 720, 620), fill=(79, 40, 218, 46), width=8)
        crown = [(392, 352), (452, 244), (538, 346), (638, 244), (700, 352), (680, 440), (410, 440)]
        draw.polygon(crown, fill=GOLD + (245,))
        draw.line((410, 440, 680, 440), fill=GOLD_LIGHT + (255,), width=16)
        for x, y in [(380, 290), (520, 210), (692, 294)]:
            draw.ellipse((x, y, x + 40, y + 40), fill=GOLD_LIGHT + (255,))

    save_png(img, write_imageset(name))


def save_empty_state(name: str, variant: str) -> None:
    img, draw = transparent_canvas()
    draw.ellipse((235, 265, 845, 875), fill=(79, 40, 218, 14))
    stroke = INDIGO + (180,)
    if variant == "students":
        for x, instrument in [(350, "piano"), (540, "violin"), (725, "guitar")]:
            draw.ellipse((x - 32, 380, x + 32, 444), outline=stroke, width=9)
            draw.line((x, 444, x, 620), fill=stroke, width=9)
            draw.line((x, 498, x - 70, 560), fill=stroke, width=9)
            draw.line((x, 498, x + 70, 560), fill=stroke, width=9)
            draw.line((x, 620, x - 56, 745), fill=stroke, width=9)
            draw.line((x, 620, x + 56, 745), fill=stroke, width=9)
            if instrument == "piano":
                draw.rounded_rectangle((x - 120, 535, x - 34, 610), radius=12, outline=GOLD + (210,), width=8)
            elif instrument == "violin":
                draw.ellipse((x + 32, 525, x + 128, 642), outline=GOLD + (210,), width=8)
            else:
                draw.ellipse((x + 30, 545, x + 134, 666), outline=GOLD + (210,), width=8)
                draw.line((x + 110, 542, x + 170, 470), fill=GOLD + (210,), width=8)
    elif variant == "lessons":
        draw_card(draw, (280, 285, 800, 760), fill=(255, 252, 238, 225), outline=(79, 40, 218, 95))
        draw.rectangle((280, 285, 800, 390), fill=INDIGO + (170,))
        for x in [385, 510, 635]:
            draw.line((x, 440, x, 705), fill=(79, 40, 218, 45), width=5)
        for y in [485, 585]:
            draw.line((325, y, 755, y), fill=(79, 40, 218, 45), width=5)
        draw.text((482, 515), "𝄞", font=font(140), fill=GOLD + (230,))
    else:
        draw.rounded_rectangle((290, 320, 790, 730), radius=42, fill=(255, 252, 238, 230), outline=stroke, width=7)
        draw.line((360, 445, 720, 445), fill=(79, 40, 218, 70), width=8)
        draw.line((360, 520, 680, 520), fill=(79, 40, 218, 70), width=8)
        draw.rounded_rectangle((360, 590, 430, 660), radius=12, outline=GOLD + (230,), width=8)
        draw.line((377, 625, 402, 650), fill=GOLD + (230,), width=8)
        draw.line((402, 650, 430, 590), fill=GOLD + (230,), width=8)
    save_png(img, write_imageset(name))


def create_paywall_backdrop() -> None:
    img = add_grain(gradient((1080, 1920), (32, 16, 88), VIOLET, vertical=True), amount=18).convert("RGBA")
    draw = ImageDraw.Draw(img, "RGBA")
    draw.ellipse((190, 170, 890, 870), fill=(245, 158, 11, 28))
    draw.text((390, 255), "𝄞", font=font(380), fill=(245, 158, 11, 80))
    draw.rectangle((0, 1260, 1080, 1920), fill=(19, 18, 56, 130))
    save_png(img, write_imageset("PaywallBackdrop"))


def main() -> None:
    create_app_icon()
    save_onboarding("OnboardingHero1", "capture")
    save_onboarding("OnboardingAI", "ai")
    save_onboarding("OnboardingCharts", "chart")
    save_onboarding("OnboardingPro", "pro")
    save_empty_state("EmptyStudents", "students")
    save_empty_state("EmptyLessons", "lessons")
    save_empty_state("EmptyAssignments", "assignments")
    create_paywall_backdrop()


if __name__ == "__main__":
    main()
