#!/usr/bin/env python3
"""Frames raw app screenshots and puts a localized caption above them.

    python3 screenshots/compose.py en                 # every device that has raw screens
    python3 screenshots/compose.py ru iphone_69       # one device

Raw screens: screenshots/raw/<device>/<scene>.png (English UI, made by capture.sh).
Captions:    screenshots/strings/<lang>.yaml, one `scene: text` per line, in screenshot order.
Output:      screenshots/out/<lang>/<device>/<NN>_<scene>.png at the store's exact size.

A caption that needs more than two lines or is wider than the canvas fails the run instead of shrinking.
"""

import html
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
BACKGROUND = '#0a0a0a'
ACCENT = '#7C5CFC'
TEXT = '#F5F5F5'


def read_strings(lang: str) -> list[tuple[str, str]]:
    pairs = []
    for line in (ROOT / 'strings' / f'{lang}.yaml').read_text(encoding='utf-8').splitlines():
        if not line.strip() or line.lstrip().startswith('#'):
            continue
        key, _, value = line.partition(':')
        pairs.append((key.strip(), value.strip()))
    return pairs


def frame_html(kind: str, image: str, width: float) -> str:
    """The device drawn in CSS around the screenshot; `width` is the outer frame width in px."""
    src = html.escape(image)
    if kind == 'laptop':
        bezel = width * 0.018
        return f'''
        <div class="laptop" style="width:{width}px">
          <div class="lid" style="padding:{bezel}px;border-radius:{bezel * 1.4}px {bezel * 1.4}px 0 0">
            <img src="{src}" style="border-radius:{bezel * 0.4}px">
          </div>
          <div class="base" style="height:{width * 0.028}px;border-radius:0 0 {width * 0.02}px {width * 0.02}px"></div>
        </div>'''
    bezel_ratio = {'iphone': 0.035, 'android': 0.03, 'tablet': 0.03, 'foldable': 0.028}[kind]
    radius_ratio = {'iphone': 0.15, 'android': 0.1, 'tablet': 0.06, 'foldable': 0.07}[kind]
    bezel = width * bezel_ratio
    outer_radius = width * radius_ratio
    inner_radius = max(outer_radius - bezel, 0)
    hinge = '<div class="hinge"></div>' if kind == 'foldable' else ''
    return f'''
    <div class="device" style="width:{width}px;padding:{bezel}px;border-radius:{outer_radius}px">
      <img src="{src}" style="border-radius:{inner_radius}px">{hinge}
    </div>'''


def page(caption: str, image: str, size: tuple[int, int], frame: str, image_size: tuple[int, int]) -> str:
    canvas_w, canvas_h = size
    landscape = canvas_w > canvas_h
    side = canvas_w * (0.06 if not landscape else 0.05)
    font = (canvas_w if not landscape else canvas_h) * (0.072 if not landscape else 0.075)
    caption_top = canvas_h * 0.055
    caption_h = font * 1.15 * 2
    gap = canvas_h * 0.035
    area_top = caption_top + caption_h + gap
    area_h = canvas_h - area_top - canvas_h * 0.04
    area_w = canvas_w - side * 2
    img_w, img_h = image_size
    # Frame width that keeps the whole device inside the area.
    if frame == 'laptop':
        ratio = (img_h / img_w) * (1 - 0.036) + 0.036 + 0.028
    else:
        bezel = {'iphone': 0.035, 'android': 0.03, 'tablet': 0.03, 'foldable': 0.028}[frame]
        ratio = (img_h / img_w) * (1 - 2 * bezel) + 2 * bezel
    frame_w = min(area_w, area_h / ratio)
    return f'''<!doctype html><html><head><meta charset="utf-8"><style>
      html, body {{ margin:0; width:{canvas_w}px; height:{canvas_h}px; overflow:hidden; }}
      body {{ background: radial-gradient(ellipse at 50% 85%, {ACCENT}40 0%, {BACKGROUND} 62%);
              font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', system-ui, sans-serif; }}
      #caption {{ position:absolute; left:{side}px; right:{side}px; top:{caption_top}px; height:{caption_h}px;
                  display:flex; align-items:center; justify-content:center; text-align:center;
                  color:{TEXT}; font-size:{font}px; font-weight:700; line-height:1.15; letter-spacing:-0.02em;
                  overflow:hidden; overflow-wrap:normal; word-break:keep-all; hyphens:none; }}
      #caption span {{ display:block; max-width:100%; }}
      .stage {{ position:absolute; left:0; right:0; top:{area_top}px; height:{area_h}px;
                display:flex; align-items:center; justify-content:center; }}
      .device {{ background:#1c1c1e; box-shadow: 0 0 0 {canvas_w * 0.002}px #3a3a3c, 0 {canvas_h * 0.02}px {canvas_h * 0.05}px #0009;
                 position:relative; box-sizing:border-box; line-height:0; }}
      .device img, .lid img {{ width:100%; display:block; }}
      .hinge {{ position:absolute; top:0; bottom:0; left:50%; width:{canvas_w * 0.002}px; background:#ffffff14; }}
      .laptop {{ display:flex; flex-direction:column; align-items:center; line-height:0; }}
      .lid {{ background:#1c1c1e; box-sizing:border-box; width:100%; box-shadow: 0 0 0 {canvas_w * 0.0015}px #3a3a3c; }}
      .base {{ background:linear-gradient(#3a3a3c, #232325); width:116%; }}
    </style></head><body>
      <div id="caption"><span>{html.escape(caption)}</span></div>
      <div class="stage">{frame_html(frame, image, frame_w)}</div>
      <script>
        const box = document.getElementById('caption');
        const text = box.firstElementChild;
        const lineHeight = parseFloat(getComputedStyle(box).lineHeight);
        const lines = Math.round(text.getBoundingClientRect().height / lineHeight);
        const tooWide = text.scrollWidth > box.clientWidth + 1;
        document.body.dataset.fit = (lines <= 2 && !tooWide) ? 'ok' : `lines=${{lines}} wide=${{tooWide}}`;
      </script>
    </body></html>'''


