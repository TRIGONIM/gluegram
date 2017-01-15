TLG.Language = {}
local l = TLG.Language


l.not_logged = "You are not logged in"

l.on_connect = "You have joined the (%s). %s"
l.on_connect_err = "The server (%s) is already active"

l.on_disconnect = "You are disconnected from %s"
l.on_disconnect_err = "Connection to the %s is not active"

l.forb_execution = "Command execution is forbidden by the following reason: %s"
l.not_func = "The command have not assigned function. Parameter \".func\" in the config"
l.cmd_not_exists = "The command /%s doesn't exists"

l.missing_old_message = "Old message is missing"
l.received_by_server = "The message received by server"

l.no_nickname_auth = "Get lost, noname!" -- When user not have a nickname
l.you_are_banned = "You are banned from this server!\n*Nickname:* @%s\n*Reason:* %s\n*Unban date:* %s"
l.not_permitted = "Fuck you, @%s" -- when user banned or not permitted to execution

l.no_desc = "No description"
l.too_many_commands = "Ass will not burst on the number of commands?"
l.not_allowed = "[%s] You don't have access to do this" -- %s = server name in uppercase