note
	description: "Summary description for {GROUP}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GROUP
inherit
	COMPARABLE

create
	make_with_name

feature
	make_with_name(group_name : STRING)
		do
			name := group_name
			create users.make
		end

feature
	name: STRING
	id: INTEGER_64
	users : SORTED_TWO_WAY_LIST[USER]

feature
	set_id(id1 : INTEGER_64)
	do
		id := id1
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


end
