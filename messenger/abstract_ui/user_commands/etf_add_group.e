note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_ADD_GROUP
inherit
	ETF_ADD_GROUP_INTERFACE
		redefine add_group end
create
	make
feature -- command
	add_group(gid: INTEGER_64 ; group_name: STRING)
		require else
			add_group_precond(gid, group_name)
    	do
			-- perform some update on the model state
			model.default_update
			if gid <= 0 then
				model.set_is_error (TRUE)
				model.set_error_msg ("ID must be a positive integer.")
			elseif model.m.groups.has (gid) then
				model.set_is_error (TRUE)
				model.set_error_msg ("ID already in use.")
			elseif group_name.is_empty OR NOT group_name.at (1).is_alpha then
				model.set_is_error (TRUE)
				model.set_error_msg ("Group name must start with a letter.")
			else
				model.m.add_group (gid, group_name)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
