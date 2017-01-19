local BOT = TLG("167720993:AAEzqbwu8Jpq9-L3tblzrPXR1t_ywYcx5Fw",TLG.SERV)
	:SetListenPort(29000 + ServerID())
	:SetMaster(TLG.SERV == "kosson")
	:SetMotd(function()
		return "🕗 Аптайм сервера: " .. string.NiceTime(CurTime())
	end)




local function processCommand(CMD,MSG,tArgs)
	CMD:Call(MSG,tArgs)
	-- "testasdfjhk asdf asd" in tArgs
end

local function table_remove(tab,index)
	local ntab = {}

	for i = 1,#tab do
		if i == index then continue end

		ntab[#ntab + 1] = tab[i]
	end

	return ntab
end


BOT:UpdatesHook(function(UPD)
	-- EXAMPLE: /login@my_info_bot testasdfjhk asdf asd
	if !UPD["message"]["text"] or UPD["message"]["text"][1] ~= "/" then return end -- если не команда

	local MSG  = UPD:Message()
	local USER = MSG:From()

	-- Обработка нескольких команд в одном сообщении
	local parts = string.Explode(";",MSG:Text())
	for i = 1,math.Clamp(#parts,0,5) do -- ограничиваем для предотвращения абуза
		parts[i] = parts[i]:Trim() -- /cmd;  ; /cmd"
		if parts[i] == "" then continue end

		local pieces = parts[i]:Split(" ")
		local cmd = pieces[1]:Split("@")[1]:sub(2) -- /cmd@botname

		local CMD = BOT:GetCommands()[cmd]
		if CMD then

			-- Игнорируем обработку, если нужен мастер сервер, а мы им не являемся
			if CMD:ForMaster() and !TLG.CFG.isMasterServer then
				return
			end

			-- Нужна авторизация, а мы не авторизированы
			if !CMD:IsPublic() and !BOT:IsUserAuthed(USER) then
				BOT:Message(USER,"Вы не авторизированы. /login " .. BOT:Name()):Send()
				return
			end


			processCommand(CMD,UPD:Message(), table_remove(pieces,1))

		else
			BOT:Message(USER,"Команды " .. cmd .. " не существует"):Send()
		end
	end
end,"core")





--[[-------------------------------------------------------------------------
	BASE Commands
---------------------------------------------------------------------------]]

-- login
BOT:AddCommand("login",function(MSG,args)
	if true then return "Бот пока выключен" end

	if !args[1] and BOT:IsMaster() then
		return "Нужно ввести кодовое название бота, к которому хотите подключиться. Пример: /login " .. BOT:Name()
	end

	--                                  \/ /login *, /login ser*er
	if args[1] == BOT:Name() or string.find(BOT:Name(),args[1]) then
		BOT:Auth(MSG:From(),true)
		return "подключен." .. (BOT.motd and ("\n\nMOTD:\n" .. BOT.motd()) or "")
	end
end)
	:SetPublic(true)
	:SetHelp("Параметром принимает точное название бота или же его часть. Поддерживает \"*\"")
	:SetDescription("Авторизация в указанном в аргументах боте. Список доступных ботов: /bots")



-- exit
BOT:AddCommand("exit",function(MSG,args)
	if !args[1] or args[1] == BOT:Name() or string.find(BOT:Name(),args[1]) then
		BOT:Auth(MSG:From(),false)
		return "Отключились от " .. BOT:Name()
	end
end)
	:SetPublic(true)
	:SetHelp("Параметром принимает точное название бота или же его часть. Поддерживает \"*\"")
	:SetDescription("Ручное отключение от указанного бота или от всех, если название не указано. После отключения все команды перестанут вводиться до следующей авторизации (полезно при работе с несколькими серверами)")


-- help
BOT:AddCommand("help",function(MSG,args)
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

	for cmd,CMD in pairs( BOT:GetCommands() ) do
		if CMD:IsPublic() or BOT:IsUserAuthed( MSG:From() ) then
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
	:SetDescription("Возвращает список доступных на данный момент команд и краткую информацию по ним. После авторизации список может измениться. Также отображает некоторую дополнительнуюю полезную информацию")