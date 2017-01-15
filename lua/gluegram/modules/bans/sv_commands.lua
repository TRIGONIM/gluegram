
TLG.addCommand(
	"ban",
	function(chat,msgtbl,nick)

		local res
		if msgtbl[4] then
			res = ""
			for i = 4, #msgtbl do
				res = res .. msgtbl[i] .. " "
			end
		end

		local success,msg = TLG.BanUser(
			msgtbl[2],
			nick,
			msgtbl[3], -- if time = 0 then unban = nil
			res
		)

		if success then
			if msg then
				TG.SendMessage(chat, msg)
			end
		else
			if msg then
				TG.SendMessage(chat, "Ошибка: " .. msg)
			end
		end

	end,
	"Блокировка пользователя в БОТЕ. После бана все его сообщения перестанут обрабатываься, даже /help и /login. Пример использования: /ban some_nick 1440 Reason. Запилено 02.03.16"
)

TLG.addCommand(
	"unban",
	function(chat,msgtbl)
		local success,msg = TLG.UnBanUser(msgtbl[2])

		if success then
			TG.SendMessage(chat, msg)
		else
			TG.SendMessage(chat, "Ошибка: " .. msg)
		end

	end,
	"Разблокировка пользователя бота. Пример: /unban some_nick. Запилено 02.03.16"
)

TLG.addCommand(
	"banlist",
	function(chat)
		local success,msg = TLG.sendBanList()

		if success then
			TG.SendMessage(chat, msg)
		else
			TG.SendMessage(chat, "Ошибка: " .. msg)
		end

	end,
	"Выводит список забаненных пользователей. Запилено 02.03.16"
)