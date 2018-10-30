local BOT = TLG.NewBot("commands", "base")

function BOT:AddCommand(sCmd, fCallback)
	sCmd = string.lower(sCmd)

	local CMD = TLG.SetMeta({
		aliases = {},
		func = fCallback,
		cmd  = sCmd,
		meta = {},

		bot = self -- for ability to quick answer from commands
	}, "COMMAND")

	self.commands = self.commands or {}
	self.commands[sCmd] = CMD

	return CMD
end

function BOT:GetCommands()
	return self.commands
end



function BOT:CanRunCommand(USER, CMD, MSG)
	return true
end

-- function BOT:UserRunCommand(USER, CMD, MSG, tArgs, sArgs_) end

function BOT:OnCommand(MSG, cmd, sArgs_)
	local CMD = self:GetCommands()[cmd]
	if not CMD then return end

	local access = self:CanRunCommand(MSG:From(), CMD, MSG)
	if access == false then return end

	local tArgs = {}
	if sArgs_ then
		for _,arg in ipairs( string.Explode(" ", sArgs_) ) do
			if arg ~= "" then
				tArgs[#tArgs + 1] = arg
			end
		end
	end

	local reply,parse_mode = CMD.func(MSG, tArgs, sArgs_)
	if reply then
		self:Message(MSG["chat"]["id"], reply) -- "[" .. self:GetClass() .. "]: " ..
			:ReplyTo( MSG:ID() )
			:SetParseMode( parse_mode )
			:Send()
	end

	-- self:UserRunCommand(MSG:From(), CMD, MSG, tArgs, sArgs_)
end
