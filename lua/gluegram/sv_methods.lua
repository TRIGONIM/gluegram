module("TG",package.seeall)

local token = TLG.Cfg.Token



function getUpdates(cb, offset, limit, tout)
	offset = offset or ""
	limit = limit or ""
	tout = tout or ""

	--print("https://api.telegram.org/bot" .. token .. "/getUpdates?offset=" .. offset .. "&limit=" .. limit .. "&timeout=" .. tout)

	http.Fetch("https://api.telegram.org/bot" .. token .. "/getUpdates?offset=" .. offset .. "&limit=" .. limit .. "&timeout=" .. tout,
		cb,cb
	)
end



function getMe(cb)
	http.Fetch("https://api.telegram.org/bot" .. token .. "/getMe",
		cb,cb
	)
end



function SendMessage(chatid, text, parse_mode, disable_web_page_preview, reply_to_message_id, reply_markup, cb)
	print("Sending some message to telegram servers")

	http.Post("https://api.telegram.org/bot" .. token .. "/sendMessage",
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


local acts = {}
acts[1] = "typing"
acts[2] = "upload_photo"
acts[3] = "record_video"
acts[4] = "record_audio"
acts[5] = "upload_document"
acts[6] = "find_location"

function sendChatAction(chat, action, cb)
	if tonumber(action) then
		action = math.abs(action)
		action = action > #acts and 1 or action

		action = acts[action]
	end

	http.Fetch(
		"https://api.telegram.org/bot" .. token .. "/sendChatAction?chat_id=" .. chat .. "&action=" .. action,
		cb,cb
	)
end