note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_REGISTER_USER
inherit
	ETF_REGISTER_USER_INTERFACE
		redefine register_user end
create
	make
feature -- command
	register_user(uid: INTEGER_64 ; gid: INTEGER_64)
		require else
			register_user_precond(uid, gid)
    	do
			-- perform some update on the model state
			model.default_update
			if gid <= 0  OR uid <= 0 then
				model.set_is_error (TRUE)
				model.set_error_msg ("ID must be a positive integer.")
			elseif NOT model.m.users.has (uid) then
				model.set_is_error (TRUE)
				model.set_error_msg ("User with this ID does not exist.")
			elseif NOT model.m.groups.has (gid) then
				model.set_is_error (TRUE)
				model.set_error_msg ("Group with this ID does not exist.")
			elseif attached model.m.users.at (uid) as user AND then user.has_group (gid) then
				model.set_is_error (TRUE)
				model.set_error_msg ("This registration already exists.")
			else
				model.m.register_user (uid, gid)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
