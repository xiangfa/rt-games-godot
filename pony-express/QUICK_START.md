# Quick Start Guide - Pony Express Runner

Get the game running in 5 minutes!

## 🚀 Step 1: Install Godot

1. Go to [godotengine.org/download](https://godotengine.org/download)
2. Download **Godot 4.2** or later (Standard version)
3. Extract/install to your computer

## 📂 Step 2: Open the Project

1. Launch Godot Engine
2. Click **"Import"** button
3. Click **"Browse"** and navigate to:
   ```
   /Users/xiangfa/Dev/readtopia-playground-phase3/rt-game-godot/pony-express
   ```
4. Select the `project.godot` file
5. Click **"Import & Edit"**

## ▶️ Step 3: Run the Game

1. Press **F5** or click the **Play** button (▶️) in the top-right corner
2. If prompted, select `scenes/Main.tscn` as the main scene
3. The game should start!

## 🎮 Step 4: Play!

- **Main Menu** appears first
- Click **"PLAY"** to start
- Use **Arrow Keys** (↑↓) or **W/S** to switch lanes
- Collect letters (yellow squares)
- Avoid obstacles (colored rectangles)
- Press **ESC** to pause

## 📝 What You'll See

Currently, the game uses **placeholder graphics** (colored rectangles):
- **Brown square** = Player (horse + rider)
- **Green** = Cactus obstacle
- **Gray** = Rock obstacle
- **Tan** = Tumbleweed
- **Red** = Bandit
- **Yellow** = Letter (collectible)

The gameplay works, but visuals are basic!

## 🎨 Next Steps (Optional)

### To Add Custom Graphics:

1. Place sprite images in `assets/sprites/` folders
2. Open relevant script (e.g., `player.gd`)
3. Replace placeholder code with sprite loading
4. See `DEVELOPMENT_GUIDE.md` for detailed instructions

### To Add Sound:

1. Place audio files in `assets/audio/` folders
2. Open `scripts/autoload/AudioManager.gd`
3. Uncomment and update the `load()` paths
4. See `assets/audio/README.md` for audio requirements

## 🔧 Project Configuration

The game is pre-configured with:
- ✅ Input mapping (WASD + Arrow keys)
- ✅ GameManager (scoring, game states)
- ✅ Player movement (3 lanes)
- ✅ Obstacle spawning
- ✅ Collectible system
- ✅ UI (menus, HUD, game over)
- ✅ Parallax background
- ✅ HTML5 export settings

## 🌐 Export to Web

1. In Godot, go to: **Project → Export**
2. Select **"HTML5"** preset (already configured)
3. Click **"Export Project"**
4. Output will be in `exports/web/`
5. Upload to any web host (itch.io, GitHub Pages, etc.)

## 🐛 Troubleshooting

### Game doesn't start
- **Check**: Is `Main.tscn` set as the main scene?
- **Fix**: Project → Project Settings → Application → Run → Main Scene

### Player doesn't move
- **Check**: Are autoload scripts enabled?
- **Fix**: Project → Project Settings → Autoload
  - Add `GameManager.gd` as "GameManager"
  - Add `AudioManager.gd` as "AudioManager"

### No collisions happening
- **Check**: Collision layers in player and obstacles
- **Fix**: Inspector → CollisionShape2D → Mask/Layer

### Errors in console
- **Most likely**: Missing autoload scripts
- **Fix**: Set up autoloads (see above)

## 📖 Full Documentation

- **Game Design Document**: `GAME_DESIGN_DOCUMENT.md`
- **Development Guide**: `DEVELOPMENT_GUIDE.md`
- **Learning Resources**: `LEARNING_RESOURCES.md`
- **Project README**: `README.md`

## 🎯 Test Checklist

Try these to verify everything works:

- [ ] Game loads without errors
- [ ] Main menu appears
- [ ] Can start game by clicking "PLAY"
- [ ] Player (brown square) appears on left side
- [ ] Player moves up/down with arrow keys or W/S
- [ ] Obstacles (colored shapes) appear from right side
- [ ] Obstacles move left across screen
- [ ] Collectibles (yellow) appear and move
- [ ] Score increases when collecting letters
- [ ] Game ends when hitting obstacle
- [ ] Game Over screen shows final score
- [ ] Can retry or return to menu
- [ ] Pause menu works (press ESC)

## 💡 Tips

1. **Experiment**: Change values in `GameManager.gd` to adjust difficulty
2. **Learn**: Read the script comments to understand how it works
3. **Customize**: Add your own features!
4. **Share**: Export and show your friends!

## 🆘 Getting Help

- **Godot Docs**: [docs.godotengine.org](https://docs.godotengine.org/)
- **Godot Discord**: [discord.gg/godotengine](https://discord.gg/4JBkykG)
- **Reddit**: [r/godot](https://www.reddit.com/r/godot/)

---

**Have fun making games! 🎮🚀**

If you encounter any issues, check the troubleshooting section or consult the full documentation.

