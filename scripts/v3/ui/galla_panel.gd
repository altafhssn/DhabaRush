class_name GallaPanel
extends StaffPanel
## Retired in 0.3.4 (round 2 step 2, docs/round2/ui-proposal.md §3.4): the
## cashiers are hired and upgraded in STAFF › CASHIERS (StaffPanel,
## UiRoot.open_staff("cashiers"), also what a tap on a cash counter opens).
## Kept as a thin wrapper for old callers: STAFF opened on the CASHIERS tab.
## UiRoot no longer creates it.


func _before_open() -> void:
	tab = "cashiers"
	super._before_open()
