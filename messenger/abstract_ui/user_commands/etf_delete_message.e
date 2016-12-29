note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_DELETE_MESSAGE
inherit
	ETF_DELETE_MESSAGE_INTERFACE
		redefine delete_message end
create
	make
feature -- command
	delete_message(uid: INTEGER_64 ; mid: INTEGER_64)
		require else
			delete_message_precond(uid, mid)
    	do
			-- perform some update on the model state
			model.default_update
			if uid <= 0 OR mid <= 0 then
				model.set_is_error (TRUE)
				model.set_error_msg ("ID must be a positive integer.")
			elseif NOT model.m.users.has (uid) then
				model.set_is_error (TRUE)
				model.set_error_msg ("User with this ID does not exist.")
			elseif NOT model.m.has_message_id (mid) then
				model.set_is_error (TRUE)
				model.set_error_msg ("Message with this ID does not exist.")
			elseif attached model.m.users.at (uid) as user AND then NOT user.old_messages.has_key (mid) then
				model.set_is_error (TRUE)
				model.set_error_msg ("Message with this ID not found in old/read messages.")
			else
				model.m.delete_message(uid, mid)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
