local BOT_MT = TLG.NewObjectBase("BOT")
BOT_MT.__call = function(self,sCmd,fCallback)
	return self:AddCommand(sCmd,fCallback)
end

-------------------------------------------

function BOT_MT:Name()
	return self.name
end

function BOT_MT:GetToken()
	return self.token
end



--[[-------------------------------------------------------------------------
	Утилки
---------------------------------------------------------------------------]]
function BOT_MT:Request(METH, cb_typ)
	return TLG.Request(METH):SetToken( self:GetToken() ):SetCallbackType(cb_typ)
end



--[[-------------------------------------------------------------------------
	Апдейты
---------------------------------------------------------------------------]]
function BOT_MT:PushUpdate(tData)
	hook.Run("OnBotUpdate", self, TLG.SetMeta(tData,"Update"))
end

-- TODO сделать отдельным кастомным модулем. Чтобы база кода была чиста от говна
hook.Add("OnBotUpdate","CustomReceivers",function(BOT, UPD)
	if UPD.message then
		hook.Run("OnBotMessage",BOT,UPD:Message())
	elseif UPD.callback_query then
		hook.Run("OnBotCBQ",BOT,UPD:CallbackQuery())
	end
end)


-- Тупо не представляю, как назвать
-- Сжимает это: https://img.qweqwe.ovh/1513091039259.png
function BOT_MT:FormatCallback(sHook, fCallback,sUniqueName)
	local selfname = self:Name()
	hook.Add(sHook,selfname .. sUniqueName,function(bot,OBJ)
		if bot:Name() == selfname then
			fCallback(OBJ)
		end
	end)
	return self
end

-- Создает перехватчик апдейтов бота
function BOT_MT:HandleUpdate(fCallback,sUniqueName)
	return self:FormatCallback("OnBotUpdate",fCallback,sUniqueName)
end

function BOT_MT:HandleMessage(fCallback,sUniqueName)
	return self:FormatCallback("OnBotMessage",fCallback,sUniqueName)
end

function BOT_MT:HandleCBQ(fCallback,sUniqueName)
	return self:FormatCallback("OnBotCBQ",fCallback,sUniqueName)
end


--[[-------------------------------------------------------------------------
	Polling
---------------------------------------------------------------------------]]
function BOT_MT:Poll(cb)
	local polling_offset = bib.get("tlg:" .. self:Name() .. ":polling_offset") -- may be nil

	self:GetUpdates():SetOffset(polling_offset):Send(function(updList)
		if cb then
			cb(updList)
		end

		-- Апдейтов нет
		if #updList == 0 then return end

		for _,UPD in ipairs(updList) do
			self:PushUpdate( TLG.SetMeta(UPD, "Update") )
		end

		local lastUPDid = updList[#updList].update_id
		bib.set("tlg:" .. self:Name() .. ":polling_offset", lastUPDid + 1)
		-- tlg:botname:polling_offset = 1337
		-- print("lastUPDid", lastUPDid + 1)
	end)
end

function BOT_MT:StartPolling(delay)
	timer.Create("TLG.Polling." .. self:Name(), delay or 5, 0, function()
		if self.busy then -- не завершился предыдущий запрос
			ErrorNoHalt("[" .. self:Name() .. "] Some query already in process. Try to reduse polling delay\n")
			return
		end

		self.busy = true
		self:Poll(function()
			self.busy = false
		end)
	end)
end

function BOT_MT:StopPolling()
	timer.Remove("TLG.Polling." .. self:Name())
end


--[[-------------------------------------------------------------------------
	Расширения
---------------------------------------------------------------------------]]
-- /gluegram/extensions
function BOT_MT:AddExtension(sName)
	assert(file.Exists("gluegram/extensions/" .. sName .. ".lua","LUA"),"TLG Extension " .. sName .. ".lua not found")

	BOTMOD = self -- bot module
	include("gluegram/extensions/" .. sName .. ".lua")
	BOTMOD = nil

	-- For BOT:IsExtensionConnected(sName)
	self.extensions = self.extensions or {}
	self.extensions[sName] = true

	TLG.Print("Подключили модуль " .. sName .. " к " .. self:Name())

	return self
end


function BOT_MT:IsExtensionConnected(sName)
	return self.extensions and self.extensions[sName] == true
end




--[[-------------------------------------------------------------------------
	Команды
---------------------------------------------------------------------------]]
function BOT_MT:ProcessCommand(MSG, cmd, argss_)
	local CMD = self:GetCommands()[cmd]
	if !CMD then return end

	if hook.Run("TLG.CanRunCommand", self, MSG:From(), CMD, MSG) == false then
		return
	end

	local tArgs = {}
	if argss_ then
		for _,arg in ipairs( string.Explode(" ", argss_) ) do
			if arg == "" then continue end
			tArgs[#tArgs + 1] = arg
		end
	end

	local reply,parse_mode = CMD.func(MSG,tArgs,argss_)
	if reply then
		self:Message(MSG["chat"]["id"], reply) -- "[" .. self:Name() .. "]: " ..
			:ReplyTo( MSG:ID() )
			:SetParseMode( parse_mode )
			:Send()
	end

	hook.Run("TLG.OnCommand", self, MSG:Chat(), CMD, MSG, tArgs)
end





-- Поиск и обработка команд
--[[-------------------------------------------------------------------------
 /abcdef 123
 /qwer       123 ; ;    ;;;   ; ;
 /hahaa qwe ewq  ;
 /keklol heh mda
---------------------------------------------------------------------------]]
hook.Add("OnBotMessage","Commands",function(self, MSG)
	if !self:GetCommands() then return end

	-- local CHAT = MSG:Chat()
	local text = MSG.text

	if !MSG.entities then return end
	function MSG.entities:getNextCmdEnt(last)
		local next = last + 1
		local next_ent = self[next]
		if next_ent and next_ent.type ~= "bot_command" then
			return self:getNextCmdEnt(next)
		end

		return next_ent
	end

	-- https://img.qweqwe.ovh/1528146795923.png
	for i,ent in ipairs(MSG.entities) do
		if ent.type ~= "bot_command" then continue end
		if i > 10 then break end

		local start = ent.offset + 2
		local endd = start + ent.length - 2
		local cmd = text:sub(start, endd):Split("@")[1]:lower() -- /CMD@botname > cmd

		local next_ent = MSG.entities:getNextCmdEnt(i)

		start = endd + 2
		endd = next_ent and (next_ent.offset - 1) or nil

		local argss_ = text:sub(start, endd)
		if argss_ == "" then
			argss_ = nil
		end

		self:ProcessCommand(MSG, cmd, argss_)
	end
end)





-- Создаем объект обработчика входящих команд
function BOT_MT:AddCommand(sCmd,fCallback)
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

function BOT_MT:GetCommand(sCmd)
	return self.commands[sCmd]
end

function BOT_MT:GetCommands()
	return self.commands
end
