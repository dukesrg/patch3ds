SECTIONS
{
	"Signature checks disable:1" 0 : AT(0) { *(ctr.signature.1) }
	"Signature checks disable:2" 0 : AT(0) { *(ctr.signature.2) }
	"FIRM update protection" 0 : AT(0) { *(ctr.firm_protect) }
	"DSi signature checks disable:1" 0 : AT(0) { *(twl.signature.main) }
	"DSi signature checks disable:2" 0 : AT(0) { *(twl.signature.rsa) }
	"DSi signature checks disable:3" 0 : AT(0) { *(twl.signature.sha) }
	"DSi signature checks disable:4" 0 : AT(0) { *(twl.signature.logo) }
	"DSi flash card checks disable:1" 0 : AT(0) { *(twl.card.save_type) }
	"DSi flash card checks disable:2" 0 : AT(0) { *(twl.card.dsi_save) }
	"DSi flash card checks disable:3" 0 : AT(0) { *(twl.card.blacklist) }
	"DSi flash card checks disable:4" 0 : AT(0) { *(twl.card.whitelist) }
	"GBA signature checks disable" 0 : AT(0) { *(agb.signature) }
	"GBA BIOS logo show" 0 : AT(0) { *(agb.logo) }
}
