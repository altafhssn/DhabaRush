# Round 2: the current build (v0.3.2), captured 2026-10-22

Every PNG is the 720 x 1280 viewport of a windowed Godot 4.7.2 run of a scratch copy of the project (own user dir and HOME;
the real save was not opened). Money below is as the game shows it (x10 of the internal value).

## 1. First-time walk (`walk_NNN.png`)

One continuous run, seed 41: a brand-new save, the tutorial played by the project's `--auto` autopilot, then 15 game minutes
of free play by the UX audit's player bot (it follows the NEXT chip like a new player, pans once and taps HOME). Frames on
every event plus every 2 s (tutorial) / 15 s (free play); near-identical frames dropped. The tutorial ended at 3:32.
In this seed the seats beat was skipped (no door line formed: `tutorial_seats_skipped no_door_line`).

| File | t (s) | m:ss | Phase | Event | State | Staff | Cash |
|---|---|---|---|---|---|---|---|
| walk_001.png | 0.3 | 0:00 | tutorial | tick | step intro, HUD reveal 1; Munshi-ji line l1 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,000 |
| walk_002.png | 0.6 | 0:00 | tutorial | boot_first_frame | step intro, HUD reveal 1; Munshi-ji line l1 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,000 |
| walk_003.png | 3.2 | 0:03 | tutorial | line_l1 | step intro, HUD reveal 1; Munshi-ji line l1 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,000 |
| walk_004.png | 9.8 | 0:09 | tutorial | line_l2 | step intro, HUD reveal 1; Munshi-ji line l2 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,000 |
| walk_005.png | 10.3 | 0:10 | tutorial | tick | step follow, HUD reveal 1 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,000 |
| walk_006.png | 10.9 | 0:10 | tutorial | step_follow | step follow, HUD reveal 1 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,000 |
| walk_007.png | 16.3 | 0:16 | tutorial | tick | step follow, HUD reveal 1 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,000 |
| walk_008.png | 19.6 | 0:19 | tutorial | step_seated | step chai_pause, HUD reveal 1 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,000 |
| walk_009.png | 23.2 | 0:23 | tutorial | line_l3 | step brew, HUD reveal 1 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,000 |
| walk_010.png | 23.8 | 0:23 | tutorial | step_brew | step brew, HUD reveal 1 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,000 |
| walk_011.png | 25.1 | 0:25 | tutorial | step_deliver | step deliver, HUD reveal 1 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,000 |
| walk_012.png | 26.3 | 0:26 | tutorial | tick | step deliver, HUD reveal 1 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,000 |
| walk_013.png | 28.1 | 0:28 | tutorial | step_to_galla | step to_galla, HUD reveal 1 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,000 |
| walk_014.png | 32.4 | 0:32 | tutorial | tick | step to_galla, HUD reveal 1 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,000 |
| walk_015.png | 36.4 | 0:36 | tutorial | line_l4 | step galla_pause, HUD reveal 1; Munshi-ji line l4 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,000 |
| walk_016.png | 39.5 | 0:39 | tutorial | step_wait_sale | step wait_sale, HUD reveal 1 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,000 |
| walk_017.png | 43.7 | 0:43 | tutorial | hud_reveal_2 | step first_sale, HUD reveal 2; Munshi-ji line l5 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,010 |
| walk_018.png | 45.9 | 0:45 | tutorial | line_l5 | step first_sale, HUD reveal 2; Munshi-ji line l5 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,010 |
| walk_019.png | 48.4 | 0:48 | tutorial | line_l6 | step tap_chai, HUD reveal 2 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,010 |
| walk_020.png | 48.5 | 0:48 | tutorial | tick | step tap_chai, HUD reveal 2 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,010 |
| walk_021.png | 49.0 | 0:49 | tutorial | step_tap_chai | step tap_chai, HUD reveal 2 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,010 |
| walk_022.png | 50.4 | 0:50 | tutorial | hud_reveal_3 | step level, HUD reveal 3; panel station:chai; hand on @Button@318 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,010 |
| walk_023.png | 50.9 | 0:50 | tutorial | hand_level | step level, HUD reveal 3; panel station:chai; hand on @Button@318 | 1 cashier(s) · 1 waiter(s) · 2 tables | 985 |
| walk_024.png | 58.6 | 0:58 | tutorial | line_l7 | step tap_out, HUD reveal 3; panel station:chai; hand on SheetClose | 1 cashier(s) · 1 waiter(s) · 2 tables | 766 |
| walk_025.png | 59.2 | 0:59 | tutorial | hand_tap_out | step tap_out, HUD reveal 3; panel station:chai; hand on SheetClose | 1 cashier(s) · 1 waiter(s) · 2 tables | 766 |
| walk_026.png | 61.6 | 1:01 | tutorial | hud_reveal_4 | step transfer, HUD reveal 4 | 1 cashier(s) · 1 waiter(s) · 2 tables | 766 |
| walk_027.png | 61.7 | 1:01 | tutorial | step_transfer | step transfer, HUD reveal 4 | 1 cashier(s) · 1 waiter(s) · 2 tables | 766 |
| walk_028.png | 64.3 | 1:04 | tutorial | line_l8 | step transfer, HUD reveal 4; Munshi-ji line l9 | 1 cashier(s) · 1 waiter(s) · 2 tables | 766 |
| walk_029.png | 66.4 | 1:06 | tutorial | line_l9 | step tap_galla, HUD reveal 4 | 1 cashier(s) · 1 waiter(s) · 2 tables | 766 |
| walk_030.png | 67.0 | 1:06 | tutorial | step_tap_galla | step tap_galla, HUD reveal 4 | 1 cashier(s) · 1 waiter(s) · 2 tables | 782 |
| walk_031.png | 68.5 | 1:08 | tutorial | tick | step hire, HUD reveal 4; panel galla; hand on @Button@916 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,000 |
| walk_032.png | 68.8 | 1:08 | tutorial | hand_hire | step hire, HUD reveal 4; panel galla; hand on @Button@916 | 1 cashier(s) · 1 waiter(s) · 2 tables | 1,000 |
| walk_033.png | 69.6 | 1:09 | tutorial | btn_galla_hire | step close_galla, HUD reveal 4; panel galla; hand on @Button@373 | 2 cashier(s) · 1 waiter(s) · 2 tables | 500 |
| walk_034.png | 70.0 | 1:10 | tutorial | hand_close_galla | step close_galla, HUD reveal 4; panel galla; hand on @Button@373 | 2 cashier(s) · 1 waiter(s) · 2 tables | 500 |
| walk_035.png | 72.9 | 1:12 | tutorial | line_l10 | step wrap, HUD reveal 4; Munshi-ji line l10 | 2 cashier(s) · 1 waiter(s) · 2 tables | 516 |
| walk_036.png | 76.5 | 1:16 | tutorial | tick | step waiter_lines, HUD reveal 4 | 2 cashier(s) · 1 waiter(s) · 2 tables | 533 |
| walk_037.png | 79.2 | 1:19 | tutorial | line_lw1 | step waiter_lines, HUD reveal 4; Munshi-ji line lw1 | 2 cashier(s) · 1 waiter(s) · 2 tables | 549 |
| walk_038.png | 80.5 | 1:20 | tutorial | rack_tag | step waiter_lines, HUD reveal 4; Munshi-ji line lw2 | 2 cashier(s) · 1 waiter(s) · 2 tables | 549 |
| walk_039.png | 81.9 | 1:21 | tutorial | line_lw2 | step waiter_lines, HUD reveal 4; Munshi-ji line lw2 | 2 cashier(s) · 1 waiter(s) · 2 tables | 565 |
| walk_040.png | 83.6 | 1:23 | tutorial | step_tap_rack | step tap_rack, HUD reveal 4; hand on RackTag | 2 cashier(s) · 1 waiter(s) · 2 tables | 565 |
| walk_041.png | 84.0 | 1:24 | tutorial | hand_tap_rack | step tap_rack, HUD reveal 4; hand on RackTag | 2 cashier(s) · 1 waiter(s) · 2 tables | 565 |
| walk_042.png | 84.6 | 1:24 | tutorial | tick | step hire_waiter, HUD reveal 4; panel waiters | 2 cashier(s) · 1 waiter(s) · 2 tables | 565 |
| walk_043.png | 84.8 | 1:24 | tutorial | btn_rack_tag | step hire_waiter, HUD reveal 4; panel waiters | 2 cashier(s) · 1 waiter(s) · 2 tables | 565 |
| walk_044.png | 85.6 | 1:25 | tutorial | hand_hire_waiter | step hire_waiter, HUD reveal 4; panel waiters; hand on @Button@1015 | 2 cashier(s) · 1 waiter(s) · 2 tables | 565 |
| walk_045.png | 86.3 | 1:26 | tutorial | btn_waiter_hire | step close_waiters, HUD reveal 4; panel waiters; hand on @Button@399 | 2 cashier(s) · 2 waiter(s) · 2 tables | 165 |
| walk_046.png | 86.8 | 1:26 | tutorial | hand_close_waiters | step close_waiters, HUD reveal 4; panel waiters; hand on @Button@399 | 2 cashier(s) · 2 waiter(s) · 2 tables | 165 |
| walk_047.png | 87.3 | 1:27 | tutorial | waiter_hired_1 | step waiter_done, HUD reveal 4 | 2 cashier(s) · 2 waiter(s) · 2 tables | 165 |
| walk_048.png | 87.8 | 1:27 | tutorial | step_waiter_done | step waiter_done, HUD reveal 4; Munshi-ji line lw3 | 2 cashier(s) · 2 waiter(s) · 2 tables | 182 |
| walk_049.png | 90.1 | 1:30 | tutorial | line_lw3 | step waiter_done, HUD reveal 4; Munshi-ji line lw3 | 2 cashier(s) · 2 waiter(s) · 2 tables | 182 |
| walk_050.png | 91.0 | 1:30 | tutorial | hud_reveal_5 | step waiter_done, HUD reveal 5; Munshi-ji line l12 | 2 cashier(s) · 2 waiter(s) · 2 tables | 182 |
| walk_051.png | 93.0 | 1:32 | tutorial | line_l12 | step waiter_done, HUD reveal 5; Munshi-ji line l12 | 2 cashier(s) · 2 waiter(s) · 2 tables | 182 |
| walk_052.png | 94.5 | 1:34 | tutorial | hud_reveal_6 | step free, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 198 |
| walk_053.png | 94.5 | 1:34 | tutorial | step_free | step free, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 198 |
| walk_054.png | 94.7 | 1:34 | tutorial | rack_tag | step free, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 198 |
| walk_055.png | 94.9 | 1:34 | tutorial | table_tag | step free, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 198 |
| walk_056.png | 112.7 | 1:52 | tutorial | tick | step free, HUD reveal 6; panel galla | 2 cashier(s) · 2 waiter(s) · 2 tables | 312 |
| walk_057.png | 115.8 | 1:55 | tutorial | task_ready_1 | step free, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 272 |
| walk_058.png | 126.7 | 2:06 | tutorial | tick | step free, HUD reveal 6; panel station:chai | 2 cashier(s) · 2 waiter(s) · 2 tables | 321 |
| walk_059.png | 134.7 | 2:14 | tutorial | tick | step free, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 209 |
| walk_060.png | 136.5 | 2:16 | tutorial | open_galla | step free, HUD reveal 6; panel galla | 2 cashier(s) · 2 waiter(s) · 2 tables | 178 |
| walk_061.png | 140.7 | 2:20 | tutorial | tick | step free, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 94 |
| walk_062.png | 143.5 | 2:23 | tutorial | task_claimed | step free, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 590 |
| walk_063.png | 143.6 | 2:23 | tutorial | btn_task_claim_1 | step free, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 590 |
| walk_064.png | 186.6 | 3:06 | tutorial | line_l14 | step ad_deal, HUD reveal 6; Munshi-ji line l14 | 2 cashier(s) · 2 waiter(s) · 2 tables | 838 |
| walk_065.png | 188.8 | 3:08 | tutorial | tick | step bubble, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 856 |
| walk_066.png | 189.6 | 3:09 | tutorial | ad_bubble | step bubble, HUD reveal 6; hand on AdBubble | 2 cashier(s) · 2 waiter(s) · 2 tables | 856 |
| walk_067.png | 189.8 | 3:09 | tutorial | hand_bubble | step bubble, HUD reveal 6; hand on AdBubble | 2 cashier(s) · 2 waiter(s) · 2 tables | 856 |
| walk_068.png | 190.6 | 3:10 | tutorial | btn_ad_bubble | step vip, HUD reveal 6; popup vip | 2 cashier(s) · 2 waiter(s) · 2 tables | 856 |
| walk_069.png | 191.3 | 3:11 | tutorial | hand_vip | step vip, HUD reveal 6; popup vip; hand on @Button@537 | 2 cashier(s) · 2 waiter(s) · 2 tables | 856 |
| walk_070.png | 193.7 | 3:13 | tutorial | btn_vip_free | step ad_lines, HUD reveal 6; Munshi-ji line l15 | 2 cashier(s) · 2 waiter(s) · 2 tables | 1,856 |
| walk_071.png | 193.9 | 3:13 | tutorial | task_ready_1 | step ad_lines, HUD reveal 6; Munshi-ji line l15 | 2 cashier(s) · 2 waiter(s) · 2 tables | 1,856 |
| walk_072.png | 196.4 | 3:16 | tutorial | line_l15 | step ad_lines, HUD reveal 6; Munshi-ji line l15 | 2 cashier(s) · 2 waiter(s) · 2 tables | 1,891 |
| walk_073.png | 199.9 | 3:19 | tutorial | line_l16 | step ad_lines, HUD reveal 6; Munshi-ji line l16 | 2 cashier(s) · 2 waiter(s) · 2 tables | 1,891 |
| walk_074.png | 202.9 | 3:22 | tutorial | tick | step build_btn, HUD reveal 6; hand on build_button | 2 cashier(s) · 2 waiter(s) · 2 tables | 2,000 |
| walk_075.png | 203.5 | 3:23 | tutorial | hand_build_btn | step build_btn, HUD reveal 6; hand on build_button | 2 cashier(s) · 2 waiter(s) · 2 tables | 2,000 |
| walk_076.png | 205.3 | 3:25 | tutorial | btn_build_button | step build_row, HUD reveal 6; panel daftar | 2 cashier(s) · 2 waiter(s) · 2 tables | 2,000 |
| walk_077.png | 205.8 | 3:25 | tutorial | open_daftar | step build_row, HUD reveal 6; panel daftar; hand on @Button@1279 | 2 cashier(s) · 2 waiter(s) · 2 tables | 2,000 |
| walk_078.png | 206.1 | 3:26 | tutorial | hand_build_row | step build_row, HUD reveal 6; panel daftar; hand on @Button@1279 | 2 cashier(s) · 2 waiter(s) · 2 tables | 2,000 |
| walk_079.png | 206.9 | 3:26 | tutorial | btn_build_tandoor | step build_close, HUD reveal 6; panel daftar | 2 cashier(s) · 2 waiter(s) · 2 tables | 0 |
| walk_080.png | 207.7 | 3:27 | tutorial | hand_build_close | step build_close, HUD reveal 6; panel daftar; hand on @Button@489 | 2 cashier(s) · 2 waiter(s) · 2 tables | 0 |
| walk_081.png | 211.6 | 3:31 | tutorial | line_l17 | step outro, HUD reveal 6; Munshi-ji line l17 | 2 cashier(s) · 2 waiter(s) · 2 tables | 18 |
| walk_082.png | 212.5 | 3:32 | free play | step_done | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 18 |
| walk_083.png | 213.2 | 3:33 | free play | buildtag_lassi__false | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 18 |
| walk_084.png | 217.6 | 3:37 | free play | task_claimed | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 583 |
| walk_085.png | 217.7 | 3:37 | free play | btn_task_claim_1 | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 583 |
| walk_086.png | 237.3 | 3:57 | free play | btn_hire | step done, HUD reveal 6; panel station:chai | 2 cashier(s) · 2 waiter(s) · 2 tables | 772 |
| walk_087.png | 242.8 | 4:02 | free play | next_chip_save | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 623 |
| walk_088.png | 250.2 | 4:10 | free play | unlock_chai_chai.coffee | step done, HUD reveal 6; panel station:chai | 2 cashier(s) · 2 waiter(s) · 2 tables | 508 |
| walk_089.png | 255.8 | 4:15 | free play | line_menu_dish_chai | step done, HUD reveal 6; Munshi-ji line menu_dish_chai | 2 cashier(s) · 2 waiter(s) · 2 tables | 508 |
| walk_090.png | 257.6 | 4:17 | free play | task_claimed | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 1,208 |
| walk_091.png | 257.7 | 4:17 | free play | btn_task_claim_0 | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 1,208 |
| walk_092.png | 258.5 | 4:18 | free play | home_button_shown | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 1,208 |
| walk_093.png | 260.4 | 4:20 | free play | panned_away | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 1,331 |
| walk_094.png | 265.5 | 4:25 | free play | btn_home_button | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 1,331 |
| walk_095.png | 266.9 | 4:26 | free play | home_button_back | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 1,454 |
| walk_096.png | 287.9 | 4:47 | free play | tick | step done, HUD reveal 6; panel station:chai | 2 cashier(s) · 2 waiter(s) · 2 tables | 797 |
| walk_097.png | 362.9 | 6:02 | free play | tick | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 962 |
| walk_098.png | 372.9 | 6:12 | free play | seats_full_pill | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 739 |
| walk_099.png | 380.0 | 6:20 | free play | seats_full_pill | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 901 |
| walk_100.png | 390.1 | 6:30 | free play | open_station-tandoor | step done, HUD reveal 6; panel station:tandoor | 2 cashier(s) · 2 waiter(s) · 2 tables | 819 |
| walk_101.png | 392.4 | 6:32 | free play | home_button_shown | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 762 |
| walk_102.png | 402.8 | 6:42 | free play | next_chip_build | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 14,280 |
| walk_103.png | 403.0 | 6:43 | free play | build_tag | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 14,280 |
| walk_104.png | 403.3 | 6:43 | free play | buildtag_lassi__true | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 14,280 |
| walk_105.png | 408.1 | 6:48 | free play | line_menu_lassi | step done, HUD reveal 6; Munshi-ji line menu_lassi | 2 cashier(s) · 2 waiter(s) · 2 tables | 14,480 |
| walk_106.png | 409.5 | 6:49 | free play | btn_build_tag | step done, HUD reveal 6; panel daftar | 2 cashier(s) · 2 waiter(s) · 2 tables | 14,480 |
| walk_107.png | 410.9 | 6:50 | free play | btn_build_lassi | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 11,480 |
| walk_108.png | 411.4 | 6:51 | free play | buildtag_lassi_built_true | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 11,480 |
| walk_109.png | 411.9 | 6:51 | free play | buildtag_kadai_waiters-3_false | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 11,480 |
| walk_110.png | 412.0 | 6:51 | free play | next_chip_waiter_gate | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 11,480 |
| walk_111.png | 412.1 | 6:52 | free play | built_lassi | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 11,480 |
| walk_112.png | 418.1 | 6:58 | free play | btn_next_chip_waiter_gate | step done, HUD reveal 6; panel waiters; hand on @Button@1790 | 2 cashier(s) · 2 waiter(s) · 2 tables | 12,750 |
| walk_113.png | 418.7 | 6:58 | free play | hand_done | step done, HUD reveal 6; panel waiters | 2 cashier(s) · 3 waiter(s) · 2 tables | 11,550 |
| walk_114.png | 419.5 | 6:59 | free play | buildtag_kadai__false | step done, HUD reveal 6; panel waiters | 2 cashier(s) · 3 waiter(s) · 2 tables | 11,754 |
| walk_115.png | 423.0 | 7:02 | free play | tick | step done, HUD reveal 6 | 2 cashier(s) · 3 waiter(s) · 2 tables | 11,925 |
| walk_116.png | 428.5 | 7:08 | free play | open_seating | step done, HUD reveal 6; panel seating | 2 cashier(s) · 3 waiter(s) · 2 tables | 12,129 |
| walk_117.png | 429.2 | 7:09 | free play | btn_seating_add | step done, HUD reveal 6 | 2 cashier(s) · 3 waiter(s) · 3 tables | 11,829 |
| walk_118.png | 430.1 | 7:10 | free play | table_added_2 | step done, HUD reveal 6 | 2 cashier(s) · 3 waiter(s) · 3 tables | 11,829 |
| walk_119.png | 436.9 | 7:16 | free play | table_added_3 | step done, HUD reveal 6 | 2 cashier(s) · 3 waiter(s) · 4 tables | 11,936 |
| walk_120.png | 452.4 | 7:32 | free play | home_button_shown | step done, HUD reveal 6 | 2 cashier(s) · 3 waiter(s) · 4 tables | 7,556 |
| walk_121.png | 483.0 | 8:02 | free play | tick | step done, HUD reveal 6; panel station:tandoor | 2 cashier(s) · 3 waiter(s) · 4 tables | 7,777 |
| walk_122.png | 486.1 | 8:06 | free play | unlock_tandoor_tandoor.naan | step done, HUD reveal 6; panel station:tandoor | 2 cashier(s) · 3 waiter(s) · 4 tables | 5,524 |
| walk_123.png | 491.6 | 8:11 | free play | line_menu_dish_tandoor | step done, HUD reveal 6; Munshi-ji line menu_dish_tandoor | 2 cashier(s) · 3 waiter(s) · 4 tables | 7,036 |
| walk_124.png | 495.6 | 8:15 | free play | open_station-lassi | step done, HUD reveal 6; panel station:lassi | 2 cashier(s) · 3 waiter(s) · 4 tables | 13,338 |
| walk_125.png | 543.0 | 9:03 | free play | tick | step done, HUD reveal 6 | 2 cashier(s) · 3 waiter(s) · 4 tables | 5,760 |
| walk_126.png | 582.9 | 9:42 | free play | ad_bubble | step done, HUD reveal 6; popup vip | 2 cashier(s) · 3 waiter(s) · 4 tables | 13,156 |
| walk_127.png | 603.0 | 10:03 | free play | tick | step done, HUD reveal 6 | 2 cashier(s) · 3 waiter(s) · 4 tables | 51,426 |
| walk_128.png | 609.2 | 10:09 | free play | unlock_lassi_lassi.chaas | step done, HUD reveal 6; panel station:lassi | 2 cashier(s) · 3 waiter(s) · 4 tables | 40,925 |
| walk_129.png | 616.0 | 10:16 | free play | line_menu_dish_lassi | step done, HUD reveal 6; Munshi-ji line menu_dish_lassi | 2 cashier(s) · 3 waiter(s) · 4 tables | 27,669 |
| walk_130.png | 663.0 | 11:03 | free play | tick | step done, HUD reveal 6; panel station:lassi | 2 cashier(s) · 3 waiter(s) · 4 tables | 30,514 |
| walk_131.png | 723.1 | 12:03 | free play | tick | step done, HUD reveal 6 | 2 cashier(s) · 3 waiter(s) · 4 tables | 19,117 |
| walk_132.png | 778.4 | 12:58 | free play | next_chip_build | step done, HUD reveal 6 | 2 cashier(s) · 3 waiter(s) · 4 tables | 298,884 |
| walk_133.png | 783.8 | 13:03 | free play | line_menu_kadai | step done, HUD reveal 6; Munshi-ji line menu_kadai | 2 cashier(s) · 3 waiter(s) · 4 tables | 307,492 |
| walk_134.png | 785.3 | 13:05 | free play | btn_build_tag | step done, HUD reveal 6; panel daftar | 2 cashier(s) · 3 waiter(s) · 4 tables | 307,492 |
| walk_135.png | 787.2 | 13:07 | free play | buildtag_kadai_built_false | step done, HUD reveal 6 | 2 cashier(s) · 3 waiter(s) · 4 tables | 63,448 |
| walk_136.png | 792.1 | 13:12 | free play | btn_peti | step done, HUD reveal 6 | 2 cashier(s) · 3 waiter(s) · 4 tables | 673,448 |
| walk_137.png | 806.8 | 13:26 | free play | unlock_lassi_lassi.mango_lassi | step done, HUD reveal 6; panel station:lassi | 2 cashier(s) · 3 waiter(s) · 4 tables | 516,550 |
| walk_138.png | 813.1 | 13:33 | free play | tick | step done, HUD reveal 6 | 2 cashier(s) · 3 waiter(s) · 4 tables | 519,401 |
| walk_139.png | 816.9 | 13:36 | free play | open_station-kadai | step done, HUD reveal 6; panel station:kadai | 2 cashier(s) · 3 waiter(s) · 4 tables | 519,401 |
| walk_140.png | 869.3 | 14:29 | free play | unlock_kadai_kadai.dal | step done, HUD reveal 6; panel station:kadai | 2 cashier(s) · 3 waiter(s) · 4 tables | 42,519 |
| walk_141.png | 875.0 | 14:35 | free play | line_menu_dish_kadai | step done, HUD reveal 6; Munshi-ji line menu_dish_kadai | 2 cashier(s) · 3 waiter(s) · 4 tables | 61,937 |
| walk_142.png | 882.9 | 14:42 | free play | unlock_chai_chai.green_tea | step done, HUD reveal 6; panel station:chai | 2 cashier(s) · 3 waiter(s) · 4 tables | 58,141 |
| walk_143.png | 888.1 | 14:48 | free play | tick | step done, HUD reveal 6 | 2 cashier(s) · 3 waiter(s) · 4 tables | 52,538 |
| walk_144.png | 963.1 | 16:03 | free play | tick | step done, HUD reveal 6 | 2 cashier(s) · 3 waiter(s) · 4 tables | 90,263 |
| walk_145.png | 984.5 | 16:24 | free play | unlock_tandoor_tandoor.keema_paratha | step done, HUD reveal 6; panel station:tandoor | 2 cashier(s) · 3 waiter(s) · 4 tables | 87,071 |
| walk_146.png | 1023.2 | 17:03 | free play | tick | step done, HUD reveal 6 | 2 cashier(s) · 3 waiter(s) · 4 tables | 252,063 |
| walk_147.png | 1083.2 | 18:03 | free play | tick | step done, HUD reveal 6 | 2 cashier(s) · 3 waiter(s) · 4 tables | 45,654 |
| walk_148.png | 1111.8 | 18:31 | free play | free_play_end | step done, HUD reveal 6 | 2 cashier(s) · 3 waiter(s) · 4 tables | 8,513 |
| walk_5min_t302.png | 302.9 | 5:02 | free play | tick (kept for the 5-minute comparison) | step done, HUD reveal 6 | 2 cashier(s) · 2 waiter(s) · 2 tables | 8,605 |

