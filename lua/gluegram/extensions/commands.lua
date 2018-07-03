local CMD_MT = TLG.GetObject("COMMAND")

--------------------------------
function CMD_MT:Description()
	return self.description
end

function CMD_MT:Help()
	return self.help
end


--------------------------------
-- Будет отображаться в /cmd -- help или просто /help
function CMD_MT:SetDescription(sDesc)
	self.description = sDesc
	return self
end

-- Пример использования команды
function CMD_MT:SetHelp(sHelp) -- usage info
	self.help = sHelp
	return self
end





hook.Add("TLG.OnCommand", "commands ext help", function(BOT, CHAT, CMD, _, tArgs)
	if tArgs[1] == "-help" and !tArgs[2] then
		BOT:Message(CHAT,CMD:Help() or "По этой команде нет дополнительной информации"):Send()
		return
	end
end)


hook.Add("TLG.CanRunCommand","help access all",function(BOT, USER, CMD, _)
	if CMD.cmd == "help" then
		if BOT:IsExtensionConnected("master") and !BOT:IsMaster() then
			return false
		end

		return true
	end
end)


local BOT = BOTMOD
if !BOT then return end -- lua refresh

-- help
BOT:AddCommand("help",function(MSG,args)
	if BOT:GetCommand(args[1]) then -- /help cmd
		return BOT:GetCommand(args[1]):Help() or "There is no help information for this command"
	end

	local inf =
		NM([[
		*Руководство по использованию GLUA бота ]] .. BOT:Name() .. [[*

		Вы можете выполнять несколько команд сразу. Просто вводите их поочередно, бот найдет

		Чтобы в любой момент получить короткую справку о нужной команде, введите ее с аргументов -help.
		Пример: /login -help

		Некоторые команды станут доступны только после авторизации (/login ]] .. BOT:Name() .. [[)
		]])

	local auth_mod = BOT:IsExtensionConnected("auth")
	for cmd,CMD in pairs( BOT:GetCommands() ) do
		if !auth_mod or CMD:IsPublic() or BOT:GetSession( MSG:From() ) then
			if CMD.aliases and CMD.aliases[cmd] then continue end -- алиас

			inf = inf .. "*/" .. cmd .. "*" .. ((auth_mod and CMD:IsPublic()) and " Общая" or "") .. ((auth_mod and CMD:ForMaster()) and " Master" or "")

			-- Команда не является алиасом, но имеет их
			if CMD.aliases then
				inf = inf .. "\n*Алиасы:* " .. table.ConcatKeys(CMD.aliases, ", ")
			end

			inf = inf .. "\n`" .. (CMD:Description() or "no descr") .. "`\n\n"
		end
	end

	return inf,"Markdown"
end)
	-- :SetPublic(true)
	-- :SetForMaster(true)
	:SetHelp("/help command отобразит помощь по конкретной команде, ровно как и /command --help")
	:SetDescription("Возвращает список доступных на данный момент команд и краткую информацию по ним. После авторизации список может измениться. Также отображает некоторую дополнительную полезную информацию")
