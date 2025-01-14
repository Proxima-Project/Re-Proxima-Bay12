//Procedures in this file: Robotic limbs attachment, meat limbs attachment
//////////////////////////////////////////////////////////////////
//						LIMB SURGERY							//
//////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////
//	 generic limb surgery step datum
//////////////////////////////////////////////////////////////////
/singleton/surgery_step/limb
	shock_level = 40
	delicate = TRUE

/singleton/surgery_step/limb/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if (affected)
		return affected
	var/list/organ_data = target.species.has_limbs["[target_zone]"]
	return !isnull(organ_data)

//////////////////////////////////////////////////////////////////
//	 limb attachment surgery step
//////////////////////////////////////////////////////////////////
/singleton/surgery_step/limb/attach
	name = "Replace limb"
	allowed_tools = list(/obj/item/organ/external = 100)
	min_duration = 5 SECONDS
	max_duration = 7 SECONDS


/singleton/surgery_step/limb/attach/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/organ_to_attach = tool
	var/obj/item/organ/external/parent_organ = target.organs_by_name[organ_to_attach.parent_organ]
	var/obj/item/organ/external/current_organ = target.organs_by_name[organ_to_attach.organ_tag]

	if (HAS_FLAGS(organ_to_attach.status, ORGAN_CONFIGURE) && organ_to_attach.surgery_configure(user, target, parent_organ, tool, src))
		return FALSE

	if (!parent_organ)
		USE_FEEDBACK_FAILURE("\The [target]'s [organ_to_attach.amputation_point] is missing. You can't attach \the [tool] there.")
		return FALSE

	if (parent_organ.is_stump())
		USE_FEEDBACK_FAILURE("\The [target]'s [parent_organ.name] is a stump. You can't attach \the [tool] there.")
		return FALSE

	if (current_organ)
		USE_FEEDBACK_FAILURE("\The [target] already has \a [current_organ][current_organ.is_stump() ? " stump" : ""] attached there. It must be removed before you can attach \the [tool].")
		return FALSE

	if (BP_IS_ROBOTIC(parent_organ) && !BP_IS_ROBOTIC(organ_to_attach))
		USE_FEEDBACK_FAILURE("\The [target]'s [parent_organ.name] is robotic but \the [tool] is not. You cannot attach it.")
		return FALSE

	if (BP_IS_CRYSTAL(parent_organ) && !BP_IS_CRYSTAL(organ_to_attach))
		USE_FEEDBACK_FAILURE("\The [target]'s [parent_organ.name] is crystalline but \the [tool] is not. You cannot attach it.")
		return FALSE

	if (!BP_IS_CRYSTAL(parent_organ) && BP_IS_CRYSTAL(organ_to_attach))
		USE_FEEDBACK_FAILURE("\The [tool] is crystalline but \the [target]'s [parent_organ.name] is not. You cannot attach it.")
		return FALSE

	return TRUE


/singleton/surgery_step/limb/attach/get_skill_reqs(mob/living/user, mob/living/carbon/human/target, obj/item/tool, target_zone)
	var/obj/item/organ/external/external_organ = tool
	if (!istype(external_organ) || !BP_IS_ROBOTIC(external_organ))
		return ..()
	if (target.isSynthetic())
		return SURGERY_SKILLS_ROBOTIC
	return SURGERY_SKILLS_ROBOTIC_ON_MEAT


/singleton/surgery_step/limb/attach/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	if (!.)
		return

	var/obj/item/organ/external/external_tool = tool
	var/obj/item/organ/external/attach_point = target.organs_by_name[external_tool.parent_organ]
	return (attach_point && !attach_point.is_stump() && !(BP_IS_ROBOTIC(attach_point) && !BP_IS_ROBOTIC(external_tool)))

/singleton/surgery_step/limb/attach/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = tool
	user.visible_message(
		SPAN_NOTICE("\The [user] starts attaching \a [affected] to \the [target]'s [affected.amputation_point]."),
		SPAN_NOTICE("You start attaching \the [affected] to \the [target]'s [affected.amputation_point].")
	)
	playsound(target, 'sound/items/bonesetter.ogg', 50, TRUE)

/singleton/surgery_step/limb/attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!user.unEquip(tool))
		FEEDBACK_UNEQUIP_FAILURE(user, tool)
		return
	var/obj/item/organ/external/external = tool
	var/datum/pronouns/pronouns = target.choose_from_pronouns()
	user.visible_message(
		SPAN_NOTICE("\The [user] has attached \the [target]'s [external.name] to [pronouns.his] [external.amputation_point]."),
		SPAN_NOTICE("You have attached \the [target]'s [external.name] to [pronouns.his] [external.amputation_point].")
	)
	external.replaced(target)
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()

/singleton/surgery_step/limb/attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/external = tool
	user.visible_message(
		SPAN_WARNING("\The [user]'s hand slips, damaging \the [target]'s [external.amputation_point]!"),
		SPAN_WARNING("Your hand slips, damaging \the [target]'s [external.amputation_point]!")
	)
	target.apply_damage(10, DAMAGE_BRUTE, damage_flags = DAMAGE_FLAG_SHARP)

