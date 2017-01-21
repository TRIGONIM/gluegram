--[[-------------------------------------------------------------------------
	TODO TODO TODO
	• CMD:AddPassword()
	• Замена TLG.notifyGroup везде
	• TG.SendMessage тоже
	• Модуль управления конфой персонала
	• Нормальная регистрация и работа листенеров с несколькими ботами
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



--[[-------------------------------------------------------------------------
	BOTS
---------------------------------------------------------------------------]]
function TLG.NewBot(sToken,sName)
	if TLG.BOTS[sName] then return TLG.BOTS[sName] end

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
	LISTENERS object/custom/listener.lua

	Если нужно несколько ботов, придется делать несколько похожих слушателей
	Я пока наговнокодил и вышло так, как вышло.

	Например, 2 бота на разных сокетах.
	Придется регать 1 и тот же слушатель, но с разными именами и портами
	Как-нить потом поправлю
---------------------------------------------------------------------------]]
function TLG.AddListener(sName,fHandler)
	local obj = setmetatable({
		receivers = {},
		handler = fHandler,
		active = false,
	},TLG.GetMeta("LISTENER"))

	TLG.LISTENERS[sName] = obj

	return obj
end

function TLG.GetListener(sName)
	return TLG.LISTENERS[sName]
end