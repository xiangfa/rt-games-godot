# Game Design Document: Sky Words (The Helicopter Challenge)

**Target Audience:** Children (Ages 4–10)  
**Genre:** Educational / Arcade  
**Engine:** Godot 4.x  
**Language:** GDScript  

---

## 1. Game Overview
"Sky Words" is a 2D side-scrolling vocabulary game where a team of six animated helicopters works together to carry a massive movie screen. The screen displays an image, and the player must match it to the correct Chinese character/word.

### Core Loop
1.  **The Approach:** The helicopter team flies in from the left, carrying a screen with an image (e.g., an Apple).
2.  **The Quiz:** 4 Chinese words appear at the bottom of the hanging screen.
3.  **The Loop:** If the player does nothing, the team flies off the right side of the screen and circles back around (re-entering from the left) with the *same* question.
4.  **Feedback:**
    * **Correct:** "Happy" animation (Fireworks), the team flies away, and a "Wind-Spinner" in the UI lights up. A new round starts.
    * **Incorrect:** One helicopter crashes! The team struggles but keeps flying.
5.  **Goal:** Light up all 16 Wind-Spinners to win.

---

## 2. Gameplay Mechanics

### The Helicopter Team
* **Formation:** 6 Helicopters in a horizontal line (`H1 - H2 - H3 - H4 - H5 - H6`).
* **The "Immortal" Anchors:** `H1` (Far Left) and `H6` (Far Right) **cannot crash**. They are required to keep the screen attached to the formation.
* **The Crashable Middle:** Only `H2`, `H3`, `H4`, and `H5` can be destroyed.
* **Movement:** Continuous movement `Left -> Right`. Position wraps around when off-screen.

### Win & Loss Conditions
* **Win Condition:** The player successfully answers **16 questions**.
    * *Visual Reward:* All 16 Wind-Spinners in the UI circle turn from Green to Colorful.
* **Loss Condition:** The player makes **4 mistakes**.
    * *Logic:* Since there are only 4 crashable helicopters, the 4th mistake destroys the last supporting middle helicopter, causing the screen to fall. Game Over.

### UI: The Wind-Spinner Tracker
* **Layout:** 16 Wind-Spinners arranged in a circle on the HUD.
* **State A (Pending):** Green color, slow rotation.
* **State B (Success):** Multi-colored/Rainbow, fast rotation.

---

## 3. Asset Requirements

### A. Visual Assets (2D Sprites)
* **Helicopter:**
    * *Style:* Cartoon/Chibi style, friendly eyes, bright colors (Blue or Red).
    * *Parts:* Body (static), Propeller (separate sprite for spinning animation).
* **The Screen:**
    * A large white projection canvas with a frame.
    * Ropes/Cables textures (to visually connect helicopters to the screen).
* **Wind-Spinner (Pinwheel):**
    * *Texture 1:* Desaturated Green (Locked).
    * *Texture 2:* Rainbow/Bright Colors (Unlocked).
* **Background:**
    * Parallax layers: Clouds (Front), Sky (Back), maybe distant mountains.
* **VFX:**
    * *Crash:* Cartoon smoke puff (grey/black), maybe a "Band-Aid" icon.
    * *Success:* Confetti or Firework particles.

### B. Audio
* **BGM:** Upbeat, looping "Kindergarten" style track.
* **Ambience:** Soft propeller whirring (pitch-shifted randomly to sound organic).
* **SFX:**
    * *Correct:* Chime + "Yay!" sound.
    * *Wrong:* Comical "Boing" or "Clunk" sound + mechanical fail noise.
    * *Crash:* Slide whistle down or cartoon impact.
    * *Voice:* (Optional) Reading the Chinese word aloud when clicked.

---

## 4. Technical Architecture (Godot)

### Scene Structure

#### 1. `MainGame.tscn` (Node2D)
The root scene where gameplay happens.
* `BackgroundLayer` (ParallaxBackground)
    * `SkySprite` (ParallaxLayer)
* `HelicopterFormation` (Node2D - *The moving container*)
    * `Helicopter_1` (Instance of `Helicopter.tscn`)
    * ...
    * `Helicopter_6` (Instance of `Helicopter.tscn`)
    * `ScreenApparatus` (Node2D)
        * `CanvasSprite` (Sprite2D)
        * `QuestionImage` (TextureRect)
        * `AnswerButtons` (HBoxContainer) -> Contains 4 Buttons
* `HUD` (CanvasLayer)
    * `SpinnerContainer` (Control/Node2D) -> Holds 16 Spinner instances.
    * `GameOverPopup` (Control)

#### 2. `Helicopter.tscn` (Node2D)
* `Body` (Sprite2D)
* `Propeller` (Sprite2D) -> *AnimationPlayer* rotates this 360 degrees loop.
* `SmokeParticles` (GPUParticles2D) -> Emitting = False by default.

---

## 5. Implementation Logic (GDScript)

### A. Data Structure (JSON)
We will load questions from a JSON file.

```json
[
  {
    "id": 1,
    "image_path": "res://assets/images/apple.png",
    "correct_word": "苹果",
    "options": ["苹果", "香蕉", "大象", "汽车"]
  },
  { ... }
]
