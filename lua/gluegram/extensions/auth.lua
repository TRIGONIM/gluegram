--[[-------------------------------------------------------------------------
	TODO избавиться от подключаемых extensions
	Такой функционал должен подключаться к каждому боту по отдельности как к энтити
---------------------------------------------------------------------------]]


local CMD_MT = TLG.GetMeta("COMMAND")

function CMD_MT:SetNeedAuth(b) -- требовать /login
	self.need_auth = b ~= false
	return self
end





hook.Add("TLG.CanRunCommand","auth_ext",function(BOT, USER, CMD, _)
	if not BOT:IsExtensionConnected("auth") then return end

	-- Не авторизированы, а команда требует
	if CMD.need_auth and not BOT:GetSession( USER ) then return false end

	-- Не авторизированы или не имеем доступа к боту
	-- #TODO ограничить команды вместо целого бота
	-- if !BOT:HasAccess(USER:ID()) then
	-- 	return false, "Access denied"
	-- end
end)

hook.Add("TLG.OnCommand","auth_ext_autodisconnect",function(BOT, _, _, MSG)
	if not BOT:IsExtensionConnected("auth") then return end

	local USER = MSG:From()

	-- Обновляем таймер автоотключения
	timer.Create("TLG.AutoDisconnect_" .. USER:ID(),60 * 30,1,function()
		-- Еще не отключился сам
		if BOT:GetSession(USER) then
			BOT:Auth(USER, false)
			BOT:Message(USER:ID(), "Disconnected from " .. BOT:Name() .. " because of timeout"):Send()
		end
	end)
end)


local BOT = BOTMOD
if not BOT then return end -- lua refresh (Сделать бы как в SWEP, ENT и TOOL #todo)

BOT.has_access = {}


function BOT:Auth(USER, bAuth) -- не чат, а юзер, чтобы в чатах случайно не дать доступ всем
	self.sessions = self.sessions or {}
	self.sessions[USER:ID()] = bAuth and USER or nil
end

function BOT:GetSession(USER)
	return self.sessions and self.sessions[USER:ID()]
end



-- login
BOT("login",function(MSG,args)
	if not args[1] or string.find(BOT:Name(), args[1]) then
		BOT:Auth(MSG:From(),true)
		return "Connected!\nType /exit " .. BOT:Name() .. " for disconnect"
	end
end)


-- exit
BOT("exit",function(MSG,args)
	if BOT:GetSession(MSG:From()) and ( not args[1] or string.find(BOT:Name(),args[1]) ) then
		BOT:Auth(MSG:From(),false)
		return "Disconnected from " .. BOT:Name() .. ". Bye!"
	end
end)
