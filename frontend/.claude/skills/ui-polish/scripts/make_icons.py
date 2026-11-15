"""Generate PWA icons: teal diagonal gradient (full bleed, maskable-safe) + white rounded medical cross."""
import struct, sys, zlib, os

C1 = (0x0F, 0x76, 0x6E)  # $teal
C2 = (0x14, 0xB8, 0xA6)  # $teal-bright
SS = 4  # supersampling per axis


def rrect_inside(px, py, x0, y0, x1, y1, r):
    if px < x0 or px > x1 or py < y0 or py > y1:
        return False
    cx = min(max(px, x0 + r), x1 - r)
    cy = min(max(py, y0 + r), y1 - r)
    return (px - cx) ** 2 + (py - cy) ** 2 <= r * r


def in_cross(u, v):
    # u, v in [0,1]; cross fits within the 80% maskable safe circle
    arm, thick, rad = 0.40, 0.14, 0.035
    a0, a1 = 0.5 - arm / 2, 0.5 + arm / 2
    t0, t1 = 0.5 - thick / 2, 0.5 + thick / 2
    return rrect_inside(u, v, a0, t0, a1, t1, rad) or rrect_inside(u, v, t0, a0, t1, a1, rad)


def render(size):
    rows = []
    for y in range(size):
        row = bytearray([0])
        for x in range(size):
            t = (x + y) / (2 * (size - 1))
            bg = [C1[i] + (C2[i] - C1[i]) * t for i in range(3)]
            # soft light from top-left
            glow = max(0.0, 1 - ((x / size) ** 2 + (y / size) ** 2) ** 0.5) * 0.10
            bg = [c + (255 - c) * glow for c in bg]
            cov = 0
            for sy in range(SS):
                for sx in range(SS):
                    if in_cross((x + (sx + .5) / SS) / size, (y + (sy + .5) / SS) / size):
                        cov += 1
            a = cov / (SS * SS)
            row += bytes(int(round(bg[i] * (1 - a) + 255 * a)) for i in range(3))
        rows.append(bytes(row))
    raw = b''.join(rows)

    def chunk(tag, data):
        return struct.pack('>I', len(data)) + tag + data + struct.pack('>I', zlib.crc32(tag + data) & 0xffffffff)

    return (b'\x89PNG\r\n\x1a\n'
            + chunk(b'IHDR', struct.pack('>IIBBBBB', size, size, 8, 2, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(raw, 9))
            + chunk(b'IEND', b''))


if __name__ == '__main__':
    out = sys.argv[1]
    for s in (72, 96, 128, 144, 152, 192, 384, 512):
        with open(os.path.join(out, f'icon-{s}x{s}.png'), 'wb') as f:
            f.write(render(s))
        print('ok', s)
