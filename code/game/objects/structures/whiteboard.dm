/obj/structure/whiteboard
	name = "whiteboard"
	desc = "A board for writing. Use whiteboard markers. There is also an eraser on it."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "wboard"
	density = 0
	anchored = 1
	var/info = ""
	var/const/deffont = "Verdana"
	var/const/signfont = "Times New Roman"
	var/free_space = MAX_PAPER_MESSAGE_LEN
	var/fields = 0
	var/info_parts = 0
	var/const/forbid_links = "<style>.info_link{display: none;}</style>"

/obj/structure/whiteboard/examine(mob/user)
	..()
	if(!(istype(user, /mob/living/carbon/human) || istype(user, /mob/dead/observer) || istype(user, /mob/living/silicon)))
		user << browse("<HTML><HEAD><TITLE>[name]</TITLE>[forbid_links]</HEAD><BODY>[stars(info)]</BODY></HTML>", "window=[name]")
		onclose(user, "[name]")
	else
		user << browse("<HTML><HEAD><TITLE>[name]</TITLE>[forbid_links]</HEAD><BODY>[info]</BODY></HTML>", "window=[name]")
		onclose(user, "[name]")
	return

/obj/structure/whiteboard/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/pen/marker))
		user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY><font face='[deffont]'><A href='?src=\ref[src];erase=all'>Erase all</A></font><br>[info]<font face=\"[deffont]\"><A href='?src=\ref[src];write=end'>write</A></font></BODY></HTML>", "window=[name]")


/obj/structure/whiteboard/attack_hand(var/mob/user)
	if(istype(user, /mob/living/carbon/human))
		user << browse("<HTML><HEAD><TITLE>[name]</TITLE>[forbid_links]</HEAD><BODY><font face='[deffont]'><A href='?src=\ref[src];erase=all'>Erase all</A></font><br>[info]</BODY></HTML>", "window=[name]")

/obj/structure/whiteboard/attack_ai(var/mob/living/silicon/ai/user as mob)
	usr << browse("<HTML><HEAD><TITLE>[name]</TITLE>[forbid_links]</HEAD><BODY>[info]</BODY></HTML>", "window=[name]")
	onclose(usr, "[name]")
	return

/obj/structure/whiteboard/proc/write_info(var/text, var/index, var/obj/item/weapon/pen/marker/M, mob/user as mob)
	text = replacetext(text, "\[center\]", "<center>")
	text = replacetext(text, "\[/center\]", "</center>")
	text = replacetext(text, "\[br\]", "<BR>")
	text = replacetext(text, "\[b\]", "<B>")
	text = replacetext(text, "\[/b\]", "</B>")
	text = replacetext(text, "\[i\]", "<I>")
	text = replacetext(text, "\[/i\]", "</I>")
	text = replacetext(text, "\[u\]", "<U>")
	text = replacetext(text, "\[/u\]", "</U>")
	text = replacetext(text, "\[time\]", "[worldtime2text()]")
	text = replacetext(text, "\[date\]", "[worlddate2text()]")
	text = replacetext(text, "\[large\]", "<font size=\"4\">")
	text = replacetext(text, "\[/large\]", "</font>")
	text = replacetext(text, "\[sign\]", "<font face=\"[signfont]\"><i>[get_signature(M, user)]</i></font>")
	text = replacetext(text, "\[field\]", "(FIELD PLACEHOLDER)") // will be processed later
	text = replacetext(text, "\[h1\]", "<H1>")
	text = replacetext(text, "\[/h1\]", "</H1>")
	text = replacetext(text, "\[h2\]", "<H2>")
	text = replacetext(text, "\[/h2\]", "</H2>")
	text = replacetext(text, "\[h3\]", "<H3>")
	text = replacetext(text, "\[/h3\]", "</H3>")
	text = replacetext(text, "\[*\]", "<li>")
	text = replacetext(text, "\[hr\]", "<HR>")
	text = replacetext(text, "\[small\]", "<font size = \"1\">")
	text = replacetext(text, "\[/small\]", "</font>")
	text = replacetext(text, "\[list\]", "<ul>")
	text = replacetext(text, "\[/list\]", "</ul>")
	text = replacetext(text, "\[table\]", "<table border=1 cellspacing=0 cellpadding=3 style='border: 1px solid black;'>")
	text = replacetext(text, "\[/table\]", "</td></tr></table>")
	text = replacetext(text, "\[grid\]", "<table>")
	text = replacetext(text, "\[/grid\]", "</td></tr></table>")
	text = replacetext(text, "\[row\]", "</td><tr>")
	text = replacetext(text, "\[cell\]", "<td>")
	text = replacetext(text, "\[logo\]", "<img src = ntlogo.png>")
	text = "<font face=\"[deffont]\" color=[M ? M.colour : "black"]>[text]</font>"

	var/laststart = 1
	var/id = 0
	var/i = 0
	var/lastpart = 1
	if (index == "end") //players can't create new parts when entering text to a field. the <HR> itself will be there
		for (i = 1; i < length(text); i++)
			if (i < laststart)
				continue
			var/found = findtext(text, "<HR>", laststart)
			if(found==0)
				break
			user << "Found HR at [found]. Text len is [length(text)]."
			user << "Current text: [replacetext(text, "<", "\<")]"
			id++
			info_parts++ // id and info_parts are not necessarily the same numbers, as users can add text
			text = copytext(text, 1, lastpart) + "<span class=\"part[id]><A href='?src=\ref[src];erase=[id]' class='info_link'>\[erase part\]</A>" + copytext(text, lastpart, laststart) + "<br>(FIELD PLACEHOLDER)</span><!--END_PART[id]-->" + copytext(text, laststart)
			laststart = found + length("<span class=\"part[id]><A href='?src=\ref[src];erase=[id]' class='info_link'>\[erase part\]</A><br>(FIELD PLACEHOLDER)</span><!--END_PART[id]-->") + 1
			lastpart = found

	//reset for a new search
	laststart = 1
	id = 0
	i = 0
	user << "Text length: [length(text)]"
	user << "Current info is:<br>[info]"
	for (i = 1; i < length(text); i++)
		if (i < laststart)
			continue
		var/found = findtext(text, "(FIELD PLACEHOLDER)", laststart)
		if(found==0)
			break
		fields++
		id++
		text = copytext(text, 1, found) + "<font face=\"[deffont]\"><A href='?src=\ref[src];write=[id]' class='info_link'>\[write\]</A></font>" + copytext(text, found+length("(FIELD PLACEHOLDER)"))
		laststart = found + length("<font face=\"[deffont]\"><A href='?src=\ref[src];write=[id]' class='info_link'>\[write\]</A></font>")

	if (fields > 25 || info_parts > 10)
		user << "<span class='warning'>Too many fields or text parts (created with \[hr\]).</span>"
	else
		if (index == "end")
			//user << "Appending to end"
			info += text
		else
			var/field = text2num(index)
			var/last_len = length(info)
			user << "Attempting to write into [field]. field"
			info = replacetext(info, "<font face=\"[deffont]\"><A href='?src=\ref[src];write=[id]' class='info_link'>\[write\]</A></font>", text + "<font face=\"[deffont]\"><A href='?src=\ref[src];write=[id]' class='info_link'>\[write\]</A></font>")
			if (last_len == length(info)) // no change was done --> field was not found
				user << "Field does not exist"
				return
		free_space -= length(strip_html_properly(text))


