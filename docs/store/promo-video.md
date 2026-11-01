# Promo video: shot list (15–30 s)

Dhaba Rush 0.3.7 · store page track · 2026-10-26, updated 2026-10-27.

One edit, four exports: the Play listing video (English and Hindi) and two 9:16 cuts for YouTube Shorts, where the organic plan lives (faceless gameplay Shorts). Target length 25 s. Real gameplay only, from the current build. Play and YouTube both reject or demote videos that show things the game does not have, and "the ad looked different from the game" is the genre's most common review complaint.

## 1. Rules for the cut

- Gameplay on screen in the first second. No studio logo up front.
- Captions burned in, because most people watch muted. Use Baloo 2 ExtraBold (in `assets/fonts/`, OFL), white with the marigold highlight, as on the screenshots. Hindi version: the Hindi UI (`--lang=hi`) and Hindi captions.
- Sound: the game's own music and sound effects. The sound track is being reworked this sprint, so record after it lands. No film songs or other copyrighted music.
- Show only what 0.3.7 has. No sikke, no shop, no events, no prices that differ from the game.
- Play listing video: upload to YouTube as public or unlisted, with ads turned off on the video and embedding allowed, then paste the URL in Play Console. 16:9 is the safe format for the listing: put the portrait gameplay in the centre and the captions and brand on the sides. Check the current Play Console help when you upload, in case portrait video is now shown full size for portrait games.

## 2. Shot list (25 s)

Times are for the 9:16 cut; the 16:9 version uses the same beats.

| Time | Beat | On screen | Caption EN / HI | How to get it |
|---|---|---|---|---|
| 0.0–2.5 | Hook | Close on the chai counter: Pinky pours, the radial timer fills, a kulhad lands on the pass. Quick zoom out to the busy dhaba by day | Your own highway dhaba / अपना हाईवे ढाबा | Late-game state (section 3, LATE), pinch from zoom-in to the home view |
| 2.5–5.0 | Highway | A lorry reverses into the truck parking at dusk; travellers walk through the lit gate | Trucks pull in hungry / भूखे ड्राइवर रुकते हैं | Front view, `--time=0.58`, wait for a lorry (seed 7: about 40–70 s in) |
| 5.0–8.0 | Serve | A waiter carries chai and roti on one tray; the items hop onto the charpai; the traveller pays at the galla, cash burst and sale number | Serve every order / हर ऑर्डर परोसें | Follow a waiter (`--capture=tray` shows the framing), then the galla |
| 8.0–11.0 | Unlock | Tap the chai counter, three LEVEL UP taps, NEW ON THE MENU: Coffee | Unlock 16 dishes / 16 पकवान खोलें | Chai at level 22 (`--buy=chai_lvl22`), then tap LEVEL UP three times |
| 11.0–14.0 | Staff | STAFF › WAITERS, HIRE WAITER 3, the new waiter walks out and picks up a tray | Hire your staff / स्टाफ़ रखें | MID state (2 waiters), enough cash for the hire |
| 14.0–18.0 | Build | BUILD › KADAI › BUILD, the camera flies to the annex, the kadai appears, Shera stirs, steam rises | Build new counters / नए काउंटर बनाएँ | MID state plus a third waiter and ₹10,000 or more |
| 18.0–21.0 | Day to night | Speed-up from late afternoon to night: the sun drops, the fairy lights come on, headlights on the highway | Open day and night / दिन-रात खुला | `--time=0.55 --speed=8`, about 8 s of game time per second |
| 21.0–23.0 | Munshi-ji | Munshi-ji's note slides in: "We can afford a LASSI counter! Tap BUILD." | Munshi-ji shows the way / मुंशी जी रास्ता दिखाते हैं | PRE state with notes on (shot 7 of the screenshots) |
| 23.0–25.0 | Brand | The feature-graphic lockup over the night dhaba: "Dhaba Rush · Highway Idle Tycoon", then "Google Play" | (lockup only) | `export/store/play/feature_graphic.png` layout. Keep it under 2 s; drop it from the Play version if Play's guidance at upload time says no end cards |

Shorts cut (9:16, 20–30 s): the same beats. Add a one-line hook in the first 2 s ("I built a highway dhaba" / "मैंने हाईवे पर ढाबा खोला"). End on the busiest frame rather than the lockup, so the loop restarts cleanly.

## 3. How to record

**Best: a phone.** Install the internal-test build on a mid-range Android phone, set graphics to HIGH, and use Android's built-in screen recorder (1080 × 2400). That is the real "phone feel", with real touch timing. Trim to 9:16 (1080 × 1920) in the editor. Turn off notifications first (Do Not Disturb), and use a save that has reached the late game, or a debug build with the flags below.

**Desktop (debug build in a scratch copy, never the real project or save).** The flags are in `scripts/v3/main3.gd`; `docs/store/pipeline/rig/store_rig.gd` adds the purchases used for the screenshots:

- MID state: `--fresh --skip-tutorial --money=6000 --buy=tandoor,galla,waiter,table,table,lassi,chai_hire,tandoor_hire,tandoor_lvl22`. The purchases are paid from the `--money` amount and the rest stays as cash; `--money` is in reference units, shown ×10 on screen, so check the HUD shows a believable amount
- LATE state: the rig's LATE list in `docs/store/pipeline/make_store.sh` (run through the store rig, which then sets the shown cash with `--show-cash`)
- Night: `--time=0.575` (dusk turning to night about 40 s later)
- Repeatable traffic: `--seed=7`

Godot's Movie Maker (`--write-movie out.png --fixed-fps 30`) works in a scratch copy, but it records the window, which this project opens at 405 × 720. That is too small for a store video. macOS screen recording (Cmd-Shift-5) of a 720 × 1280 window (`--resolution 720x1280`, it fits this Mac's screen) is the practical desktop route; upscale to 1080 × 1920 in the editor. A frame-accurate 1080 × 1920 recorder now exists (2026-10-27): `docs/shorts/rig/clip_rig.gd` renders the game in a 1080 × 1920 SubViewport under Movie Maker (`--fixed-fps 30`), saves every frame and the game's own audio, and `docs/shorts/encode.py` cuts the .mp4 in Blender. Its `zoomout`, `lorry`, `waiter`, `unlock`, `build`, `daynight` and `busy` clips are the beats of section 2; `docs/shorts/README.md` says how to run it. The first Short (`export/shorts/w1_mon_highway_dhaba/`) is a 23.6 s cut of these beats from the desktop build; the phone recording above is still the better source for the Play listing video.

**Edit:** CapCut or DaVinci Resolve (both free). Export H.264, 1080 × 1920 and 1920 × 1080, 30 fps, about 10–16 Mbps.

## 4. Files to deliver

| File | Use |
|---|---|
| `promo_en_16x9.mp4`, `promo_hi_16x9.mp4` | YouTube (unlisted) → Play listing, English and Hindi listings |
| `short_en_9x16.mp4`, `short_hi_9x16.mp4` | YouTube Shorts, Instagram Reels |
| Thumbnail 1280 × 720 | YouTube; reuse the feature graphic layout |

## 5. Faceless Shorts ideas from the same footage

1. "₹0 to ₹1 lakh: building a highway dhaba", a time-lapse of the first 10 minutes.
2. "Day vs night at the dhaba", a split screen at the same framing.
3. "Every dish on the menu", 16 unlock pops cut to the beat.
4. "POV: you're the waiter", the follow camera on a tray run.
5. "Munshi-ji rates your dhaba", his lines over gameplay.
