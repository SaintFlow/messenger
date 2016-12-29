note
	description: "Summary description for {MESSENGER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MESSENGER
inherit
	ANY
		redefine out end

create
	make

feature
	make
		do
			something := "hello"
			another := "hi"
			create users.make (20)
			create groups.make (20)
			create messages.make(100)
			message_length := 16
			message_count := 0
		--	create registration.make
		end

feature -- Access

	something: 	STRING
	another: STRING
	users: HASH_TABLE[USER, INTEGER_64]
	groups: HASH_TABLE[GROUP, INTEGER_64]
	messages : ARRAYED_LIST[TUPLE[mid :INTEGER_64; txt: STRING; gid :INTEGER_64]]
	message_length : INTEGER_32
	message_count : INTEGER_64

--	registration: TABLE[GROUP,USER]

feature -- queries
	has_message_id (mid : INTEGER_64) : BOOLEAN
	local
		i : INTEGER
	do
		Result := false
		from
			i := 1
		until
			i > messages.count
		loop
			if messages.at (i).mid = mid then
				Result := true
			end
			i := i + 1
		end
	end

	can_read_message (uid : INTEGER_64 mid : INTEGER_64) : BOOLEAN
	local
		i : INTEGER
	do
		Result := false
		if attached users.at (uid) as user1 then
			from
				i := 1
			until
				i > messages.count
			loop
				if messages.at (i).mid = mid then
					if user1.has_group (messages.at (i).gid) then
						Result := true
					end
				end
				i := i + 1
			end
		end

	end

feature -- commands

	register_user (uid: INTEGER_64 ; gid : INTEGER_64)
	do
		if attached groups.at (gid) as group AND attached users.at (uid) as user then
			user.add_group (group, gid)
		end
	end

	send_message(uid: INTEGER_64 ; gid: INTEGER_64 ; txt: STRING)
	local
		i :INTEGER
		userkeys : ARRAY[INTEGER_64]
		temp_tuple : TUPLE[INTEGER_64, STRING, INTEGER_64]

	do
		create userkeys.make_from_array (users.current_keys)
		message_count := message_count + 1
		temp_tuple := [message_count, txt, gid]
		from
			i := 1
		until
			i > userkeys.count
		loop
			if attached users.at (userkeys.at (i)) as user then
				if user.has_group (gid) AND NOT (user.id = uid) then
					user.add_new_message (gid, temp_tuple)

				end
			end
			i := i + 1
		end

		messages.extend (temp_tuple)
	end


	add_user(uid : INTEGER_64; user_name : STRING)
		-- add a new user to the system
	local
		new_user : USER
	do
		create
		new_user.make_with_name_and_id (user_name, uid)
		users.extend (new_user, uid)
	end

	add_group(id : INTEGER_64; group_name : STRING)
	local
		new_group : GROUP
	do
		create new_group.make_with_name (group_name)
		new_group.set_id (id)
		groups.extend (new_group, id)
	end

	set_message_preview(n: INTEGER_64)
	do
		message_length := n.as_integer_32 + 1
	end

	delete_message(uid: INTEGER_64 ; mid: INTEGER_64)
	local
	do
		if attached users.at (uid) as user then
			user.old_messages.remove (mid)
		end
	end

	read_message(uid: INTEGER_64 ; mid: INTEGER_64) : STRING
	local
		i : INTEGER
	do
		create Result.make_empty
		if attached users.at (uid) as user then
			if attached user.messages.at (mid) as message then
				Result.append("  Message for user [")
				Result.append(uid.out + ", " + user.name + "]: [" + mid.out + ", ")
				Result.append("%"" + message + "%"]%N")
				user.messages.remove (mid)
				user.old_messages.extend (message, mid)
				Result.append(out)

			end
		end
	end

