return function(BOT)
local BOT_MT = table.Copy(getmetatable(BOT))


function BOT_MT:Auth(USER,bAuth)
	self.sessions[USER:ID()] = bAuth and USER or nil -- не даем записать false. Лишняя память)
end

-- Проверяется, если "not CMD:IsPublic()"
function BOT_MT:GetSession(USER)
	return self.sessions[USER:ID()]
end

-- Функция будет выполняться после /login botname
function BOT_MT:SetMotd(fMotd)
	self.motd = fMotd
	return self
end

setmetatable(BOT,BOT_MT)






-- login
BOT("login",function(MSG,args)
	if MSG:From():Login() ~= "amd_nick" then return "Бот пока выключен" end

	if !args[1] and (!BOT.IsMaster or BOT:IsMaster()) then -- если не подключен экстра модуль (.IsMaster)
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
BOT("exit",function(MSG,args)
	if !args[1] or args[1] == BOT:Name() or string.find(BOT:Name(),args[1]) then
		BOT:Auth(MSG:From(),false)
		return "отключились. Бай-бай"
	end
end)
	:SetPublic(true)
	:SetHelp("Параметром принимает точное название бота или же его часть. Поддерживает \"*\"")
	:SetDescription("Ручное отключение от указанного бота или от всех, если название не указано. После отключения все команды перестанут вводиться до следующей авторизации (полезно при работе с несколькими серверами)")
end