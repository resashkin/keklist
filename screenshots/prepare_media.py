#!/usr/bin/env python3
"""Prepares demo media for a capture run.

    python3 screenshots/prepare_media.py <out_dir>

- Downloads the Unsplash photos listed in PHOTOS into screenshots/demo/photos (gitignored) if missing.
- Copies them to <out_dir>/photos with an EXIF date, so the photo library files each one under its demo day.
- Makes the voice note and the round video for the "voice" scene in <out_dir>/user_files.
"""

import datetime
import struct
import shutil
import subprocess
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent
TODAY_SLOTS = 6
TODAY_SLOT_MINUTES = 35
TODAY_PHOTO_SLOTS = [1, 3, 5]
PHOTO_DIR = ROOT / 'demo' / 'photos'

# Unsplash photo id -> days before today. Unsplash License: https://unsplash.com/license
PHOTOS = {
    '1495474472287-4d71bcdd2085': 0,   # coffee with friends
    '1476480862126-209bfaa8edc8': 0,   # running shoes on stairs
    '1490645935967-10de6ba17061': 0,   # salad bowl
    '1518791841217-8f162f1e1131': 1,   # cat
    '1470071459604-3b5ec3a7fe05': 3,   # green valley
    '1501785888041-af3ef285b470': 3,   # mountain lake with a boat
    '1493246507139-91e8fad9978e': 3,   # lake at sunset
    '1506744038136-46273834b3fb': 3,   # valley lake
    '1500530855697-b586d89ba3ee': 3,   # road through the canyon
    '1441974231531-c6227db76b6e': 3,   # forest path
    '1529156069898-49953e39b3ac': 3,   # friends from behind
    '1472214103451-9374bd1c798e': 3,   # green hills
    '1509042239860-f550ce710b93': 5,   # coffee cups
    '1517836357463-d25dfeac3438': 8,   # gym
    '1504674900247-0877df9cc836': 10,  # dinner plate
    '1513104890138-7c749659a591': 12,  # pizza
    '1519681393784-d120267933ba': 15,  # stars over mountains
    '1543466835-00a7907e9de1': 17,     # dog
    '1507525428034-b723cf961d3e': 20,  # beach
    '1516483638261-f4dbaf036963': 24,  # Cinque Terre
    '1502602898657-3e91760cbb34': 26,  # Paris
    '1477959858617-67f85cf4f1df': 28,  # city skyline
    '1449824913935-59a10b8d2000': 28,  # city street
}


def download_photos() -> None:
    PHOTO_DIR.mkdir(parents=True, exist_ok=True)
    for photo_id in PHOTOS:
        target = PHOTO_DIR / f'{photo_id}.jpg'
        if target.exists():
            continue
        url = f'https://images.unsplash.com/photo-{photo_id}?w=1600&q=82&fm=jpg'
        target.write_bytes(urllib.request.urlopen(url, timeout=60).read())


def exif_segment(when: datetime.datetime) -> bytes:
    """A minimal APP1 Exif block with DateTimeOriginal and DateTime."""
    stamp = when.strftime('%Y:%m:%d %H:%M:%S').encode() + b'\0'
    # TIFF header, IFD0 with DateTime + ExifIFD pointer, Exif IFD with DateTimeOriginal.
    ifd0_offset = 8
    ifd0_size = 2 + 2 * 12 + 4
    exif_offset = ifd0_offset + ifd0_size
    exif_size = 2 + 1 * 12 + 4
    data_offset = exif_offset + exif_size
    tiff = b'II*\0' + struct.pack('<I', ifd0_offset)
    tiff += struct.pack('<H', 2)
    tiff += struct.pack('<HHII', 0x0132, 2, len(stamp), data_offset)
    tiff += struct.pack('<HHII', 0x8769, 4, 1, exif_offset)
    tiff += struct.pack('<I', 0)
    tiff += struct.pack('<H', 1)
    tiff += struct.pack('<HHII', 0x9003, 2, len(stamp), data_offset)
    tiff += struct.pack('<I', 0)
    tiff += stamp
    payload = b'Exif\0\0' + tiff
    return b'\xff\xe1' + struct.pack('>H', len(payload) + 2) + payload


def stamp_photos(out_dir: Path) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    today = datetime.datetime.now().replace(minute=0, second=0, microsecond=0)
    per_day: dict[int, int] = {}
    for photo_id, days_ago in PHOTOS.items():
        order = per_day[days_ago] = per_day.get(days_ago, -1) + 1
        when = (today - datetime.timedelta(days=days_ago)).replace(hour=min(9 + order, 21))
        if days_ago == 0:
            # Between today's notes; keep in step with kDemoToday* in lib/domain/services/screenshots/screenshot_demo.dart.
            slot = TODAY_PHOTO_SLOTS[order]
            when = datetime.datetime.now() - datetime.timedelta(minutes=TODAY_SLOT_MINUTES * (TODAY_SLOTS - slot))
        jpeg = (PHOTO_DIR / f'{photo_id}.jpg').read_bytes()
        assert jpeg[:2] == b'\xff\xd8', photo_id
        (out_dir / f'{days_ago:02d}_{order:02d}_{photo_id}.jpg').write_bytes(jpeg[:2] + exif_segment(when) + jpeg[2:])


def run(*args: str) -> None:
    subprocess.run(args, check=True, capture_output=True)


def make_voice_and_video(out_dir: Path) -> None:
    audio_dir = out_dir / 'user_files' / 'audio'
    video_dir = out_dir / 'user_files' / 'video'
    audio_dir.mkdir(parents=True, exist_ok=True)
    video_dir.mkdir(parents=True, exist_ok=True)
    speech = out_dir / 'speech.aiff'
    run('say', '-o', str(speech), 'Walked home the long way today. The air was cold and clear, and I finally had time to think.')
    run('ffmpeg', '-y', '-loglevel', 'error', '-i', str(speech), '-t', '14', '-c:a', 'aac', '-b:a', '96k',
        str(audio_dir / 'demo_voice.m4a'))
    source = PHOTO_DIR / '1493246507139-91e8fad9978e.jpg'
    video = video_dir / 'demo_round.mp4'
    run('ffmpeg', '-y', '-loglevel', 'error', '-loop', '1', '-i', str(source),
        '-vf', "crop='min(iw,ih)':'min(iw,ih)',scale=1200:1200,zoompan=z='1+0.0015*on':d=240:s=640x640:fps=30",
        '-t', '8', '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-an', str(video))
    run('ffmpeg', '-y', '-loglevel', 'error', '-i', str(video), '-frames:v', '1', str(video_dir / 'demo_round.jpg'))
    # The face in the camera circle of the recording scene; generated on pollinations.ai (no real person).
    shutil.copy(ROOT / 'demo' / 'round_face.jpg', video_dir / 'demo_round_face.jpg')


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    out_dir = Path(sys.argv[1])
    download_photos()
    stamp_photos(out_dir / 'photos')
    make_voice_and_video(out_dir)
    return 0


if __name__ == '__main__':
    sys.exit(main())
