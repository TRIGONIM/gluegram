local CMD_MT = TLG.GetObject("COMMAND") -- todo сделать локальное применение, а не всей метатаблице

-- Может ли каждый желающий использовать команду
-- Если не указано или false, то проверка на авторизованность (:IsPublic())
-- происходит в objects/custom/bot.lua
function CMD_MT:SetPublic(bPublic)
	self.public = bPublic
	return self
end

function CMD_MT:IsPublic()
	return self.public
end



hook.Add("TLG.CanRunCommand","auth ext",function(BOT, USER, CMD, _)
	if !BOT:IsExtensionConnected("auth") then return end

	if CMD:IsPublic() then return end

	-- Не авторизированы
	if !BOT:GetSession(USER) then return false end

	-- Не авторизированы или не имеем доступа к боту
	-- #TODO ограничить команды вместо целого бота
	if !BOT:HasAccess(USER:ID()) then
		return false, "Access denied"
	end
end)

hook.Add("TLG.OnCommand","auth ext autodisconnect",function(BOT, CHAT)
	if !BOT:IsExtensionConnected("auth") then return end

	-- Обновляем таймер автоотключения
	timer.Create("TLG.AutoDisconnect_" .. CHAT:ID(),60 * 30,1,function()
		-- Еще не отключился сам
		if BOT:GetSession(CHAT) then
			BOT:Auth(CHAT,false)
			BOT:Message(CHAT,"Вы отключены от " .. BOT:Name()):Send()
		end
	end)
end)


local BOT = BOTMOD
if !BOT then return end -- lua refresh (Сделать бы как в SWEP, ENT и TOOL #todo)

BOT.has_access = {}


function BOT:Auth(USER,bAuth)
	self.sessions[USER:ID()] = bAuth and USER or nil -- не даем записать false. Лишняя память)
end

function BOT:GetSession(USER)
	return self.sessions[USER:ID()]
end


function BOT:AddAccess(user_id)
	assert(user_id,"user_id expected, got nil")
	self.has_access[user_id] = true
end

function BOT:HasAccess(user_id)
	return self.has_access[user_id]
end




-- login
BOT("login",function(MSG,args)
	if !args[1] or string.find(BOT:Name(), args[1]) then
		BOT:Auth(MSG:From(),true)
		return BOT:Name() .. " подключен."
	end
end):SetPublic(true)



-- exit
BOT("exit",function(MSG,args)
	if BOT:GetSession(MSG:From()) and ( !args[1] or string.find(BOT:Name(),args[1]) ) then
		BOT:Auth(MSG:From(),false)
		return "Отключились от " .. BOT:Name() .. ". Бай-бай"
	end
end):SetPublic(true)
