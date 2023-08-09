/mob/living/simple_animal/hostile/abnormality/shrimp_exec
	name = "Hands of the Dead"
	desc = "A hollowed out device, very faintly, you can hear something inside whirring."
	icon = 'ModularTegustation/Teguicons/32x32.dmi'
	icon_state = "executive"
	icon_living = "executive"
	faction = list("neutral")
	speak_emote = list("burbles")
	threat_level = WAW_LEVEL
	start_qliphoth = 1
	work_chances = list(
						ABNORMALITY_WORK_INSTINCT = 30,
						ABNORMALITY_WORK_INSIGHT = 30,
						ABNORMALITY_WORK_ATTACHMENT = 30,
						ABNORMALITY_WORK_REPRESSION = -100	//He's a snobby shrimp dude.
						)
	work_damage_amount = 11
	work_damage_type = WHITE_DAMAGE	//He insults you.

	ego_list = list(
		/datum/ego_datum/weapon/executive,
		/datum/ego_datum/armor/executive
		)
	gift_type =  /datum/ego_gifts/executive