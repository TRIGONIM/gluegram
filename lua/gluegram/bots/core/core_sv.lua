local BOT = TLG("167720993:AAEzqbwu8Jpq9-L3tblzrPXR1t_ywYcx5Fw",TLG.SERV)

BOT:AddModule("commands"):AddModule("commands_auth"):AddModule("bot_extra")

BOT:SetMaster(TLG.SERV == "kosson")
BOT:SetListener("socket",29000 + SERVERS:ID())
BOT:SetMotd(function()
	return "🕗 Аптайм сервера: " .. string.NiceTime(CurTime()) .. ". ID: " .. SERVERS:ID()
end)


--[[-------------------------------------------------------------------------
	Это пиздец, но я слишком глуп, чтобы использовать регулярку
	или другим образом получить полный путь к соседней с файлом папке модулей
---------------------------------------------------------------------------]]
local full_path = debug.getinfo(1).short_src  -- addons/gluegram/lua/gluegram/bots/core/core_sv.lua
local file_path = full_path:Split("/lua/")[2] -- gluegram/bots/core/core_sv.lua
local pieces    = file_path:Split("/")
local dir_path  = table.concat(pieces,"/",1,#pieces - 1) -- gluegram/bots/core

LoadModules(dir_path .. "/modules","Core TLG Bot")






--[[-------------------------------------------------------------------------
	BASE Commands
---------------------------------------------------------------------------]]

-- help
BOT("help",function(MSG,args)
	if BOT:GetCommand(args[1]) then
		return BOT:GetCommand(args[1]):Help()
	end

	local inf =
		NM([[
		*Руководство по использованию GLUA бота ]] .. BOT:Name() .. [[*

		Вы можете выполнять до 5 команд сразу. Для этого необходимо вводить их через ";"
		Пример: /login \* ; /exit

		Чтобы в любой момент получить короткую справку о нужной команде, введите ее с аргументов -help.
		Пример: /login -help

		Некоторые команды станут доступны только после авторизации (/login ]] .. BOT:Name() .. [[)

		]])

	local auth_mod = BOT:IsModuleConnected("commands_auth")
	for cmd,CMD in pairs( BOT:GetCommands() ) do
		if !auth_mod or CMD:IsPublic() or BOT:GetSession( MSG:From() ) then
			if CMD.aliases and CMD.aliases[cmd] then continue end -- алиас

			inf = inf .. "*/" .. cmd .. "*" .. (CMD:IsPublic() and " Общая" or "") .. (CMD:ForMaster() and " Master" or "")

			-- Команда не является алиасом, но имеет их
			if CMD.aliases then
				inf = inf .. "\n*Алиасы:* " .. table.ConcatKeys(CMD.aliases, ", ")
			end

			inf = inf .. "\n`" .. CMD:Description() .. "`\n\n"
		end
	end

	return inf,"Markdown"
end)
	:SetPublic(true)
	:SetForMaster(true)
	:SetHelp("/help command отобразит помощь по конкретной команде, ровно как и /command --help")
	:SetDescription("Возвращает список доступных на данный момент команд и краткую информацию по ним. После авторизации список может измениться. Также отображает некоторую дополнительную полезную информацию")