## 2. Panels and HUD elements (`panel_<state>_<what>.png`)

Staged runs from a fresh save; each state is set with the game's own debug flags:

- **early**: `--fresh --skip-tutorial --money=410 --buy=chai_lvl12,chai_speed,galla,tandoor` (1 waiter, lassi needs 2)
- **lassi**: `--money=330 --buy=chai_lvl12,galla,tandoor`, then the stage hires waiter 2 and builds the lassi
- **claim**: `--money=5000 --buy=chai_lvl24,galla,tandoor`: dish unlock, CLAIM, chest
- **mid**: `--money=10000000 --buy=galla,waiter,waiter,table,tandoor,lassi,chai_lvl60,tandoor_lvl30,lassi_lvl10,chai_hire,tandoor_hire`
- **seats**: `--money=500 --buy=chai_lvl20,chai_speed,chai_speed,galla,tandoor --arrivals=40`: seats full
- **session2**: the walk's own save relaunched with the clock 2 h 5 min on (offline popup)
- **start**: `--fresh --skip-tutorial --money=100` (chai only, 1 waiter, 1 cashier)
- **early5**: `--money=150 --buy=chai_lvl12,galla,waiter` (2 waiters, saving for the tandoor)
- **kadai**: `--money=2000 --buy=chai_lvl40,galla,waiter,tandoor,lassi,tandoor_lvl20,lassi_lvl10,table` (2 waiters, kadai waits on waiter 3)

