# Pony Express - Game Design Document

## 1. Game Overview

**Title:** Pony Express Runner  
**Genre:** Endless Runner / Side-scrolling Arcade  
**Platform:** Web (HTML5), Desktop  
**Engine:** Godot 4.x  
**Target Audience:** Casual gamers, all ages  
**Inspiration:** Google Doodle Pony Express Game (2015)

## 2. Game Concept

Players control a Pony Express rider galloping across the Old West, collecting mail letters while avoiding obstacles. The game features automatic forward movement with vertical lane-switching to dodge hazards and collect items.

### Core Loop
1. Ride horse forward (auto-scroll)
2. Move up/down between lanes to avoid obstacles
3. Collect letters for points
4. Reach stations to change horses
5. Game ends when hitting too many obstacles

## 3. Game Mechanics

### 3.1 Player Controls
- **Arrow Keys (Up/Down)** or **W/S**: Switch between lanes
- **Space**: Jump (optional enhancement)
- **Touch Controls**: Swipe up/down for mobile

### 3.2 Movement System
- **Auto-scroll**: Constant forward movement
- **3 Lanes**: Top, Middle, Bottom
- **Speed**: Gradually increases over time/distance
- **Lane Switching**: Quick transition between lanes

### 3.3 Obstacles
Different obstacle types require different strategies:

1. **Cacti** - Ground level, middle lane
2. **Rocks** - Various lanes, static
3. **Bandits** - Moving obstacles that chase
4. **Rivers** - Must jump or avoid
5. **Low-hanging branches** - Upper lane hazards
6. **Tumbleweeds** - Rolling obstacles

### 3.4 Collectibles
- **Letters**: Primary collectible (+10 points each)
- **Power-ups** (Future enhancement):
  - Speed Boost
  - Invincibility Shield
  - Magnet (auto-collect letters)

### 3.5 Station System
- Appear every 500-1000 meters
- Automatic horse change (visual feedback)
- Checkpoint/continue point
- Brief invincibility during transition

### 3.6 Scoring System
- Letters collected: 10 points each
- Distance traveled: 1 point per 10 meters
- Station reached: 100 bonus points
- Combo multiplier for consecutive collections

### 3.7 Difficulty Progression
- Speed increases every 30 seconds
- Obstacle density increases
- More complex obstacle patterns
- Faster enemy bandits

## 4. Visual Design

### 4.1 Art Style
- Retro pixel art or cartoon style
- Warm color palette (browns, yellows, oranges)
- Western/frontier theme
- Parallax scrolling backgrounds

### 4.2 Environments
1. **Desert Plains** (Start) - Cacti, sand dunes
2. **Rocky Canyon** - Stone formations, cliffs
3. **Forest Trail** - Trees, logs
4. **Snow Pass** - White landscape, ice

### 4.3 Character Design
- Rider: Classic Pony Express uniform (red/blue)
- Horse: Multiple color variants per station
- Smooth run animation cycle

## 5. Audio Design

### 5.1 Sound Effects
- Horse gallop (looping)
- Letter collection (ding)
- Collision impact (thud)
- Station bell (checkpoint)
- UI clicks and transitions

### 5.2 Music
- Upbeat Western-themed background music
- Intensity increases with speed
- Victory/Game Over stingers

## 6. User Interface

### 6.1 Main Menu
- Title logo
- Play button
- High score display
- Settings (audio, controls)
- Credits

### 6.2 HUD (In-Game)
- **Top Left**: Letters collected / Target
- **Top Right**: Distance traveled
- **Top Center**: Current score
- **Bottom**: Mini-map or station progress bar

### 6.3 Game Over Screen
- Final score
- Letters collected
- Distance reached
- Retry button
- Main menu button

## 7. Technical Specifications

### 7.1 Godot Scenes Structure
```
Main.tscn (Root game scene)
├── Player.tscn (Horse + Rider)
├── World.tscn (Background, lanes)
├── ObstacleSpawner.tscn
├── UIManager.tscn
└── AudioManager.tscn
```

### 7.2 Key Scripts
- `game_manager.gd`: Core game loop, state management
- `player.gd`: Player movement, collision
- `obstacle_spawner.gd`: Procedural obstacle generation
- `parallax_background.gd`: Scrolling background
- `ui_manager.gd`: HUD updates
- `save_manager.gd`: High score persistence

### 7.3 Performance Targets
- **60 FPS** minimum
- **< 50MB** total game size
- **Fast loading** (< 3 seconds)

## 8. Development Phases

### Phase 1: Core Gameplay (Week 1-2)
- [ ] Player movement and lane switching
- [ ] Background scrolling
- [ ] Basic obstacle spawning
- [ ] Collision detection

### Phase 2: Game Systems (Week 2-3)
- [ ] Letter collection
- [ ] Scoring system
- [ ] Station checkpoints
- [ ] Difficulty progression

### Phase 3: Polish & UI (Week 3-4)
- [ ] Main menu and game over screens
- [ ] HUD implementation
- [ ] Sound effects and music
- [ ] Particle effects and animations

### Phase 4: Testing & Export (Week 4-5)
- [ ] Gameplay balancing
- [ ] Bug fixes
- [ ] HTML5 export optimization
- [ ] Cross-browser testing

## 9. Future Enhancements

### Post-Launch Features
1. **Leaderboards**: Online high score tracking
2. **Daily Challenges**: Special obstacle courses
3. **Multiple Characters**: Unlock different riders
4. **Power-up System**: Strategic gameplay elements
5. **Story Mode**: Structured levels with objectives
6. **Multiplayer**: Race against other players

## 10. Success Metrics

- **Engagement**: Average play session > 5 minutes
- **Replayability**: 70% of players retry after game over
- **Performance**: 60 FPS on mid-range devices
- **Accessibility**: Touch and keyboard controls work smoothly

---

## Reference Materials

### Inspiration
- Google Doodle Pony Express (April 14, 2015)
- Chrome Dino Game (T-Rex Runner)
- Jetpack Joyride
- Flappy Bird

### Historical Context
The Pony Express was a mail service running from 1860-1861, delivering messages across the American frontier. Riders would change horses at stations approximately every 10-15 miles.

---

**Document Version:** 1.0  
**Last Updated:** January 15, 2026  
**Author:** Game Development Team

