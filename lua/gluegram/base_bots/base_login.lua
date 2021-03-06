--[[-------------------------------------------------------------------------
	Бот для работы на нескольких серверах сразу и требущий /login
---------------------------------------------------------------------------]]

-- Конкретный бот
local BOT = TLG.GetBot("base_auth") or TLG.BotFrom("commands", "base_auth")

-- #todo user_id instead of USER
function BOT:Auth(USER, bAuth) -- не чат, а юзер, чтобы в чатах случайно не дать доступ всем
	self.sessions = self.sessions or {}
	self.sessions[USER:ID()] = bAuth and USER or nil
end

function BOT:GetSession(USER)
	return self.sessions and self.sessions[USER:ID()]
end

function BOT:AddNeedAuthCMD(name, cb)
	return self:AddCommand(name, function(MSG, ...)
		if not self:GetSession( MSG:From() ) then return end

		return cb(MSG, ...)
	end)
end

function BOT:CreateAuthCommands()
	self:AddCommand("login",function(MSG, args)
		if not args[1] or string.find(self.class, args[1]) then
			self:Auth(MSG:From(), true)
			return "Connected!\nType /exit " .. self.class .. " for disconnect"
		end
	end)

	self:AddCommand("exit",function(MSG, args)
		if self:GetSession(MSG:From()) and string.find(self.class,args[1] or self.class) then
			self:Auth(MSG:From(), false)
			return "Disconnected from " .. self.class .. ". Bye!"
		end
	end)
end

function BOT:AutoDisconnectUser(USER, delay)
	timer.Create("TLG.AutoDisconnect_" .. USER:ID(), delay or 60 * 30,1,function()
		if self:GetSession(USER) then
			self:Auth(USER, false)
			self:Message(USER:ID(), "Disconnected from " .. self.class .. " because of timeout"):Send()
		end
	end)
end
