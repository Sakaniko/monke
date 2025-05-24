/obj/item/choice_beacon
	name = "choice beacon"
	desc = "Hey, why are you viewing this?!! Please let CentCom know about this odd occurrence."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-blue"
	inhand_icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	/// How many uses this item has before being deleted
	var/uses = 1
	/// Used in the deployment message - What company is sending the equipment, flavor
	var/company_source = "Central Command"
	/// Used inthe deployment message - What is the company saying with their message, flavor
	var/company_message = span_bold("Item request received. Your package is inbound, please stand back from the landing site.")

/obj/item/choice_beacon/interact(mob/user)
	. = ..()
	if(!can_use_beacon(user))
		return

	open_options_menu(user)

/// Return the list that will be used in the choice selection.
/// Entries should be in (type.name = type) fashion.
/obj/item/choice_beacon/proc/generate_display_names()
	return list()

/// Checks if this mob can use the beacon, returns TRUE if so or FALSE otherwise.
/obj/item/choice_beacon/proc/can_use_beacon(mob/living/user)
	if(user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return TRUE

	playsound(src, 'sound/machines/buzz-sigh.ogg', 40, TRUE)
	return FALSE

/// Opens a menu and allows the mob to pick an option from the list
/obj/item/choice_beacon/proc/open_options_menu(mob/living/user)
	var/list/display_names = generate_display_names()
	if(!length(display_names))
		return
	var/choice = tgui_input_list(user, "Which item would you like to order?", "Select an Item", display_names)
	if(isnull(choice) || isnull(display_names[choice]))
		return
	if(!can_use_beacon(user))
		return

	consume_use(display_names[choice], user)

/// Consumes a use of the beacon, sending the user a message and creating their item in the process
/obj/item/choice_beacon/proc/consume_use(obj/choice_path, mob/living/user)
	to_chat(user, span_hear("You hear something crackle from the beacon for a moment before a voice speaks. \
		\"Please stand by for a message from [company_source]. Message as follows: [company_message] Message ends.\""))

	spawn_option(choice_path, user)
	uses--
	if(uses <= 0)
		do_sparks(3, source = src)
		qdel(src)
		return

	to_chat(user, span_notice("[uses] use[uses > 1 ? "s" : ""] remain[uses > 1 ? "" : "s"] on [src]."))

/// Actually spawns the item selected by the user
/obj/item/choice_beacon/proc/spawn_option(obj/choice_path, mob/living/user)
	podspawn(list(
		"target" = get_turf(src),
		"style" = STYLE_BLUESPACE,
		"spawn" = choice_path,
	))


/obj/item/choice_beacon/ingredient
	name = "ingredient delivery beacon"
	desc = "Summon a box of ingredients to help you get started cooking."
	icon_state = "gangtool-white"
	company_source = "Sophronia Broadcasting"
	company_message = span_bold("Please enjoy your Sophronia Broadcasting's 'Plasteel Chef' Ingredients Box, exactly as shown in the hit show!")

/obj/item/choice_beacon/ingredient/generate_display_names()
	var/static/list/ingredient_options
	if(!ingredient_options)
		ingredient_options = list()
		for(var/obj/item/storage/box/ingredients/box as anything in subtypesof(/obj/item/storage/box/ingredients))
			ingredient_options[initial(box.theme_name)] = box
	return ingredient_options

/obj/item/choice_beacon/hero
	name = "heroic beacon"
	desc = "To summon heroes from the past to protect the future."
	company_source = "Sophronia Broadcasting"
	company_message = span_bold("Please enjoy your Sophronia Broadcasting's 'History Comes Alive branded' Costume Set, exactly as shown in the hit show!")

/obj/item/choice_beacon/hero/generate_display_names()
	var/static/list/hero_item_list
	if(!hero_item_list)
		hero_item_list = list()
		for(var/obj/item/storage/box/hero/box as anything in typesof(/obj/item/storage/box/hero))
			hero_item_list[initial(box.name)] = box
	return hero_item_list

/obj/item/choice_beacon/augments
	name = "augment beacon"
	desc = "Summons augmentations. Can be used 3 times!"
	uses = 3
	company_source = "S.E.L.F."
	company_message = span_bold("Item request received. Your package has been teleported, use the autosurgeon supplied to apply the upgrade.")

/obj/item/choice_beacon/augments/generate_display_names()
	var/static/list/augment_list
	if(!augment_list)
		augment_list = list()
		// cyberimplants range from a nice bonus to fucking broken bullshit so no subtypesof
		var/list/selectable_types = list(
			/obj/item/organ/internal/cyberimp/brain/anti_drop,
			/obj/item/organ/internal/cyberimp/arm/item_set/toolset,
			/obj/item/organ/internal/cyberimp/arm/item_set/surgery,
			/obj/item/organ/internal/cyberimp/chest/thrusters,
			/obj/item/organ/internal/lungs/cybernetic/tier3,
			/obj/item/organ/internal/liver/cybernetic/tier3,
			/obj/item/organ/internal/spleen/cybernetic/tier3,
		)
		for(var/obj/item/organ/organ as anything in selectable_types)
			augment_list[initial(organ.name)] = organ

	return augment_list

// just drops the box at their feet, "quiet" and "sneaky"
/obj/item/choice_beacon/augments/spawn_option(obj/choice_path, mob/living/user)
	new choice_path(get_turf(user))
	playsound(src, 'sound/weapons/emitter2.ogg', 50, extrarange = SILENCED_SOUND_EXTRARANGE)

/obj/item/choice_beacon/holy
	name = "armaments beacon"
	desc = "Contains a set of armaments for the chaplain."

/obj/item/choice_beacon/holy/can_use_beacon(mob/living/user)
	if(user.mind?.holy_role)
		return ..()

	playsound(src, 'sound/machines/buzz-sigh.ogg', 40, TRUE)
	return FALSE

// Overrides generate options so that we can show a neat radial instead
/obj/item/choice_beacon/holy/open_options_menu(mob/living/user)
	if(GLOB.holy_armor_type)
		to_chat(user, span_warning("A selection has already been made."))
		consume_use(GLOB.holy_armor_type, user)
		return

	// Not bothering to cache this stuff because it'll only even be used once
	var/list/armament_names_to_images = list()
	var/list/armament_names_to_typepaths = list()
	for(var/obj/item/storage/box/holy/holy_box as anything in typesof(/obj/item/storage/box/holy))
		var/box_name = initial(holy_box.name)
		var/obj/item/preview_item = initial(holy_box.typepath_for_preview)
		armament_names_to_typepaths[box_name] = holy_box
		armament_names_to_images[box_name] = image(icon = initial(preview_item.icon), icon_state = initial(preview_item.icon_state))

	var/chosen_name = show_radial_menu(
		user = user,
		anchor = src,
		choices = armament_names_to_images,
		custom_check = CALLBACK(src, PROC_REF(can_use_beacon), user),
		require_near = TRUE,
	)
	if(!can_use_beacon(user))
		return
	var/chosen_type = armament_names_to_typepaths[chosen_name]
	if(!ispath(chosen_type, /obj/item/storage/box/holy))
		return

	consume_use(chosen_type, user)

/obj/item/choice_beacon/holy/spawn_option(obj/choice_path, mob/living/user)
	playsound(src, 'sound/effects/pray_chaplain.ogg', 40, TRUE)
	SSblackbox.record_feedback("tally", "chaplain_armor", 1, "[choice_path]")
	GLOB.holy_armor_type = choice_path
	return ..()

//Monkestation edit start

//Gun Beacons
//HoS weapon beacon
//objective datum handled in objective_items.dm
/obj/item/choice_beacon/hos_gun
	name = "head of security's gun beacon"
	desc = "A single use beacon to deliver a gunset of your choice to help with security detail."
	company_source = "Central Command"
	company_message = span_bold("Supply Pod incoming, please stand back.")

/obj/item/choice_beacon/hos_gun/generate_display_names()
	var/static/list/selectable_guns = list(
		"X-01 MultiPhase Energy Gun" = /obj/item/gun/energy/e_gun/hos,
		"Lawbringer" = /obj/item/gun/energy/e_gun/lawbringer,
		"Compact Combat Shotgun" = /obj/item/gun/ballistic/shotgun/automatic/combat/compact,
	)
	return selectable_guns

//Command equipment choice beacons
//These sections all handle what are choices available in the beacons objective datums are handled in objective_items.dm
//HoS
/obj/item/choice_beacon/hos_equipment
	name = "head of security's equipment beacon"
	desc = "A single use beacon to choose one of several prototype security items ready to be field tested by the Head of Security."
	company_source = "NanoTrasen Security Division"
	company_message = span_bold("Prototype Delivery Pod incoming, please stand back.")

/obj/item/choice_beacon/hos_equipment/generate_display_names()
	var/static/list/selectable_equipment = list (
		"Dual Stun Baton" = /obj/item/melee/baton/dual/loaded,
		"Light Amplification Goggles" = /obj/item/clothing/glasses/hud/security/lightamp,
		"Experimental Flash" = /obj/item/assembly/flash/experimental,
	)
	return selectable_equipment

//CMO
/obj/item/choice_beacon/cmo_equipment
	name = "chief medical officer's equipment beacon"
	desc = "A single use beacon to choose one of several highly valuable pieces of medical equipment, only approved for Chief Medical Officer use."
	company_source = "NanoTrasen Medical Division"
	company_message = span_bold("Medical Prototype Delivery Pod incoming, please stand back.")

/obj/item/choice_beacon/cmo_equipment/generate_display_names()
	var/static/list/selectable_equipment = list (
		"Hypospray" = /obj/item/reagent_containers/hypospray/cmo,
		"Bluespace Defibrillator" = /obj/item/shockpaddles/bluespace,
		"Advaned Medbeam Gun" = /obj/item/gun/medbeam/advanced,
	)
	return selectable_equipment
//RD
/obj/item/choice_beacon/rd_equipment
	name = "research director's equipment beacon"
	desc = "A single use beacon to choose one of several incredibly high-tech items that only the Research Director has been entrusted to test."
	company_source = "NanoTrasen Research Division"
	company_message = span_bold("Research Prototype Delivery Pod incoming, please stand back.")

/obj/item/choice_beacon/rd_equipment/generate_display_names()
	var/static/list/selectable_equipment = list (
		"O.M.N.I. HUD" = /obj/item/clothing/glasses/hud/omni

	)
	return selectable_equipment
//CE
/obj/item/choice_beacon/ce_equipment
	name = "chief engineer's equipment beacon"
	desc = "A single use beacon to choose one of several pieces of advanced engineering equipment that only the Chief Engineer has been given permission to use."
	company_source = "NanoTrasen Engineering Division"
	company_message = span_bold("Advanced Equipment Delivery Pod incoming, please stand back.")

/obj/item/choice_beacon/ce_equipment/generate_display_names()
	var/static/list/selectable_equipment = list (
		"Advanced Magboots" = /obj/item/clothing/shoes/magboots/advance
	)
	return selectable_equipment
//Monkestation edit end
