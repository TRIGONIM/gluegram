local function concatenateArgs(msgparts)
	local argss = ""
	for i = 2,#msgparts do
		argss = argss .. msgparts[i] .. " "
	end

	return argss ~= "" and argss -- вернет nil, усли аргументов нет
end


TLG.addCommand(
	"lyrics",
	function(chat,msgtbl,nick)
		if !TLG.Cfg.isMasterServer then return end

		local args = concatenateArgs(msgtbl)

		if !args then
			TG.SendMessage(chat,"Необходимо ввести аргументы. Пример в /help")
			return
		end

		local request_parts = string.Explode(" - ",args)
		local artist,song   = request_parts[1],request_parts[2]

		dprint(artist,song)

		if !song then -- если указан лишь первый "аргумент" без дефиса. Например /lyrics money for nothing
			song   = artist
			artist = nil
		end

		dprint(artist,song)

		-- выполнение всего внутри каллбэка - гарант того, что функция поиска сработала без ошибок
		-- хорошо тем, что функция не врубит ожидание ид лирикса, если не отправит юзеру список песен
		LYR.searchSong(artist,song,function(tracks)
			if !tracks then
				TG.SendMessage(chat,"Ничего не найдено. Повторите запрос")
				return
			end

			local txt = ""

			for id,track in pairs(tracks) do
				local tr = track.track

				local album   = tr.album_name
				local image   = tr.album_coverart_100x100
				local author  = tr.artist_name
				local name    = tr.track_name
				local link    = tr.track_share_url

				local trackid = tr.track_id
				local lyrics  = tr.lyrics_id

				txt = txt .. string.format(
					"[%s] %s\nAlbum: %s\nImage: %s\nLink: %s\n/%s\n\n",
					author,name,
					album,
					image,
					link,
					trackid
				)
			end

			TG.SendMessage(TLG_AMD,txt)




			TLG.TMP["holding_lyrics"]       = TLG.TMP["holding_lyrics"] or {}
			TLG.TMP["holding_lyrics"][nick] = true

			hook.Add("onNewGluegramMessage","TLG.LyricsHolding",function(message)
				local text        = message["message"]["text"]
				local sender_nick = message["message"]["from"]["username"]

				local cmd = string.sub(string.Explode(" ",text)[1],2) -- эксплодом вырываем первое слово, чтобы не впустили "cmd stats" например
				if TLG.CMDS[cmd] then return end -- мы ждем сообщение вида /12345678, поэтому не обрабатываем ввод обычных команд

				if sender_nick ~= nick then return end -- если пишет в чат не активатор команды

				LYR.getLyrics(function(lyrics)
					local lyrtext = lyrics and lyrics["lyrics_body"] ~= "" and lyrics["lyrics_body"]

					if !lyrtext then
						TG.SendMessage(chat,"Увы, нет текста к этой песенке. Попробуйте другой код")
						return
					end

					print(chat,lyrtext)

					TG.SendMessage(chat,lyrtext)
					hook.Remove("onNewGluegramMessage","TLG.LyricsHolding")
				end,string.sub(text,2)) -- срезаем слэш в начале
			end)
			TG.SendMessage(chat, "Вот все, что найдено. Для поиска текста песни введите через слэш ее идентификатор (Написан после каждой песни) или повторите ваш запрос той же коммандой, чтобы искать другой результат. Пример: /12345678")

		end) -- конец поиска песен

	end,
	"Позволяет по фасту получить текст песни. Использование: /lyrics taylor swift - blabla bla. Можно указывать исполнителя и название через дефис или только название. Начало разработки - утро 08.07.16, когда у меня отключили интернет ._.",
	true
)