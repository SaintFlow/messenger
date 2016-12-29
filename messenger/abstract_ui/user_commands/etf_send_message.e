note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_SEND_MESSAGE
inherit
	ETF_SEND_MESSAGE_INTERFACE
		redefine send_message end
create
	make
feature -- command
	send_message(uid: INTEGER_64 ; gid: INTEGER_64 ; txt: STRING)
		require else
			send_message_precond(uid, gid, txt)
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
			elseif txt.is_empty then
				model.set_is_error (TRUE)
				model.set_error_msg ("A message may not be an empty string.")
			elseif attached model.m.users.at (uid) as user AND then NOT user.has_group (gid) then
				model.set_is_error (TRUE)
				model.set_error_msg ("User not authorized to send messages to the specified group.")
			else
				model.m.send_message(uid,gid,txt)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
