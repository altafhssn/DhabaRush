# YouTube Shorts: weeks 1–2, and the clip recorder

Six faceless Shorts for the first two weeks of the plan in [../launch/soft-launch-checklist.md](../launch/soft-launch-checklist.md) section E2, recorded from the game itself, plus the recorder that makes more. Written 27 Oct 2026 on 0.3.7.

- Nothing was uploaded. You upload (about 10 minutes each) and answer comments.
- Every clip was recorded in a scratch copy of the project with its own HOME. Your save and the project were not touched. Nothing was exported or installed.
- The game version in the clips is 0.3.7 on the desktop build, graphics HIGH. Gameplay numbers are the real ones.

## 1. The six clips

Each folder in `export/shorts/` holds the video (`<id>.mp4`, 1080 × 1920, 30 fps, H.264 + AAC 48 kHz stereo, −14.9 to −16.2 LUFS, true peak −1.5 dBTP or lower, 6–25 MB), `cover.jpg` (a frame to pick as the thumbnail) and `upload.txt` (title, description, hashtags, pinned comment and the settings to choose).

| Post (7 pm IST) | Folder | Format | Language | Length | Text on the video (first seconds) |
|---|---|---|---|---|---|
| W1 Mon 9 Nov | `w1_mon_highway_dhaba` | "I built a highway dhaba": a 7-beat cut (chai close-up pulling back, a lorry backing in, a waiter's whole-order trip, a dish unlock, BUILD the kadai, dusk to night, the busy dhaba at night) | English | 23.6 s | I built a **highway dhaba** |
| W1 Wed 11 Nov | `w1_wed_day_night` | Day vs night: one framing, the light sweeps from afternoon to night, fairy lights and headlights come on | Hindi | 15.0 s | एक ढाबा, **दिन और रात** |
| W1 Fri 13 Nov | `w1_fri_chai_pour` | Chai pour close-up: Pinky at the kettle, the timer filling, kulhads landing on the pass, waiters picking up | English | 13.0 s | Chai for every **truck driver** |
| W2 Mon 16 Nov | `w2_mon_level_up` | LEVEL UP spam: four taps, then a held LEVEL UP with the rising pitch, through the coffee (L25) and green tea (L50) unlocks | Hindi | 12.5 s | बस एक और **लेवल अप**... |
| W2 Wed 18 Nov | `w2_wed_every_dish` | Every dish on the menu: all four counters, a LEVEL UP at each L25 / L50 / L100, a "DISHES n / 16" counter | English | 23.0 s | Every dish in my **highway dhaba** |
| W2 Fri 20 Nov | `w2_fri_waiter_pov` | POV: you're the waiter. The camera follows Raju on his trips (one waiter for two busy counters, so he never stops) | Hindi | 15.0 s | POV: आप हाईवे ढाबे के **वेटर** हैं |

The checklist asked for 15–30 s and this round for 10–25 s; the six are 12.5–23.6 s (the LEVEL UP clip is the short one: it loops well). Every clip ends on a short "Dhaba Rush · Join the free test" line (Hindi: "ढाबा रश · फ़्री टेस्ट में खेलें"), except the dish clip, which ends on 16 / 16.

### The rules they follow (checklist E2)

- Gameplay in the first second, no logo first.
- The game's own sound: its music, ambience and effects at the in-game mix. No voice, no film music, nothing from YouTube's library.
- Only what the game has. No tractors, no sikke, no shop, no events. Prices, levels and dish unlocks are the game's own.
- **No ads on screen.** The AD bubble (the wall-ad offer) is held back for the whole recording, and the desktop build never shows an ad. No debug text, no cursor: the white ring is a drawn finger tap, as in phone screen recordings.
- **No debug values.** The cash on screen is what a player has at that stage (about ₹98,000 to ₹1 lakh late game; it goes down when something is bought).
- Captions alternate English and Hindi, and the Hindi clips show the Hindi game (`--lang=hi`).
- The burned-in text sits under the game's top bar and above the bottom third, where YouTube draws its own title and buttons.

## 2. What you do

**Once, before 9 Nov (20 min):**

1. Create the "Dhaba Rush" channel (B15) and upload the promo.
2. YouTube Studio › Customisation › Basic info › **Links**: add the test link. Before launch: the Google Group link from [../launch/tester-kit.md](../launch/tester-kit.md) (`[GROUP LINK]`), titled "Join the free test". From launch day: the Play link with the YouTube referrer (checklist E2). Links in Shorts descriptions and comments don't click, so the channel page is where viewers find it.
3. Read the Hindi texts of the three Hindi clips on the review sheet ([../hindi-review/hindi-review.md](../hindi-review/hindi-review.md), group "YouTube Shorts"). If a burned-in text changes, tell Claude: one clip is re-recorded in about 3 minutes.

**Each Short (10 min), best on the desktop so you can schedule all six in one sitting:**

1. studio.youtube.com › Create › Upload videos › the `.mp4`. A vertical video under 3 minutes becomes a Short by itself.
2. Title and description from `upload.txt` (hashtags at the end of the description).
3. Audience: **No, it's not made for kids**. Altered or synthetic content: **No**.
4. Category Gaming, language as in `upload.txt`.
5. Visibility › **Schedule**: the date in `upload.txt`, 7:00 pm, India Standard Time.
6. After it is live: pin the comment from `upload.txt`; in the YouTube app, Edit › Related video › the promo (or the W1 Monday Short); Edit › Thumbnail › the frame shown in `cover.jpg`.

**Every Monday (15 min):** YouTube Studio › each Short: views, "viewed vs swiped away", average % viewed, subscribers; Play Console › Store performance › YouTube installs. Send Claude the numbers. After week 3, keep the formats with 60 % or more "viewed" (checklist E2).

## 3. The recorder

A Godot scene that plays the real game in a 1080 × 1920 viewport and saves every frame and the game's own sound, plus a Blender script that cuts the `.mp4`. This Mac has no `ffmpeg`, so Blender's built-in FFmpeg encodes.

| File | What it does |
|---|---|
| `docs/shorts/rig/clip_rig.gd`, `clip_rig.tscn` | The recorder (copied into the scratch copy's `tools/shorts/`, never into the game). Runs `scenes/main3.tscn` in a SubViewport with the 720-px-wide phone layout, scripts a moment (`--clip=`), and between roll and cut saves `frames/f00000.jpg…` and `audio.wav` (Master bus, through an AudioEffectRecord). Draws the caption text (Baloo 2, as on the store screenshots) and the tap rings on top. Taps are real input events, so buttons, holds and sounds behave as on a phone |
| `docs/shorts/encode.py` | Run by Blender. Joins the segments, lays one music bed under clips cut from several runs, brings the mix to −15 LUFS with a peak limit of −1.5 dBTP (loudness code from `tools/audio/measure.py`), encodes H.264 (CRF high) + AAC 192 kb/s, saves the cover frame |
| `docs/shorts/clips.json` | The six clips: game state, camera, timing, burned-in text, upload text (with English glosses for the Hindi) |
| `docs/shorts/make_shorts.py` | Runs it all: scratch copy (`$TMPDIR/dhaba_shorts`, own HOME per run, custom user dir), record, encode, a contact sheet per clip (one frame a second) to check, and `--install` into `export/shorts/` |
| `docs/shorts/probe_mp4.swift` | Optional check of a finished `.mp4` with Apple's AVFoundation: size, frame rate, codec, audio, one decoded frame |

Run it:

```zsh
/usr/bin/python3 docs/shorts/make_shorts.py                          # all six, about 20 min
/usr/bin/python3 docs/shorts/make_shorts.py --only=w1_fri_chai_pour  # one clip, about 3 min
/usr/bin/python3 docs/shorts/make_shorts.py --install                # also copy into export/shorts/
```

**Why Movie Maker.** Godot's Movie Maker (`--write-movie … --fixed-fps 30`) makes every frame exactly 1/30 s of game time and mixes the audio in step, however slowly the 1080 × 1920 frames are saved (about 35 % of real time). Without it the sound would drift from the picture. Movie Maker's own window recording (405 × 720) is thrown away; the rig saves the full-size frames itself.

**Clip types** (`--clip=` in `clips.json`):

| Clip | What it does | Main flags |
|---|---|---|
| `zoomout` | Close on the chai counter, then the camera pulls back to the dhaba | `--zoom-from --zoom-to --pull-at --pull-s --span` |
| `lorry` | Waits for a lorry reversing into the truck parking and follows it | `--zoom --lead --span` |
| `waiter` | Follows a waiter (POV), starting on a loaded trip or at the pass | `--waiter --zoom --start=loaded\|pass --span` |
| `chai` | Holds a framing (`--cam`) and watches | `--cam --span` |
| `daynight` | Freezes the day cycle and sweeps it from `--from` to `--to` | `--hold-a --sweep --hold-b --cam` |
| `unlock` | A counter's sheet, LEVEL UP taps up to a dish unlock | `--station --level --span` |
| `levelspam` | Taps, then a held LEVEL UP (6 a second, rising pitch) | `--level --hold --span` |
| `dishes` | All 16 dishes, one LEVEL UP per milestone, with the n / 16 counter | `--per --open-s --start --tail` |
| `build` | BUILD panel, the BUILD tap, the camera flying to the new counter | `--station --scroll --tap-at --span` |
| `busy` | Watches (`--cam`, `--time`) | `--span` |
| `views` | Stills for choosing a framing (`--views=x:z:zoom;…`) | |

Every main3 debug flag works too (`--lang`, `--time`, `--arrivals`, `--seed`, `--gfx`). Game states for `--prep` (MID, LATE, ALL4, CHAI, POV1) are in `clips.json`; the purchases are the store rig's.

**Checks made on 27 Oct:** each `.mp4` opened with AVFoundation (1080 × 1920, 30 fps, H.264, AAC 48 kHz stereo, length = frames ÷ 30); a decoded frame matched its source frame (mean brightness 161.3 vs 161.2, colour unchanged); the audio recording matched the frame count within one frame; every clip's contact sheet (a frame a second) and frame sequences of the busy moments were looked at.

**Limits:**

- It records the desktop build, not a phone. It looks like the phone at HIGH; LOW would lose the sun shadows.
- Large floating sale numbers show in the close-ups, because the game draws them that way at close zoom.
- Clips with several segments get the music as one bed under the cut (the in-game music would restart at each cut). Night dimming of the music is then not heard in that clip.

## 4. Weeks 3–6

From checklist E2. Week 3 can be made with the same recorder; weeks 4–6 need other material.

| Week | Shorts | How |
|---|---|---|
| W3 · 23–29 Nov | ₹0 to ₹1 lakh time-lapse · Munshi-ji rates your dhaba · A lorry backs into the parking | A new `timelapse` clip (the `--auto` bot at `--speed`, frames saved every Nth); Munshi-ji's notes with `--notes-after-prep`; `lorry` with a longer `--span` |
| W4 · 30 Nov–6 Dec | Low-poly tandoor, Blender to game · The dhaba's music · English or Hindi? | Blender turntable of the tandoor model, then the `chai`-style clip on the tandoor; the music over a slow `busy` pan; a split screen of two `--lang` runs |
| W5 · 7–13 Dec | "On Google Play 15 Dec" countdown · two re-cuts of the best format | Re-cuts from `clips.json`, new text |
| W6 · 14–20 Dec | Launch day · Day 1 vs day 100 · Answer a comment | `zoomout` from a fresh dhaba and from LATE; the comment's text as the hook |

Claude prepares each week's clips by the Friday before (checklist E2).
