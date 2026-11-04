# Phone test sheet: Dhaba Rush 0.3.8 (B8)

For **Thu 5 – Sat 7 Nov**, on the internal-test build from Play (B7). Made to read on a phone.

**Updated 2 Nov 2026 for the core-and-feel build** ([../core-and-feel/change-list.md](../core-and-feel/change-list.md)): interstitials are off (D4), a Starter Pack joins the purchases (E1, E7; the purchase tests need two phones with two test accounts), the AD bubble hides when no ad is ready (D3), three new sounds (K7), and section N covers what only a screen can show. Updated again on 3 Nov after the final review: C7 (closing the tutorial's bonus video), F6 (three lines still in English in Hindi mode), N15 (Munshi-ji's "All 16 dishes!" stop). The build's version number is yours to decide (owner-tasks.md); write it in the results block.

- About 60 min on the first phone, 30 min on each other phone.
- Test 2 or 3 phones. One should have **4 GB of RAM or less**, so GRAPHICS AUTO picks LOW.
- Every check has an ID (A1, B2, …). Write down only the IDs that went wrong.
- **Where results go:** copy the results block at the end of this page into WhatsApp (send it to yourself) or Google Keep, one per phone. Fill it in as you go, then paste it into the Claude chat.
- Screen-record anything odd: pull down quick settings, tap **Screen record**, then say the ID in the results ("D3: see video 14:32").
- Plug in USB only if you want Claude to read the phone's log.

---

## 0. Before you start

- [ ] Phone details: **Settings › About phone**. Write the model, Android version and RAM in the results block.
- [ ] Battery 50 % or more. Wi-Fi on. Volume at your normal level.
- [ ] Your Gmail and a second Gmail are on Play's **License testing** list (Play Console › Settings › License testing). Without it, a purchase in E costs real money. Phone 1 uses your Gmail in Play, phone 2 the second one: one account can buy Remove Ads plus **either** the Starter Pack **or** VIP, never both (section E).
- [ ] VIP, Remove Ads and the Starter Pack exist in Play Console (B2; [sdk.md §11](sdk.md) item 9).
- [ ] Do the test on **Sat 7 Nov** if you can: the weekend baraat (N2) runs only on Saturdays and Sundays.

---

## A. Install (5 min)

- **A1** Uninstall any Dhaba Rush you sideloaded before. This deletes that save.
- **A2** Open the internal-test link from Play Console on the phone › Accept › **Download it on Google Play** › Install. Note the download size shown by Play. The listing says "small download" with no number until this is recorded ([../store/play-listing.md](../store/play-listing.md) §5).
- **A3** The home-screen icon is Munshi-ji with a chai glass on saffron. The name under it reads "Dhaba Rush".
- **A4** Android 13 or newer: turn on themed icons (long-press the wallpaper › Wallpaper & style › Themed icons). Munshi-ji's grey outline shows, not a blank square.

## B. First launch (5 min)

- **B1** Time the cold start: tap the icon, count until you can see the dhaba. Write the seconds. Under 5 s on the 4 GB phone is the target.
- **B2** Splash: saffron with Munshi-ji's face, then Munshi-ji with folded hands and "Dhaba Rush". No black or blue flash in between.
- **B3** Language: Hindi if the phone's language is Hindi, otherwise English.
- **B4** The **HELP US IMPROVE** card (Hindi: गेम बेहतर बनाने में मदद करें) does not come at once. It waits until about 2 minutes into the tutorial (C), after the seats lesson, when Munshi-ji lets you play on your own. A phone that closes the game before then is asked on its next launch. When the card comes, NO THANKS and ALLOW are the same size, and the text fits the card.
  - Phone 1: tap **ALLOW**. Phone 2: tap **NO THANKS**.
- **B5** No Google privacy form appears (expected in India). If one does, screenshot it.
- **B6** Close the game fully (swipe it away), open it again. The HELP US IMPROVE card does not come back.
- **B7** Settings › ANALYTICS shows ON on phone 1 and OFF on phone 2. Tap it: it switches.
- **B8** Settings, just above the version line at the bottom: "Player ID: XXXX-XXXX-XXXX-XXXX · tap to copy". Tap it: toast "Player ID copied." Paste it into WhatsApp to check it is the same text.

