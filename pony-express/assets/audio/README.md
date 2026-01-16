# Audio Assets

This directory contains all audio files for the game.

## Directory Structure

```
audio/
├── sfx/              # Sound effects
│   ├── gallop.wav
│   ├── letter_collect.wav
│   ├── collision.wav
│   ├── station_bell.wav
│   └── game_over.wav
└── music/            # Background music
    ├── menu_theme.ogg
    └── gameplay_theme.ogg
```

## Audio Requirements

### Sound Effects (sfx/)

1. **gallop.wav**
   - Horse galloping sound
   - Looping capability
   - Duration: 1-2 seconds
   - Format: WAV (uncompressed)

2. **letter_collect.wav**
   - Pleasant "ding" or chime
   - Short (< 0.5 seconds)
   - Not too loud

3. **collision.wav**
   - Impact/thud sound
   - Short (< 0.5 seconds)

4. **station_bell.wav**
   - Bell or checkpoint sound
   - Duration: 1-2 seconds

5. **game_over.wav**
   - Sad/descending sound
   - Duration: 1-2 seconds

### Music (music/)

1. **menu_theme.ogg**
   - Upbeat Western-themed music
   - Looping
   - Format: OGG Vorbis (compressed)
   - Duration: 30-60 seconds loop

2. **gameplay_theme.ogg**
   - Energetic, builds tension
   - Looping
   - Can increase tempo over time
   - Duration: 60-120 seconds loop

## Free Audio Resources

### Sound Effects
1. **Freesound.org** - https://freesound.org/
   - Search: "horse gallop", "bell", "ding"
   - Free with attribution

2. **Mixkit** - https://mixkit.co/free-sound-effects/
   - No attribution required
   - High quality

3. **Zapsplat** - https://www.zapsplat.com/
   - Free with attribution
   - Professional quality

### Music
1. **Incompetech** - https://incompetech.com/music/
   - Kevin MacLeod music library
   - Search "Western" genre
   - Free with attribution

2. **Purple Planet Music** - https://www.purple-planet.com/
   - Free music for projects
   - Western category available

3. **OpenGameArt** - https://opengameart.org/
   - Community music contributions
   - Various licenses

## Audio Editing

**Audacity** (Free) - https://www.audacityteam.org/
- Trim, adjust volume
- Convert formats (WAV ↔ OGG)
- Add fade in/out

## Format Guidelines

- **Sound Effects**: Use WAV (16-bit, 44.1kHz) for quality
- **Music**: Use OGG Vorbis for compression
- Keep file sizes reasonable for web (<1MB per file ideally)

## Attribution Template

If using music that requires attribution, add to game credits:

```
Music by Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 3.0
http://creativecommons.org/licenses/by/3.0/

Sound Effects from Freesound.org:
- [Sound name] by [Username]
```

## Notes

- Currently, AudioManager is set up but no actual audio files loaded
- Game will work without audio (silent)
- Add audio files here and update AudioManager.gd load paths

