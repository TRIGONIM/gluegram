local BOT = TLG.BOTS[TLG.SERV]

-- bots
BOT:AddCommand("bots",function(MSG)
	return (BOT:IsUserAuthed(MSG:From()) and "✅" or "❌") .. " Я " .. BOT:Name() .. (BOT:IsMaster() and " (MASTER)" or "")
end)
	:SetPublic(true)
	:AddAlias("servers"):AddAlias("ping")
	:SetDescription("Выводит список доступных ботов. Активные боты имеют соответствующую иконку")


-- cmd
local rectxt = ""
BOT:AddCommand("cmd",function(MSG,args)
	if !args[1] then
		return "Нужно ввести саму команду. Пример в --help"
	end

	-- Если enginespew нет, то сообщение с ответом будет пустым
	hook.Add("EngineSpew","TLG.TopKostil",function(_,msg)
		rectxt = rectxt .. "💩 " .. msg
	end)


	RunConsoleCommand(args[1], unpack(args,2))

	timer.Simple(.4,function()
		hook.Remove("EngineSpew","TLG.TopKostil")

		-- не return ибо в таймере
		BOT:Message(MSG:Chat(),string.format("Выполнение команды %s с аргументами [%s]:\n%s", args[1],string.Implode(" ",args),rectxt)):Send()

		rectxt = ""
	end)
end)
	:SetHelp("/cmd status")
	:SetDescription("Выполняет введенную консольную команду на сервере, закрепленным за ботом")


-- serverinfo
BOT:AddCommand("serverinfo",function(MSG)
	local plys = player.GetAll()

	local plys_props = {}
	for k,v in pairs(ents.GetAll()) do
		if !IsValid(v) or v:GetPersistent() then continue end

		if v.FPPOwnerID then
			plys_props[v.FPPOwnerID] = plys_props[v.FPPOwnerID] or {}
			plys_props[v.FPPOwnerID][#plys_props[v.FPPOwnerID] + 1] = v
		end
	end

	local props = 0 -- counter
	for stid,t in pairs(plys_props) do
		props = props + #t
	end

	local plysinf =
		"👥 Онлайн: " .. #plys .. "/" .. game.MaxPlayers() .. "\n" ..
		"⚽️ Пропов игроков: " .. props .. "\n" ..
		"=======================" .. "\n"

	for i = 1, #plys do
		local ply = plys[i]
		local steamid = ply:SteamID()

		plysinf =
			plysinf ..
			"👤 " .. ply:Nick() .. "\n" ..
			"🎫 " .. steamid .. "\n" ..
			"🕵 Убийств, смертей: " .. ply:Frags() .. "|" .. ply:Deaths() .. "\n" ..
			"⚒ Пропов: " .. (plys_props[steamid] and #plys_props[steamid] or 0) .. "\n" ..
			"------------------------------------"  .. "\n"
	end

	return plysinf
end):SetDescription("Информация о сервере, закрепленным за ботом (Онлайн, аптайм, убийства и смерти онлайн игроков, а также их ник и стимайди")


-- // say to server chat
BOT:AddCommand("/",function(MSG,args)
	qq.CMessage(player.GetAll(),("[" .. MSG:From() .. "] ") .. string.Implode(" ",args),Color(255,50,50))

	return "Сообщение получено"
end):SetDescription("Отправляет сообщение в чат закрепленного за ботом сервера. Перед вашим сообщением будет @telegramlogin")


-- chat, test
BOT:AddCommand("chat",function(MSG,args)
	local USER = MSG:From()
	local CHAT = MSG:Chat()

	return ("\nЗдравствуй, %s(*%s*)%s!\n*Твой ID:* %s\n\n*ID сообщения:* %s\n*Дата:*%s%s\n\n*ID чата:* %s\n*Тип:* %s")
		:format(
			USER:FName(), USER:Login() or "nologin", USER:LName() and (" " .. USER:LName()) or "", USER:ID(),
			MSG:ID(), MSG:Date(), args[1] and ("\nАргументы: " .. string.Implode(" ",args)) or "",
			CHAT:ID(), CHAT:Type()
		),"Markdown"
end)
	:SetPublic(true)
	:AddAlias("test")
	:SetDescription("Информация о текущем чате")


-- logchat
local interceptors = {}
BOT:AddCommand("logchat",function(MSG)
	local CHAT = MSG:Chat()

	if interceptors[CHAT:ID()] then
		interceptors[CHAT:ID()] = nil

		if table.Count(interceptors) == 0 then
			hook.Remove("PlayerSay","TLG.ChatIntercept")
		end

		return "Перехват выключен"
	end

	interceptors[CHAT:ID()] = CHAT

	hook.Add("PlayerSay","TLG.ChatIntercept",function(ply,txt,tm)
		for id,CHT in pairs(interceptors) do
			BOT:Message(CHT, "(" ..  ply:Nick() .. "): " .. txt ):Send()
		end
	end)

	return "Логирование чата включено"
end):SetDescription("Ретрансляция всех сообщения из чата связанного сервера в чат телеграмма. После деавторизации сообщения продолжат перехватываться, если не выключить вручную")