/obj/structure/whiteboard/Topic(href, href_list)
	..()
	if(!usr || (usr.stat || usr.restrained()))
		return

	if(href_list["write"])
		var/id = href_list["write"]
		if(free_space <= 0)
			usr << "<span class='info'>There isn't enough space left on \the [src] to write anything.</span>"
			return

		var/t =  sanitize(input("Enter what you want to write:", "Write", null, null) as message, free_space, extra = 0)
		if(!t)
			return

		var/obj/item/i = usr.get_active_hand() // check if user has marker
		if(!istype(i, /obj/item/weapon/pen/marker))
			return

		// user must be near the whiteboard
		if(!(src.loc.loc == usr || src.loc.Adjacent(usr)))
			return

		t = replacetext(t, "\n", "<BR>")
		write_info(t, id, i, usr)
	if(href_list["erase"])
		var/id = href_list["erase"]
		if (id == "all")
			clear_board()
		else
			clear_part(text2num(id))
	update_icon()
	usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY><font face='[deffont]'><A href='?src=\ref[src];erase=all'>Erase all</A></font><br>[info]<font face=\"[deffont]\"><A href='?src=\ref[src];write=end'>write</A></font></BODY></HTML>", "window=[name]")

/obj/structure/whiteboard/proc/clear_board()
	info = ""
	free_space = MAX_PAPER_MESSAGE_LEN
	fields = 0
	info_parts = 0
	overlays.Cut()
	update_icon()

/obj/structure/whiteboard/proc/clear_part(var/index)
	var/start = findtext(info, "<span class=\"part[index]>")
	usr << "Found desired part at [start]."
	if (start == 0)
		return
	var/end = findtext(info, "<!--END_PART[index]-->") + length("<!--END_PART[index]-->")
	info = copytext(info, 1, start) + copytext(info, end)
	count_fields()

/obj/structure/whiteboard/proc/count_fields() //count already processed fields (new ones are handled during creation) after removing a part of info
	fields = 0
	var/laststart = 1
	var/i = 0
	for (i = 1; i < length(info); i++)
		if (i < laststart)
			continue
		var/found = findtext(info, "class='info_link'>write</A></font>", laststart)
		if(found==0)
			break
		fields++
		laststart = found + length("class='info_link'>write</A></font>") + 1

/obj/structure/whiteboard/proc/get_signature(var/obj/item/weapon/pen/marker/M, mob/user as mob)
	if(M && istype(M, /obj/item/weapon/pen/marker))
		return M.get_signature(user)
	return (user && user.real_name) ? user.real_name : "Anonymous"

/obj/structure/whiteboard/update_icon()
	overlays.Cut()
	if (free_space < MAX_PAPER_MESSAGE_LEN)
		overlays += image(icon, icon_state="wboard_over_text")
		if (free_space < 4 * MAX_PAPER_MESSAGE_LEN / 5)
			overlays += image(icon, icon_state="wboard_over_image")