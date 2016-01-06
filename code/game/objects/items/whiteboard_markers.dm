// to do: base markers on pens or use pens

/obj/item/weapon/pen/marker
	desc = "It's a black whiteboard marker."
	name = "marker"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "marker"
	item_state = "marker"
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
	matter = list(DEFAULT_WALL_MATERIAL = 10)
	colour = "black"
	pressure_resistance = 2

/obj/item/weapon/pen/marker/red
	desc = "It's a red whiteboard marker."
	icon_state = "marker_red"
	item_state = "marker_red"
	colour = "red"

/obj/item/weapon/pen/marker/green
	desc = "It's a green whiteboard marker."
	icon_state = "marker_green"
	item_state = "marker_green"
	colour = "green"

/obj/item/weapon/pen/marker/blue
	desc = "It's a blue whiteboard marker."
	icon_state = "marker_blue"
	item_state = "marker_blue"
	colour = "blue"

/obj/item/weapon/pen/attack(mob/M as mob, mob/user as mob)
	if(!ismob(M))
		return
	user << "<span class='warning'>You stab [M] with the marker.</span>"
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been stabbed with [name]  by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to stab [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) Used the [name] to stab [M.name] ([M.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	return