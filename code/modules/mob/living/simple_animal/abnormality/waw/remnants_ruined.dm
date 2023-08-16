//Huge thanks for Jack for helping design this abnormality o7 -Mel
/mob/living/simple_animal/hostile/abnormality/remnants_ruined
	name = "Remnants of a Ruined World"
	desc = "A hollowed out device. Very faintly, you can hear something inside whirring."
	maxHealth = 400
	health = 400
	icon = 'ModularTegustation/Teguicons/32x64.dmi'
	icon_state = "remnants_ruined"
	threat_level = WAW_LEVEL
	start_qliphoth = 2
	work_chances = list(
						ABNORMALITY_WORK_INSTINCT = 0,
						ABNORMALITY_WORK_INSIGHT = 40,
						ABNORMALITY_WORK_ATTACHMENT = 0,
						ABNORMALITY_WORK_REPRESSION = 0
						)
	work_damage_amount = 10
	work_damage_type = WHITE_DAMAGE	//Bomb are pretty scary.
	light_color = COLOR_YELLOW
	light_range = 5
	light_power = 5
	var/explosion_damage = 250 //Instantly insane even at maximum prudence if you aren't wearing any armor, yeowch.

	var/time = 1 MINUTES //Should be enough for you to get a work in
	var/timing_id
	var/finish_time
	var/obj/effect/countdown/remnants_ruined/countdown

	var/list/normal_work_chances = list(
						ABNORMALITY_WORK_INSTINCT = 0,
						ABNORMALITY_WORK_INSIGHT = 40,
						ABNORMALITY_WORK_ATTACHMENT = 0,
						ABNORMALITY_WORK_REPRESSION = 0
						)
	var/list/primed_work_chances =  list(
						ABNORMALITY_WORK_INSTINCT = 60,
						ABNORMALITY_WORK_INSIGHT = 60,
						ABNORMALITY_WORK_ATTACHMENT = 60,
						ABNORMALITY_WORK_REPRESSION = 60
						)

	ego_list = list(
		/datum/ego_datum/weapon/executive,
		/datum/ego_datum/armor/executive
		)
	gift_type =  /datum/ego_gifts/executive


/mob/living/simple_animal/hostile/abnormality/remnants_ruined/Initialize()
	. = ..()
	countdown = new(src)

/mob/living/simple_animal/hostile/abnormality/remnants_ruined/Destroy()
	QDEL_NULL(countdown)
	. =..()

//Fluff examine
/mob/living/simple_animal/hostile/abnormality/remnants_ruined/examine(mob/user)
	. = ..()
	switch(datum_reference?.qliphoth_meter)
		if(0)
			to_chat(user, "It seems like it is armed to explode!")
		if(1)
			to_chat(user, "You feel like fiddling with it may be a bad idea.")

//If qliph lowers, prime the bomb
/mob/living/simple_animal/hostile/abnormality/remnants_ruined/proc/PrimeBomb()
	say("Prime Bomb")
	icon_state = "remnants_ruined_primed"
	fear_level = WAW_LEVEL + 1 //ALEPH
	work_damage_amount = 15 //5 more damage per tick
	work_chances = primed_work_chances.Copy()

//Lowers again, you're in for a bad time.
/mob/living/simple_animal/hostile/abnormality/remnants_ruined/proc/ArmBomb()
	say("Arm Bomb")
	ToggleCountdown()
	notify_ghosts("The remnants have been disturbed.", source = src, action = NOTIFY_ORBIT, header="Something Interesting!")
	icon_state = "remnants_ruined_armed"
	fear_level = WAW_LEVEL + 2 //ALEPH +1
	work_damage_amount = 20 //10 more damage per tick

/mob/living/simple_animal/hostile/abnormality/remnants_ruined/proc/ToggleCountdown()
	say("Countdown")
	if(!timing_id)
		finish_time = world.time + time
		timing_id = addtimer(CALLBACK(src, .proc/Explode), time, TIMER_STOPPABLE)
		countdown.start()
	else
		ResetBomb()

//resets everything that priming the bomb changes
/mob/living/simple_animal/hostile/abnormality/remnants_ruined/proc/ResetBomb()
	say("Reset Bomb")
	datum_reference.qliphoth_change(2)
	icon_state = "remnants_ruined"
	work_damage_amount = 10
	fear_level = WAW_LEVEL
	work_chances = normal_work_chances.Copy()
	deltimer(timing_id)
	timing_id = null
	countdown.stop()
	finish_time = null

//taken from BS
/mob/living/simple_animal/hostile/abnormality/remnants_ruined/proc/Explode()
	SLEEP_CHECK_DEATH(5 SECONDS)
	playsound(src, 'sound/abnormalities/bluestar/pulse.ogg', 100, FALSE, 40, falloff_distance = 20)
	for(var/mob/living/L in livinginrange(30, src)) //18 less range than Blue Star
		if(L.z != z)
			continue
		if(faction_check_mob(L))
			continue
		if(!ishuman(L))
			continue
		L.apply_damage((explosion_damage - (get_dist(src, L) * 2.5)), WHITE_DAMAGE, null, L.run_armor_check(null, WHITE_DAMAGE), spread_damage = TRUE) //My le bomb... le insaned people?
	ResetBomb()

//WORK RELATED STUFF
/mob/living/simple_animal/hostile/abnormality/remnants_ruined/MeltdownStart()
	datum_reference.qliphoth_change(-1)
	return ..()

/mob/living/simple_animal/hostile/abnormality/remnants_ruined/FailureEffect(mob/living/carbon/human/user, work_type, pe)
	datum_reference.qliphoth_change(-1)
	return

/mob/living/simple_animal/hostile/abnormality/remnants_ruined/NeutralEffect(mob/living/carbon/human/user, work_type, pe)
	if(prob(33))
		datum_reference.qliphoth_change(-1)
	return

/mob/living/simple_animal/hostile/abnormality/remnants_ruined/OnQliphothChange(mob/living/carbon/human/user, amount = 1)
	. = ..()
	if(datum_reference?.qliphoth_meter ==1)
		PrimeBomb()

/mob/living/simple_animal/hostile/abnormality/remnants_ruined/ZeroQliphoth(mob/living/carbon/human/user)
	. = ..()
	if(!timing_id)
		ArmBomb()


/mob/living/simple_animal/hostile/abnormality/remnants_ruined/AttemptWork(mob/living/carbon/human/user, work_type)
	if(datum_reference?.qliphoth_meter != 2) //are we not inert?
		to_chat(user, "Tick... Tock...")
	return ..()

/mob/living/simple_animal/hostile/abnormality/remnants_ruined/WorkChance(mob/living/carbon/human/user, chance, work_type)
	if(datum_reference?.qliphoth_meter != 2) //are we primed or armed?
		return chance - (get_attribute_level(user, TEMPERANCE_ATTRIBUTE)/5) //Negates temperance bonus entirely while primed

/*
TODO:
Countdown effects
Countdown
Sprites
sound/machines/nuke/angry_beep.ogg
playsound(loc, 'sound/items/timer.ogg', volume, FALSE)
*/
