"""Create synthetic local assets for manual Telegram verification."""
import hashlib
import json
import math
from pathlib import Path
import struct
import uuid
import wave
import zlib


def main():
    root = Path(__file__).resolve().parents[2]
    output = root / ".local" / "messaging-fixtures" / uuid.uuid4().hex
    output.mkdir(parents=True, exist_ok=False)
    (output / "text.txt").write_bytes(
        "FELOGRAM_TEST_TEXT\nHello developer\nമലയാളം العربية 日本語\n"
        "Emoji: 😀 👩🏽‍💻 🚀\nMultiline: first\nsecond\nLink: https://example.org/\n".encode("utf-8")
    )
    (output / "code.txt").write_bytes(
        'FELOGRAM_TEST_CODE\ndef example():\n\tvalue = "α 🚀 `backtick`"\n'
        '\treturn value  \n\n# Preserve tabs, trailing spaces and final newline.\n'.encode("utf-8")
    )
    (output / "transfer-32MiB.bin").write_bytes(bytes(range(256)) * (32 * 1024 * 1024 // 256))

    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))

    width, height = 640, 480
    rows = b"".join(b"\x00" + bytes((20, 160, 140) if y < 240 else (240, 180, 40)) * width for y in range(height))
    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
    (output / "photo.png").write_bytes(png + chunk(b"IDAT", zlib.compress(rows)) + chunk(b"IEND", b""))
    with wave.open(str(output / "tone.wav"), "wb") as audio:
        audio.setparams((1, 2, 16000, 0, "NONE", "not compressed"))
        audio.writeframes(b"".join(struct.pack("<h", int(4000 * math.sin(2 * math.pi * 440 * i / 16000))) for i in range(48000)))
    manifest = [{"file": p.name, "bytes": p.stat().st_size, "sha256": hashlib.sha256(p.read_bytes()).hexdigest()}
                for p in sorted(output.iterdir())]
    (output / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"Synthetic fixtures ready: {output}")
    print("No network requests or account data were used. Messaging results remain untested.")


if __name__ == "__main__":
    main()
