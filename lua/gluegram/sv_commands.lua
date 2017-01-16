local c = TLG.Cfg
local l = TLG.Language

TLG.addCommand(
	"login",
	function(chat, msgtbl)
		if !msgtbl[2] then
			TG.SendMessage(chat, "Нужно ввести кодовое название сервера. Пример: /login prisma")
			return
		end

		if string.lower(msgtbl[2]) == c.SVName or msgtbl[2] == "*" then
			TLG.connect(chat)
		end
	end,
	"Авторизация на указанном в аргументах сервере. Список доступных серверов: /servers",
	true
)

TLG.addCommand(
	"servers",
	function(chat)
		TG.SendMessage(chat, "Кодовое название: " .. (c.isMasterServer and (c.SVName .. " (MASTER)" ) or c.SVName))
	end,
	"Каждый из активных серверов отправляет вам свое кодовое название. Возможность добавлена 15.02.16",
	true
)

TLG.addCommand(
	"help",
	function(chat)

		local inf =
			[[
			*Руководство по использованию GLUA бота для TELEGRAM от _AMD_*

			Для начала нужно авторизироваться на нужном вам сервере.
			Пока вы не авторизируетесь на сервере, все вводимые команды будут игнорироваться

			Для авторизации на сервере введите /login <servername>, где <servername> - кодовое название сервера, которое указано в конфиге.
			Есть возможность авторизации сразу на нескольких серверах. В таком случае все вводимые команды будут обрабатываться сразу на нескольких серверах
			Чтобы подключиться ко всем серверам сразу введите /login \*

			Вы можете выполнять несколько команд сразу. Для этого вводите команды через " ; ". Пример: /login \* ; /logchat

			Чтобы повторить введение последней запущенной команды просто введите !!. Это может помочь избежать повторного ввода длинных команд

			Некоторые команды станут доступны только после авторизации

			]]
		local unused = {} -- невызываемые команды (ни за какой группой не закреплены)

		local usergroup = c.Users[chat] and c.Users[chat].group or ""
		local groupcmds = TLG.Groups[ usergroup ]
		for cmd,tab in pairs(TLG.CMDS) do

			-- Если имеет право на выполнение команды или команда не требует авторизации
			if TLG.CMDS[cmd].nologin or (groupcmds and groupcmds[cmd]) then
				inf = inf ..
				"``` /" .. cmd .. " - " .. tab.desc .. "```\n\n"
			end

			-- Если команда требует авторизации и ее нету в списке используемых команд
			if !TLG.Permissions[cmd] and !TLG.CMDS[cmd].nologin then
				unused[cmd] = tab
			end

		end

		if table.Count(unused) > 0 then
			inf = inf ..
			[[

			Странные команды, которые не может никто выполнять:
			]]
			for cmd,tab in pairs(unused) do

				inf = inf ..
				"``` /" .. cmd .. " - " .. tab.desc .. "```\n\n"

			end

		end

		inf = inf ..
		[[
		После авторизации также добавится возможность написать любое сообщение от имени админа в чат.
		Для этого просто введи ваше сообщение без слэша. оно отправится красным текстом с префиксом [@<yourlogin>]
		Внимание. Кириллические сообщения после 60 символов ОБРЕЗАЮТСЯ. С латинницей все нормально.
		Возможность добавлена 14.02.16

		Чтобы в любой момент получить короткую справку о нужной команде, введите ее с аргументов -help.
		Пример: /login -help
		]]

		TG.SendMessage(chat, inf, "Markdown")
	end,
	"Получение помощи по доступным коммандам",
	true,
	function(chat,nick,msgtbl)
		if !c.isMasterServer then
			return false
		end

		return true
	end
)

------------------------------------------------------------------

