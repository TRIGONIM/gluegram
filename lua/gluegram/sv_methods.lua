


module("TG",package.seeall)


function SendMessage(chatid, text, parse_mode, disable_web_page_preview, reply_to_message_id, reply_markup, cb)
	print("Sending some message to telegram servers")

	http.Post("https://api.telegram.org/bot" .. TLG.BOTS[TLG.SERV]:GetToken() .. "/sendMessage",
		{
			["chat_id"] = tostring(chatid),
			["text"] = text,
			["parse_mode"] = parse_mode,
			["disable_web_page_preview"] = disable_web_page_preview,
			["reply_to_message_id"] = reply_to_message_id,
			["reply_markup"] = reply_markup
		},
		cb,cb
	)
end

