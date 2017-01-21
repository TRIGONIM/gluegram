--[[-------------------------------------------------------------------------
Этот слушатель работает в комбинации с веб частью (прокси).
Представляет собой открывашку сокета, на который прокси-скрипт
будет ретранслировать входящие от серверов телеграмма сообщения

Прокси (веб часть) нужна из-за того, что телеграмм может работать с веб хуками
только по https://, а сделать веб сервер с поддержкой SSL на сокетах я не умею
Кроме того прокси ретранслирует один входящий запрос на все адреса,
которые указаны в базе данных, что позволяет работать одному боту сразу на нескольких адресах
---------------------------------------------------------------------------]]


local whitelist = {
	["localhost"]       = true,
	["127.0.0.1"]       = true,
	["89.108.104.58"]   = true, -- renter dedic
	["193.124.185.164"] = true, -- ihor dedic
	["194.67.215.50"]   = true, -- ihor vds
}

TLG.AddListener("socket",function(self)
	local port = 29000 + ServerID()

	TLG.SOCKETS = TLG.SOCKETS or {}
	TLG.SOCKETS[port] = TLG.SOCKETS[port] or BromSock(BROMSOCK_TCP)

	local sock = TLG.SOCKETS[port]

	if !sock:Listen(port) then
		MsgC(Color(200,50,50),"TLG Socket not opened\n")

		local msg = "Сокет телеграмма не открылся и не готов принимать сообщения.\nПроверьте не занят ли " .. port .. " порт"

		TLG.notifyGroup("root",msg)
		TLG.LogError(msg)

	else
		MsgC(Color(50,200,50),"TLG Socket successfuly set\n")

		sock:SetCallbackAccept(function(l_ssock, l_csock)
			if whitelist[l_csock:GetIP()] then
				l_csock:SetCallbackReceive(function(_, packet)

					local tbl = util.JSONToTable( packet:ReadStringAll() )
					if !tbl then return end -- не мусор пришел

					self:Callback( TLG.SetMeta(tbl,"Update") )
				end)
			else
				TLG.LogError("Этот хер пытался обратиться к сокету обновлений TLG с запрещенного ИП: " .. l_csock:GetIP())
			end

			l_csock:SetTimeout(1000)
			l_csock:ReceiveUntil("\r\n\r")
			l_ssock:Accept()
		end)
		sock:Accept()
	end
end)
