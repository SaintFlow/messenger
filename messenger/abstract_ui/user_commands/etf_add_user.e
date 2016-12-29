note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_ADD_USER
inherit
	ETF_ADD_USER_INTERFACE
		redefine add_user end
create
	make
feature -- command
	add_user(uid: INTEGER_64 ; user_name: STRING)
		require else
			add_user_precond(uid, user_name)
    	do
			-- perform some update on the model state
			model.default_update
			if uid <= 0 then
				model.set_is_error (TRUE)
				model.set_error_msg ("ID must be a positive integer.")
			elseif model.m.users.has (uid) then
				model.set_is_error (TRUE)
				model.set_error_msg ("ID already in use.")
			elseif user_name.is_empty OR NOT user_name.at (1).is_alpha then
				model.set_is_error (TRUE)
				model.set_error_msg ("User name must start with a letter.")
			else
				model.m.add_user (uid, user_name)
			end

			etf_cmd_container.on_change.notify ([Current])
    	end

end
