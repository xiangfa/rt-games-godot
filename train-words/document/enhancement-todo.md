# Train Words Game Enhancement TODO

> A Chinese learning game enhancement plan to make it more fun, attractive to kids, and educationally effective.

## Current Features Summary

- **Core Gameplay**: Balloons with crates (Chinese words) → drop onto matching train cars
- **Matching**: 3 cars (A/B/C) with icons, 6 crates per car to fill
- **Scoring**: +10 per match, win when all cars full
- **Animations**: Train movement, smoke particles, driver, wheel rotation, cargo stacking
- **API Integration**: Fetches words from dictionary with images

---

## 🎨 Visual & Engagement

| Priority | Feature | Description |
|----------|---------|-------------|
| High | **Character/Mascot** | Cute animated mascot (panda/rabbit) that reacts to success/failure |
| High | **Particle Effects** | Star burst/confetti on match, shake on miss |
| High | **Theme Variations** | Seasonal themes (forest, space, underwater) |
| Medium | **Dynamic Backgrounds** | Day/night cycle or weather changes |
| Medium | **Character Customization** | Choose train colors, driver appearance |
| Medium | **Crate Visual Variety** | Different crate colors per word category |

---

## 🎮 Gameplay Enhancements

| Priority | Feature | Description |
|----------|---------|-------------|
| High | **Difficulty Levels** | Easy (3 words), Medium (5 words), Hard (8 words) |
| High | **Audio Pronunciation** | Play word audio when balloon appears AND crate lands |
| High | **Tutorial Mode** | Guided first-play with animated arrows/hints |
| Medium | **Power-ups** | Slow-mo, magnet (auto-attract), hint bubble |
| Medium | **Combo System** | Bonus points for consecutive correct matches |
| Medium | **Timer Challenge** | Race against clock for competitive mode |
| Low | **Obstacle Crates** | Wrong words that should be avoided |

---

## 📚 Educational Effectiveness

| Priority | Feature | Description |
|----------|---------|-------------|
| **Critical** | **Word + Pinyin** | Show pinyin above/below Chinese characters |
| **Critical** | **Image on Crate** | Display word image ON the crate (not just car icon) |
| **Critical** | **Audio Repetition** | Speak word when spawned, matched, and in victory |
| High | **Review Mode** | Post-game screen showing all words with audio replay |
| High | **Spaced Repetition** | Track missed words, show them more frequently |
| High | **Word Categories** | Organize by themes (animals, food, colors, numbers) |
| Medium | **Writing Practice** | Trace character mini-game after level completion |
| Medium | **Sentence Building** | Advanced mode: build simple sentences |

---

## 👶 Kid-Friendly UX

| Priority | Feature | Description |
|----------|---------|-------------|
| High | **Larger Touch Targets** | Make balloons bigger for young children |
| High | **No Fail State** | Endless mode where wrong drops just lose bonus |
| High | **Progress Indicators** | Visual progress bar/stars for each car |
| Medium | **Celebration Animations** | Fireworks, dancing characters on level complete |
| Medium | **Sticker Rewards** | Collect virtual stickers for achievements |
| Low | **Parent Dashboard** | Stats on words learned, time played |

---

## 🔊 Audio & Music

| Priority | Feature | Description |
|----------|---------|-------------|
| High | **Background Music** | Cheerful, loopable train-themed music |
| High | **Word Pronunciation** | Native speaker audio for each word |
| Medium | **Varied Success Sounds** | Multiple "yay!", "great!" voice clips |
| Medium | **Train Sound Effects** | Chugging, whistle when completing a car |

---

## Recommended Implementation Phases

### Phase 1 - Core Learning (Highest Impact)
- [ ] Add word audio pronunciation
- [ ] Show pinyin alongside characters
- [ ] Display word images on crates
- [ ] Post-game review screen

### Phase 2 - Engagement
- [ ] Add particle effects (confetti, stars)
- [ ] Background music
- [ ] Tutorial mode
- [ ] Difficulty levels

### Phase 3 - Polish
- [ ] Mascot character
- [ ] Celebration animations
- [ ] Theme variations
- [ ] Reward system (stickers)

---

## Technical Notes

- Current API fetches from dictionary: `https://rtstgapi.../api/dictionary`
- Word data includes: `word`, `image.url`, `id`
- Consider adding `pinyin` and `audio_url` fields to API response
- For TTS fallback, consider integrating with a Chinese TTS service
