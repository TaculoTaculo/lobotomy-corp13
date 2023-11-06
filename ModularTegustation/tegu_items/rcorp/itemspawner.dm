//Split into weapons and not weapons.
/obj/effect/landmark/rcorpitemspawn
	name = "spawner for rcrop"
	desc = "It spawns an item. Notify a coder. Thanks!"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x4"
	var/list/possible_items = list(
	/obj/item/storage/firstaid/revival,
	/obj/item/reagent_containers/hypospray/medipen/salacid,
	/obj/item/reagent_containers/hypospray/medipen/mental,
	/obj/item/stack/sheet/mineral/sandbags,
	/obj/item/weldingtool,
	)
	var/list/possible_weapons = list(
	/obj/item/gun/energy/e_gun/rabbitdash,
	/obj/item/gun/energy/e_gun/rabbitdash/small,
	/obj/item/gun/energy/e_gun/rabbitdash/sniper,
	/obj/item/gun/energy/e_gun/rabbitdash/white,)


/obj/effect/landmark/rcorpitemspawn/Initialize()
	..()
	var/spawning = pick(possible_items)
	if(prob(30))
		spawning = pick(possible_weapons)
	new spawning(get_turf(src))
	var/timeradd = rand(1200, 3000)
	addtimer(CALLBACK(src, .proc/spawnagain), timeradd)

/obj/effect/landmark/rcorpitemspawn/proc/spawnagain()
	var/timeradd = rand(1200, 3000)
	addtimer(CALLBACK(src, .proc/spawnagain), timeradd)

	if(prob(80))	//20% to spawn
		return

	var/spawning = pick(possible_items)
	new spawning(get_turf(src))

//Golden Bough Objective
/obj/structure/golden_bough
	name = "Golden Bough"
	desc = "You need this."
	icon_state = "bough_pedestal"
	icon = 'ModularTegustation/Teguicons/32x48.dmi'
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE

	light_color = COLOR_YELLOW
	light_range = 2
	light_power = 2
	light_on = TRUE

	//Collecting vars
	var/cooldown
	var/list/bastards = list() //ckeys that have already tried to grab the bough

	//Visual Filters
	var/obj/effect/golden_bough/bough //The bough effect that is spawned above the pedestal
	var/f1 //Filter 1, Ripple filter applied on the bough effect.
	var/f2 //Filter 2, Rays filter,

/obj/structure/golden_bough/Initialize()
	..()
	bough = new/obj/effect/golden_bough(src)
	//Filter 1 gets applied to the bough
	bough.filters += filter(type="ripple", x = 0, y = 11, size = 20, repeat = 6, radius = 0, falloff = 1)
	f1 = bough.filters[bough.filters.len]
	//Filter 2 gets applied to the pedestal
	filters += filter(type="rays", x = 0, y = 11, size = 20, color = COLOR_VERY_SOFT_YELLOW, offset = 0.2, density = 10, factor = 0.4, threshold = 0.5)
	f2 = filters[filters.len]
	vis_contents += bough
	FilterLoop(1) //Starts the filter's loop

/obj/structure/golden_bough/Destroy()
	qdel(bough)
	..()

/obj/structure/golden_bough/proc/FilterLoop(loop_stage) //Takes a numeric argument for advancing the loop's stage in a cycle (1 > 2 > 3 > 1 > ...)
	if(filters[filters.len]) // Stops the loop if we have no filters to animate
		switch(loop_stage)
			if(1)
				animate(f1, radius = 60, falloff = 0.2, time = 60, flags = CIRCULAR_EASING | EASE_OUT | ANIMATION_PARALLEL)
				animate(f2, size = 30, offset = pick(4,5,6), threshold = 0.4, time = 60, flags = SINE_EASING | EASE_OUT | ANIMATION_PARALLEL)
				addtimer(CALLBACK(src, .proc/FilterLoop, 2), 6 SECONDS)
			if(2)
				animate(f1, size = 25, radius = 80, falloff = 0.8, time = 20, flags = CIRCULAR_EASING | EASE_OUT | ANIMATION_PARALLEL)
				animate(f2, size = 20, offset = pick(0.2,0.4), threshold = 0.5, time = 60, flags = SINE_EASING | EASE_OUT | ANIMATION_END_NOW | ANIMATION_PARALLEL)
				addtimer(CALLBACK(src, .proc/FilterLoop, 3), 2 SECONDS)
			if(3)
				animate(f1, size = 20, radius = 0, falloff = 1, time = 0, flags = CIRCULAR_EASING | EASE_IN | EASE_OUT | ANIMATION_PARALLEL)
				addtimer(CALLBACK(src, .proc/FilterLoop, 1), 4 SECONDS)
		update_icon()

/obj/structure/golden_bough/attack_hand(mob/living/carbon/human/user)
	if(cooldown > world.time)
		to_chat(user, "<span class='notice'>You're having a hard time grabbing this.</span>")
		return
	if(user.ckey in bastards)
		to_chat(user, "<span class='userdanger'>You already tried to grab this.</span>")
		return

	cooldown = world.time + 45 SECONDS // Spam prevention
	for(var/mob/M in GLOB.player_list)
		to_chat(M, "<span class='userdanger'>[uppertext(user.real_name)] is collecting the golden bough!</span>")

	RoundEndEffect(user)

/obj/structure/golden_bough/proc/RoundEndEffect(mob/living/carbon/human/user)
	bastards += user.ckey
	if(do_after(user, 45 SECONDS))
		clear_filters()
		bough.clear_filters()
		vis_contents.Cut()
		qdel(bough)
		light_on = FALSE
		update_light()
		SSticker.SetRoundEndSound('sound/abnormalities/donttouch/end.ogg')
		SSticker.force_ending = 1
		for(var/mob/M in GLOB.player_list)
			to_chat(M, "<span class='userdanger'>[uppertext(user.real_name)] has collected the bough!</span>")
	else
		user.gib() //lol, idiot.

/obj/effect/golden_bough
	name = "Golden Bough"
	desc = "the ramus aurum itself."
	icon = 'ModularTegustation/Teguicons/32x48.dmi'
	icon_state = "bough_bough"
	move_force = INFINITY
	pull_force = INFINITY
