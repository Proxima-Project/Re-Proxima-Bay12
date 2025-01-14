 //////////////////////////////////////////////////////////////////
//	facial reconstruction surgery step
//////////////////////////////////////////////////////////////////
/singleton/surgery_step/fix_face
	name = "Repair face"
	allowed_tools = list(
		/obj/item/hemostat = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/device/assembly/mousetrap = 10,
		/obj/item/material/utensil/fork = 75
	)
	min_duration = 10 SECONDS
	max_duration = 12 SECONDS
	surgery_candidate_flags = SURGERY_NO_ROBOTIC | SURGERY_NO_CRYSTAL | SURGERY_NEEDS_RETRACTED

/singleton/surgery_step/fix_face/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (target_zone != BP_HEAD)
		return FALSE
	var/obj/item/organ/external/affected = ..()
	if (!affected)
		return FALSE
	if (!HAS_FLAGS(affected.status, ORGAN_DISFIGURED))
		return FALSE
	return affected

/singleton/surgery_step/fix_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("\The [user] starts repairing damage to \the [target]'s face with \a [tool]."),
		SPAN_NOTICE("You start repairing damage to \the [target]'s face with \the [tool].")
	)
	playsound(target, 'sound/items/hemostat.ogg', 50, TRUE)
	..()

/singleton/surgery_step/fix_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("\The [user] repairs \the [target]'s face with \a [tool]."),
		SPAN_NOTICE("You repair \the [target]'s face with \the [tool].")
	)
	var/obj/item/organ/external/head/head = target.get_organ(target_zone)
	if (!head)
		return
	CLEAR_FLAGS(head.status, ORGAN_DISFIGURED)

/singleton/surgery_step/fix_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_WARNING("\The [user]'s hand slips, tearing skin on \the [target]'s face with \the [tool]!"),
		SPAN_WARNING("Your hand slips, tearing skin on \the [target]'s face with \the [tool]!")
	)
	affected.take_external_damage(10, 0, DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE, tool)

//////////////////////////////////////////////////////////////////
//	Plastic Surgery
//////////////////////////////////////////////////////////////////

/singleton/surgery_step/plastic_surgery
	surgery_candidate_flags = SURGERY_NO_ROBOTIC | SURGERY_NO_CRYSTAL | SURGERY_NEEDS_RETRACTED
	var/required_stage = 0

/singleton/surgery_step/plastic_surgery/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (target_zone != BP_HEAD)
		return FALSE
	var/obj/item/organ/external/affected = ..()
	if (!affected)
		return FALSE
	if (affected.stage != required_stage)
		return FALSE
	return affected

/singleton/surgery_step/plastic_surgery/prepare_face
	name = "Prepare Face"
	allowed_tools = list(
		/obj/item/scalpel = 100,
		/obj/item/material/shard = 50
	)
	min_duration = 10 SECONDS
	max_duration = 12 SECONDS
	can_infect = TRUE
	shock_level = 20

/singleton/surgery_step/plastic_surgery/prepare_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("\The [user] starts peeling back the skin around \the [target]'s face with \a [tool]."),
		SPAN_NOTICE("You start peeling back the skin around \the [target]'s face with \the [tool].")
	)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if (affected.stage == 0)
		affected.stage = 1
	playsound(target, 'sound/items/scalpel.ogg', 50, TRUE)
	..()

/singleton/surgery_step/plastic_surgery/prepare_face/end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("\The [user] finishes peeling back the skin around \the [target]'s face with \a [tool]."),
		SPAN_NOTICE("You finish peeling back the skin around \the [target]'s face with \the [tool].")
	)

/singleton/surgery_step/plastic_surgery/prepare_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_WARNING("\The [user]'s hand slips, tearing skin on \the [target]'s face with \the [tool]!"),
		SPAN_WARNING("Your hand slips, tearing skin on \the [target]'s face with \the [tool]!")
	)
	affected.take_external_damage(10, 0, DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE, tool)

/singleton/surgery_step/plastic_surgery/reform_face
	name = "Reform Face"
	allowed_tools = list(
		/obj/item/hemostat = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/device/assembly/mousetrap = 10,
		/obj/item/material/utensil/fork = 75
	)
	min_duration = 10 SECONDS
	max_duration = 12 SECONDS
	can_infect = TRUE
	shock_level = 20
	required_stage = 1

/singleton/surgery_step/plastic_surgery/reform_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("\The [user] starts molding \the [target]'s face with \a [tool]."),
		SPAN_NOTICE("You start molding \the [target]'s face with \the [tool].")
	)
	playsound(target, 'sound/items/hemostat.ogg', 50, TRUE)
	..()

/singleton/surgery_step/plastic_surgery/reform_face/end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("\The [user] finishes molding \the [target]'s face with \a [tool]."),
		SPAN_NOTICE("You finish molding \the [target]'s face with \the [tool].")
	)
	if (!target.fake_name)
		var/new_name = sanitizeSafe(input(user, "Select a new name for \the [target].") as text|null, MAX_NAME_LEN)
		if (!new_name || !user.use_sanity_check(target, tool))
			return
		user.visible_message(
			SPAN_NOTICE("\The [user] molds \the [target]'s face into the spitting image of [new_name] with \a [tool]!"),
			SPAN_NOTICE("You mold \the [target]'s face into the spitting image of [new_name] with \the [tool]!")
		)
		target.fake_name = new_name
		target.name = new_name
	else
		target.fake_name = null
		user.visible_message(
			SPAN_NOTICE("\The [user] returns \the [target]'s face back to normal with \a [tool]!"),
			SPAN_NOTICE("You return \the [target]'s face back to normal with \the [tool]!")
		)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	affected.stage = 0

/singleton/surgery_step/plastic_surgery/reform_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_WARNING("\The [user]'s hand slips, tearing skin on \the [target]'s face with \the [tool]!"),
		SPAN_WARNING("Your hand slips, tearing skin on \the [target]'s face with \the [tool]!")
	)
	var/obj/item/organ/external/head/head = target.get_organ(target_zone)
	affected.take_external_damage(10, 0, DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE, tool)
	if (head)
		CLEAR_FLAGS(head.status, ORGAN_DISFIGURED)