def png_size(path: Path) -> tuple[int, int]:
    data = path.read_bytes()[16:24]
    return int.from_bytes(data[:4], 'big'), int.from_bytes(data[4:], 'big')


def chrome(args: list[str]) -> str:
    """Headless Chrome with its own throwaway profile; retried because a cold start occasionally exits early."""
    for attempt in range(3):
        with tempfile.TemporaryDirectory() as profile:
            base = [CHROME, '--headless=new', '--disable-gpu', '--hide-scrollbars', '--force-device-scale-factor=1',
                    '--allow-file-access-from-files', '--virtual-time-budget=2000', f'--user-data-dir={profile}',
                    '--no-first-run', '--no-default-browser-check']
            result = subprocess.run(base + args, capture_output=True, text=True)
        if result.returncode == 0:
            return result.stdout
    raise RuntimeError(f'Chrome failed: {result.stderr[-500:]}')


def compose(lang: str, device: str, spec: dict, strings: list[tuple[str, str]]) -> list[str]:
    raw_dir = ROOT / 'raw' / device
    out_dir = ROOT / 'out' / lang / device
    out_dir.mkdir(parents=True, exist_ok=True)
    errors = []
    size = tuple(spec['size'])
    for index, (scene, caption) in enumerate(strings, start=1):
        raw = raw_dir / f'{scene}.png'
        if not raw.exists():
            errors.append(f'{device}/{scene}: no raw screen at {raw.relative_to(ROOT)}')
            continue
        with tempfile.NamedTemporaryFile('w', suffix='.html', delete=False, encoding='utf-8') as f:
            f.write(page(caption, raw.as_uri(), size, spec['frame'], png_size(raw)))
            page_path = Path(f.name)
        window = f'--window-size={size[0]},{size[1]}'
        dom = chrome([window, '--dump-dom', page_path.as_uri()])
        fit = re.search(r'data-fit="([^"]*)"', dom)
        if not fit or fit.group(1) != 'ok':
            errors.append(f'{lang}/{device}/{scene}: caption does not fit ({fit.group(1) if fit else "no result"}): {caption}')
            continue
        target = out_dir / f'{index:02d}_{scene}.png'
        chrome([window, f'--screenshot={target}', page_path.as_uri()])
        page_path.unlink()
        if png_size(target) != size:
            errors.append(f'{target.relative_to(ROOT)} is {png_size(target)}, expected {size}')
    return errors


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    lang = sys.argv[1]
    devices = json.loads((ROOT / 'devices.json').read_text())
    wanted = sys.argv[2:] or [d for d in devices if (ROOT / 'raw' / d).is_dir()]
    strings = read_strings(lang)
    errors = []
    for device in wanted:
        errors += compose(lang, device, devices[device], strings)
        print(f'{lang}/{device}: done')
    for error in errors:
        print(f'ERROR {error}', file=sys.stderr)
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())
