/datum/quirk/amputee
	name = "Amputee"
	desc = "You are missing one of your limbs, for reasons only you know. Even if you replace it, the limb will never work."
	icon = FA_ICON_USER_SLASH //this is the best icon I could find.
	value = QUIRK_COST_AMPUTEE
	hardcore_value = QUIRK_HARDCORE_AMPUTEE
	quirk_flags = QUIRK_HUMAN_ONLY | QUIRK_CHANGES_APPEARANCE | QUIRK_DONT_CLONE
	/// The slot to REMOVE, in string form
	var/slot_string = "limb"
	/// The slot to DESTROY, in GLOB.limb_zones (both arms and both legs)
	var/limb_zone
	species_blacklist = list(SPECIES_OOZELING) //Species that would just negate missing a limb.

	var/obj/item/bodypart/amputated_limb //Variable where the limb that should be removed is stored

/datum/quirk/amputee/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_CARBON_ATTACH_LIMB, PROC_REF(on_limb_gain))

/datum/quirk/amputee/add_unique(client/client_source)
	limb_zone = GLOB.limb_choice[client_source?.prefs?.read_preference(/datum/preference/choiced/limb/amputee)]
	if (isnull(limb_zone))  //Client gone or they chose a random limb
		limb_zone = GLOB.limb_choice[pick(GLOB.limb_choice)]

	slot_string = body_zone_as_plaintext(limb_zone) //Copies name of chosen limb to use for the chat warning and med records
	medical_record_text = "Patient is missing their [slot_string]." //Medical Records text
	var/mob/living/carbon/human/human_holder = quirk_holder


	switch (limb_zone) //Check which limb the character has selected and save it to the variable...
		if (BODY_ZONE_L_ARM)
			amputated_limb = human_holder.get_bodypart(BODY_ZONE_L_ARM)
		if (BODY_ZONE_R_ARM)
			amputated_limb = human_holder.get_bodypart(BODY_ZONE_R_ARM)
		if (BODY_ZONE_L_LEG)
			amputated_limb = human_holder.get_bodypart(BODY_ZONE_L_LEG)
		if (BODY_ZONE_R_LEG)
			amputated_limb = human_holder.get_bodypart(BODY_ZONE_R_LEG)

	amputated_limb.drop_limb() //...then remove it...
	qdel(amputated_limb) //...then delete it once its removed, so it isn't just on the floor.

/datum/quirk/amputee/proc/on_limb_gain(datum/source, obj/item/bodypart/new_limb, special)
	var/mob/living/carbon/human/human_holder = quirk_holder
	SIGNAL_HANDLER
	if (limb_zone)
		human_holder.gain_trauma(new /datum/brain_trauma/severe/paralysis/limb(amputated_limb), TRAUMA_RESILIENCE_ABSOLUTE)


/datum/quirk/amputee/post_add()
	to_chat(quirk_holder, span_bolddanger("Your [slot_string] is missing."))

/datum/quirk/amputee/remove() //On quirk removal, give them back their limb.
	if(QDELETED(quirk_holder))
		return

	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.return_and_replace_bodypart(amputated_limb) //Use return and replace instead of reset because they don't have an arm to reset.
	human_holder.cure_trauma_type(/datum/brain_trauma/severe/paralysis/limb, TRAUMA_RESILIENCE_ABSOLUTE) //And give them limb control back.
