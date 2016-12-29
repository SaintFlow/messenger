note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_READ_MESSAGE
inherit
	ETF_READ_MESSAGE_INTERFACE
		redefine read_message end
create
	make
feature -- command
	read_message(uid: INTEGER_64 ; mid: INTEGER_64)
		require else
			read_message_precond(uid, mid)
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
			elseif NOT model.m.can_read_message (uid, mid) then
				model.set_is_error (TRUE)
				model.set_error_msg ("User not authorized to access this message.")
			elseif attached model.m.users.at (uid) as user AND then NOT user.messages.has (mid) then
				model.set_is_error (TRUE)
				model.set_error_msg ("Message has already been read. See `list_old_messages'.")
			else
				model.set_is_new_mg (TRUE)
				model.set_error_msg (model.m.read_message (uid, mid))
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
