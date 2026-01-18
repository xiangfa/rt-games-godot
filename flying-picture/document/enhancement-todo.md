# Flying Picture (Sky Words) Game Enhancement TODO

> A Chinese learning game enhancement plan to make it more fun, attractive to kids, and educationally effective.

## Current Features Summary

**Game Concept**: "Sky Words" - 6 helicopters carry a screen showing an image, player matches image to correct Chinese word from 4 options.

### Existing Mechanics:
- **Helicopter Formation**: 6 helicopters (2 anchors + 4 crashable) with propeller animation & hover bob
- **Quiz System**: 4-option multiple choice, image displayed on carried screen
- **Progress Tracker**: 16 wind-spinners in circular layout (green → colorful on success)
- **Win/Lose**: 16 correct = WIN, 6 crashes = GAME OVER
- **Survival Mode**: When 1 anchor left, screen tilts and swings dramatically
- **Effects**: Smoke on crash, fireworks on victory, celebration animations
- **API Integration**: Fetches words from dictionary with images

---

## 🎨 Visual & Engagement

| Priority | Feature | Description |
|----------|---------|-------------|
| High | **Character Expressions** | Helicopters show happy/worried/sad faces based on performance |
| High | **Improved Helicopter Design** | Larger, friendlier cartoon helicopters with unique colors |
| High | **Better Button Styling** | More colorful, child-friendly answer buttons with hover effects |
| Medium | **Dynamic Weather** | Clouds moving, sun/rain based on progress |
| Medium | **Screen Frame Decor** | Add movie projector lights, "cinema" style frame |
| Medium | **Parallax Background** | Multi-layer sky with animated clouds |
| Low | **Night Mode** | Stars/moon theme after certain hours |

---

## 🎮 Gameplay Enhancements

| Priority | Feature | Description |
|----------|---------|-------------|
| High | **Difficulty Levels** | Easy (2 options), Medium (4 options), Hard (6 options) |
| High | **Hint System** | Show first character of pinyin or flash correct answer briefly |
| High | **Lifeline/Power-ups** | "Repair" a crashed helicopter, "50/50" remove 2 wrong answers |
| Medium | **Combo Streak** | Bonus for consecutive correct answers (streak counter) |
| Medium | **Speed Challenge** | Faster flying = more points, but harder timing |
| Medium | **Boss Rounds** | Every 4 rounds, a "hard" word with larger reward |
| Low | **Formation Variations** | V-shape, diamond, or stacked helicopter formations |
| Low | **Rescue Missions** | Bonus mini-games between rounds |

---

## 📚 Educational Effectiveness

| Priority | Feature | Description |
|----------|---------|-------------|
| **Critical** | **Show Pinyin** | Display pinyin above/below each Chinese word option |
| **Critical** | **Word Pronunciation** | Play audio when option is shown AND when correct answer selected |
| **Critical** | **Image-Word Association** | Brief "learning moment" showing word + image together on success |
| High | **Review Screen** | Post-game summary of all words with replay pronunciation |
| High | **Wrong Answer Learning** | On mistake, show correct answer with image + audio before flying off |
| High | **Spaced Repetition** | Track missed words, include them more often in future games |
| High | **Word Categories** | Group words by theme (animals, food, colors, body parts) |
| Medium | **Sentence Context** | Show simple sentence using the word |
| Medium | **Stroke Animation** | Brief character writing animation on correct answer |

---

## 👶 Kid-Friendly UX

| Priority | Feature | Description |
|----------|---------|-------------|
| High | **Bigger Buttons** | Increase touch target size for smaller fingers |
| High | **Tutorial/Onboarding** | Animated intro explaining how to play |
| High | **Positive Reinforcement** | More celebration, less punishment visuals |
| High | **Practice Mode** | No fail state, just learning (infinite helicopters) |
| Medium | **Progress Save** | Remember completed words across sessions |
| Medium | **Encouragement Messages** | "Great job!", "Keep trying!" voice/text |
| Medium | **Adjustable Speed** | Let parent/teacher control helicopter speed |
| Low | **Accessibility** | Color-blind friendly spinner colors, larger text options |

---

## 🔊 Audio & Music

| Priority | Feature | Description |
|----------|---------|-------------|
| High | **Background Music** | Cheerful, loopable adventure/flying theme music |
| High | **Word Audio** | Native pronunciation for every Chinese word |
| High | **Helicopter Sounds** | Soft propeller whirring ambience |
| Medium | **Success Jingles** | Varied celebration sounds for streaks |
| Medium | **Crash Sound** | Comical (not scary) crash/bonk sound |
| Medium | **Final Answer Audio** | Chinese voice saying the correct word when selected |

---

## 🎯 Game Balance Improvements

| Priority | Feature | Description |
|----------|---------|-------------|
| High | **More Helicopters (7-8)** | Allow more mistakes before game over |
| High | **Configurable Rounds** | Choose 8, 12, or 16 spinners per game |
| Medium | **Adaptive Difficulty** | Increase challenge based on player performance |
| Medium | **Score Multiplier** | Higher scores for answering quickly |
| Low | **Leaderboard** | Local high score tracking |

---

## Recommended Implementation Phases

### Phase 1 - Core Learning (Highest Impact)
- [ ] Add pinyin display to answer buttons
- [ ] Integrate word pronunciation audio (on show + on correct)
- [ ] "Learning moment" on correct answer (show word + image + audio)
- [ ] Post-game review screen with all words

### Phase 2 - Engagement & Polish
- [ ] Background music
- [ ] Improved button styling
- [ ] Tutorial mode
- [ ] Difficulty levels (Easy/Medium/Hard)

### Phase 3 - Advanced Features
- [ ] Hint/power-up system
- [ ] Spaced repetition for missed words
- [ ] Practice mode (no fail state)
- [ ] Combo/streak rewards

---

## Technical Notes

- Current API: `https://rtstgapi.../api/dictionary`
- Word data: `{ word, image.url, id }`
- Consider adding `pinyin`, `audio_url` fields to API
- Audio fallback: Integrate browser TTS or pre-recorded Chinese audio
- Current pool: Downloads up to 50 words from dictionary API
