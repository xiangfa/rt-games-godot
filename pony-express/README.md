# Pony Express Runner 🐴📬

A web-based endless runner game built with Godot Engine, inspired by the Google Doodle Pony Express game.

## 🎮 Game Overview

Ride across the Old West as a Pony Express mail carrier! Collect letters, avoid obstacles, and deliver the mail across changing terrain. How far can you go?

## 🚀 Features

- **Endless Runner Gameplay**: Auto-scrolling side-view with lane-based movement
- **Dynamic Obstacles**: Cacti, rocks, bandits, and more!
- **Letter Collection**: Gather mail for points
- **Station Checkpoints**: Change horses at relay stations
- **Progressive Difficulty**: Speed increases as you travel farther
- **Web-Ready**: Optimized for HTML5 export

## 🎯 How to Play

### Controls
- **Arrow Keys / W-S**: Move between lanes (up/down)
- **Space**: Jump (future feature)
- **ESC**: Pause game
- **Touch Controls**: Swipe up/down (mobile)

### Objective
- Collect as many letters as possible
- Avoid obstacles to keep your horse healthy
- Reach stations to change horses
- Beat your high score!

## 🛠️ Development

### Prerequisites
- Godot Engine 4.2+ ([Download](https://godotengine.org/download))
- Basic knowledge of GDScript (Python-like syntax)

### Project Structure

```
pony-express/
├── assets/                    # Game assets
│   ├── sprites/              # Character and object sprites
│   │   ├── player/          # Horse and rider animations
│   │   ├── obstacles/       # Obstacle sprites
│   │   └── collectibles/    # Letters and power-ups
│   ├── backgrounds/          # Environment backgrounds
│   ├── audio/               # Sound effects and music
│   │   ├── sfx/            # Sound effects
│   │   └── music/          # Background music
│   └── ui/                  # UI elements and icons
├── scenes/                   # Godot scene files
│   ├── Main.tscn           # Main game scene
│   ├── MainMenu.tscn       # Start menu
│   ├── Player.tscn         # Player scene
│   ├── World.tscn          # Game world
│   ├── obstacles/          # Obstacle scenes
│   ├── collectibles/       # Collectible scenes
│   └── ui/                 # UI scenes
├── scripts/                  # GDScript files
│   ├── autoload/           # Singleton/autoload scripts
│   │   ├── GameManager.gd  # Game state management
│   │   ├── ScoreManager.gd # Scoring system
│   │   └── AudioManager.gd # Audio controller
│   ├── player.gd           # Player movement
│   ├── obstacle_spawner.gd # Obstacle generation
│   ├── parallax_bg.gd      # Background scrolling
│   └── ui_manager.gd       # UI updates
├── exports/                  # Build output directory
├── project.godot            # Godot project file
└── README.md               # This file
```

### Getting Started

1. **Clone/Open Project**
   ```bash
   cd rt-game-godot/pony-express
   ```

2. **Open in Godot**
   - Launch Godot Engine
   - Click "Import"
   - Navigate to the `pony-express` folder
   - Select `project.godot`

3. **Run the Game**
   - Press F5 or click the Play button in Godot
   - Use arrow keys to move up/down

### Exporting for Web

1. In Godot, go to: **Project → Export**
2. Add "HTML5" export template
3. Configure settings:
   - Export Path: `exports/web/index.html`
   - Export Mode: "Release"
4. Click "Export Project"
5. Upload `exports/web/` folder to your web host

## 📋 Development Roadmap

- [x] Phase 1: Game Design Document
- [x] Phase 2: Project Structure Setup
- [ ] Phase 3: Core Gameplay Implementation
  - [ ] Player movement system
  - [ ] Background scrolling
  - [ ] Obstacle spawning
  - [ ] Collision detection
- [ ] Phase 4: Game Systems
  - [ ] Letter collection
  - [ ] Scoring system
  - [ ] Station checkpoints
  - [ ] Difficulty progression
- [ ] Phase 5: UI & Polish
  - [ ] Main menu
  - [ ] HUD (score, letters, distance)
  - [ ] Game over screen
  - [ ] Sound and music
- [ ] Phase 6: Testing & Deployment
  - [ ] Playtesting and balancing
  - [ ] HTML5 export
  - [ ] Performance optimization

## 🎨 Asset Credits

(Add your asset sources and credits here)

- Sprites: [Placeholder - to be created]
- Music: [Placeholder - to be added]
- Sound Effects: [Placeholder - to be added]

## 📚 Learning Resources

### Godot Documentation
- [Godot 4 Docs](https://docs.godotengine.org/en/stable/)
- [GDScript Basics](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)
- [2D Movement Tutorial](https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html)

### Game Development Tutorials
- [Godot Endless Runner Tutorial](https://www.youtube.com/results?search_query=godot+endless+runner)
- [Side-scrolling Games](https://docs.godotengine.org/en/stable/tutorials/2d/index.html)

## 🤝 Contributing

This is a learning project! Feel free to:
- Experiment with the code
- Add new features
- Improve the game design
- Create better art assets

## 📝 License

Educational/Personal Use

---

**Version:** 0.1.0-alpha  
**Engine:** Godot 4.2+  
**Last Updated:** January 15, 2026

Happy coding! 🚀

