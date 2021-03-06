
/obj/item/weapon/reagent_containers/robodropper
	name = "Industrial Dropper"
	desc = "A larger dropper. Transfers 10 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dropper0"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1,2,3,4,5,6,7,8,9,10)
	volume = 10
	var/filled = 0

	afterattack(obj/target, mob/user , flag)
		if(!user.Adjacent(target))
			return

		if(!target.reagents) return

		if(filled)

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "<span class='warning'>[target] is full.</span>"
				return

			if(!target.is_open_container() && !ismob(target) && !istype(target,/obj/item/weapon/reagent_containers/food)) //You can inject humans and food but you cant remove the shit.
				user << "<span class='warning'>You cannot directly fill this object.</span>"
				return


			var/trans

			if(isobj(target))
				// /vg/: Logging transfers of bad things
				if(istype(reagents_to_log) && reagents_to_log.len && target.log_reagents)
					var/list/badshit=list()
					for(var/bad_reagent in reagents_to_log)
						if(reagents.has_reagent(bad_reagent))
							badshit += reagents_to_log[bad_reagent]

					if(badshit.len)
						var/hl="<span class='danger'>([english_list(badshit)])</span>"
						message_admins("[user.name] ([user.ckey]) added [trans]U to \a [target] with [src].[hl] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
						log_game("[user.name] ([user.ckey]) added [trans]U to \a [target] with [src].")
				trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
				user << "<span class='notice'>You transfer [trans] units of the solution.</span>"
				if (src.reagents.total_volume<=0)
					filled = 0
					icon_state = "dropper[filled]"

			else if(ismob(target))
				if(istype(target , /mob/living/carbon/human))
					var/mob/living/carbon/human/victim = target

					var/obj/item/safe_thing = victim.get_body_part_coverage(EYES)

					if(safe_thing)
						if(!safe_thing.reagents)
							safe_thing.create_reagents(100)
						trans = src.reagents.trans_to(safe_thing, amount_per_transfer_from_this)

						for(var/mob/O in viewers(world.view, user))
							O.show_message(text("<span class='danger'>[] tries to squirt something into []'s eyes, but fails!</span>", user, target), 1)
						spawn(5)
							src.reagents.reaction(safe_thing, TOUCH)


						user << "<span class='notice'>You transfer [trans] units of the solution.</span>"
						if (src.reagents.total_volume<=0)
							filled = 0
							icon_state = "dropper[filled]"
						return


				for(var/mob/O in viewers(world.view, user))
					O.show_message(text("<span class='danger'>[] squirts something into []'s eyes!</span>", user, target), 1)
				src.reagents.reaction(target, TOUCH)

				var/mob/M = target
				var/list/injected = list()
				for(var/datum/reagent/R in src.reagents.reagent_list)
					injected += R.name
				var/contained = english_list(injected)
				M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been squirted with [src.name] by [user.name] ([user.ckey]). Reagents: [contained]</font>")
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to squirt [M.name] ([M.key]). Reagents: [contained]</font>")
				msg_admin_attack("[user.name] ([user.ckey]) squirted [M.name] ([M.key]) with [src.name]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
				if(!iscarbon(user))
					M.LAssailant = null
				else
					M.LAssailant = user

		else

			if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers))
				user << "<span class='warning'>You cannot directly remove reagents from [target].</span>"
				return

			if(!target.reagents.total_volume)
				user << "<span class='warning'>[target] is empty.</span>"
				return

			var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)

			user << "<span class='notice'>You fill the dropper with [trans] units of the solution.</span>"

			filled = 1
			icon_state = "dropper[filled]"

		return