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
	["193.124.185.164"] = true, -- ihor dedic
	["194.67.215.50"]   = true, -- ihor vds
}


-- Сокеты - это такая ебучая хуйня, которую лишний раз трогать страшно
-- Лучше обновить функцию каллбэка при рефреше скрипта, чем закрывать сокет и оверрайдить его каллбэк с переоткрытием
-- просто оверрайднуть каллбэк нельзя. Надо извращаться вот так вот

-- UPD чет он так нихуя не обновляется
-- Наверное, нужно какую-то глобальную блять функцию ему ебнуть
-- Типа SetCallback и GetCallback, а то тут присосалось и все
TLG.AddListener("socket",function(callback,port)
	TLG.SOCKETS = TLG.SOCKETS or {}

	if TLG.SOCKETS[port] then
		return
	end

	require("bromsock")

	TLG.SOCKETS[port] = BromSock(BROMSOCK_TCP)

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

					callback( TLG.SetMeta(tbl,"Update") )
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


-- При ресете глуграмма закрываем сокеты, а то не откроются опять
-- hook.Add("onGluegramLoaded","CloseSockets",function()
-- 	for port,sock in pairs(TLG.SOCKETS or {}) do
-- 		MsgC(Color(50,250,50),"TLG Socket on port " .. port .. " has been closed")
-- 		sock:Close()
-- 	end
-- end)