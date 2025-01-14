//Procedures in this file: Fracture repair surgery
//////////////////////////////////////////////////////////////////
//						BONE SURGERY							//
//////////////////////////////////////////////////////////////////

/singleton/surgery_step/bone
	surgery_candidate_flags = SURGERY_NO_ROBOTIC | SURGERY_NO_CRYSTAL | SURGERY_NEEDS_ENCASEMENT
	var/required_stage = 0

/singleton/surgery_step/bone/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = ..()
	if (!affected || !HAS_FLAGS(affected.status, ORGAN_BROKEN) || affected.stage != required_stage)
		return FALSE
	return affected

//////////////////////////////////////////////////////////////////
//	bone gelling surgery step
//////////////////////////////////////////////////////////////////
/singleton/surgery_step/bone/glue
	name = "Begin bone repair"
	allowed_tools = list(
		/obj/item/bonegel = 100,
		/obj/item/tape_roll = 75
	)
	can_infect = TRUE
	blood_level = BLOOD_LEVEL_HANDS
	min_duration = 5 SECONDS
	max_duration = 6 SECONDS
	shock_level = 20

/singleton/surgery_step/bone/glue/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/bone = affected.encased ? "\the [target]'s [affected.encased]" : "bones in \the [target]'s [affected.name]"
	if (affected.stage == 0)
		user.visible_message(
			SPAN_NOTICE("\The [user] starts applying \a [tool] to [bone]."),
			SPAN_NOTICE("You start applying \the [tool] to [bone].")
		)
	target.custom_pain("Something in your [affected.name] is causing you a lot of pain!", 50, affecting = affected)
	playsound(target, 'sound/items/bonegel.ogg', 50, TRUE)

	..()

/singleton/surgery_step/bone/glue/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/bone = affected.encased ? "\the [target]'s [affected.encased]" : "bones in \the [target]'s [affected.name]"
	user.visible_message(
		SPAN_NOTICE("\The [user] applies some [tool.name] to [bone]"),
		SPAN_NOTICE("You apply some [tool.name] to [bone].")
	)
	if (affected.stage == 0)
		affected.stage = 1
	CLEAR_FLAGS(affected.status, ORGAN_BRITTLE)

/singleton/surgery_step/bone/glue/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_WARNING("\The [user]'s hand slips, smearing \the [tool] in the incision in \the [target]'s [affected.name]!"),
		SPAN_WARNING("Your hand slips, smearing \the [tool] in the incision in \the [target]'s [affected.name]!")
	)


//////////////////////////////////////////////////////////////////
//	bone setting surgery step
//////////////////////////////////////////////////////////////////
/singleton/surgery_step/bone/set_bone
	name = "Set bone"
	allowed_tools = list(
		/obj/item/bonesetter = 100,
		/obj/item/swapper/power_drill = 100,
		/obj/item/wrench = 75
	)
	min_duration = 6 SECONDS
	max_duration = 7 SECONDS
	shock_level = 40
	delicate = TRUE
	surgery_candidate_flags = SURGERY_NO_ROBOTIC | SURGERY_NEEDS_ENCASEMENT
	required_stage = 1

/singleton/surgery_step/bone/set_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/bone = affected.encased ? "\the [target]'s [affected.encased]" : "bones in \the [target]'s [affected.name]"
	if (affected.encased == "skull")
		user.visible_message(
			SPAN_NOTICE("\The [user] begins to piece [bone] back together with \a [tool]."),
			SPAN_NOTICE("You begin to piece [bone] back together with \the [tool].")
		)
	else
		user.visible_message(
			SPAN_NOTICE("\The [user] begins to set [bone] in place with \a [tool]."),
			SPAN_NOTICE("You begin to set [bone] in place with \the [tool].")
		)
	target.custom_pain("The pain in your [affected.name] is going to make you pass out!", 50, affecting = affected)
	playsound(target, 'sound/items/bonesetter.ogg', 50, TRUE)

	..()

/singleton/surgery_step/bone/set_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/bone = affected.encased ? "\the [target]'s [affected.encased]" : "bones in \the [target]'s [affected.name]"
	if (HAS_FLAGS(affected.status, ORGAN_BROKEN))
		var/verb = affected.encased == "skull" ? "piece" : "set"
		user.visible_message(
			SPAN_NOTICE("\The [user] [verb]s [bone] back together with \a [tool]."),
			SPAN_NOTICE("You [verb] [bone] back together with \the [tool].")
		)
		affected.stage = 2
		return

	user.visible_message(
		"[SPAN_NOTICE("\The [user] sets [bone]")] [SPAN_WARNING("in the WRONG place with \a [tool].")]",
		"[SPAN_NOTICE("You set [bone]")] [SPAN_WARNING("in the WRONG place with \the [tool].")]"
	)
	affected.fracture()

/singleton/surgery_step/bone/set_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_WARNING("\The [user]'s hand slips, damaging the [affected.encased ? affected.encased : "bones"] in \the [target]'s [affected.name] with \the [tool]!") , \
		SPAN_WARNING("Your hand slips, damaging the [affected.encased ? affected.encased : "bones"] in \the [target]'s [affected.name] with \the [tool]!")
	)
	affected.fracture()
	affected.take_external_damage(5, used_weapon = tool)

//////////////////////////////////////////////////////////////////
//	post setting bone-gelling surgery step
//////////////////////////////////////////////////////////////////
/singleton/surgery_step/bone/finish
	name = "Finish bone repair"
	allowed_tools = list(
		/obj/item/bonegel = 100,
		/obj/item/tape_roll = 75
	)
	can_infect = TRUE
	blood_level = BLOOD_LEVEL_HANDS
	min_duration = 5 SECONDS
	max_duration = 6 SECONDS
	shock_level = 20
	required_stage = 2

/singleton/surgery_step/bone/finish/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/bone = affected.encased ? "\the [target]'s damaged [affected.encased]" : "damaged bones in \the [target]'s [affected.name]"
	user.visible_message(
		SPAN_NOTICE("\The [user] starts to finish mending [bone] with \a [tool]."),
		SPAN_NOTICE("You start to finish mending [bone] with \the [tool].")
	)
	playsound(target, 'sound/items/bonegel.ogg', 50, TRUE)

	..()

/singleton/surgery_step/bone/finish/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/bone = affected.encased ? "\the [target]'s damaged [affected.encased]" : "damaged bones in \the [target]'s [affected.name]"
	user.visible_message(
		SPAN_NOTICE("\The [user] has mended [bone] with \a [tool]."),
		SPAN_NOTICE("You have mended [bone] with \the [tool].")
	)
	CLEAR_FLAGS(affected.status, ORGAN_BROKEN)
	affected.stage = 0
	affected.update_wounds()

/singleton/surgery_step/bone/finish/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_WARNING("\The [user]'s hand slips, smearing \the [tool] in the incision in \the [target]'s [affected.name]!"),
		SPAN_WARNING("Your hand slips, smearing \the [tool] in the incision in \the [target]'s [affected.name]!")
	)
