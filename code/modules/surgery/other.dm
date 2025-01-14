//Procedures in this file: Internal wound patching, Implant removal.
//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
//	 Tendon fix surgery step
//////////////////////////////////////////////////////////////////
/singleton/surgery_step/fix_tendon
	name = "Repair tendon"
	allowed_tools = list(
		/obj/item/FixOVein = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/tape_roll = 50
	)
	can_infect = TRUE
	blood_level = BLOOD_LEVEL_HANDS
	min_duration = 7 SECONDS
	max_duration = 9 SECONDS
	shock_level = 40
	delicate = TRUE
	surgery_candidate_flags = SURGERY_NO_CRYSTAL | SURGERY_NO_ROBOTIC | SURGERY_NO_STUMP | SURGERY_NEEDS_RETRACTED

/singleton/surgery_step/fix_tendon/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = ..()
	if (!affected || !HAS_FLAGS(affected.status, ORGAN_TENDON_CUT))
		return FALSE
	return affected

/singleton/surgery_step/fix_tendon/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_NOTICE("\The [user] starts reattaching the damaged [affected.tendon_name] in [target]'s [affected.name] with \the [tool]."),
		SPAN_NOTICE("You start reattaching the damaged [affected.tendon_name] in [target]'s [affected.name] with \the [tool].")
	)
	target.custom_pain("The pain in your [affected.name] is unbearable!",100,affecting = affected)
	playsound(target, 'sound/items/fixovein.ogg', 50, TRUE)
	..()

/singleton/surgery_step/fix_tendon/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_NOTICE("\The [user] has reattached the [affected.tendon_name] in \the [target]'s [affected.name] with \a [tool]."),
		SPAN_NOTICE("You have reattached the [affected.tendon_name] in \the [target]'s [affected.name] with \the [tool].")
	)
	CLEAR_FLAGS(affected.status, ORGAN_TENDON_CUT)
	affected.update_damages()

/singleton/surgery_step/fix_tendon/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_WARNING("\The [user]'s hand slips, smearing \the [tool] in the incision in \the [target]'s [affected.name]!"),
		SPAN_WARNING("Your hand slips, smearing \the [tool] in the incision in \the [target]'s [affected.name]!")
	)
	affected.take_external_damage(5, used_weapon = tool)

//////////////////////////////////////////////////////////////////
//	 IB fix surgery step
//////////////////////////////////////////////////////////////////
/singleton/surgery_step/fix_vein
	name = "Repair arterial bleeding"
	allowed_tools = list(
		/obj/item/FixOVein = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/tape_roll = 50
	)
	can_infect = TRUE
	blood_level = BLOOD_LEVEL_HANDS
	min_duration = 7 SECONDS
	max_duration = 9 SECONDS
	shock_level = 40
	delicate = TRUE
	strict_access_requirement = FALSE
	surgery_candidate_flags = SURGERY_NO_CRYSTAL | SURGERY_NO_ROBOTIC | SURGERY_NO_STUMP | SURGERY_NEEDS_RETRACTED

/singleton/surgery_step/fix_vein/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = ..()
	if (!affected || !HAS_FLAGS(affected.status, ORGAN_ARTERY_CUT))
		return FALSE
	return affected

/singleton/surgery_step/fix_vein/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_NOTICE("\The [user] starts patching the damaged [affected.artery_name] in \the [target]'s [affected.name] with \a [tool]."),
		SPAN_NOTICE("You start patching the damaged [affected.artery_name] in \the [target]'s [affected.name] with \the [tool].")
	)
	target.custom_pain("The pain in your [affected.name] is unbearable!", 100, affecting = affected)
	playsound(target, 'sound/items/fixovein.ogg', 50, TRUE)
	..()

/singleton/surgery_step/fix_vein/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_NOTICE("\The [user] has patched the [affected.artery_name] in \the [target]'s [affected.name] with \a [tool]."),
		SPAN_NOTICE("You have patched the [affected.artery_name] in \the [target]'s [affected.name] with \the [tool].")
	)
	CLEAR_FLAGS(affected.status, ORGAN_ARTERY_CUT)
	affected.update_damages()

/singleton/surgery_step/fix_vein/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_WARNING("\The [user]'s hand slips, smearing \the [tool] in the incision in \the [target]'s [affected.name]!"),
		SPAN_WARNING("Your hand slips, smearing \the [tool] in the incision in \the [target]'s [affected.name]!")
	)
	affected.take_external_damage(5, used_weapon = tool)


//////////////////////////////////////////////////////////////////
//	 Hardsuit removal surgery step
//////////////////////////////////////////////////////////////////
/singleton/surgery_step/hardsuit
	name = "Remove hardsuit"
	allowed_tools = list(
		/obj/item/weldingtool = 80,
		/obj/item/circular_saw = 60,
		/obj/item/psychic_power/psiblade/master/grand/paramount = 100,
		/obj/item/psychic_power/psiblade = 75,
		/obj/item/gun/energy/plasmacutter = 30
	)
	min_duration = 12 SECONDS
	max_duration = 18 SECONDS

/singleton/surgery_step/hardsuit/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return TRUE