feature -- Output
	print_users : STRING
	local
		sorted : SORTED_TWO_WAY_LIST[INTEGER_64]
		i : INTEGER
	do
		create Result.make_empty
		if NOT users.is_empty then
			Result.append ("%N")
			i := 1
			create sorted.make
			sorted.fill (users.current_keys)
			from
				i := 1
			until
				i > sorted.count
			loop
				if attached users.at (sorted.at (i)) as user then
					Result.append ("      ")
					Result.append(sorted.at (i).out)
					Result.append ("->")
					Result.append (user.name)
					if NOT (i = sorted.count) then
						Result.append ("%N")
					end
				end
				i := i + 1
			end
		end
	end

	list_old_messages (uid: INTEGER_64) : STRING
	local
		i : INTEGER
		messagekeys : SORTED_TWO_WAY_LIST[INTEGER_64]
		temp_message : STRING
	do
		create Result.make_empty
		create messagekeys.make
		create temp_message.make_empty
		if attached users.at (uid) as user AND then NOT user.old_messages.is_empty then
			Result.append ("  Old/read messages for user [")
			Result.append (uid.out + ", ")
			Result.append (user.name + "]:%N")
			messagekeys.fill (user.old_messages.current_keys)
			from
				i := 1
			until
				i > messagekeys.count
			loop
				if attached user.old_messages.at(messagekeys.at (i)) as message then
					Result.append("      " + messagekeys.at (i).out + "->")
					if message.count > message_length then
						temp_message.make_from_string (message)
						temp_message.remove_substring (message_length, message.count)
						Result.append (temp_message)
						Result.append (" ...")
					else
						Result.append (message)
					end
				end
				if NOT (i = messagekeys.count) then
					Result.append("%N")
				end
				i := i + 1
			end
		else
			Result.append("  There are no old messages for this user.")
		end
	end

	print_groups : STRING
	local
		sorted : SORTED_TWO_WAY_LIST[INTEGER_64]
		i : INTEGER
	do
		create Result.make_empty
		if NOT groups.is_empty then
			Result.append ("%N")
			i := 1
			create sorted.make
			sorted.fill (groups.current_keys)
			from
				i := 1
			until
				i > sorted.count
			loop
				if attached groups.at (sorted.at (i)) as group then
					Result.append ("      ")
					Result.append(sorted.at (i).out)
					Result.append ("->")
					Result.append (group.name)
					if NOT (i = sorted.count) then
						Result.append ("%N")
					end
				end
				i := i + 1
			end
		end

	end

	out : STRING
	local
		keys, groupkeys : ARRAY[INTEGER_64]
		i : INTEGER
		sorted : SORTED_TWO_WAY_LIST[INTEGER_64]
	do
		create Result.make_empty
		Result.append ("  Users:") ----------------------------
		Result.append (print_users)
		Result.append ("%N  Groups:") ---------------------------
		Result.append (print_groups)
		Result.append ("%N" )
		Result.append ("  Registrations:") ---------------------------------
		Result.append (list_registrations)
		Result.append ("%N" )
		Result.append ("  All messages:") -----------------------------------
		Result.append (list_all_messages)
		Result.append ("%N" )
		Result.append ("  New messages:") ------------------------------------
		Result.append (list_user_notifications)
		Result.append ("%N" )
		Result.append ("  Old/read messages:") ------------------------------------
		Result.append (list_old_notifications)

	end

	list_old_notifications : STRING
	local
		i,j : INTEGER
		userkeys : ARRAY[INTEGER_64]
		sorted : SORTED_TWO_WAY_LIST[INTEGER_64]
		sorted_messages : SORTED_TWO_WAY_LIST[INTEGER_64]
	do
		create Result.make_empty
		create userkeys.make_from_array (users.current_keys)
		create sorted.make
		create sorted_messages.make
		sorted.fill (userkeys)
		from
			i := 1
		until
			i > sorted.count
		loop
			if attached users.at (sorted.at (i)) as user then
				if NOT user.old_messages.is_empty then
					Result.append("%N")
					create sorted_messages.make
					sorted_messages.fill (user.old_messages.current_keys)
					Result.append ("      [")
					Result.append(sorted.at (i).out)
					Result.append (", ")
					Result.append (user.name)
					Result.append ("]->{")
					from
						j := 1
					until
						j > sorted_messages.count
					loop
						Result.append(sorted_messages.at (j).out)
						if NOT (j = sorted_messages.count) then
							Result.append (", ")
						end
						j := j + 1
					end
					Result.append ("}")
				--	if NOT (i = sorted.count) then
			--			Result.append ("%N")
			--		end

				end

			end
			i:= i + 1
		end
	end

	list_user_notifications : STRING
	local
		i,j : INTEGER
		userkeys : ARRAY[INTEGER_64]
		sorted : SORTED_TWO_WAY_LIST[INTEGER_64]
		sorted_messages : SORTED_TWO_WAY_LIST[INTEGER_64]
	do
		create Result.make_empty
		create userkeys.make_from_array (users.current_keys)
		create sorted.make
		create sorted_messages.make
		sorted.fill (userkeys)
		from
			i := 1
		until
			i > sorted.count
		loop
			if attached users.at (sorted.at (i)) as user then
				if NOT user.messages.is_empty then
					Result.append("%N")
					create sorted_messages.make
					sorted_messages.fill (user.messages.current_keys)
					Result.append ("      [")
					Result.append(sorted.at (i).out)
					Result.append (", ")
					Result.append (user.name)
					Result.append ("]->{")
					from
						j := 1
					until
						j > sorted_messages.count
					loop
						Result.append(sorted_messages.at (j).out)
						if NOT (j = sorted_messages.count) then
							Result.append (", ")
						end
						j := j + 1
					end
					Result.append ("}")
				--	if NOT (i = sorted.count) then
			--			Result.append ("%N")
			--		end

				end

			end
			i:= i + 1
		end
	end

	list_all_messages : STRING
	local
		i : INTEGER
		temp_message : STRING
	do
		create Result.make_empty
		create temp_message.make_empty
		if NOT messages.is_empty then



			from
				i := 1
			until
				i > messages.count
			loop
				Result.append("%N")
				Result.append("      ")
				Result.append (i.out)
				Result.append ("->")


					if messages.at (i).txt.count > message_length then
						temp_message.make_from_string (messages.at (i).txt)
						temp_message.remove_substring (message_length, messages.at (i).txt.count)
						Result.append (temp_message)
						Result.append (" ...")
					else
						Result.append (messages.at (i).txt)
					end


			--	if NOT (i = messages.count) then
			--		Result.append ("%N")
			--	end
				i := i + 1
			end
		end
	end

	list_users : STRING
	local
		keys : ARRAY[INTEGER_64]
		final_keys : ARRAYED_LIST[INTEGER_64]
		values : ARRAY[STRING]
		i,j  : INTEGER
		sorted_names : SORTED_TWO_WAY_LIST[STRING]
		temp_string : STRING
		users_copy: HASH_TABLE[USER, INTEGER_64]
		sorted_users : SORTED_TWO_WAY_LIST[USER]
	do
		create Result.make_empty
		create final_keys.make (100)
		create temp_string.make_empty
		create sorted_names.make
		if users.is_empty then
			Result := "  There are no users registered in the system yet."
		else
			keys := users.current_keys
			create users_copy.make (100)
			create sorted_users.make
