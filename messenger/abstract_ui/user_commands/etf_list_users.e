note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_LIST_USERS
inherit
	ETF_LIST_USERS_INTERFACE
		redefine list_users end
create
	make
feature -- command
	list_users
    	do
			-- perform some update on the model state
			model.default_update
			model.set_is_new_mg (TRUE)
			model.set_error_msg (model.m.list_users)
			etf_cmd_container.on_change.notify ([Current])
    	end

end
