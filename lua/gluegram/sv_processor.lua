TLG.CMDS = TLG.CMDS or {}
TLG.TMP  = {}

local c = TLG.Cfg
local l = TLG.Language


-- ccheck и func -- это функции.
-- ccheck должен возвращать разрешение и сообщение об ошибке.
-- Например: false, "Команду можно выполнять только ночью"
function TLG.addCommand(cmd, func, desc, nolog, ccheck)
	cmd = cmd:lower()

	TLG.CMDS[cmd] = TLG.CMDS[cmd] or {}
	TLG.CMDS[cmd].func    = func
	TLG.CMDS[cmd].desc    = desc
	TLG.CMDS[cmd].check   = ccheck
	TLG.CMDS[cmd].nologin = nolog
end

local cusrs = {} -- connected users chat ids
function TLG.connect(chid)
	if !cusrs[chid] then
		cusrs[chid] = true
		TG.SendMessage(chid, string.format(l.on_connect,c.SVName,c.MOTD))
	else
		TG.SendMessage(chid, string.format(l.on_connect_err,c.SVName))
	end
end
function TLG.disconnect(chid, manually)
	if cusrs[chid] then
		cusrs[chid] = nil

		if manually or (!manually and !c.noEchoOnDisconnect) then
			TG.SendMessage(chid, string.format(l.on_disconnect,c.SVName))
		end

	else -- вы не авторизированы
		if c.totalServers > 1 then
			TG.SendMessage(chid, string.format(l.on_disconnect_err,c.SVName))
		end
	end
end

