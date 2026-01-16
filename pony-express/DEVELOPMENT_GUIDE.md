# Pony Express - Development Guide

This guide will walk you through the development process and help you understand how to work with the Godot project.

## 📚 Table of Contents

1. [Getting Started](#getting-started)
2. [Project Architecture](#project-architecture)
3. [Game Development Process](#game-development-process)
4. [Key Concepts](#key-concepts)
5. [Implementation Steps](#implementation-steps)
6. [Testing & Debugging](#testing--debugging)
7. [Optimization Tips](#optimization-tips)

## 🚀 Getting Started

### Prerequisites

1. **Install Godot Engine**
   - Download Godot 4.2+ from [godotengine.org](https://godotengine.org/download)
   - Choose the Standard version (not Mono unless you need C#)
   - Install or extract to your preferred location

2. **Open the Project**
   ```bash
   cd rt-game-godot/pony-express
   ```
   - Launch Godot
   - Click "Import"
   - Browse to this directory
   - Select `project.godot`
   - Click "Import & Edit"

### First Run

1. Press **F5** or click the **Play** button (▶️) in the top-right
2. The game will start with a basic main menu
3. Click "PLAY" to start the game
4. Use **Arrow Keys** or **W/S** to move between lanes

## 🏗️ Project Architecture

### Singleton Pattern (Autoload Scripts)

The game uses Godot's Autoload feature for global managers:

```
GameManager.gd  → Game state, scoring, progression
AudioManager.gd → Sound effects and music
```

These are always accessible via `GameManager` or `AudioManager` from any script.

### Scene Structure

```
Main.tscn (Root scene)
├── ParallaxBackground (Scrolling layers)
├── Player (Horse + Rider)
├── ObstacleSpawner (Generates obstacles)
├── CollectibleSpawner (Generates letters)
└── UIManager (All UI elements)
```

### Script Organization

```
scripts/
├── autoload/          # Global singleton scripts
│   ├── GameManager.gd
│   └── AudioManager.gd
├── player.gd          # Player movement & collision
├── obstacle_spawner.gd
├── collectible_spawner.gd
├── parallax_background.gd
└── ui_manager.gd
```

## 🎮 Game Development Process

### Phase 1: Core Mechanics (Current Status)

✅ **Completed:**
- Game design document
- Project structure
- Core scripts (GameManager, Player, Spawners)
- Basic UI system
- Parallax background

🔄 **Next Steps:**
1. Test the game in Godot
2. Add visual assets (sprites)
3. Implement audio
4. Fine-tune gameplay balance

### Phase 2: Visual Assets

**What You'll Need:**

1. **Player Sprites:**
   - Horse (running animation, 4-8 frames)
   - Rider (sitting on horse)
   - Size: ~64x64 pixels

2. **Obstacle Sprites:**
   - Cactus (~40x80px)
   - Rock (~60x50px)
   - Tumbleweed (~50x50px)
   - Bandit (~45x70px)

3. **Collectible Sprites:**
   - Letter/envelope (~40x30px)

4. **Background Layers:**
   - Sky (1280x720)
   - Mountains (1280x300)
   - Hills (1280x400)
   - Ground (1280x200)

**Where to Get Assets:**

- Create your own using [Aseprite](https://www.aseprite.org/) or [Piskel](https://www.piskelapp.com/)
- Use free assets from [OpenGameArt.org](https://opengameart.org/)
- Use [Kenney.nl](https://kenney.nl/) asset packs (free)

### Phase 3: Audio

**Sound Effects Needed:**
- Horse gallop (looping)
- Letter collection (short ding)
- Collision impact
- Station bell/checkpoint

**Music:**
- Upbeat Western theme (looping)

**Free Audio Resources:**
- [Freesound.org](https://freesound.org/)
- [OpenGameArt.org](https://opengameart.org/)
- [Incompetech](https://incompetech.com/) (Kevin MacLeod)

## 🔑 Key Concepts

### 1. Signals (Event System)

Godot uses signals for communication between nodes:

```gdscript
# Define signal
signal letter_collected

# Emit signal
letter_collected.emit()

# Connect to signal
player.letter_collected.connect(_on_letter_collected)
```

**Why?** Decouples code, making it modular and maintainable.

### 2. Autoload Singletons

Scripts that are always loaded and globally accessible:

```gdscript
# Access from anywhere
GameManager.add_score(10)
AudioManager.play_sfx("gallop")
```

### 3. Node Tree & Scenes

Everything in Godot is a node in a tree:
- Parent nodes can access children
- Signals flow up and down the tree
- Scenes can be instanced (reused)

### 4. Delta Time

Use `delta` for frame-independent movement:

```gdscript
func _process(delta: float) -> void:
    position.x += speed * delta  # Moves at consistent speed regardless of FPS
```

## 📝 Implementation Steps

### Step 1: Replace Placeholder Graphics

1. Open `player.gd`
2. Find `create_placeholder_sprite()` function
3. Replace with your sprite:
   ```gdscript
   func setup_sprite() -> void:
       sprite = $Sprite2D
       sprite.texture = load("res://assets/sprites/player/horse_run.png")
   ```

### Step 2: Add Animation

1. In Godot editor, select the Player node
2. Add an `AnimationPlayer` child node
3. Create animations:
   - "run" (default running)
   - "switch_lane" (moving up/down)
4. The player script will automatically use them

### Step 3: Add Sound Effects

1. Place audio files in `assets/audio/sfx/`
2. Open `AudioManager.gd`
3. Load your sounds:
   ```gdscript
   func load_audio_resources() -> void:
       sfx_gallop = load("res://assets/audio/sfx/gallop.wav")
       sfx_letter_collect = load("res://assets/audio/sfx/ding.wav")
       # ... etc
   ```

### Step 4: Fine-Tune Gameplay

Adjust these constants in `GameManager.gd`:

```gdscript
var base_speed: float = 300.0          # Initial scroll speed
var max_speed: float = 800.0           # Maximum speed
var speed_increase_rate: float = 0.05  # How fast it accelerates
var obstacle_spawn_rate: float = 1.5   # Seconds between obstacles
```

Test and adjust until it feels right!

### Step 5: Create Obstacle Scenes

Instead of generating obstacles programmatically, create proper scenes:

1. In Godot: Scene → New Scene
2. Add Area2D as root
3. Add Sprite2D child (your obstacle image)
4. Add CollisionShape2D
5. Attach script for movement
6. Save as `Obstacle_Cactus.tscn`

Then in `obstacle_spawner.gd`:
```gdscript
var cactus_scene = preload("res://scenes/obstacles/Obstacle_Cactus.tscn")

func spawn_obstacle():
    var obstacle = cactus_scene.instantiate()
    # ... position and add to scene
```

## 🧪 Testing & Debugging

### Debug Tools

1. **Print Debugging:**
   ```gdscript
   print("Player position: ", position)
   ```

2. **Remote Scene Tree:**
   - Run game (F5)
   - Go to Debugger tab
   - View live scene tree and properties

3. **Breakpoints:**
   - Click left of line numbers in script editor
   - Game pauses when that line runs
   - Inspect variables

### Common Issues

**Problem:** Game runs too fast/slow
- **Solution:** Check `Engine.time_scale` and delta usage

**Problem:** Collisions not working
- **Solution:** Verify collision layers and masks in Project Settings

**Problem:** Sprites not showing
- **Solution:** Check Z-index, ensure sprite has texture loaded

## ⚡ Optimization Tips

### For Web Export

1. **Reduce Texture Sizes:**
   - Use power-of-2 dimensions (256, 512, 1024)
   - Compress with VRAM compression

2. **Limit Particles:**
   - Keep particle counts low
   - Reuse particles instead of creating new ones

3. **Object Pooling:**
   - Reuse obstacle instances instead of creating/destroying
   ```gdscript
   var obstacle_pool: Array = []
   
   func get_obstacle():
       if obstacle_pool.size() > 0:
           return obstacle_pool.pop_back()
       else:
           return create_new_obstacle()
   ```

4. **Optimize Draw Calls:**
   - Combine similar sprites into sprite sheets
   - Use CanvasLayer strategically

### Performance Monitoring

Enable FPS display:
- Debug → Visible Collision Shapes (F7)
- Debug → Monitor (check FPS, memory)

## 🎯 Next Learning Resources

### Official Godot Docs
- [Your First 2D Game](https://docs.godotengine.org/en/stable/getting_started/first_2d_game/index.html)
- [Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)

### Video Tutorials
- [Heartbeast - Godot Tutorials](https://www.youtube.com/c/uheartbeast)
- [Brackeys - Game Dev Basics](https://www.youtube.com/user/Brackeys)
- [GDQuest - Godot Courses](https://www.gdquest.com/)

### Game Design
- [Game Maker's Toolkit](https://www.youtube.com/user/McBacon1337) - Design analysis
- [Extra Credits](https://www.youtube.com/extracredits) - Game design concepts

## 🤝 Tips for Learning

1. **Start Small:** Get one feature working before moving to next
2. **Experiment:** Change values, break things, learn by doing
3. **Read Code:** Study the scripts, understand what each line does
4. **Use Documentation:** Godot docs are excellent, use them!
5. **Join Community:** Godot Discord, Reddit r/godot, forums

## 📋 Development Checklist

- [ ] Game runs in Godot editor
- [ ] Player moves smoothly between lanes
- [ ] Obstacles spawn and move correctly
- [ ] Collision detection works
- [ ] Letters can be collected
- [ ] Score increases appropriately
- [ ] Game over triggers correctly
- [ ] UI displays correct information
- [ ] Can restart game
- [ ] High score saves/loads
- [ ] Add custom sprites (replace placeholders)
- [ ] Add sound effects
- [ ] Add background music
- [ ] Add particle effects
- [ ] Test difficulty curve
- [ ] Export to HTML5
- [ ] Test in web browser
- [ ] Optimize performance

---

**Happy Game Development! 🎮🚀**

Remember: Every game developer started as a beginner. Don't be afraid to experiment, make mistakes, and learn from them!

