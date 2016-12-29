note
	description: "Summary description for {USER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	USER
inherit
	COMPARABLE
create
	make_with_name_and_id

feature --initialization
	make_with_name_and_id(username : STRING; uid: INTEGER_64)
		do
			name := username
			id := uid
			create groups.make
			create messages.make(100)
			create old_messages.make(100)
		end

feature -- attributes
	name: STRING
	id : INTEGER_64
	groups : SORTED_TWO_WAY_LIST[GROUP]
	messages : HASH_TABLE[STRING, INTEGER_64]
	old_messages: HASH_TABLE[STRING, INTEGER_64]

feature -- Commands
	add_group(group: GROUP ; gid : INTEGER_64)
	local
		group_messages : SET[TUPLE[INTEGER_64, STRING]]

	do
		create group_messages.make_empty

		groups.extend (group)

	end

	add_new_message(gid : INTEGER_64 ; message : TUPLE[mid :INTEGER_64; txt: STRING])
	local
		exam : STRING
	do
		create exam.make_empty

		messages.extend (message.txt, message.mid)
	end

	print_new_messages : STRING
	local
	do
		create Result.make_empty
	end

feature -- Queries
	is_less alias "<" (other: like Current) : BOOLEAN
	do
		Result := FALSE
		if name < other.name then
			Result := TRUE
		elseif name.is_equal (other.name) then
			if id < other.id then
				Result := TRUE
			end
		end
	end

	has_group(gid : INTEGER_64) : BOOLEAN
	local
		i : INTEGER
	do
		Result := FALSE
		from
			i := 1
		until
			i > groups.count
		loop
			if groups.at (i).id = gid then
				Result := TRUE
			end
			i := i + 1
		end
	end

end
