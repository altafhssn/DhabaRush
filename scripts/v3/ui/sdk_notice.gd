class_name SdkNotice
extends RefCounted
## Player-facing messages for the ad and store SDKs (launch integration).
## The facades report reason codes (Ads.rewarded_block_reason(),
## Ads.last_rewarded_outcome(), the Iap.purchase_result signal); this turns
## them into one short line in the current language (the English text is the
## msgid; Hindi in res://i18n/hi.po) and shows it as the HUD toast, which
## sits above every popup.
##
## Callers: VipPopup (WATCH AD), OfflinePopup (COLLECT x2), SettingsPopup
## (RESTORE PURCHASES, PRIVACY OPTIONS, privacy policy link), UiRoot (every
## purchase result: pending, cancelled, failed, a late grant ...).
## The consent form itself is Google's (UMP), in the phone's language.


## "No rewarded ad right now" (x2 / WATCH AD tapped with nothing loaded).
static func ad_unavailable_text() -> String:
	var why: String = "loading"
	var ads: Node = UiKit.autoload("Ads")
	if ads != null and ads.has_method("rewarded_block_reason"):
		why = str(ads.call("rewarded_block_reason"))
	match why:
		"busy":
			return UiKit.t("Another ad is still open.")
		"consent":
			return UiKit.t("Ads are paused until you answer the privacy question.")
		"none":
			return UiKit.t("Ads are not available on this device.")
	return UiKit.t("No ad available right now. Try again in a minute.")


## Why the rewarded ad that just ended paid nothing ("" when it paid).
static func ad_result_text() -> String:
	var outcome: String = ""
	var ads: Node = UiKit.autoload("Ads")
	if ads != null and ads.has_method("last_rewarded_outcome"):
		outcome = str(ads.call("last_rewarded_outcome"))
	match outcome:
		"skipped":
			return UiKit.t("Watch the ad to the end to get the reward.")
		"failed":
			return UiKit.t("The ad could not play. Please try again.")
		"unavailable", "busy":
			return ad_unavailable_text()
	return ""


## Message for an Iap.purchase_result ("" for a plain successful purchase:
## the UI shows that itself, e.g. VIP turns ACTIVE).
static func purchase_text(result: String) -> String:
	match result:
		"pending":
			return UiKit.t("Payment pending. You will get it as soon as the payment goes through.")
		"granted":
			return UiKit.t("Payment received. Thank you!")
		"restored":
			return UiKit.t("Purchases restored.")
		"cancelled":
			return UiKit.t("Purchase cancelled.")
		"failed":
			return UiKit.t("Purchase failed. Please try again.")
		"unavailable":
			return UiKit.t("The store is not available right now. Please try again later.")
		"busy":
			return UiKit.t("Please wait, a purchase is still in progress.")
	return ""


## Settings › RESTORE PURCHASES: did the store answer, and is anything owned
## now?
static func restore_text(store_answered: bool, owns_something: bool) -> String:
	if not store_answered:
		return UiKit.t("Could not reach the store. Please try again later.")
	if owns_something:
		return UiKit.t("Purchases restored.")
	return UiKit.t("Nothing to restore.")


## Settings › PRIVACY OPTIONS could not open the form.
static func privacy_failed_text() -> String:
	return UiKit.t("Privacy options could not open. Please try again later.")


## Settings › privacy policy link could not be opened.
static func link_failed_text() -> String:
	return UiKit.t("Could not open the privacy policy.")


## Toast top (fraction of the screen height): under the popup cards' buttons
## (FREE CASH, WELCOME BACK) and over the dimmed HUD bottom.
const TOAST_Y := 0.84


## Shows `text` as the HUD toast (above popups). Empty text: nothing.
static func toast(text: String) -> void:
	if text == "":
		return
	var refs: Node = UiKit.autoload("Refs")
	var hud: Variant = refs.get("hud") if refs != null else null
	if hud != null and is_instance_valid(hud) and (hud as Object).has_method("toast"):
		(hud as Object).call("toast", text, TOAST_Y)
	elif OS.is_debug_build():
		print("[toast] (no HUD) " + text)
