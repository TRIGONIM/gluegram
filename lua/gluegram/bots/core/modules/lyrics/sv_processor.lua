
local BOT = TLG_CORE_BOT


BOT:AddCommand("lyrics",function(MSG,args)
	if !BOT:IsMaster() then return end

	if !args[1] then
		return "Нужно ввести аргументы. */lyrics -help* для большей инфы", "Markdown"
	end

	-- Сначала склеиваем все аргументы, которых может быть 10 шт, а потом разделяем на исполнителя и трек
	-- Это можно сделать через string.match, но я не умею.
	-- Черт руку дернул попытаться. Пока подобрал регулярку, еще сильнее возненавидел их
	local query = string.Implode(" ",args)
	local artist,song = string.match(query,"([%w]+)%s*%-%s*([%w]+)")

	-- Регулярка не сработала, значит чел указал запрос без дефиса и ищет только песню
	if !artist then
		song = query
	end

	local IKB = TLG.InlineKeyboard()

	-- выполнение всего внутри каллбэка - гарант того, что функция поиска сработала без ошибок
	-- хорошо тем, что функция не врубит ожидание ид лирикса, если не отправит юзеру список песен
	LYR.searchSong(artist,song,function(tracks)
		if !tracks then
			BOT:Message(MSG:Chat(), "Ничего не найдено. Повторите запрос"):Send()
			return
		end

		for id,track in pairs(tracks) do
			local tr = track.track

			local author  = tr.artist_name
			local name    = tr.track_name
			local trackid = tr.track_id

			IKB:Line(IKB:Button(("%s - %s"):format(author,name)):SetCallBackData({
				track_id = trackid
			}))
		end

		local msg = BOT:Message(MSG:Chat(), "Вот такая дичь короче тут:"):SetReplyMarkup(IKB)

		TLG.SendAndHandleCBQ(BOT,msg,function(CBQ)
			LYR.getLyrics(function(lyrics)
				local lyrtext = lyrics and lyrics["lyrics_body"] ~= "" and lyrics["lyrics_body"]

				if !lyrtext then
					BOT:Message(CBQ["message"]["chat"],"Увы, нет текста к этой песенке. Попробуйте другой код"):Send()
					return
				end

				BOT:Message(CBQ["message"]["chat"],lyrtext):Send()
			end, CBQ:Data().track_id)
		end)
	end) -- конец поиска песен


	return "Ищем песенку"
end)
	:SetPublic(true)
	:AddAlias("song")
	:SetHelp("/lyrics muse - drones. Можно указывать исполнителя и название через дефис или только название")
	:SetDescription("Позволяет по фасту получить текст песни")



