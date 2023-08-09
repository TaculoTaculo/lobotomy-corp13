//Huge thanks for Jack for helping design this abnormality o7 -Mel
/mob/living/simple_animal/hostile/abnormality/hands_of_dread
	name = "Hands of Dread"
	desc = "A hollowed out device. Very faintly, you can hear something inside whirring."
	health = 100000 //shouldnt matter, takes 0 damage from everything
	maxHealth = 100000 //same as above
	icon = 'ModularTegustation/Teguicons/32x64.dmi'
	icon_state = "hands_of_dread"
	icon_living = "hands_of_dread"
	threat_level = WAW_LEVEL
	fear_level = WAW_LEVEL + 1 //ALEPH
	can_breach = TRUE
	start_qliphoth = 2
	damage_coeff = list(BRUTE = 1, RED_DAMAGE = 0, WHITE_DAMAGE = 0, BLACK_DAMAGE = 0, PALE_DAMAGE = 0)
	work_chances = list(
						ABNORMALITY_WORK_INSTINCT = -40, //40 primed
						ABNORMALITY_WORK_INSIGHT = 40, //50 primed
						ABNORMALITY_WORK_ATTACHMENT = -40, //40 primed
						ABNORMALITY_WORK_REPRESSION = -40 //40 primed
						)
	work_damage_amount = 13
	work_damage_type = WHITE_DAMAGE	//Bomb that may be armed is pretty scary.
	can_patrol = FALSE
	wander = FALSE
	light_color = COLOR_YELLOW
	light_range = 5
	light_power = 5
	var/primed = FALSE //acts differently when primed
	var/meltdown_count = 2 //After 2 meltdowns, primes itself

	ego_list = list(
		/datum/ego_datum/weapon/executive,
		/datum/ego_datum/armor/executive
		)
	gift_type =  /datum/ego_gifts/executive

//after 2 meltdowns, or if qliph changes, prime the bomb
/mob/living/simple_animal/hostile/abnormality/hands_of_dread/proc/PrimeBomb()
	primed = TRUE
	icon_state = "hands_of_dread_primed"
	fear_level = WAW_LEVEL + 2 //ALEPH +1
	work_damage_amount = 20 //7 more damage per tick
	meltdown_count = 2
	work_chances = list(
						ABNORMALITY_WORK_INSTINCT = 40,
						ABNORMALITY_WORK_INSIGHT = 50,
						ABNORMALITY_WORK_ATTACHMENT = 40,
						ABNORMALITY_WORK_REPRESSION = 40
						)

//resets everything that priming the bomb changes
/mob/living/simple_animal/hostile/abnormality/hands_of_dread/proc/ResetBomb()
	primed = FALSE
	datum_reference.qliphoth_change(2)
	icon_state = "hands_of_dread"
	work_damage_amount = 13
	fear_level = WAW_LEVEL + 1
	work_chances = list(
						ABNORMALITY_WORK_INSTINCT = -40,
						ABNORMALITY_WORK_INSIGHT = 40,
						ABNORMALITY_WORK_ATTACHMENT = -40,
						ABNORMALITY_WORK_REPRESSION = -40
						)
	meltdown_count = 2

/mob/living/simple_animal/hostile/abnormality/hands_of_dread/Move()
	return FALSE

/mob/living/simple_animal/hostile/abnormality/hands_of_dread/CanAttack(atom/the_target)
	return FALSE

//custom fear messages, stolen from CENSORED
/mob/living/simple_animal/hostile/abnormality/hands_of_dread/FearEffectText(mob/affected_mob, level = 0)
	level = num2text(clamp(level, 3, 4))
	var/list/result_text_list = list(
		"3" = list("Why is such a thing here!?", "It could go off at any time!!"),
		"4" = list("Tick... Tock...", "That thing is not armed... is it?")
		)
	return pick(result_text_list[level])

/mob/living/simple_animal/hostile/abnormality/hands_of_dread/OnQliphothEvent()
	if(!primed)
		meltdown_count--
		if(meltdown_count == 0)
			PrimeBomb()
	return ..()

/mob/living/simple_animal/hostile/abnormality/hands_of_dread/OnQliphothChange(mob/living/carbon/human/user, amount = 1)
	if(!primed)
		PrimeBomb()
	return ..()

/mob/living/simple_animal/hostile/abnormality/hands_of_dread/PostWorkEffect(mob/living/carbon/human/user, work_type, pe, work_time)
	if(user.sanity_lost)
		datum_reference.qliphoth_change(-1)
	return

/mob/living/simple_animal/hostile/abnormality/hands_of_dread/NeutralEffect(mob/living/carbon/human/user, work_type, pe)
	if(prob(33))
		datum_reference.qliphoth_change(-1)
	return

//taken from PoS
/mob/living/simple_animal/hostile/abnormality/hands_of_dread/ZeroQliphoth(mob/living/carbon/human/user)
	primed = FALSE
	SLEEP_CHECK_DEATH(5 SECONDS)
	sound_to_playing_players_on_level('sound/abnormalities/silence/price.ogg', 50, zlevel = z)
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(faction_check_mob(H, FALSE) || H.z != z || H.stat == DEAD)
			continue
		new /obj/effect/temp_visual/thirteen(get_turf(H))	//A visual effect if it hits
		H.apply_damage(300, WHITE_DAMAGE, null, H.run_armor_check(null, WHITE_DAMAGE), spread_damage = TRUE)
		ResetBomb()
	return

/mob/living/simple_animal/hostile/abnormality/hands_of_dread/BreachEffect(mob/living/carbon/human/user)
	..()