//////////////////////////////////////////////////////////////////
//	 limb connecting surgery step
//////////////////////////////////////////////////////////////////
/singleton/surgery_step/limb/connect
	name = "Connect limb"
	allowed_tools = list(
		/obj/item/hemostat = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/device/assembly/mousetrap = 20
	)
	can_infect = TRUE
	min_duration = 10 SECONDS
	max_duration = 12 SECONDS


/singleton/surgery_step/limb/connect/get_skill_reqs(mob/living/user, mob/living/carbon/human/target, obj/item/tool, target_zone)
	var/obj/item/organ/external/external_organ = target && target.get_organ(target_zone)
	if (!istype(external_organ) || !BP_IS_ROBOTIC(external_organ))
		return ..()
	if (target.isSynthetic())
		return SURGERY_SKILLS_ROBOTIC
	return SURGERY_SKILLS_ROBOTIC_ON_MEAT


/singleton/surgery_step/limb/connect/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	if (!.)
		return

	var/obj/item/organ/external/external = target.get_organ(target_zone)
	return external && !external.is_stump() && HAS_FLAGS(external.status, ORGAN_CUT_AWAY)

/singleton/surgery_step/limb/connect/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_NOTICE("\The [user] starts connecting tendons and muscles in \the [target]'s [affected.amputation_point] with \a [tool]."),
		SPAN_NOTICE("You start connecting tendons and muscle in \the [target]'s [affected.amputation_point] with \the [tool].")
	)
	playsound(target, 'sound/items/fixovein.ogg', 50, TRUE)

/singleton/surgery_step/limb/connect/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/external = target.get_organ(target_zone)
	user.visible_message(
		SPAN_NOTICE("\The [user] has connected tendons and muscles in \the [target]'s [external.amputation_point] with \a [tool]."),
		SPAN_NOTICE("You have connected tendons and muscles in \the [target]'s [external.amputation_point] with \the [tool].")
	)
	CLEAR_FLAGS(external.status, ORGAN_CUT_AWAY)
	if (external.children)
		for (var/obj/item/organ/external/child in external.children)
			CLEAR_FLAGS(child.status, ORGAN_CUT_AWAY)
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()

/singleton/surgery_step/limb/connect/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/external = target.get_organ(target_zone)
	user.visible_message(
		SPAN_WARNING("\The [user]'s hand slips, damaging \the [target]'s [external.amputation_point]!"),
		SPAN_WARNING("Your hand slips, damaging \the [target]'s [external.amputation_point]!")
	)
	target.apply_damage(10, DAMAGE_BRUTE, damage_flags = DAMAGE_FLAG_SHARP)

//////////////////////////////////////////////////////////////////
//	 robotic limb attachment surgery step
//////////////////////////////////////////////////////////////////
/singleton/surgery_step/limb/mechanize
	name = "Attach prosthetic limb"
	allowed_tools = list(/obj/item/robot_parts = 100)

	min_duration = 8 SECONDS
	max_duration = 10 SECONDS


/singleton/surgery_step/limb/mechanize/get_skill_reqs(mob/living/user, mob/living/carbon/human/target, obj/item/tool)
	if (target.isSynthetic())
		return SURGERY_SKILLS_ROBOTIC
	return SURGERY_SKILLS_ROBOTIC_ON_MEAT


/singleton/surgery_step/limb/mechanize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	if (!.)
		return

	var/obj/item/robot_parts/robot_parts = tool
	if (robot_parts.part)
		if (!(target_zone in robot_parts.part))
			return FALSE

	return isnull(target.get_organ(target_zone))

/singleton/surgery_step/limb/mechanize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("\The [user] starts attaching \a [tool] to \the [target]."),
		SPAN_NOTICE("You start attaching \the [tool] to \the [target].")
	)
	playsound(target, 'sound/items/bonesetter.ogg', 50, TRUE)

/singleton/surgery_step/limb/mechanize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/robot_parts/robot_parts = tool
	user.visible_message(
		SPAN_NOTICE("\The [user] has attached \a [tool] to \the [target]."),
		SPAN_NOTICE("You have attached \the [tool] to \the [target].")
	)

	if (robot_parts.part)
		for (var/part_name in robot_parts.part)
			if (!isnull(target.get_organ(part_name)))
				continue
			var/list/organ_data = target.species.has_limbs["[part_name]"]
			if (!organ_data)
				continue
			var/new_limb_type = organ_data["path"]
			var/obj/item/organ/external/new_limb = new new_limb_type(target)
			new_limb.robotize(robot_parts.model_info)
			if (robot_parts.sabotaged)
				SET_FLAGS(new_limb.status, ORGAN_SABOTAGED)

	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()

	qdel(tool)

/singleton/surgery_step/limb/mechanize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(
		SPAN_WARNING("\The [user]'s hand slips, damaging \the [target]'s flesh with \the [tool]!"),
		SPAN_WARNING("Your hand slips, damaging \the [target]'s flesh with \the [tool]!")
	)
	target.apply_damage(10, DAMAGE_BRUTE, damage_flags = DAMAGE_FLAG_SHARP)
