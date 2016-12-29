note
	description: "A default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MODEL

inherit
	ANY
		redefine
			out
		end

create {ETF_MODEL_ACCESS}
	make

feature {NONE} -- Initialization
	make
			-- Initialization for `Current'.
		do
			create s.make_empty
			create error_msg.make_empty
			create m.make
			is_error := FALSE
			is_new_out := FALSE
			i := 0
		end

feature -- model attributes
	s : STRING
	i : INTEGER
	m : MESSENGER
	is_error: BOOLEAN
	is_new_out : BOOLEAN
	error_msg : STRING

feature -- model operations
	default_update
			-- Perform update to the model state.
		do
			i := i + 1

		end

	reset
			-- Reset model state.
		do
			make
		end

feature
	set_error_msg (err : STRING)
	do
		error_msg := err
	end

	set_is_new_mg (b: BOOLEAN)
	do
		is_new_out := b
	end

	set_is_error (b : BOOLEAN)
	do
		is_error := b
	end

feature -- queries
	out : STRING
		do
			create Result.make_from_string ("  ")
			Result.append (i.out)
			Result.append (":  ")
			if (is_error = TRUE) then
				Result.append ("ERROR %N  ")
				Result.append (error_msg)
				Result.append ("%N")
			elseif (is_new_out = TRUE) then
				Result.append ("OK%N")
				--Result.append ("%N")
				Result.append (error_msg)
				Result.append ("%N")
			else
				Result.append ("OK%N")
				if i = 0 then
				else
					Result.append (m.out)
					Result.append ("%N")
				end

			end

			--Result.append (m.another)
			is_error := false
			is_new_out := false
		end

end