## C. Tutorial (5 min, don't skip it)

- **C1** Munshi-ji's lines are easy to read. Tapping moves them on.
- **C2** Every hand pointer lands on what it points at. Nothing needs two tries.
- **C3** First sale: you hear the cash box and coins, and the cash goes up top left.
- **C4** About 3 minutes in, ask yourself: "what do I do next, and why?" Can you answer from the screen alone? Write yes or no.
- **C5** The tutorial ends in free play with the NEXT chip at the top. Write how long the tutorial took.
- **C6** Nobody walks out angry: when every seat is taken, travellers wait at the gate and the board at the gate says FULL. No "No seat!" and no red LOST count anywhere.
- **C7** On phone 2 only: in the tutorial's ad lesson, tap the AD bubble, then close FREE BONUS with its X without watching. Munshi-ji goes on to the BUILD lesson and the tutorial ends normally (the bonus video is optional). On phone 1, watch the video as usual.

## D. Ads: test ads only (10 min)

Every ad in this build must say **Test Ad**. A real ad anywhere is a blocker.

- **D1** When the AD bubble appears, tap it › WATCH AD. A Google test video plays. Close it after the reward: cash goes up.
- **D2** Do it again, but close the video early: no cash, and the toast "Watch the ad to the end to get the reward."
- **D3** Airplane mode on and play for a few minutes. An AD bubble that cannot play an ad goes away by itself, and no new one comes while the phone is offline. If you tap WATCH AD with nothing loaded, the toast says "No internet: bonus videos come back when you are online." Airplane mode off, leave the game and come back: the bubble returns and works.
- **D4** No full-screen ads at all in this build. From the **4th launch** of the game: open a counter, tap LEVEL UP, close the counter. Nothing pops up. Any full-screen ad anywhere is a blocker.
- **D5** After 30+ minutes away (do this with I4): WELCOME BACK offers COLLECT x2 when its test video is ready (otherwise only COLLECT). Tap it: a test video, then double cash.

## E. Purchases with Play test cards (10 min on each of two phones)

Only with the phone's Gmail on License testing (section 0). Play's sheet must say **Test card**.

**Two phones, two accounts.** After any purchase (or a restore) the game offers neither the Starter Pack nor VIP again, only FREE BONUS, and Play gives purchases back on a reinstall. So one account can buy Remove Ads plus either the Starter Pack or VIP, never both. A session is one launch of the game: close it fully (swipe it away) and open it again for the next one.
- Phone 1 (your Gmail): E1, E7, E3, then E6.
- Phone 2 (the second Gmail): E4, E2, E5, then E6.
- To use an account again from the start: Play Console › Order management, refund and revoke its test orders, then Settings › Apps › Dhaba Rush › Clear storage.

- **E1** Phone 1. Settings › REMOVE ADS shows Play's price in rupees (placeholder ₹149), with "One-time, forever. Optional bonus videos stay." under it. The STARTER PACK offer (₹49) and the VIP OFFER (₹299) come from the AD bubble in session 2 or later, and only while nothing has been bought with that phone's account: the first bubble tap of session 2 or later shows STARTER PACK (once ever), then the first tap of each later session shows VIP OFFER. Only Play's real prices count; write them down (VIP's on phone 2, E2).
- **E2** Phone 2, in the session after E4: the first AD bubble tap shows VIP OFFER. Tap UNLOCK and buy VIP with "Test card, always approves". Every sale doubles. The AD bubble keeps working, and from now on it only offers FREE BONUS. (Skipped E4? In session 2, close the STARTER PACK offer with X without buying; VIP OFFER comes on the first bubble tap of session 3.)
- **E3** Phone 1, after E7: buy REMOVE ADS the same way. Settings now shows "No forced ads. Thank you!" in its place. Bonus videos still work.
- **E4** Phone 2, before buying anything: in session 2, tap the AD bubble › STARTER PACK › BUY with "Test card, always declines". Nothing is given, toast "Purchase failed. Please try again." or "Purchase cancelled." The offer has now been seen, so the next session offers VIP (E2).
- **E5** Phone 2, after E2: Settings › REMOVE ADS with "Slow test card, approves after a few minutes": toast "Payment pending. …", then "Payment received. Thank you!" a few minutes later, even if you closed the game in between.
- **E6** Each phone: uninstall, reinstall from Play. The products bought with that account are back at launch: phone 1 No Ads and the Starter Pack, phone 2 VIP and No Ads. The Starter Pack's 15,000 dhaba cash is paid once more after the new game's tutorial (expected: Play restores it and the new save pays it once).
- **E7** Starter Pack, phone 1, before E3 (nothing bought yet with this account): in session 2 or later, tap the AD bubble › STARTER PACK "+15,000 dhaba cash, one time" › BUY with "Test card, always approves". The toast "Starter Pack: +15,000 dhaba cash" and the cash arrive. Close and reopen the game: the cash does not come again. The bubble now only offers FREE BONUS (VIP is tested on phone 2, E2).

