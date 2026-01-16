# Sprite Assets

This directory contains all sprite assets for the game.

## Directory Structure

```
sprites/
├── player/           # Horse and rider sprites
│   ├── horse_run_*.png
│   └── horse_idle.png
├── obstacles/        # Obstacle sprites
│   ├── cactus.png
│   ├── rock.png
│   ├── tumbleweed.png
│   └── bandit.png
└── collectibles/     # Item sprites
    └── letter.png
```

## Sprite Requirements

### Player Sprites
- **horse_run_1.png** to **horse_run_8.png**: Running animation frames
- Size: 64x64 pixels
- Format: PNG with transparency
- Style: Pixel art or cartoon

### Obstacle Sprites
- **cactus.png**: 40x80 pixels
- **rock.png**: 60x50 pixels
- **tumbleweed.png**: 50x50 pixels
- **bandit.png**: 45x70 pixels
- All with transparency

### Collectible Sprites
- **letter.png**: 40x30 pixels (envelope)

## Free Asset Resources

1. **Kenney.nl** - https://kenney.nl/assets
   - Search for "Western" or "Horse"
   - CC0 License (free to use)

2. **OpenGameArt.org** - https://opengameart.org/
   - Search for specific items
   - Check licenses

3. **Create Your Own**
   - Use Piskel: https://www.piskelapp.com/
   - Use Aseprite: https://www.aseprite.org/

## Notes

- Currently, the game uses placeholder colored rectangles
- Replace with actual sprites when ready
- Keep consistent art style across all assets
- Export at appropriate sizes for web (not too large)

