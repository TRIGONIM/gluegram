-- TODO перенести в TADMIN, когда будет возможность создать
-- нормального отдельного модульного бота без зависимостей
function ta.TLGMSG(chat_id,msg)
	TLG_CORE_BOT:Message(chat_id,"*" .. TLG.SERV .. "*: " .. msg):SetParseMode("markdown"):Send()
end

-- function ta.PrepareTLGMSG(iToChatID,msg)
-- 	return TLG_CORE_BOT:Message(chat_id,"[" .. TLG.SERV .. "] " .. msg)
-- end

-- обратная совместимость
-- todo убрать
function TLG.notifyGroup(groupname_or_ids,message)
	message = message or debug.traceback()

	-- Если список айдишников в таблице
	if istable(groupname_or_ids) then
		for i = 1,#groupname_or_ids do
			ta.TLGMSG(groupname_or_ids[i],message)
		end

	-- Если строка-название группы
	else
		-- Там только root бывает
		ta.TLGMSG(TLG_CONF_REPORTS,message)
	end
end