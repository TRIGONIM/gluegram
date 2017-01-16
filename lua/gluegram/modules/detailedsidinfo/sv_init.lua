TLG.TYPES = TLG.TYPES or {}

-- Довольно опасная функция. Получает информацию из заданной таблицы
-- В калбэке возвращает ячейку таблицы или ошибку в string
function TLG.getMySQLInfo(cb,dbtable,whereclmn,value)

	MySQLite.query(
		"SELECT * FROM " .. dbtable .. " WHERE " .. whereclmn .. " = " .. MySQLite.SQLStr(value) .. " LIMIT 1;",
		function(t) cb(t and t[1] or "Nonexistent account") end,
		function(err,msg) cb("Error: [" .. err .. "]") end
	)

end


function TLG.addPlyDataType(typ, func)

	TLG.TYPES[typ] = TLG.TYPES[typ] or {}
	TLG.TYPES[typ].func = func

end


-- Получает информацию об игроке по SteamID
-- Возвращает информацию после получения в CallBack функции.
-- callback через аргументы передает таблицу вида [тип: значение]
-- Значение - строчная переменная
function TLG.getPlyData(cb, typs, sid)
	local uid = util.CRC( "gm_" .. sid .. "_gm" )

	local plys = player.GetAll()
	local ply

	for i = 1, #plys do
		if plys[i]:SteamID() == sid then
			ply = plys[i]
			break
		end
	end

	local report = {}

	if type(typs) ~= "table" then typs = {tostring(typs)} end -- надо будет проверить сработает ли такая хня
	if #typs == 0 then -- получаем все данные
		local needresults = table.Count(TLG.TYPES)
		local currresults = 0

		for key,t in pairs(TLG.TYPES) do
			t.func(
				function(data)
					data = data or "Ошибка получения данных #1: " .. debug.traceback()

					currresults = currresults + 1
					report[key] = data

					if currresults == needresults then
						cb(report)
						return
					end

				end, sid, ply, uid
			)
		end

	else -- получаем конкретные данные по аргументам

		local curresults = 0
		for i,key in pairs(typs) do

			if TLG.TYPES[key] and TLG.TYPES[key].func then
				TLG.TYPES[key].func(
					function(data)
						data = data or "Ошибка получения данных #2: " .. debug.traceback()

						report[key] = data
						curresults = curresults + 1

						if #typs == curresults then
							cb(report)
						end
					end, sid, ply, uid
				)

			else -- некорректный аргумент

				report["error" .. i .. ""] = "Invalid argument entered: [" .. key .. "]"
				curresults = curresults + 1

				if #typs == curresults then
					cb(report)
				end

			end
		end

	end

end


TLG.addCommand(
	"sidinf",
	function(chat, msgtbl)
--		TG.sendChatAction(chat, "typing")

		local sid = msgtbl[2]

		if !sid then
			TG.SendMessage(chat, "Необходимо ввести steamid. Пример: /sidinf STEAM_0:1:55598730")
			return
		end

		if sid == "-args" then
			local txt = "*Доступные аргументы:* "
			for arg,func in pairs(TLG.TYPES) do
				txt = txt .. arg .. ", "
			end
			txt = string.sub(txt,1,#txt - 2)

			TG.SendMessage(chat, txt, "Markdown") --, nil, nil, util.TableToJSON(key_markup))
			return
		end

		if !sid:match( "^STEAM_%d:%d:%d+$" ) then
			TG.SendMessage(chat, "Не введен или введен некорректный SteamID. Пример: STEAM_0:1:55598730")
			return
		end

		local args = {}
		for i = 3, #msgtbl do
			args[#args + 1] = msgtbl[i]
		end

		-------------------------

		TLG.getPlyData(
			function(t)
				local reportstr = " "

				for tpe, value in pairs(t) do
					reportstr = reportstr .. "[" .. tpe .. "] " .. value .. "\n\n"
				end

				TG.SendMessage(chat, reportstr)
			end,
			args, sid
		)

	end,
	"Выводит полезную информацию о SteamID. Есть возможность указать конкретные данные через пробел. Если ввести steamid без доп. аргументов, то выведет всю информацию. Если команда не дала выхлоп, значит где-то какие-то данные не обработались. Посмотреть список доступных аргументов можно через /sidinf -args. Возможность запилена в ночь с 16.02 по 17.02"
)