| File | State |
|---|---|
| panel_early_hud_idle_early.png | early |
| panel_early_sheet_chai_early.png | early |
| panel_early_levelup_feedback_0.1s.png | early |
| panel_early_levelup_feedback_0.5s.png | early |
| panel_early_sheet_chai_info_tap.png | early |
| panel_early_sheet_tandoor_l1.png | early |
| panel_early_galla_early.png | early |
| panel_early_waiters_early.png | early |
| panel_early_seating_early.png | early |
| panel_early_daftar_build_early.png | early |
| panel_early_hisaab_early.png | early |
| panel_early_vip_popup.png | early |
| panel_early_settings_popup.png | early |
| panel_early_hudbtn_stats_button.png | early |
| panel_early_ad_bubble_home.png | early |
| panel_early_table_tag_ghost.png | early |
| panel_early_build_tag_lassi_needs_waiters.png | early |
| panel_early_zoomed_out_early.png | early |
| panel_lassi_after_note_need_waiters.png | lassi |
| panel_lassi_build_tag_needs_waiters_affordable_cash.png | lassi |
| panel_lassi_waiters_hire_offer.png | lassi |
| panel_lassi_waiters_hired_0.4s.png | lassi |
| panel_lassi_waiters_after_hire.png | lassi |
| panel_lassi_build_tag_lassi_affordable.png | lassi |
| panel_lassi_daftar_lassi_affordable.png | lassi |
| panel_lassi_lassi_built_0.6s.png | lassi |
| panel_lassi_lassi_built_2.6s.png | lassi |
| panel_lassi_home_with_lassi.png | lassi |
| panel_claim_line_menu_need_waiters_lassi.png | claim |
| panel_claim_sheet_chai_l24.png | claim |
| panel_claim_unlock_pop_0.25s.png | claim |
| panel_claim_unlock_pop_0.95s.png | claim |
| panel_claim_unlock_pop_2.4s.png | claim |
| panel_claim_sheet_chai_l25_after_pop.png | claim |
| panel_claim_kaam_claim_ready.png | claim |
| panel_claim_line_menu_dish_chai.png | claim |
| panel_claim_note_dish_chai.png | claim |
| panel_claim_kaam_claim_ready_calm.png | claim |
| panel_claim_task_claim_burst_0.3s.png | claim |
| panel_claim_task_claim_after_1.3s.png | claim |
| panel_claim_kaam_chest_ready.png | claim |
| panel_claim_chest_open_0.4s.png | claim |
| panel_claim_chest_open_2s.png | claim |
| panel_mid_home_mid.png | mid |
| panel_mid_sheet_chai_mid_L60.png | mid |
| panel_mid_sheet_tandoor_mid_L30.png | mid |
| panel_mid_sheet_lassi_mid_L10.png | mid |
| panel_mid_sheet_chai_mid_broke.png | mid |
| panel_mid_daftar_build_mid_kadai_needs_waiters.png | mid |
| panel_mid_hisaab_mid.png | mid |
| panel_mid_waiters_mid.png | mid |
| panel_mid_seating_mid.png | mid |
| panel_mid_galla_mid.png | mid |
| panel_mid_build_tag_kadai_needs_3_waiters.png | mid |
| panel_seats_seats_full_pill.png | seats |
| panel_seats_seats_full_pill_door.png | seats |
| panel_seats_hisaab_seats_full.png | seats |
| panel_seats_seating_from_pill.png | seats |
| panel_session2_relaunch_offline_popup.png | session2 |
| panel_session2_offline_collect_0.4s.png | session2 |
| panel_session2_offline_collect_2s.png | session2 |
| panel_session2_relaunch_home.png | session2 |
| panel_start_home.png | start |
| panel_start_rack.png | start |
| panel_start_sheet_chai.png | start |
| panel_start_waiters.png | start |
| panel_start_galla.png | start |
| panel_early5_home.png | early5 |
| panel_early5_rack.png | early5 |
| panel_early5_sheet_chai.png | early5 |
| panel_early5_waiters.png | early5 |
| panel_early5_galla.png | early5 |
| panel_kadai_home.png | kadai |
| panel_kadai_rack.png | kadai |
| panel_kadai_sheet_chai.png | kadai |
| panel_kadai_waiters.png | kadai |
| panel_kadai_galla.png | kadai |
