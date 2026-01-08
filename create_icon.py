from PIL import Image, ImageDraw

# Créer une image avec fond noir et un cercle or (comme icône todo)
size = 1024
img = Image.new('RGB', (size, size), color=(26, 26, 26))
draw = ImageDraw.Draw(img)

# Dessiner un cercle or avec une checkbox
margin = 100
draw.ellipse([(margin, margin), (size-margin, size-margin)], fill=(255, 184, 0), outline=(255, 184, 0))

# Dessiner une checkmark blanche
line_width = 50
# Ligne diagonale descendante
draw.line([(300, 450), (450, 600)], fill=(26, 26, 26), width=line_width)
# Ligne diagonale montante
draw.line([(450, 600), (750, 300)], fill=(26, 26, 26), width=line_width)

img.save('assets/icon/icon.png')
print('Icône créée avec succès!')
