#!/usr/bin/env python3
import math
import re
import datetime
from PIL import Image, ImageDraw, ImageFont

COLORS_CONF_PATH = "/home/anasa/.config/hypr/hyprlock/colors.conf"

# Fallback palette, used if colors.conf is missing or unparsable
FALLBACK_RGB = {
    "text_color": (223, 229, 205),
    "entry_border_color": (146, 144, 141),
    "surface_color": (24, 29, 15),
    "entry_color": (195, 205, 175),
    "primary_color": (239, 83, 80),
}

VAR_RE = re.compile(r"\$(\w+)\s*=\s*rgba\(([0-9a-fA-F]{6})([0-9a-fA-F]{2})?\)")

def load_theme_rgb():
    """Parse $var = rgba(RRGGBB[AA]) lines from hyprlock/colors.conf, ignoring alpha."""
    rgb = dict(FALLBACK_RGB)
    try:
        with open(COLORS_CONF_PATH, "r") as f:
            content = f.read()
        for name, hexrgb, _alpha in VAR_RE.findall(content):
            r = int(hexrgb[0:2], 16)
            g = int(hexrgb[2:4], 16)
            b = int(hexrgb[4:6], 16)
            rgb[name] = (r, g, b)
    except (OSError, ValueError):
        pass
    return rgb

def render_material_clock():
    size = 450
    center = size // 2
    radius = size // 2 - 24

    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Palette - hue from the wallpaper-generated theme, alpha per element (tuned by hand)
    theme = load_theme_rgb()
    color_bg_fill = (*theme["surface_color"], 110)
    color_bg_stroke = (*theme["entry_border_color"], 60)
    color_ticks_major = (*theme["text_color"], 230)
    color_ticks_minor = (*theme["entry_border_color"], 100)
    color_numbers = (*theme["text_color"], 255)
    color_hour_hand = (*theme["text_color"], 255)
    color_min_hand = (*theme["entry_color"], 240)
    color_sec_hand = (*theme["primary_color"], 255)
    color_pivot = (*theme["text_color"], 255)

    # Frosted Glass Backing Circle
    draw.ellipse(
        [center - radius, center - radius, center + radius, center + radius],
        fill=color_bg_fill,
        outline=color_bg_stroke,
        width=3
    )

    # Load Font for 12, 3, 6, 9
    try:
        font_num = ImageFont.truetype("/usr/share/fonts/TTF/GoogleSans-Medium.ttf", 26)
    except Exception:
        font_num = ImageFont.load_default()

    # Draw Hour Ticks & Numbers
    for i in range(60):
        angle = math.radians(i * 6 - 90)
        is_hour = (i % 5 == 0)
        
        if is_hour:
            # Material Pill Ticks
            t_len = 16
            x1 = center + (radius - t_len - 8) * math.cos(angle)
            y1 = center + (radius - t_len - 8) * math.sin(angle)
            x2 = center + (radius - 8) * math.cos(angle)
            y2 = center + (radius - 8) * math.sin(angle)
            draw.line([(x1, y1), (x2, y2)], fill=color_ticks_major, width=4)
        else:
            # Minor Dots
            x = center + (radius - 12) * math.cos(angle)
            y = center + (radius - 12) * math.sin(angle)
            dot_r = 2
            draw.ellipse([x - dot_r, y - dot_r, x + dot_r, y + dot_r], fill=color_ticks_minor)

    # Draw Numbers (12, 3, 6, 9)
    nums = [("12", 0), ("3", 90), ("6", 180), ("9", 270)]
    for text, deg in nums:
        rad = math.radians(deg - 90)
        nx = center + (radius - 42) * math.cos(rad)
        ny = center + (radius - 42) * math.sin(rad)
        bbox = draw.textbbox((0, 0), text, font=font_num)
        tw = bbox[2] - bbox[0]
        th = bbox[3] - bbox[1]
        draw.text((nx - tw / 2, ny - th / 2), text, font=font_num, fill=color_numbers)

    # Get Time
    now = datetime.datetime.now()
    hrs = now.hour % 12
    mins = now.minute
    secs = now.second

    hour_angle = math.radians((hrs + mins / 60.0) * 30 - 90)
    min_angle = math.radians((mins + secs / 60.0) * 6 - 90)
    sec_angle = math.radians(secs * 6 - 90)

    # Material 3 Capsule Hour Hand
    h_len = radius * 0.50
    hx = center + h_len * math.cos(hour_angle)
    hy = center + h_len * math.sin(hour_angle)
    draw.line([(center, center), (hx, hy)], fill=color_hour_hand, width=12)

    # Material 3 Capsule Minute Hand
    m_len = radius * 0.72
    mx = center + m_len * math.cos(min_angle)
    my = center + m_len * math.sin(min_angle)
    draw.line([(center, center), (mx, my)], fill=color_min_hand, width=7)

    # Second Hand with Circle Tip
    s_len = radius * 0.82
    sx = center + s_len * math.cos(sec_angle)
    sy = center + s_len * math.sin(sec_angle)
    tail_x = center - (radius * 0.22) * math.cos(sec_angle)
    tail_y = center - (radius * 0.22) * math.sin(sec_angle)
    draw.line([(tail_x, tail_y), (sx, sy)], fill=color_sec_hand, width=2)
    
    # Second Hand Ring Tip
    tip_r = 5
    draw.ellipse([sx - tip_r, sy - tip_r, sx + tip_r, sy + tip_r], outline=color_sec_hand, width=2)

    # Center Pivot Node
    p_outer = 9
    draw.ellipse([center - p_outer, center - p_outer, center + p_outer, center + p_outer], fill=color_sec_hand)
    p_inner = 4
    draw.ellipse([center - p_inner, center - p_inner, center + p_inner, center + p_inner], fill=color_pivot)

    img.save("/tmp/hyprlock_analog_clock.png", "PNG")

if __name__ == "__main__":
    render_material_clock()
