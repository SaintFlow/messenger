note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_LIST_NEW_MESSAGES
inherit
	ETF_LIST_NEW_MESSAGES_INTERFACE
		redefine list_new_messages end
create
	make
feature -- command
	list_new_messages(uid: INTEGER_64)
		require else
			list_new_messages_precond(uid)
    	do
			-- perform some update on the model state
			model.default_update
			if uid <= 0 then
				model.set_is_error (TRUE)
				model.set_error_msg ("ID must be a positive integer.")
			elseif NOT model.m.users.has_key(uid) then
				model.set_is_error (TRUE)
				model.set_error_msg ("User with this ID does not exist.")
			else
				model.set_is_new_mg (TRUE)
				model.set_error_msg (model.m.list_new_messages (uid))
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
