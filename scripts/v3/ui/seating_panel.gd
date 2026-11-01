class_name SeatingPanel
extends Daftar
## Retired in 0.3.4 (round 2 step 2, docs/round2/ui-proposal.md §3.5; owner
## decision 4: BUILD covers counters and tables): tables are built from the
## ghost table's 2-tap card (QuickBuy) or BUILD's TABLES row (Daftar), and the
## SEATING numbers (seats, seats full, left with no seat) are STATS rows.
## UiRoot.open_seating() redirects there (open_tables). Kept as a thin
## wrapper for old callers: BUILD with the TABLES row highlighted. UiRoot no
## longer creates it.


func open(p_tab: String = "build") -> void:
	super.open(p_tab)
	focus_tables()
