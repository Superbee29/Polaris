/datum/technomancer/spell/repel_missiles
	name = "Repel Missiles"
	desc = "Places a repulsion field around you, which attempts to deflect incoming bullets and lasers, making them 30% less likely \
	to hit you.  The field lasts for two minutes and can be granted to yourself or an ally."
	cost = 60
	obj_path = /obj/item/weapon/spell/insert/repel_missiles
	ability_icon_state = "tech_repelmissiles"

/obj/item/weapon/spell/insert/repel_missiles
	name = "repel missiles"
	desc = "Use it before they start shooting at you!"
	icon_state = "generic"
	cast_methods = CAST_RANGED
	aspect = ASPECT_FORCE
	light_color = "#FF5C5C"
	inserting = /obj/item/weapon/inserted_spell/repel_missiles

/obj/item/weapon/inserted_spell/repel_missiles/on_insert()
	spawn(1)
		if(isliving(host))
			var/mob/living/L = host
			L.evasion += 2
			L << "<span class='notice'>You have a repulsion field around you, which will attempt to deflect projectiles.</span>"
			spawn(2 MINUTES)
				if(src)
					on_expire()

/obj/item/weapon/inserted_spell/repel_missiles/on_expire()
	if(isliving(host))
		var/mob/living/L = host
		L.evasion -= 2
		L << "<span class='warning'>Your repulsion field has expired.</span>"
		..()