## F. Hindi (5 min)

- **F1** Settings › LANGUAGE / भाषा › हिंदी. The HUD, open panels and Munshi-ji switch at once.
- **F2** On the smallest phone, open every panel (STAFF, BUILD, STATS, a counter, Settings). No text is cut off or runs outside its box. Screenshot anything that is.
- **F3** Money shows lakh and crore (for example "2.50 लाख").
- **F4** Airplane mode: any toast (D3, J3) is in Hindi.
- **F5** Switch back to English. Everything comes back in English.
- **F6** Expected in Hindi for now, do not report: three lines from the last fixes stay in English until the Hindi pass (owner-tasks §3): a task card "Collect … for the dhaba", the BUILD › TABLES line "More tables, more travellers." and the toast "Baraat reward: +… dhaba cash". Anything else in English in Hindi mode is a finding.

## G. GRAPHICS: what AUTO picked (5 min)

- **G1** Settings › GRAPHICS says **AUTO**.
- **G2** Look at the shadows in the dhaba:
  - long sun shadows from walls and people = AUTO picked **HIGH**;
  - only round blobs under people = AUTO picked **LOW**.
  Write HIGH or LOW in the results block. Expected: LOW on phones with 4 GB or less, HIGH on 6 GB or more.
- **G3** Tap GRAPHICS to go to HIGH, then LOW. The look changes at once, and brightness stays the same on both.
- **G4** On LOW, scrolling and zooming are a little less smooth (30 frames a second). Is it still fine? Put it back on AUTO.

## H. Back button (3 min)

Try with gesture navigation (swipe from the edge), and with the 3 buttons if the phone has them.

- **H1** Open a counter, press back: the counter closes, nothing else.
- **H2** Back with nothing open: "LEAVE THE DHABA?" with STAY and LEAVE.
- **H3** Back again, or STAY, or a tap outside the card: you stay.
- **H4** LEAVE: the game closes. Open it again: your cash and levels are as you left them.
- **H5** Back while Munshi-ji is talking: the same question, and his line is still there after STAY.
- **H6** On a fresh install (or after Settings › Apps › Dhaba Rush › Clear storage), press back while the HELP US IMPROVE card is up: LEAVE THE DHABA? appears above it. STAY brings the card back. LEAVE, then open the game again: the card asks again.

## I. Background and resume (10 min, plus the wait for I4)

- **I1** Press home in the middle of a sale: silence at once. Come back: the sound fades back in, cash not lost.
- **I2** Pull down the notification shade: silent while it is down.
- **I3** Lock the screen for 1 minute, unlock: the game is where you left it.
- **I4** Leave the game for **10+ minutes**: WELCOME BACK with what your staff took in while you were away. After **30+ minutes**: COLLECT x2 is offered too, when its video is ready (D5).
- **I5** Turn the phone sideways: the game stays upright.
- **I6** A call or an alarm during play: the game pauses its sound and carries on afterwards.

## J. Play offline (5 min)

The store listing promises "Works without internet" (short description, first line, and the "Play offline" bullet). If this fails, those lines come out of the listing in both languages.

