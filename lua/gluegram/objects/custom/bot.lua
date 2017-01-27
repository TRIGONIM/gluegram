local BOT = TLG.NewObjectBase("BOT")

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
		local name = self:Name()
		hook.Run(name[1]:upper() .. name:sub(2) .. "BotUpdated",UPD)
		-- dion > Dion
	end,...)

	return self
end

-- Создает перехватчик апдейтов бота
function BOT:HandleUpdates(fCallback,sUniqueName)
	local name = self:Name()
	hook.Add(name[1]:upper() .. name:sub(2) .. "BotUpdated","UpdateHook-" .. sUniqueName,fCallback)
	return self
end

-------------------------------------------

-- Создаем объект сообщения
function BOT:Message(iTo,sText)
	if istable(iTo) then -- USER or CHAT object
		iTo = iTo["id"]
	end

	return TLG.Request("sendMessage",self:GetToken())
		:BindParams(iTo,sText)
end

-- Принимает объект сообщения полученной с сервера "Update" таблицы
-- По желанию, можно указать "text", иначе он не изменится
-- "sText" указывать ОБЯЗАТЕЛЬНО, если указан "bAppend"
function BOT:EditMessage(MSG,sText,bAppend)
	-- print("BOT:EditMessage(MSG,sText,bAppend)",MSG,sText,bAppend)
	-- PrintTable(MSG)

	return TLG.Request("editMessageText",self:GetToken())
		:BindParams(bAppend and (MSG["text"] .. sText) or sText or MSG["text"])
		:SetEditMessageID(MSG["message_id"])
		:SetChatID(MSG["chat"]["id"])
end

-------------------------------------------

-- Модуль должен быть в /gluegram/modules
function BOT:AddModule(sName)
	local returned_func = CompileFile("gluegram/modules/" .. sName .. ".lua")()

	if returned_func then
		returned_func(self)
	end

	-- For BOT:IsModuleConnected(sName) 
	self.modules = self.modules or {}
	self.modules[sName] = true

	TLG.Print("Подключили модуль " .. sName .. " к " .. self:Name())

	return self
end


function BOT:IsModuleConnected(sName)
	return self.modules[sName] == true
end