SECTIONS
{
	"Signature checks disable" 0 : { *(ctr.signature.1) }
	":1" 0 : { *(ctr.signature.2) }
	"FIRM update protection" 0 : { *(ctr.firm_protect) }
	"DSi signature checks disable" 0 : { *(twl.signature.main) }
	":2" 0 : { *(twl.signature.rsa) }
	":3" 0 : { *(twl.signature.sha) }
	":4" 0 : { *(twl.signature.logo) }
	"DSi flash card checks disable" 0 : { *(twl.card.save_type) }
	":5" 0 : { *(twl.card.dsi_save) }
	":6" 0 : { *(twl.card.blacklist) }
	":7" 0 : { *(twl.card.whitelist) }
	"GBA signature checks disable" 0 : { *(agb.signature) }
	"GBA BIOS logo show" 0 : { *(agb.logo) }
}