- **J1** Airplane mode on. Swipe the game away, then open it (cold start).
- **J2** Play for 5 minutes: no freeze, no endless loading, no privacy question stuck on screen.
- **J3** Ads and purchases fail politely (toasts), and everything else works.

## K. Feel and sound (10 min)

- **K1** Taps that spend nothing (opening a panel, tabs, the X) do not vibrate.
- **K2** Spending (LEVEL UP, HIRE) gives a light tick. Hold LEVEL UP: ticks while the levels climb. Pleasant, or too much?
- **K3** CLAIM and BUILD give a strong pulse. A new dish gives a double pulse.
- **K4** Settings › VIBRATION OFF: no vibration anywhere. Turn it back on.
- **K5** Horns match the vehicle that honks: car "peep-peep", lorry two-note air horn, auto "paw-paw", bike beep.
- **K6** The listening list, part 2 (docs/polish/audio.md §2, points 1–16). Write the point number and what is wrong:
  1. Music level next to other apps
  2. Munshi-ji's typing ticks
  3. First sale sound
  4. Serve (dish on the table)
  5. Waiter pickup pop
  6. LEVEL UP held (rising pitch)
  7. CLAIM and the count-up
  8. BUILD fanfare
  9. Grey button "no" sound
  10. Horns (none makes you jump)
  11. Day and night ambience with MUSIC off
  12. Night music
  13. Lassi churn, kadai sizzle, egg, dal
  14. MUSIC OFF and SOUND OFF act at once
  15. Background silence, and silence under a test ad
  16. Earphones: nothing lopsided
- **K7** The three new world sounds (audio.md §3, "World sounds"): at night, a quiet cricket crowd from the TV now and then; on Sat or Sun, a dhol and trumpet when the baraat bus drops its guests; the sitting dog barks as a vehicle that does not stop (the dhaba had no room for its riders) passes the gate, at most once every 45 s. Too loud, too quiet, or annoying after a few times?
- **K8** C8.5: listen to the music on the phone speaker and on earphones (points 1, 12 and 17–20 of audio.md §2). The music was made by software and nobody has heard it on a phone yet.

## L. 20 minutes of play: battery and heat

- **L1** Note the battery % and the time. Brightness about half. GRAPHICS on AUTO.
- **L2** Play for 20 minutes without stopping (build, level up, let it run).
- **L3** Note the battery % again. Is the back of the phone cool, warm or hot?
- **L4** Did the game get slower or stutter as time went on?

## M. Crashes and freezes (all the time)

- **M1** If the game closes by itself (crash) or Android says it "isn't responding": write the time and what was on screen.
- **M2** A day later: Play Console › Android vitals › Crashes and ANRs shows what the phones reported. Tell Claude if anything is listed.

## N. What only a screen can show (core and feel, 25 min)

The builders checked these by numbers in headless runs, never by eye. Screenshot anything that looks wrong and write the ID.