TLG.addCommand(
	"info",
	function(chat)
		local plys = player.GetAll()
		local plys_props = {}
		local props = 0 -- counter

		for k,v in pairs(ents.GetAll()) do
				if !IsValid(v) or v:GetPersistent() then continue end

				if v.FPPOwnerID then

					plys_props[v.FPPOwnerID] = plys_props[v.FPPOwnerID] or {}
					plys_props[v.FPPOwnerID][#plys_props[v.FPPOwnerID] + 1] = v

				end
		end

		for stid,t in pairs(plys_props) do
			props = props + #t
		end

		local plysinf =
			"👥 Онлайн: " .. #plys .. "/" .. game.MaxPlayers() .. "\n" ..
			"🕗 Аптайм сервера: " .. string.NiceTime(CurTime()) .. "\n" ..
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

		TG.SendMessage(chat, plysinf)
	end,
	"Выводит информацию о текущем сервере (Онлайн, аптайм, убийства и смерти онлайн игроков, а также их ник и стимайди). Возможность сделана **.01.16"
)



TLG.addCommand(
	"logchat",
	function(chat,msgtbl,nick)

		TLG.TMP["interceptors"] = TLG.TMP["interceptors"] or c.Interceptors or {}

		if TLG.TMP["interceptors"][chat] then
			TLG.TMP["interceptors"][chat] = nil
		else
			TLG.TMP["interceptors"][chat] = {}
		end

		if TLG.TMP["interceptors"][chat] then
			hook.Add("PlayerSay","TG.ChatIntercept",function(ply,txt,tm)

				local parts = string.Split(txt," ")

				for chatid,data in pairs(TLG.TMP["interceptors"]) do
					if !data or !data.modes then continue end

					for mode in pairs(data.modes) do
						local complies,custommsg = c.InterModes[mode](parts,txt,ply,tm)
						if complies then
							TG.SendMessage(chatid, custommsg or ("(" ..  ply:Nick() .. "): " .. txt))
							break -- чтобы не обрабатывать фразу несколькими фильтрами, если она даже подходит под них
						end
					end
				end

			end)


			hook.Add("onNewGluegramMessage","TG.ChatInterceptSettings",function(message)

				if string.sub(message["message"]["text"],1,1) == "/" then return end
				if message["message"]["from"]["username"] ~= nick then return end -- если пишет в чат не активатор команды

				local mode = string.Split(message["message"]["text"]," ")[1]

				if c.InterModes[mode] then

					local self_inter = isbool(TLG.TMP["interceptors"][chat]) and {} or TLG.TMP["interceptors"][chat]
					self_inter.modes = self_inter.modes or {}

					if self_inter.modes[mode] then
						self_inter.modes[mode] = nil
						TG.SendMessage(chat, "Режим перехвата отключен")
					else
						self_inter.modes[mode] = true
						TG.SendMessage(chat, "Режим перехвата подключен")
					end

					return false -- вырубаем дальнейшую обработку данного сообщения
				end

			end)

			local kb = {} -- keyboard
			for mode in pairs(c.InterModes) do

				-- Если кнопок в ряду нет или их 3 (Можно сделать и больше, так то)
				if #kb == 0 or #kb[#kb] == 3 then
					kb[#kb + 1] = kb[#kb + 1] or {}
				end

				-- Добавляем кнопку в ряд
				--table.insert(kb[#kb],mode)
				kb[#kb][ #kb[#kb] + 1 ] = mode

			end

			local key_markup = {
				["keyboard"]          = kb,
				["resize_keyboard"]   = true,
				["one_time_keyboard"] = true,
				--["selective"]         = true
			}

			TG.SendMessage(
				chat,
				"Перехват чатов ВКЛючен. Выберите желаемые режимы для перехвата или введите команду еще раз для отключения. Подробнее о режимах можно прочитать в /logchat -help",
				nil, nil, nil,
				util.TableToJSON(key_markup)
			)

		else
			hook.Remove("PlayerSay","TG.ChatIntercept")
			hook.Remove("onNewGluegramMessage","TG.ChatInterceptSettings")

			TG.SendMessage(chat, "Перехват чатов ВЫКЛючен")
			TLG.TMP["interceptors"][chat] = nil
		end

	end,
	"Включение или отключение перехвата глобальных и личных сообщений из чата. После деавторизации сообщения продолжат перехватываться, если не выключить вручную. Возможность сделана 15.02.16"
)

TLG.addCommand(
	"exit",
	function(chat, msgtbl)
		if msgtbl[2] and string.lower(msgtbl[2]) == c.SVName then TLG.disconnect(chat, true)
		elseif !msgtbl[2] then TLG.disconnect(chat, true) end
		-- else может быть в случае, если указан второй параметр и он не соответствует текущему названию сервера
	end,
	"Ручная деавторизация на выбранном сервере или на всех активных серверах, если не указан аргумент. После деавторизации все команды перестанут вводиться до следующей авторизации (полезно при работе с несколькими серверами). Возможность сделана 14.02.16"
)


--------------------------------------------------------------------------
local rectxt = ""
TLG.addCommand(
	"cmd",
	function(chat,msgtbl)
		local args = {}
		for i = 3, #msgtbl do
			args[#args + 1] = msgtbl[i]
		end

		if !msgtbl[2] then TG.SendMessage(chat, "Нужно также ввести саму команду. Пример: /cmd ulx maprestart") return end

		-- Если enginespew нет, то сообщение с ответом будет пустым
		hook.Add("EngineSpew","TLG.TopKostil",function(_,msg)
			rectxt = rectxt .. "💩 " .. msg
		end)

		RunConsoleCommand(msgtbl[2], unpack(args)) -- не катит для надписей в ТАБе
		--ConCommand(string.Implode(" ",args))

		timer.Simple(.4,function()
			hook.Remove("EngineSpew","TLG.TopKostil")
			TG.SendMessage( chat, string.format("Выполнение команды %s с аргументами [%s]:\n%s", msgtbl[2],string.Implode(" ",args),rectxt) )
			rectxt = ""
		end)

	end,
	"Выполнение консольной команды от сервера. Есть возможность ввода аргументов. Без аргументов выведет подсказку. Возможность добавлена 14.02.16"
)
--------------------------------------------------------------------------

TLG.addCommand(
	"say",
	function(chat,msgtbl,nick)
		TLG.TMP["conv"] = TLG.TMP["conv"] or {}
		TLG.TMP["conv"][nick] = !TLG.TMP["conv"][nick] -- TLG.TMP -- variable for store any data

		if TLG.TMP["conv"][nick] then
			hook.Add("onNewGluegramMessage","TLG.SayCmdHook",function(message)

				if string.sub(message["message"]["text"],1,1) == "/" then return end
				if message["message"]["from"]["username"] ~= nick then return end -- если пишет в чат не активатор команды

				ULib.tsayColor( nil, false, Color( 255, 50, 50 ), "[@" .. nick .. "] " .. message["message"]["text"] )
				print("[@" .. nick .. "] " .. message["message"]["text"])
				TG.SendMessage(chat, l.received_by_server)

			end)
			TG.SendMessage(chat, "Режим переписки ВКЛючен")

		else
			hook.Remove("onNewGluegramMessage","TLG.SayCmdHook")
			TG.SendMessage(chat, "Режим переписки ВЫКЛючен")

		end

	end,
	"Включение функции общения через чат. Все ваши сообщения после включения данной функции будут отправлены в чат. Для отключение нужно будет еще раз ввести эту команду. Запилено 01.03.16"
)

-- TLG.addCommand(
-- 	"action",
-- 	function(chat, msgtbl)
-- 		TG.sendChatAction(chat, msgtbl[2] or 1)
-- 	end,
-- 	"Проверка работоспособности функции отправки статуса выполнения действия (Пареметры: http://i.imgur.com/F7zVkOC.png). Пример использования: /action 3 (Покажет сообщение о записи видео)"
-- )

TLG.addCommand(
	"selfmsg",
	function(chat, msgtbl)
		TG.SendMessage(chat, string.Implode(" ",msgtbl))
	end,
	"Функция для отладки. Отправляет сообщение вам же. Пример: /selfmsg :like:. Запилено 17.02.16"
)

TLG.addCommand(
	"getme",
	function(chat, msgtbl)
		TG.SendMessage(chat, "🔻 *Ид чата с вами*: " .. chat .. "\nОн может пригодиться для вставки в различные конфиги для репортов в ваш телеграм", "Markdown")
	end,
	"Функция для получения ИД своего чата с ботом. Запилено 30.03.16",
	true
)