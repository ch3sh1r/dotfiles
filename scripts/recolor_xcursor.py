"""Deterministic Dracula palette transform for native, premultiplied XCursor data."""

import colorsys
from functools import lru_cache
import struct


@lru_cache(maxsize=262144)
def dracula_pixel(pixel):
    alpha = pixel >> 24
    if not alpha:
        return pixel
    rgb = tuple(min(1.0, ((pixel >> shift) & 255) / alpha) for shift in (16, 8, 0))
    hue, saturation, value = colorsys.rgb_to_hsv(*rgb)
    if saturation < 0.12:
        # Neutral details span Dracula's background and foreground.
        dark, light = (40, 42, 54), (248, 248, 242)
        mapped = tuple((a + (b - a) * value) / 255 for a, b in zip(dark, light))
    else:
        # Red NEURODANCE accents become purple. Other semantic hues retain
        # their roles using Dracula's yellow, green, cyan, and pink accents.
        if hue < 0.12 or hue >= 0.9:
            target = (189, 147, 249)
        elif hue < 0.20:
            target = (241, 250, 140)
        elif hue < 0.45:
            target = (80, 250, 123)
        elif hue < 0.72:
            target = (139, 233, 253)
        else:
            target = (255, 121, 198)
        target_hue, target_saturation, target_value = colorsys.rgb_to_hsv(*(c / 255 for c in target))
        # Match the dominant upstream red (#eb2941) to Dracula purple while
        # retaining the relative saturation and brightness of shaded pixels.
        mapped = colorsys.hsv_to_rgb(
            target_hue,
            min(1.0, saturation * target_saturation / (194 / 235)),
            min(1.0, value * target_value / (235 / 255)),
        )
    red, green, blue = (min(alpha, max(0, round(c * alpha))) for c in mapped)
    return (alpha << 24) | (red << 16) | (green << 8) | blue


def recolor_xcursor(original):
    if original[:4] != b"Xcur":
        raise ValueError("Not an XCursor file")
    result = bytearray(original)
    _, header, _, count = struct.unpack_from("<4I", original)
    visited = set()
    for index in range(count):
        kind, _, offset = struct.unpack_from("<3I", original, header + index * 12)
        if kind != 0xFFFD0002 or offset in visited:
            continue
        visited.add(offset)
        chunk_header, _, _, _, width, height, xhot, yhot, _ = struct.unpack_from("<9I", original, offset)
        start = offset + chunk_header
        end = start + width * height * 4
        if chunk_header < 36 or end > len(original) or xhot >= width or yhot >= height:
            raise ValueError("Invalid XCursor frame")
        for position in range(start, end, 4):
            pixel = struct.unpack_from("<I", original, position)[0]
            struct.pack_into("<I", result, position, dracula_pixel(pixel))
    return bytes(result)