- **N1** **The TV at night.** On the left wall at home view, the TV shows a green cricket field with a plain score strip and a soft flicker, only at night. No team names, no channel logo. It does not look like a black or pink square.
- **N2** **The meter and the BARAAT button.** The four-row meter (SEATS, COOKS, WAITERS, CASHIERS) at the left edge, under the task strip: every word is readable, the highlighted row is clear, and the line under it ("Road: … /min") fits. On Sat or Sun, after 10 minutes of play past the tutorial, the BARAAT button shows under the meter; tap it: the event panel opens with the goals and the time left.
- **N3** **The spend notes.** Buy something (LEVEL UP, a hire, a table): small notes fly from the cash pill to what you bought. Smooth on GRAPHICS LOW too? Any stutter on the 4 GB phone?
- **N4** **The tray and BIGGER TRAY!** When a waiter reaches level 15 (and 30), he bounces with rings and sparkles and "BIGGER TRAY!" rises over him; if he is off screen the camera flies to him and back. Readable? Too long?
- **N5** **The "+X/min" float.** After a hire or a table that makes the dhaba take in more, "+X/min" rises under the cash pill, over the task strip. Can you read it, or does it clash with the task strip?
- **N6** **The quick card.** Tap the waiter hire tag in the world, or the NEXT chip when it suggests a waiter: the small waiter card opens. It can cover STATS and part of the task strip for a moment, but never the meter. Is that a problem?
- **N7** **The Family Dhaba and NH 48 pictures** (if you reach them, or with a save that has): BUILD › FAMILY DHABA › SEE shows a before / after picture, not a plain coloured panel.
- **N8** **The seats board at the gate.** At the home view, the "SEATS · सीटें" board shows the seats in use as its biggest number, and FULL on a red plate when every seat is taken. Readable on the smallest phone?
- **N9** **A counter sheet.** Open a counter: the grey "Not the bottleneck now" ribbons, the saffron fix button, the "×2 TODAY" chip on a special dish (on a day with Aaj ka special), and in STAFF › WAITERS the Munshi-ji row (its task-claim count up to 20, then an ON/OFF toggle). Do they look right and fit their boxes in both languages?
- **N10** **Munshi-ji's reaction chip.** After the tutorial, buy what the meter highlights (for example hire a waiter when WAITERS is the limit). Within a few seconds a small cream chip with Munshi-ji's face and one line ("Shabaash! Food moves faster now.") shows at the bottom centre, just above the HOME button, for about 2.5 s. The same chip brings "One day this becomes a FAMILY DHABA. See BUILD." about 1.5 minutes into free play. Readable, at most two lines, inside the screen, in both languages?
- **N11** **The tutorial's waiter and seats lessons** (watch for them in C). When Munshi-ji says "Tap the new WAITER, then HIRE.", the "+ WAITER" tag pops in over the new waiter, with a pulsing ring that shows through the dim. While Munshi-ji talks about the waiters, the meter's WAITERS row pulses; in the seats lesson ("Every seat is taken!") its SEATS row pulses. Easy to see, or easy to miss?
- **N12** **The hoarding.** BUILD › HIGHWAY SIGNBOARD › BUILD: the camera flies across the highway to the painted hoarding by the bus stop, then comes back. The whole board ("DHABA RUSH · 1 KM") is on screen, clear of the cash pill, the meter and the buttons. From signboard level 3 (if you get there) a frame of bulbs shows round the board: pan to it at night too.
- **N13** **The AC family hall on a tall phone** (if you reach the Family Dhaba, or with a save that has): the renovation reveal flies to the hall, and later a tap on HOME while the camera is already home goes to the hall. Do this on your tallest phone and write its screen resolution (its spec page has it, for example 1080 × 2400). The hall's sign, its three tables and its door should be on screen. On a phone taller than 16:9 the camera zooms out a little so that all of it fits, so a cut-off door or sign end is a bug: screenshot it.
- **N14** **The sugarcane cart at NH 48** (if you reach NH 48, or with a save that has): the juice glasses on the sugarcane cart across the road look pale green, not khaki.
- **N15** **Munshi-ji's "All 16 dishes!" line** (when every counter is built and at level 100, before the Family Dhaba, or with a save that has that): Munshi-ji says "All 16 dishes! The FAMILY DHABA waits in BUILD." while the camera flies east to the empty plot beyond the courtyard, where the AC family hall will stand, and zooms out a little. His box stays open. The plot should show above and to the left of Munshi-ji, not hidden behind him, his MUNSHI-JI plaque or the box. Screenshot it and write the phone's screen resolution.

---

## Results block (copy one per phone)

```
DHABA RUSH PHONE TEST · version [x.y.z]
Phone: [model] · Android [version] · RAM [GB]
Date: [day] · tested by: [name]
B1 cold start: [seconds]   C5 tutorial: [minutes]
G2 AUTO picked: [HIGH / LOW]
A2 download size: [MB]
L1→L3 battery: [start %] → [end %] in 20 min · phone felt: [cool / warm / hot]
C4 knew what to do next at 3 min: [yes / no]

All OK except:
- [ID]: [what happened]
- [ID]: [what happened]

Sound list (K6, K7, K8): [point numbers and what is wrong]
Screen checks (N1–N15): [IDs that looked wrong]
Videos: [ID and time]
```

Claude reads the blocks, fixes blockers the same day (checklist C3), and says whether the "Play offline" line stays.
