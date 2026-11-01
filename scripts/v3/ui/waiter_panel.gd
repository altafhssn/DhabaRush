class_name WaiterPanel
extends StaffPanel
## Retired in 0.3.4 (round 2 step 2, docs/round2/ui-proposal.md §3.4): every
## person is hired and upgraded in STAFF (StaffPanel, UiRoot.open_staff), and
## its row builders live in StaffRows. Kept as a thin wrapper for old callers:
## STAFF opened on the WAITERS tab. UiRoot no longer creates it.


func _before_open() -> void:
	tab = "waiters"
	super._before_open()
