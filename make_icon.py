#!/usr/bin/env python3
"""Bold single-emblem app icon: one oversized red block (Cao Cao's 2x2 general block,
matching the actual in-app block color/character) tilted on a dark charcoal gradient.
No detailed scene, no extra text."""

from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
img = Image.new("RGB", (SIZE, SIZE), "#141416")
draw = ImageDraw.Draw(img)

top = (24, 24, 27)
bottom = (10, 10, 12)
for y in range(SIZE):
    t = y / SIZE
    r = int(top[0] + (bottom[0] - top[0]) * t)
    g = int(top[1] + (bottom[1] - top[1]) * t)
    b = int(top[2] + (bottom[2] - top[2]) * t)
    draw.line([(0, y), (SIZE, y)], fill=(r, g, b))

block_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
bdraw = ImageDraw.Draw(block_layer)
bw = bh = SIZE * 0.66
cx, cy = SIZE / 2, SIZE / 2
bdraw.rounded_rectangle(
    [cx - bw / 2, cy - bh / 2, cx + bw / 2, cy + bh / 2],
    radius=SIZE * 0.07, fill=(191, 31, 31, 255)
)

white = (250, 247, 240, 255)
try:
    font_big = ImageFont.truetype("/System/Library/Fonts/STHeiti Medium.ttc", int(SIZE * 0.34))
except OSError:
    font_big = ImageFont.load_default()

def centered_text(d, text, font, cx, cy, fill):
    bbox = d.textbbox((0, 0), text, font=font)
    w, h = bbox[2] - bbox[0], bbox[3] - bbox[1]
    d.text((cx - w / 2 - bbox[0], cy - h / 2 - bbox[1]), text, font=font, fill=fill)

centered_text(bdraw, "帥", font_big, cx, cy, white)

rotated = block_layer.rotate(-9, resample=Image.BICUBIC, expand=False, center=(cx, cy))
img.paste(rotated, (0, 0), rotated)

img.save("/Users/user/Klotski/Klotski/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
print("wrote AppIcon.png", img.size)
