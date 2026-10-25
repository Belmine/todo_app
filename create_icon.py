from PIL import Image, ImageDraw

# Icône : une grande coche foncée sur fond orange, aux couleurs de l'app.
#
# Génère :
#  - assets/icon/icon.png : icône complète (iOS et anciens Android)
#  - assets/icon/icon_foreground.png : premier plan de l'icône adaptative
#    Android, posé sur la couleur adaptive_icon_background du pubspec.yaml
# Ensuite, lancer : dart run flutter_launcher_icons

SIZE = 1024
SUPERSAMPLE = 4  # dessin en grand puis réduction, pour des bords lisses
ORANGE = (255, 184, 0, 255)
DARK = (26, 26, 26, 255)
TRANSPARENT = (0, 0, 0, 0)

# Android n'affiche que le centre de l'icône adaptative (72 dp sur 108 dp) :
# la coche y est plus petite pour rester visible quelle que soit la forme.
FULL_ICON_SCALE = 1.35
FOREGROUND_SCALE = 0.95


def draw_check(scale, background=TRANSPARENT):
    """Dessine la coche, définie dans un repère de 1024 px, à l'échelle voulue."""
    s = SUPERSAMPLE
    img = Image.new('RGBA', (SIZE * s, SIZE * s), background)
    draw = ImageDraw.Draw(img)

    def pos(value):
        return (SIZE / 2 + (value - SIZE / 2) * scale) * s

    points = [(pos(292), pos(517)), (pos(442), pos(667)), (pos(732), pos(357))]
    width = 110 * scale * s
    draw.line(points, fill=DARK, width=round(width), joint='curve')
    # Bouts arrondis
    for x, y in (points[0], points[-1]):
        draw.ellipse([x - width / 2, y - width / 2, x + width / 2, y + width / 2], fill=DARK)

    return img.resize((SIZE, SIZE), Image.LANCZOS)


if __name__ == '__main__':
    draw_check(FULL_ICON_SCALE, background=ORANGE).convert('RGB').save('assets/icon/icon.png')
    draw_check(FOREGROUND_SCALE).save('assets/icon/icon_foreground.png')
    print('Icônes créées avec succès!')