--			users_copy.deep_copy(users)
--			sorted_names.compare_objects
			from
				i := 1
			until
				i > keys.count
			loop
				if attached users.at (keys.at (i)) as user then
					sorted_users.extend (user)
					sorted_names.extend (temp_string)
				end
				i := i + 1
			end

			from
				 i := 1
			until
				i > sorted_users.count
			loop
				Result.append ("  ")
				Result.append(sorted_users.at (i).id.out)
				Result.append ("->")
				Result.append (sorted_users.at (i).name)
				if NOT (i = sorted_users.count) then
					Result.append ("%N")
				end
				i := i + 1
			end

--			from
--				i := 1
--			until
--				i > sorted_names.count
--			loop
--				from
--					j := 1
--				until
--					j > keys.count
--				loop
--					if  NOT users_copy.is_empty AND attached users_copy.at (keys.at (j)) as user then
--						if user.name.is_equal (sorted_names.at (i)) then
--							Result.append ("  ")
--							Result.append(keys.at (j).out)
--							Result.append ("->")
--							Result.append (user.name)
--							if NOT (i = sorted_names.count) then
--								Result.append ("%N")
--							end
--							users_copy.remove (keys.at (j))
--						end

--					end
--					j := j + 1
--				end
--				i := i + 1
--				j := 1
--			end
		end
	end


	list_registrations : STRING
	local
		userkeys : ARRAY[INTEGER_64]
		i, j : INTEGER
		sorted : SORTED_TWO_WAY_LIST[INTEGER_64]

	do
		create Result.make_empty
		i := 1
		j := 1
		if NOT users.is_empty then
			userkeys := users.current_keys
			create sorted.make
			sorted.fill (userkeys)
			from
				i := 1
			until
				i > sorted.count
			loop
				if attached users.at (sorted.at (i)) as user THEN
					if NOT user.groups.is_empty then
						Result.append("%N")
						Result.append ("      [")
						Result.append(sorted.at (i).out)
						Result.append (", ")
						Result.append (user.name)
						Result.append ("]->{")
						from
							j := 1
						until
							j > user.groups.count
						loop
							if attached user.groups.at(j) as group then
								Result.append (group.id.out)
								Result.append ("->")
								Result.append (group.name)
								if NOT (j = user.groups.count) then
									Result.append(", ")
								end
								j := j + 1
							end
						end

						Result.append("}")
					--	if NOT (i = sorted.count) then
					--		Result.append ("%N")
					--	end
					end
				end
				i := i + 1
			end
		end
	end

	new_messages_out : STRING
	local
	do
		create Result.make_empty
	end

	list_new_messages(uid : INTEGER_64) : STRING
	local
		i : INTEGER
		messagekeys : SORTED_TWO_WAY_LIST[INTEGER_64]
		temp_message : STRING
	do
		create Result.make_empty
		create messagekeys.make
		create temp_message.make_empty
		if attached users.at (uid) as user AND then NOT user.messages.is_empty then
			Result.append ("  New/unread messages for user [")
			Result.append (uid.out + ", ")
			Result.append (user.name + "]:%N")
			messagekeys.fill (user.messages.current_keys)
			from
				i := 1
			until
				i > messagekeys.count
			loop
				if attached user.messages.at(messagekeys.at (i)) as message then
					Result.append("      " + messagekeys.at (i).out + "->")
					if message.count > message_length then
						temp_message.make_from_string (message)
						temp_message.remove_substring (message_length, message.count)
						Result.append (temp_message)
						Result.append (" ...")
					else
						Result.append (message)
					end
				end
				if NOT (i = messagekeys.count) then
					Result.append("%N")
				end
				i := i + 1
			end
		else
			Result.append("  There are no new messages for this user.")
		end
	end

	list_groups : STRING
	local
		keys : ARRAY[INTEGER_64]
		i,j  : INTEGER
		users_copy: HASH_TABLE[USER, INTEGER_64]
		sorted_groups : SORTED_TWO_WAY_LIST[GROUP]
	do
		create Result.make_empty
		create sorted_groups.make
		if groups.is_empty then
			Result := "  There are no groups registered in the system yet."
		else
			keys := groups.current_keys
			from
				i := 1
			until
				i > keys.count
			loop
				if attached groups.at (keys.at (i)) as group then
					sorted_groups.extend (group)
				end
				i := i + 1
			end

			from
				 i := 1
			until
				i > sorted_groups.count
			loop
				Result.append ("  ")
				Result.append(sorted_groups.at (i).id.out)
				Result.append ("->")
				Result.append (sorted_groups.at (i).name)
				if NOT (i = sorted_groups.count) then
					Result.append ("%N")
				end
				i := i + 1
			end
		end
	end

end
