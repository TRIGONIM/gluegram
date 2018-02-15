local BOT = TLG_CORE_BOT

-- bots
BOT:AddCommand("bots",function(MSG)
	return (BOT:GetSession(MSG:From()) and "✅" or "❌") .. " Я " .. BOT:Name() .. (BOT:IsMaster() and " (MASTER)" or "")
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

		if IsValid(v:CPPIGetOwner()) then
			local _, uid = v:CPPIGetOwner()
			plys_props[uid] = plys_props[uid] or {}
			plys_props[uid] [#plys_props[uid] + 1] = v
		end
	end

	local props = 0 -- counter
	for _,t in pairs(plys_props) do
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

local function tableConcat(t) -- с tostring
	local s = ""
	for i,v in ipairs(t) do
		s = s .. tostring(v) .. " "
	end
	return s:sub(1,-2)
end

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

	local function sendMsg(t)
		for id,CHT in pairs(interceptors) do
			BOT:Message(CHT, t):Send()
		end
	end

	hook.Add("cmd.OnCommandRun","TLG.ChatIntercept",function(pl,CMD,args)
		sendMsg("[CMD] (" ..  pl:Nick() .. "): /" .. CMD:GetNiceName() .. " -> " .. tableConcat(args))
	end)
	hook.Add("PlayerSay","TLG.ChatIntercept",function(pl,txt,tm)
		sendMsg((tm and "[TEAM] " or "") .. "(" ..  pl:Nick() .. "): " .. txt)
	end)

	return "Логирование чата включено"
end):SetDescription("Ретрансляция всех сообщения из чата связанного сервера в чат телеграмма. После деавторизации сообщения продолжат перехватываться, если не выключить вручную")


local pending_tasks = {} -- TODO сделать, чтобы другие юзеры не могли удалять чужие задачи
BOT:AddCommand("timer",function(MSG,args)
	if args[1] == "remove" then
		args[2] = tonumber(args[2])

		if !pending_tasks[ args[2] ] then
			return "Задача с ID " .. args[2] .. " отсутствует. Попробуйте /timer list"
		end

		pending_tasks[ args[2] ] = nil

		return "Задача удалена и не выполнится"
	end

	if args[1] == "list" then
		local cmds = "\n"
		for id,t in pairs(pending_tasks) do -- pairs, чтобы ничего не прпоустить, если удалить из сереединки эллемент
			cmds = cmds .. "`" .. id .. "` *" .. t.cmd.cmd .. "* " .. table.concat(t.args," ") .. "\n" ..
			"`Выполнится через " .. timeToStr(t.call_in - CurTime()) .. "`\n\n"
		end

		return cmds ~= "" and cmds or "Список пуст", "markdown"
	end

	local mins,scmd = args[1],args[2]
	local err =
		!mins and "Не указано время таймера" or
		!tonumber(mins) and "Время нужно указывать числом" or
		!scmd and "Не указано действие (команда)"

	if err then
		return err
	end

	local CMD = BOT:GetCommand(scmd)
	if !CMD then
		return "Команды " .. scmd .. " не существует"
	end

	local tArgs = {}
	for i = 3,#args do
		tArgs[#tArgs + 1] = args[i]
	end

	local id = table.insert(pending_tasks,{
		cmd     = CMD,
		args    = tArgs,
		call_in = CurTime() + 60 * mins
	})

	timer.Simple(60 * mins,function()
		local task = pending_tasks[id]
		if task then
			task.cmd:Call(MSG, task.args)
			pending_tasks[id] = nil
		end
	end)

	return "Команда выполнится через *" .. mins .. "* мин." ..
	"\n*ID задачи*: " .. id ..
	"\nВведите /timer remove " .. id .. " для остановки",
		"markdown"
end)
	:SetDescription(
		"Выполняет команду с задержкой. " ..
		"Полезно для, например, рестарта сервера через время, если сам хочешь спать и нет возможности офнуть. " ..
		"Или же для выключения логгинга сообщения чата"
	)
	:SetHelp("/timer MINS CMD CMD_ARGS. /timer list. /timer remove ID. /timer 1 cmd say Это сообщение через минуту напишется от консоли")
