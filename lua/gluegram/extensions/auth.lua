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
	-- Нужна авторизация, а мы не авторизированы
	if BOT:IsExtensionConnected("auth") and !CMD:IsPublic() and !BOT:GetSession(USER) then
		return false
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
if !BOT then return end -- lua refresh

BOT.has_access = {}


function BOT:Auth(USER,bAuth)
	self.sessions[USER:ID()] = bAuth and USER or nil -- не даем записать false. Лишняя память)
end

-- Проверяется, если "not CMD:IsPublic()"
function BOT:GetSession(USER)
	return self.sessions[USER:ID()]
end

-- Функция будет выполняться после /login botname
function BOT:SetMotd(fMotd)
	self.motd = fMotd
	return self
end


-- TODO Потом будет через БД с командами управления юзерами
-- -- /addaccess chat_id kosson, /removeaccess chat_id delta
function BOT:AddAccess(user_id)
	assert(user_id,"user_id expected, got nil")
	self.has_access[user_id] = true
end

function BOT:HasAccess(user_id)
	return self.has_access[user_id]
end








-- login
BOT("login",function(MSG,args)
	if !BOT:HasAccess(MSG:From():ID()) then return "Access denied" end

	if !args[1] and (!BOT.IsMaster or BOT:IsMaster()) then -- если не подключен экстра модуль (.IsMaster)
		return "Нужно ввести кодовое название бота, к которому хотите подключиться. Пример: /login " .. BOT:Name()

	-- Не мастер сервере, но не введен сервер
	elseif !args[1] then
		return
	end

	--                                  \/ /login *, /login ser*er
	if args[1] == BOT:Name() or string.find(BOT:Name(),args[1]) or args[1] == "*" then
		BOT:Auth(MSG:From(),true)
		return "подключен." .. (BOT.motd and ("\n\nMOTD:\n" .. BOT.motd()) or "")
	end
end):SetPublic(true)



-- exit
BOT("exit",function(MSG,args)
	if BOT:GetSession(MSG:From()) and ( !args[1] or args[1] == BOT:Name() or string.find(BOT:Name(),args[1]) ) then
		BOT:Auth(MSG:From(),false)
		return "отключились. Бай-бай"
	end
end):SetPublic(true)
