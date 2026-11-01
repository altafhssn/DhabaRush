# Phone test sheet: Dhaba Rush 0.3.8 (B8)

For **Thu 5 – Sat 7 Nov**, on the internal-test build from Play (B7). Made to read on a phone.

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
- [ ] Your Gmail is on Play's **License testing** list (Play Console › Settings › License testing). Without it, a purchase in E costs real money.
- [ ] VIP and Remove Ads exist in Play Console (B2).

---

## A. Install (5 min)

- **A1** Uninstall any Dhaba Rush you sideloaded before. This deletes that save.
- **A2** Open the internal-test link from Play Console on the phone › Accept › **Download it on Google Play** › Install. Note the download size shown by Play.
- **A3** The home-screen icon is Munshi-ji with a chai glass on saffron. The name under it reads "Dhaba Rush".
- **A4** Android 13 or newer: turn on themed icons (long-press the wallpaper › Wallpaper & style › Themed icons). Munshi-ji's grey outline shows, not a blank square.

## B. First launch (5 min)

- **B1** Time the cold start: tap the icon, count until you can see the dhaba. Write the seconds. Under 5 s on the 4 GB phone is the target.
- **B2** Splash: saffron with Munshi-ji's face, then Munshi-ji with folded hands and "Dhaba Rush". No black or blue flash in between.
- **B3** Language: Hindi if the phone's language is Hindi, otherwise English.
- **B4** Once the dhaba is on screen, the **HELP US IMPROVE** card (Hindi: गेम बेहतर बनाने में मदद करें) appears over it. NO THANKS and ALLOW are the same size, and the text fits the card.
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

## D. Ads: test ads only (10 min)

Every ad in this build must say **Test Ad**. A real ad anywhere is a blocker.

- **D1** When the AD bubble appears, tap it › FREE. A Google test video plays. Close it after the reward: cash goes up.
- **D2** Do it again, but close the video early: no cash, and the toast "Watch the ad to the end to get the reward."
- **D3** Airplane mode on, tap the next bubble: toast "No ad available right now. Try again in a minute." Airplane mode off, leave the game and come back: the bubble works again.
- **D4** From the **4th launch** of the game: open a counter, tap LEVEL UP, close the counter. A test interstitial about half a second later.
  - Not more than once a minute.
  - Never during the tutorial.
  - Never after closing a counter where you bought nothing.
- **D5** After 30+ minutes away (do this with I4): WELCOME BACK offers COLLECT x2. Tap it: a test video, then double cash.

## E. Purchases with Play test cards (10 min)

Only with your Gmail on License testing (section 0). Play's sheet must say **Test card**.

- **E1** Settings › REMOVE ADS and the VIP offer show prices in rupees (₹199 and ₹299).
- **E2** Buy VIP with "Test card, always approves". Income doubles. The AD bubble keeps working.
- **E3** Buy REMOVE ADS the same way. Settings now shows "No ads. Thank you!" in its place. No more interstitials (D4).
- **E4** A second phone or account: "Test card, always declines". Nothing is given, toast "Purchase failed. Please try again." or "Purchase cancelled."
- **E5** "Slow test card, approves after a few minutes": toast "Payment pending. …", then "Payment received. Thank you!" a few minutes later, even if you closed the game in between.
- **E6** Uninstall, reinstall from Play: VIP and No Ads are back at launch.

## F. Hindi (5 min)

- **F1** Settings › LANGUAGE / भाषा › हिंदी. The HUD, open panels and Munshi-ji switch at once.
- **F2** On the smallest phone, open every panel (STAFF, BUILD, STATS, a counter, Settings). No text is cut off or runs outside its box. Screenshot anything that is.
- **F3** Money shows lakh and crore (for example "2.50 लाख").
- **F4** Airplane mode, tap the AD bubble: the toast is in Hindi.
- **F5** Switch back to English. Everything comes back in English.

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
- **I4** Leave the game for **10+ minutes**: WELCOME BACK with your earnings. After **30+ minutes**: COLLECT x2 is offered too (D5).
- **I5** Turn the phone sideways: the game stays upright.
- **I6** A call or an alarm during play: the game pauses its sound and carries on afterwards.

## J. Play offline (5 min)

The store listing promises "Play offline". If this fails, that line comes out of the listing.

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

## L. 20 minutes of play: battery and heat

- **L1** Note the battery % and the time. Brightness about half. GRAPHICS on AUTO.
- **L2** Play for 20 minutes without stopping (build, level up, let it run).
- **L3** Note the battery % again. Is the back of the phone cool, warm or hot?
- **L4** Did the game get slower or stutter as time went on?

## M. Crashes and freezes (all the time)

- **M1** If the game closes by itself (crash) or Android says it "isn't responding": write the time and what was on screen.
- **M2** A day later: Play Console › Android vitals › Crashes and ANRs shows what the phones reported. Tell Claude if anything is listed.

---

## Results block (copy one per phone)

```
DHABA RUSH 0.3.8 PHONE TEST
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

Sound list (K6): [point numbers and what is wrong]
Videos: [ID and time]
```

Claude reads the blocks, fixes blockers the same day (checklist C3), and says whether the "Play offline" line stays.
