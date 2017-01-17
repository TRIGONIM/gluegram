local BOT = TLG.BOTS[TLG.SERV]


-- login
BOT:AddCommand("login",function(MSG,args)
	if !args[1] and BOT:IsMaster() then
		return "Нужно ввести кодовое название бота, к которому хотите подключиться. Пример: /login " .. BOT:Name()
	end

	--                                  \/ /login *, /login ser*er
	if args[1] == BOT:Name() or string.find(BOT:Name(),args[1]) then
		BOT:Auth(MSG:From(),true)
		return "Подключились к " .. BOT:Name()
	end
end)
	:SetPublic(true)
	:SetHelp("Параметром принимает точное название бота или же его часть. Поддерживает \"*\"")
	:SetDescription("Авторизация в указанном в аргументах боте. Список доступных ботов: /bots")



-- exit
BOT:AddCommand("exit",function(MSG,args)
	if !args[1] or args[1] == BOT:Name() or string.find(BOT:Name(),args[1]) then
		BOT:Auth(MSG:From(),false)
		return "Отключились от " .. BOT:Name()
	end
end)
	:SetPublic(true)
	:SetHelp("Параметром принимает точное название бота или же его часть. Поддерживает \"*\"")
	:SetDescription("Ручное отключение от указанного бота или от всех, если название не указано. После отключения все команды перестанут вводиться до следующей авторизации (полезно при работе с несколькими серверами)")


-- bots
BOT:AddCommand("bots",function(MSG)
	return (BOT:IsUserAuthed(MSG:From()) and "✅" or "❌") .. " Я " .. BOT:Name() .. (BOT:IsMaster() and " (MASTER)" or "")
end)
	:SetPublic(true)
	:SetDescription("Выводит список доступных ботов. Активные боты имеют соответствующую иконку")

-- cmd
local rectxt = ""
BOT:AddCommand("cmd",function(MSG,args)
	if true then return "Выключено" end

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
		BOT:Message(MSG:From(),string.format("Выполнение команды %s с аргументами [%s]:\n%s", args[1],string.Implode(" ",args),rectxt)):Send()

		rectxt = ""
	end)
end)
	:SetHelp("/cmd status")
	:SetDescription("Выполняет введенную консольную команду на сервере, закрепленным за ботом")
