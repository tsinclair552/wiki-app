#!/usr/bin/env python3
"""Generate a simple wiki app icon — book on rounded square."""

import struct, zlib, os, sys

def create_png(width, height, pixels):
    """Create a PNG from raw RGBA pixel data (list of (r,g,b,a) tuples)."""
    raw = b""
    for y in range(height):
        raw += b"\x00"  # filter byte
        for x in range(width):
            px = pixels[y * width + x]
            raw += struct.pack("BBBB", *px)

    def chunk(chunk_type, data):
        c = chunk_type + data
        return struct.pack(">I", len(data)) + c + struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)

    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)

    return (b"\x89PNG\r\n\x1a\n" +
            chunk(b"IHDR", ihdr) +
            chunk(b"IDAT", zlib.compress(raw)) +
            chunk(b"IEND", b""))

def generate_icon(size, output_path):
    """Generate a book-on-rounded-square icon."""
    s = size
    r = int(s * 0.17)  # corner radius
    pad = int(s * 0.08)
    pixels = []

    bg = (0, 85, 184, 255)       # blue #0055b8
    book = (255, 255, 255, 255)  # white

    for y in range(s):
        for x in range(s):
            in_corner = False
            if x < r and y < r:
                in_corner = (x - r) ** 2 + (y - r) ** 2 > r * r
            elif x >= s - r and y < r:
                in_corner = (x - (s - 1 - r)) ** 2 + (y - r) ** 2 > r * r
            elif x < r and y >= s - r:
                in_corner = (x - r) ** 2 + (y - (s - 1 - r)) ** 2 > r * r
            elif x >= s - r and y >= s - r:
                in_corner = (x - (s - 1 - r)) ** 2 + (y - (s - 1 - r)) ** 2 > r * r

            if in_corner:
                pixels.append((0, 0, 0, 0))
                continue

            # Book shape
            bx, by = x / s, y / s
            book_left = 0.25
            book_right = 0.75
            book_top = 0.2
            book_bottom = 0.8

            if book_left < bx < book_right and book_top < by < book_bottom:
                # Pages
                page_mid = 0.46
                spine = 0.32
                if bx < spine:
                    # Spine
                    shade = 1.0 - (spine - bx) / (spine - book_left) * 0.3
                    c = int(200 * shade)
                    pixels.append((c, c, c, 255))
                elif abs(bx - page_mid) < 0.015:
                    # Page line
                    pixels.append((180, 200, 220, 255))
                else:
                    # Page
                    shade = 1.0 - abs(bx - 0.5) * 0.15
                    c = int(245 * shade)
                    pixels.append((c, c, c, 255))
            else:
                pixels.append(bg)

    png_data = create_png(size, size, pixels)
    with open(output_path, "wb") as f:
        f.write(png_data)

def main():
    iconset_dir = sys.argv[1]
    os.makedirs(iconset_dir, exist_ok=True)

    sizes = [(16, "16x16"), (32, "16x16@2x"), (32, "32x32"), (64, "32x32@2x"),
             (128, "128x128"), (256, "128x128@2x"), (256, "256x256"), (512, "256x256@2x"),
             (512, "512x512"), (1024, "512x512@2x")]

    for px, name in sizes:
        path = os.path.join(iconset_dir, f"icon_{name}.png")
        generate_icon(px, path)
        print(f"  Generated {path} ({px}x{px})")

if __name__ == "__main__":
    main()
