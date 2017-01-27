--[[-------------------------------------------------------------------------
	TODO TODO TODO
	• CMD:AddPassword()
	• Замена TLG.notifyGroup везде
	• TG.SendMessage тоже
	• Модуль управления конфой персонала
	• То же самое касается хэндлеров команд и нажатий кнопок, к примеру
---------------------------------------------------------------------------]]



TLG.BOTS      = TLG.BOTS      or {}
TLG.LISTENERS = TLG.LISTENERS or {}


setmetatable(TLG, {
	__call = function(self,...)
		return self.NewBot(...)
	end
})


--[[-------------------------------------------------------------------------
	MISCELLANEOUS
---------------------------------------------------------------------------]]
function TLG.LogError(err)
	local sErr = isstring(err) and err
	if !sErr then
		sErr = "==== " .. TL.getDatetime() .. " ===="
		for typ,val in pairs(err) do
			sErr = sErr .. "\n" .. typ .. ": " .. val
		end
		sErr = sErr .. "\n========= [TLG ERR] =========\n\n"
	else
		sErr = "[TLG ERR] " .. sErr
	end

	print("\n\n\n" .. sErr)
	file.Append("telegram_errors.txt",sErr)
end


local GREEN = Color(50,200,50)
local WHITE = Color(245,245,245)
local GRAY  = Color(200,200,200)
function TLG.Print(msg)
	MsgC(GREEN,"[",WHITE,"TLG",GREEN,"] ", GRAY,msg .. "\n")
end


--[[-------------------------------------------------------------------------
	BOTS
---------------------------------------------------------------------------]]
function TLG.NewBot(sToken,sName)
	if TLG.BOTS[sName] then return TLG.BOTS[sName] end -- закомментить, если надо изменить метафункцию

	local bot_obj = setmetatable({
		commands = {},
		sessions = {}, -- авторизированные пользователи

		token = sToken,
		name  = sName,
	}, TLG.GetMeta("BOT"))

	TLG.BOTS[sName] = bot_obj

	return bot_obj
end

function TLG.GetBot(sName)
	return TLG.BOTS[sName]
end



--[[-------------------------------------------------------------------------
	LISTENERS. No OOP
---------------------------------------------------------------------------]]
function TLG.AddListener(sName,fHandler)
	TLG.LISTENERS[sName] = fHandler
end

function TLG.GetListener(sName)
	return TLG.LISTENERS[sName]
end