/singleton/surgery_step/hardsuit/assess_surgery_candidate(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target_zone == BP_CHEST && istype(target.back, /obj/item/rig) && !(target.back.canremove)


/singleton/surgery_step/hardsuit/get_skill_reqs(mob/living/user, mob/living/carbon/human/target, obj/item/tool)
	return list(SKILL_EVA = SKILL_BASIC)


/singleton/surgery_step/hardsuit/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	if (!.)
		return

	if (isWelder(tool))
		var/obj/item/weldingtool/welder = tool
		if (!welder.remove_fuel(1, user))
			return FALSE

/singleton/surgery_step/hardsuit/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("\The [user] starts cutting through the support systems of \the [target]'s [target.back] with \a [tool]."),
		SPAN_NOTICE("You start cutting through the support systems of \the [target]'s [target.back] with \the [tool].")
	)
	playsound(target, 'sound/items/circularsaw.ogg', 50, TRUE)
	..()

/singleton/surgery_step/hardsuit/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/rig/rig = target.back
	if (!istype(rig))
		return
	rig.reset()
	user.visible_message(
		SPAN_NOTICE("\The [user] has cut through the support systems of \the [target]'s [rig.name] with \a [tool]."),
		SPAN_NOTICE("You have cut through the support systems of \the [target]'s [rig.name] with \the [tool].")
	)

/singleton/surgery_step/hardsuit/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(
		SPAN_DANGER("\The [user]'s [tool.name] can't quite seem to get through the metal..."), \
		SPAN_DANGER("Your [tool.name] can't quite seem to get through the metal. It's weakening, though - try again.")
	)


//////////////////////////////////////////////////////////////////
//	 Disinfection step
//////////////////////////////////////////////////////////////////
/singleton/surgery_step/sterilize
	name = "Sterilize wound"
	allowed_tools = list(
		/obj/item/reagent_containers/spray = 100,
		/obj/item/reagent_containers/dropper = 100,
		/obj/item/reagent_containers/glass/bottle = 90,
		/obj/item/reagent_containers/food/drinks/flask = 90,
		/obj/item/reagent_containers/glass/beaker = 75,
		/obj/item/reagent_containers/food/drinks/bottle = 75,
		/obj/item/reagent_containers/food/drinks/glass2 = 75,
		/obj/item/reagent_containers/glass/bucket = 50
	)
	min_duration = 5 SECONDS
	max_duration = 6 SECONDS

/singleton/surgery_step/sterilize/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = ..()
	if (!affected || affected.is_disinfected() || !check_chemicals(tool))
		return FALSE
	return affected


/singleton/surgery_step/sterilize/get_skill_reqs(mob/living/user, mob/living/carbon/human/target, obj/item/tool)
	return list(SKILL_MEDICAL = SKILL_BASIC)


/singleton/surgery_step/sterilize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_NOTICE("\The [user] starts pouring \a [tool]'s contents on \the [target]'s [affected.name]."),
		SPAN_NOTICE("You start pouring \the [tool]'s contents on \the [target]'s [affected.name].")
	)
	target.custom_pain("Your [affected.name] is on fire!", 50, affecting = affected)
	playsound(target, 'sound/items/spray_1.ogg', 15, TRUE)
	..()

/singleton/surgery_step/sterilize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if (!istype(tool, /obj/item/reagent_containers))
		return

	var/obj/item/reagent_containers/container = tool

	var/amount = container.amount_per_transfer_from_this
	var/temp_holder = new/obj()
	var/datum/reagents/temp_reagents = new(amount, temp_holder)
	container.reagents.trans_to_holder(temp_reagents, amount)

	var/trans = temp_reagents.trans_to_mob(target, temp_reagents.total_volume, CHEM_BLOOD) //technically it's contact, but the reagents are being applied to internal tissue
	if (trans > 0)
		user.visible_message(
			SPAN_NOTICE("\The [user] rubs \the [target]'s [affected.name] down with \a [tool]'s contents"),
			SPAN_NOTICE("You rub \the [target]'s [affected.name] down with \the [tool]'s contents.")
		)
	affected.disinfect()
	qdel(temp_reagents)
	qdel(temp_holder)

/singleton/surgery_step/sterilize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if (!istype(tool, /obj/item/reagent_containers))
		return
	var/obj/item/reagent_containers/container = tool

	container.reagents.trans_to_mob(target, container.amount_per_transfer_from_this, CHEM_BLOOD)

	user.visible_message(
		SPAN_WARNING("\The [user]'s hand slips, spilling \the [tool]'s contents over the \the [target]'s [affected.name]!"),
		SPAN_WARNING("Your hand slips, spilling \the [tool]'s contents over the \the [target]'s [affected.name]!")
	)
	affected.disinfect()

/singleton/surgery_step/sterilize/proc/check_chemicals(obj/item/reagent_containers/container)
	if(istype(container) && container.is_open_container())
		if(container.reagents.has_reagent(/datum/reagent/sterilizine))
			return TRUE
		else
			var/datum/reagent/ethanol/booze = locate() in container.reagents.reagent_list
			if(istype(booze))
				if(booze.strength <= 40)
					return TRUE
	return FALSE
