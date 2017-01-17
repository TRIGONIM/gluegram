local BOT = TLG("167720993:AAEzqbwu8Jpq9-L3tblzrPXR1t_ywYcx5Fw",TLG.SERV)
	:SetListenPort(29000 + ServerID())
	:SetMaster(TLG.SERV == "kosson")




local function processCommand(CMD,MSG,tArgs)
	PrintTable(CMD)

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

		PrintTable(BOT:GetCommands())

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