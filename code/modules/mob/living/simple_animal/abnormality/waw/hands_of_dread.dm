//Huge thanks for Jack for helping design this abnormality o7 -Mel
/mob/living/simple_animal/hostile/abnormality/hands_of_dread
	name = "Hands of Dread"
	desc = "A hollowed out device. Very faintly, you can hear something inside whirring."
	health = 10000 //shouldnt matter, breaches in godmode
	maxHealth = 10000 //same as above
	icon = 'ModularTegustation/Teguicons/32x64.dmi'
	icon_state = "hands_of_the_dead"
	icon_living = "hands_of_the_dead"
	faction = list("neutral")
	speak_emote = list("burbles")
	threat_level = WAW_LEVEL
	fear_level = WAW_LEVEL + 1
	can_breach = TRUE
	start_qliphoth = 2
	damage_coeff = list(BRUTE = 1, RED_DAMAGE = 1, WHITE_DAMAGE = 1, BLACK_DAMAGE = 1, PALE_DAMAGE = 1)
	work_chances = list(
						ABNORMALITY_WORK_INSTINCT = 0, //50 primed
						ABNORMALITY_WORK_INSIGHT = 40, //60 primed
						ABNORMALITY_WORK_ATTACHMENT = 0, //50 primed
						ABNORMALITY_WORK_REPRESSION = 0 //50 primed
						)
	work_damage_amount = 13
	work_damage_type = WHITE_DAMAGE	//Bomb that may be armed is pretty scary.
	can_patrol = FALSE
	wander = FALSE
	light_color = COLOR_YELLOW
	light_range = 5
	light_power = 5
	var/primed = FALSE //acts differently when primed

	ego_list = list(
		/datum/ego_datum/weapon/executive,
		/datum/ego_datum/armor/executive
		)
	gift_type =  /datum/ego_gifts/executive

/mob/living/simple_animal/hostile/abnormality/hands_of_dread/FearEffectText(mob/affected_mob, level = 0)
	level = num2text(clamp(level, 3, 4)) //stolen from CENSORED
	var/list/result_text_list = list(
		"3" = list("Tick... Tock....", "It could go off at any time!!"),
		"4" = list("Why is such a thing here!?", "That thing is not armed... is it?")
		)
	return pick(result_text_list[level])

/mob/living/simple_animal/hostile/abnormality/hands_of_dread/Move()
	return FALSE

/mob/living/simple_animal/hostile/abnormality/hands_of_dread/CanAttack(atom/the_target)
	return FALSE

/mob/living/simple_animal/hostile/abnormality/hands_of_dread/PostWorkEffect(mob/living/carbon/human/user, work_type, pe, work_time)
	if(user.sanity_lost)
		datum_reference.qliphoth_change(-1)
	return

/mob/living/simple_animal/hostile/abnormality/hands_of_dread/OnQliphothChange(mob/living/carbon/human/user, amount = 1)
	primed = TRUE
	return ..()

/mob/living/simple_animal/hostile/abnormality/hands_of_dread/NeutralEffect(mob/living/carbon/human/user, work_type, pe)
	if(prob(33))
		datum_reference.qliphoth_change(-1)
	return

/mob/living/simple_animal/hostile/abnormality/hands_of_dread/BreachEffect(mob/living/carbon/human/user)
	..()
	var/turf/T = pick(GLOB.department_centers) //stolen from Blue Star
	forceMove(T)
	return
