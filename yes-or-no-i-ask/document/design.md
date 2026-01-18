# Godot Game Design & Development Description  
## Yes-or-No Mystery Word Guessing Game

---

## 1. Overview

This game is a **data-driven yes-or-no guessing game** built with **Godot**.  
The core mechanic is simple: the **NPC guesses a word the player is thinking of** by asking a sequence of **yes/no questions**, progressively eliminating words until only one remains.

The game is designed for **children aged 4–12**, with a strong focus on:
- clarity
- visual feedback
- fun and mystery
- scalability through data (JSON)

---

## 2. Core Design Principles

- **Data-driven logic**  
  All questions, word splits, and decision paths come from JSON files.  
  No guessing logic is hardcoded in the game loop.

- **Deterministic state transitions**  
  At any moment, the game state is fully defined by:
  - the current subset of remaining words

- **Scalable difficulty**
  - 4 words (2×2 grid)
  - 9 words (3×3 grid)
  - 16 words (4×4 grid)

- **Child-friendly UX**
  - Large buttons
  - Clear visuals
  - Immediate feedback

---

## 3. Game Flow (Logic Layer)

### 3.1 Initial State
- Load a word group from JSON
- Display all words in a square grid
- Player silently chooses one word in their mind
- Game sets `remaining_words = all words`

---

### 3.2 Question Loop

1. Generate a **canonical subset ID** from `remaining_words`
   - Normalize words
   - Sort by **Pinyin**
   - Join into a canonical string
   - Hash if needed for fast lookup

2. Look up the matching state in the JSON data.

3. If the state contains:
   - `answer` → end the round
   - `question` → continue

4. Display the question on screen.

5. Player clicks **Yes** or **No**.

6. Based on the answer:
   - Update `remaining_words`
     - Yes → `yes_remaining_words`
     - No  → `no_remaining_words`
   - Visually cross out eliminated words.

7. Repeat until only one word remains.

---

### 3.3 End State

- When `remaining_words.length == 1`:
  - NPC announces the guessed word
  - Show success feedback
  - Option to restart or change difficulty

---

## 4. Data Structure (JSON-Driven)

Each word group contains:
- `group_id` (number)
- `group_size` (number)
- `words` (list of strings)
- `states` (list of records)

Each state record includes:
- `remaining_words`
- `question` (optional)
- `yes_remaining_words`
- `no_remaining_words`
- `answer` (only if remaining_words size == 1)

The game engine does **not rely on explicit state labels**.  
Instead, it uses the **remaining_words subset** as the state identity.

---

## 5. Godot Scene Structure

### 5.1 Main Scene
- Root: `Control`
- Children:
  - WordGrid (GridContainer)
  - QuestionPanel (Label)
  - AnswerButtons (Yes / No)
  - HistoryPanel (optional)
  - NPC Panel (optional)

---

### 5.2 Word Grid
- Uses `GridContainer`
- Grid size determined by difficulty level
- Each word is a reusable `WordTile` scene:
  - Label
  - Cross-out animation / fade
  - Active / eliminated states

---

### 5.3 UI Components
- **Question Display**
  - Large, centered text
- **Yes / No Buttons**
  - Touch-friendly
  - Keyboard support optional
- **History Panel (Optional)**
  - Previous questions
  - Player answers
  - Eliminated words

---

## 6. NPC Behavior

- NPC acts as a **friendly detective**
- NPC responsibilities:
  - Ask questions
  - React to Yes / No
  - Celebrate correct guesses
- NPC text can be:
  - Static (initial version)
  - Data-driven (future expansion)

---

## 7. Visual & UX Design

- Bright, playful colors
- Clear contrast between:
  - active words
  - eliminated words
- Smooth animations:
  - word elimination
  - question transitions
- Mystery / detective theme to encourage curiosity

---

## 8. Input & Controls

### Initial Version
- Mouse / touch input:
  - Click **Yes**
  - Click **No**

### Future Extensions
- Keyboard shortcuts
- Voice input
- Accessibility options

---

## 9. Scalability & Extensibility

This design supports:
- Larger word sets (9, 16, or more)
- Multiple themes (animals, food, objects, concepts)
- Localization (multi-language)
- AI-generated question sets
- Procedural content generation

Because the game logic is **fully data-driven**, new content can be added **without changing code**.

---

## 10. Summary

This Godot-based guessing game uses a **clean state-driven architecture** where:
- gameplay logic is separated from content
- difficulty scales naturally
- children learn through interaction and deduction
- the system remains flexible, maintainable, and expandable

The result is a **simple-to-play but well-structured educational game** suitable for both standalone use and integration into a larger learning platform.
