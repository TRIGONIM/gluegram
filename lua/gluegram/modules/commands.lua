
local function processCommand(BOT,CMD,MSG,USER,tArgs)
	if tArgs[1] == "-help" and !tArgs[2] then
		BOT:Message(USER,CMD:Help() or "По этой команде нет дополнительной информации"):Send()
		return
	end

	--                    "testasdfjhk asdf asd" in tArgs
	local reply,parse_mode = CMD:Call(MSG,tArgs)
	if reply then
		BOT:Message(MSG["chat"]["id"], "[" .. BOT:Name() .. "]: " .. reply )
			:ReplyTo( MSG:ID() )
			:SetParseMode(parse_mode)
			:Send()
	end

	-- Обновляем таймер автоотключения
	if !BOT:IsModuleConnected("commands_auth") then return end
	timer.Create("TLG.AutoDisconnect_" .. USER:ID(),60 * 30,1,function()
		-- Еще не отключился сам
		if BOT:GetSession(USER) then
			BOT:Auth(USER,false)
			BOT:Message(USER,"Вы отключены от " .. BOT:Name()):Send()
		end
	end)
end

local function table_remove(tab,index)
	local ntab = {}

	for i = 1,#tab do
		if i == index then continue end

		ntab[#ntab + 1] = tab[i]
	end

	return ntab
end


--[[-------------------------------------------------------------------------
	КЛЮЧЕВОЕ МЕСТО КЛЮЧЕВОЕ МЕСТО КЛЮЧЕВОЕ МЕСТО КЛЮЧЕВОЕ МЕСТО
	КЛЮЧЕВОЕ МЕСТО КЛЮЧЕВОЕ МЕСТО КЛЮЧЕВОЕ МЕСТО КЛЮЧЕВОЕ МЕСТО
	Блять, во что я превратил нормального бота. Говнокод ебучий
---------------------------------------------------------------------------]]
return function(BOT)

BOT:HandleUpdates(function(UPD)
	-- EXAMPLE: /login@my_info_bot testasdfjhk asdf asd
	if !UPD["message"] or !UPD["message"]["text"] or UPD["message"]["text"][1] ~= "/" then return end -- если не команда

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
			if BOT:IsModuleConnected("bot_extra") and CMD:ForMaster() and !BOT:IsMaster() then
				return
			end

			-- Нужна авторизация, а мы не авторизированы
			if BOT:IsModuleConnected("commands_auth") and !CMD:IsPublic() and !BOT:GetSession(USER) then
				BOT:Message(USER,"Вы не авторизированы. /login " .. BOT:Name()):Send()
				return
			end

			--if !CMD:CheckPassword(value)

			processCommand(BOT,CMD,MSG,USER, table_remove(pieces,1))

		else
			BOT:Message(USER,BOT:Name() .. " - команды " .. cmd .. " не существует"):Send()
		end
	end
end,"module_commands")




-- пиздец однако. Сложно объяснить. Это вроде через __newindex должно делаться
-- Сделано для того, чтобы мета применялась не для всех ботов, а только текущего,
-- который решил заюзать модуль
local BOT_MT = table.Copy(getmetatable(BOT))
BOT_MT.__call = function(self,...) return self:AddCommand(...) end -- = BOT.AddCommand


-- Создаем объект обработчика входящих команд
-- Подробнее в command.lua
function BOT_MT:AddCommand(sCmd,fCallback)
	sCmd = string.lower(sCmd)

	local obj = TLG.SetMeta({
		func = fCallback,
		cmd  = sCmd,

		bot = self -- assign this bot for ability to quick answer from commands
	},"COMMAND")

	self.commands[sCmd] = obj

	return obj
end

function BOT_MT:GetCommand(sCmd)
	return self.commands[sCmd]
end

function BOT_MT:GetCommands()
	return self.commands
end



setmetatable(BOT,BOT_MT)
end