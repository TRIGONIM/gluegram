local BOT = TLG.NewObjectBase("BOT")
BOT.__call = function(self,sCmd,fCallback)
	return self:AddCommand(sCmd,fCallback)
end

-------------------------------------------

function BOT:Name()
	return self.name
end

function BOT:GetToken()
	return self.token
end

-------------------------------------------
-- Создает хук, на который кидает апдейты с бота
function BOT:SetListener(sName,...)
	TLG.GetListener(sName)(function(UPD)
		hook.Run("OnBotUpdate",self,UPD)

		if UPD.message then
			hook.Run("OnBotMessage",self,UPD:Message())
		elseif UPD.callback_query then
			hook.Run("OnBotCBQ",self,UPD:CallbackQuery())
		end
	end,...)

	return self
end


-- Тупо не представляю, как назвать
-- Сжимает это: https://img.qweqwe.ovh/1513091039259.png
function BOT:AddCallback(sHook, fCallback,sUniqueName)
	local selfname = self:Name()
	hook.Add(sHook,selfname .. sUniqueName,function(bot,OBJ)
		if bot:Name() == selfname then
			fCallback(OBJ)
		end
	end)
	return self
end

-- Создает перехватчик апдейтов бота
function BOT:HandleUpdate(fCallback,sUniqueName)
	return self:AddCallback("OnBotUpdate",fCallback,sUniqueName)
end

function BOT:HandleMessage(fCallback,sUniqueName)
	return self:AddCallback("OnBotMessage",fCallback,sUniqueName)
end

function BOT:HandleCBQ(fCallback,sUniqueName)
	return self:AddCallback("OnBotCBQ",fCallback,sUniqueName)
end

-------------------------------------------

-- Создаем объект сообщения
function BOT:Message(iTo,sText)
	if istable(iTo) then -- USER or CHAT object
		iTo = iTo["id"]
	end

	return TLG.Request("sendMessage",self:GetToken())
		:SetChatID(iTo)
		:SetText(sText)
end

-- Принимает объект сообщения полученной с сервера "Update" таблицы
-- По желанию, можно указать "text", иначе он не изменится
-- "sText" указывать ОБЯЗАТЕЛЬНО, если указан "bAppend"
function BOT:EditMessage(MSG,sText,bAppend)
	-- print("BOT:EditMessage(MSG,sText,bAppend)",MSG,sText,bAppend)
	-- PrintTable(MSG)

	-- Обновляем локальный текст
	MSG["text"] = bAppend and (MSG["text"] .. sText) or sText or MSG["text"]

	return TLG.Request("editMessageText",self:GetToken())
		:SetNewText(MSG["text"])
		:SetEditMessageID(MSG["message_id"])
		:SetChatID(MSG["chat"]["id"])
end

function BOT:DeleteMessage(MSG)
	return TLG.Request("deleteMessage",self:GetToken())
		:SetDeletingMessageID(MSG["message_id"])
		:SetChatID(MSG["chat"]["id"])
end

--[[-------------------------------------------------------------------------
Модули
---------------------------------------------------------------------------]]
-- Модуль должен быть в /gluegram/modules
function BOT:AddModule(sName)
	BOTMOD = self -- bot module
	include("gluegram/modules/" .. sName .. ".lua")
	BOTMOD = nil

	-- For BOT:IsModuleConnected(sName)
	self.modules = self.modules or {}
	self.modules[sName] = true

	TLG.Print("Подключили модуль " .. sName .. " к " .. self:Name())

	return self
end


function BOT:IsModuleConnected(sName)
	return self.modules and self.modules[sName] == true
end

--[[-------------------------------------------------------------------------
	Команды
---------------------------------------------------------------------------]]
-- Утилиты
local function processCommand(BOT_OBJ,CMD,MSG,USER,tArgs)
	if tArgs[1] == "-help" and !tArgs[2] then
		BOT_OBJ:Message(USER,CMD:Help() or "По этой команде нет дополнительной информации"):Send()
		return
	end

	--                    "testasdfjhk asdf asd" in tArgs
	local reply,parse_mode = CMD:Call(MSG,tArgs)
	if reply then
		BOT_OBJ:Message(MSG["chat"]["id"], "[" .. BOT_OBJ:Name() .. "]: " .. reply )
			:ReplyTo( MSG:ID() )
			:SetParseMode(parse_mode)
			:Send()
	end

	-- Обновляем таймер автоотключения
	if !BOT_OBJ:IsModuleConnected("commands_auth") then return end
	timer.Create("TLG.AutoDisconnect_" .. USER:ID(),60 * 30,1,function()
		-- Еще не отключился сам
		if BOT_OBJ:GetSession(USER) then
			BOT_OBJ:Auth(USER,false)
			BOT_OBJ:Message(USER,"Вы отключены от " .. BOT_OBJ:Name()):Send()
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


-- Поиск и обработка команд
hook.Add("OnBotMessage","Commands",function(self,MSG)
	if !self:GetCommands() then return end

	-- EXAMPLE: /login@my_info_bot testasdfjhk asdf asd
	if !MSG["text"] or MSG["text"][1] ~= "/" then return end -- если не команда

	local USER = MSG:From()

	-- Обработка нескольких команд в одном сообщении
	local parts = string.Explode(";",MSG:Text())
	for i = 1,math.Clamp(#parts,0,5) do -- ограничиваем для предотвращения абуза
		parts[i] = parts[i]:Trim() -- /cmd;  ; /cmd"
		if parts[i] == "" then continue end

		local pieces = parts[i]:Split(" ")
		local cmd = pieces[1]:Split("@")[1]:sub(2) -- /cmd@botname


		local CMD = self:GetCommands()[cmd]
		if CMD then
			-- Игнорируем обработку, если нужен мастер сервер, а мы им не являемся
			if self:IsModuleConnected("bot_extra") and CMD:ForMaster() and !self:IsMaster() then
				return
			end

			-- Нужна авторизация, а мы не авторизированы
			if self:IsModuleConnected("commands_auth") and !CMD:IsPublic() and !self:GetSession(USER) then
				-- if self:IsMaster() then
				-- 	self:Message(MSG:Chat(),"Вы не авторизированы. /login " .. self:Name()):Send()
				-- end

				return
			end

			--if !CMD:CheckPassword(value)

			processCommand(self,CMD,MSG,USER, table_remove(pieces,1))

		-- else
		-- 	self:Message(MSG:Chat(),self:Name() .. " - команды " .. cmd .. " не существует"):Send()
		end
	end
end)



-- Создаем объект обработчика входящих команд
-- Подробнее в command.lua
function BOT:AddCommand(sCmd,fCallback)
	if !self.commands then
		self.commands = {}
	end

	sCmd = string.lower(sCmd)

	local obj = TLG.SetMeta({
		func = fCallback,
		cmd  = sCmd,

		bot = self -- assign this bot for ability to quick answer from commands
	},"COMMAND")

	self.commands[sCmd] = obj

	return obj
end

function BOT:GetCommand(sCmd)
	return self.commands[sCmd]
end

function BOT:GetCommands()
	return self.commands
end
