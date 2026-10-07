from pathlib import Path
import os
import struct
import sys

os.environ.setdefault('QT_QPA_PLATFORM', 'offscreen')
from PySide6.QtCore import QByteArray, QBuffer, QIODevice, QRectF
from PySide6.QtGui import QColor, QFont, QFontDatabase, QGuiApplication, QImage, QPainter
from PySide6.QtSvg import QSvgRenderer

app = QGuiApplication([])
font_path = Path('C:/Windows/Fonts/segoeui.ttf')
if font_path.exists():
    QFontDatabase.addApplicationFont(str(font_path))
root = Path(__file__).resolve().parents[2]
assets = root / 'Telegram/Resources/art/felogram'
renderer = QSvgRenderer(str(assets / 'mark.svg'))
if not renderer.isValid():
    raise ValueError('Invalid Felogram source SVG')

def render(size):
    image = QImage(size, size, QImage.Format_ARGB32)
    image.fill(0)
    painter = QPainter(image)
    renderer.render(painter, QRectF(0, 0, size, size))
    painter.end()
    return image

sizes = [16, 20, 24, 32, 40, 48, 64, 128, 256]
pngs = []
for size in sizes:
    data = QByteArray()
    buffer = QBuffer(data)
    buffer.open(QIODevice.WriteOnly)
    if not render(size).save(buffer, 'PNG'):
        raise ValueError('PNG encoding failed')
    pngs.append(bytes(data))
offset = 6 + 16 * len(sizes)
entries = []
for size, data in zip(sizes, pngs):
    entries.append(struct.pack('<BBBBHHII', size % 256, size % 256, 0, 0, 1, 32, len(data), offset))
    offset += len(data)
(assets / 'felogram.ico').write_bytes(struct.pack('<HHH', 0, 1, len(sizes)) + b''.join(entries) + b''.join(pngs))
for name in ['logo_256.png', 'logo_256_no_margin.png']:
    if not render(256).save(str(assets / name)):
        raise ValueError('Logo encoding failed')

if len(sys.argv) > 1:
    preview = QImage(1200, 600, QImage.Format_ARGB32)
    painter = QPainter(preview)
    painter.setFont(QFont('Segoe UI', 10))
    for row, background in enumerate(['#f8fafc', '#17212b']):
        painter.fillRect(0, row * 300, 1200, 300, QColor(background))
        painter.setPen(QColor('#17212b' if row == 0 else '#f8fafc'))
        painter.drawText(24, row * 300 + 30, 'Felogram: light/dark backgrounds; 16/24/32 px cover 100/150/200% small icons')
        x = 24
        for size in sizes:
            painter.drawImage(x, row * 300 + 50, render(size))
            painter.drawText(x, row * 300 + 290, str(size) + ' px')
            x += max(size, 60) + 28
    painter.end()
    if not preview.save(sys.argv[1]):
        raise ValueError('Preview save failed')
print('Generated Felogram PNG logos and 9-size Windows ICO from mark.svg.')
