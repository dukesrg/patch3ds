SECTIONS
{
	"Signature checks disable" 0 : { *(ctr.signature.1) }
	"e" 0 : { *(ctr.signature.2) }

	"EmuNAND" 0 : { *(ctr.emunand.main) }
	"b" 0 : { *(ctr.emunand.flags) }
	"c" 0 : { *(ctr.emunand.writehook) }
	"X" 0 : { *(ctr.emunand.readhook) }
	"_sdmc" 0 : { *(ctr.emunand._sdmc) }

	"Reboot" 0 : { *(ctr.reboot.1) }
	"z" 0 : { *(ctr.reboot.2) }
	"_fopen" 0 : { *(ctr.reboot._fopen) }
	"_reboot_code" 0 : { *(ctr.reboot._reboot_code) }

	"Slot 0x25 KeyX" 0 : { *(ctr.slot25keyx.main) }
	"y" 0 : { *(ctr.slot25keyx.hook) }
	"_aes_setkey" 0 : { *(ctr.slot25keyx._aes_setkey) }
	"_aes_unk" 0 : { *(ctr.slot25keyx._aes_unk) }

	"FIRM update protection" 0 : { *(ctr.firm_protect) }

	"DSi signature checks disable" 0 : { *(twl.signature.main) }
	"k" 0 : { *(twl.signature.rsa) }
	"n" 0 : { *(twl.signature.sha) }
	"a" 0 : { *(twl.signature.logo) }

	"DSi flash card checks disable" 0 : { *(twl.card.save_type) }
	"o" 0 : { *(twl.card.dsi_save) }
	"t" 0 : { *(twl.card.blacklist) }
	"w" 0 : { *(twl.card.whitelist) }

	"GBA signature checks disable" 0 : { *(agb.signature) }

	"GBA BIOS logo show" 0 : { *(agb.logo) }
}
