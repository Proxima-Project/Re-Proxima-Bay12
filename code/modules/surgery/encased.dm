//Procedures in this file: Generic ribcage opening steps, Removing alien embryo, Fixing internal organs.
//////////////////////////////////////////////////////////////////
//				GENERIC	RIBCAGE SURGERY							//
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
//	generic ribcage surgery step datum
//////////////////////////////////////////////////////////////////
/singleton/surgery_step/open_encased
	name = "Saw through bone"
	allowed_tools = list(
		/obj/item/circular_saw = 100,
		/obj/item/material/knife = 50,
		/obj/item/material/hatchet = 75
	)
	can_infect = TRUE
	blood_level = BLOOD_LEVEL_HANDS
	min_duration = 5 SECONDS
	max_duration = 7 SECONDS
	shock_level = 60
	delicate = TRUE
	surgery_candidate_flags = SURGERY_NO_ROBOTIC | SURGERY_NO_CRYSTAL | SURGERY_NO_STUMP | SURGERY_NEEDS_RETRACTED

/singleton/surgery_step/open_encased/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = ..()
	if (!affected?.encased)
		return FALSE
	return affected

/singleton/surgery_step/open_encased/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_NOTICE("\The [user] begins to cut through [target]'s [affected.encased] with \a [tool]."),
		SPAN_NOTICE("You begin to cut through [target]'s [affected.encased] with \the [tool].")
	)
	target.custom_pain("Something hurts horribly in your [affected.name]!", 60, affecting = affected)
	playsound(target, 'sound/items/circularsaw.ogg', 50, TRUE)
	..()

/singleton/surgery_step/open_encased/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_NOTICE("\The [user] has cut \the [target]'s [affected.encased] open with \a [tool]."),
		SPAN_NOTICE("You have cut \the [target]'s [affected.encased] open with \the [tool].")
	)
	affected.fracture()

/singleton/surgery_step/open_encased/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_WARNING("\The [user]'s hand slips, cracking \the [target]'s [affected.encased] with \the [tool]!"),
		SPAN_WARNING("Your hand slips, cracking \the [target]'s [affected.encased] with \the [tool]!")
	)
	affected.take_external_damage(15, 0, DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE, tool)
	affected.fracture()