local last_msgs = {}
function TLG.processTXT(uid, chid, nick, txt)
	local mtbl = string.Explode(" ",txt)
	local cmd = string.sub(mtbl[1],2,#mtbl[1])

	local allow_access = TLG.Groups[ c.Users[uid] and c.Users[uid].group or "" ] or {}

	if string.sub(mtbl[1],1,1) == "/" then

		if TLG.CMDS[cmd] then -- если команда существует

			if TLG.CMDS[cmd].func then

				local function doFunc()
					-- Если команда требует авторизацию, но у нас нет права
					if !TLG.CMDS[cmd].nologin and !allow_access[cmd] then
						TG.SendMessage(chid, string.format(l.not_allowed,string.upper(c.SVName)))
					else
						TLG.CMDS[cmd].func(chid, mtbl, nick)
					end
				end

				-- Если нужна авторизация, а мы не авторизированы
				if !TLG.CMDS[cmd].nologin and !cusrs[chid] then
					if c.totalServers < 2 then
						TG.SendMessage(chid, l.not_logged)
					end

				elseif mtbl[2] == "-help" then
					if !c.isMasterServer then return end
					TG.SendMessage(chid, TLG.CMDS[cmd].desc or l.no_desc)

				elseif !TLG.CMDS[cmd].check then
					doFunc()

				else
					-- Все, что ниже выполняется только, если есть кастомная проверка
					-- ... и мы авторизированы или команда не требует авторизации
					local allow, msg = TLG.CMDS[cmd].check(chid, nick, mtbl)
					if allow then
						doFunc()
					elseif msg then
						TG.SendMessage(chid, string.format(l.forb_execution,msg))
					end

				end

			else
				TG.SendMessage(chid, l.not_func)
			end

		else
			if c.isMasterServer then
				TG.SendMessage(chid, string.format(l.cmd_not_exists,cmd))

				local cmds = ""
				for command,t in pairs(TLG.CMDS) do
					local groupcmds = TLG.Groups[c.Users[uid] and c.Users[uid].group or ""]

					-- Если в группе прав чела не прописана команда и она требует авторизации
					if !groupcmds[command] and !TLG.CMDS[command].nologin then continue end
					if !string.find(command,cmd) then continue end
					cmds = cmds .. command .. ", "
				end

				-- Если найдены похожие команды
				if cmds ~= "" then
					cmds = string.sub(cmds,1,#cmds - 2) -- удаление ", " на конце
					TG.SendMessage(chid, string.format("Возможно, вы имели в виду: " .. cmds) )
				end
			end
		end

	elseif mtbl[1] == "!!" then

		if last_msgs[uid] then
			if last_msgs[uid][1] ~= "!!" then
				TLG.processTXT(uid, chid, nick, string.Implode(" ",last_msgs[uid]))
			end
		else
			TG.SendMessage(chid, l.missing_old_message)
		end

		-- Чтобы команда не записывалась в историю
		-- Предотвращение входа в цикл
		return
	end

	last_msgs[uid] = mtbl

	-- Сбрасываем таймер автоотключения
	timer.Create("TLG.AutoDisconnect" .. chid,c.DiscTime,1,function()
		if table.Count(cusrs) == 0 then return end
		TLG.disconnect(chid)
	end)
end



local last_message_id -- чтобы не отправлять инфу до бесконечности

local function processUpdate(json)
	local tbl = util.JSONToTable(json)
	if tbl then
		local UPD = TLG.SetMeta(tbl,"Update")
		hook.Run("TLG.OnUpdate",UPD)

		if UPD["callback_query"] then
			hook.Run("TLG.OnCallbackQuery",UPD:CallbackQuery())
		end
	end











	local tab,err = TLG.getDataFrom.Update(json)
	if err then
		TLG.notifyGroup({TLG_AMD},"ОШИБКА В TLG.getDataFrom.Update(json): " .. err .. "\n\n" .. json)
		return
	end

	local txt = tab["message"] and tab["message"]["text"]
	if !txt then return end -- если еще не было сообщений

	local from_id   = tab["message"]["from"]["id"]
	local from_nick = tab["message"]["from"]["username"]

	local lstmsgid = tab["update_id"]

	if lstmsgid == last_message_id then return end
	last_message_id = lstmsgid

	local canprocess = hook.Run("onNewGluegramMessage",tab)
	if canprocess == false then return end

	if !from_nick then
	TG.SendMessage(from_id, l.no_nickname_auth) return end


	-- if !c.Users[from_id] then
	-- TG.SendMessage(from_id, string.format(l.not_permitted,from_nick)) return end

	local parts = string.Explode(";",txt)
	local maxcmds = c.Users[from_id] and (c.Users[from_id].maxcmds or 0) or 1
	if maxcmds >= 1 and #parts > maxcmds then
		TG.SendMessage(from_id, l.too_many_commands)
		return
	end

	for i = 1, #parts do
		local msg = parts[i]
		-- /login ;  ; /login
		msg = string.Trim(msg)
		if msg == ("" or " ") then continue end

		--print("|" .. msg .. "|")
		--print("|",from_id,from_nick,msg,"|")
		TLG.processTXT(from_id, tab["message"]["chat"]["id"], from_nick, msg)
	end
end



require("bromsock")

local function SetReceiver()
	ssock = BromSock(BROMSOCK_TCP)

	if !ssock:Listen(c.SocksListenPort) then
		MsgC(Color(200,50,50),"TLG Socket not opened\n")
		TLG.notifyGroup("root","Сокет для телеграмма не открылся и не готов принимать сообщения")
	else
		MsgC(Color(50,200,50),"TLG Socket successfuly set\n")
		ssock:SetCallbackAccept(function(l_ssock, l_csock)
			--print("Sock IP: ",l_csock:GetIP())
			if c.SocksIPWhitelist[l_csock:GetIP()] then
				l_csock:SetCallbackReceive(function(sock, packet)

					local packet_str = packet:ReadStringAll()
					--print(packet_str)
					processUpdate(packet_str) --(packet:ReadStringAll())
					--TLG.notifyGroup({TLG_AMD},packet_str)
				end)
			else
				TLG.LogError("Этот хер пытался обратиться к сокету обновлений TLG с запрещенного ИП: " .. l_csock:GetIP())
			end

			l_csock:SetTimeout(1000)
			l_csock:ReceiveUntil("\r\n\r")
			l_ssock:Accept()
		end)
		ssock:Accept()
	end
end

-- Этот говнокод сделан для предотвращения ошибки открытия сокета
-- Бывало так, что если после закрытия сокета сразу же пытаться его открыть, то он не открывался
-- Спустя некоторое время я заметил, что ему просто нужно время
-- Эта хуйня ниже выполняет подряд 2 задачи при каждом рефреше файла
-- Если сокет существует, то оно его закрывает и через 2 сек открывает опять
-- Если не существует, то открывает сразу
local funcs = {
	function()
		-- Избежание конфликта двойного открытия на 1 порту
		if ssock then
			ssock:Close()
		end
	end,
	SetReceiver
}
tasks:Start(funcs,ssock and 2 or 0)




hook("Initialize","TLG.ServerRestarted",function()
	TLG.notifyGroup({TLG_AMD},"Сервер перезапустился")
end)