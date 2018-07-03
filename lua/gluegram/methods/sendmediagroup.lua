local BOT_MT = TLG.GetObject("BOT")
local METHOD = TLG.NewMethod("sendMediaGroup")

-- disable_notification
-- reply_to_message_id

function BOT_MT:MediaGroup(chat_id, tMedia) -- 2-10 items
	return self:Request(METHOD)
		:SetParam("chat_id", chat_id)
		:SetParam("media", util.TableToJSON(tMedia))
end



-- local ALBUM = TLG.InputMedia()

-- ALBUM:AddPhoto("https://i.imgur.com/HI2uWrQ.jpg", "Малая. [Ссылка](imgur.com/HI2uWrQ)", "markdown")
-- ALBUM:AddPhoto("https://i.imgur.com/ZNLMkNw.png", "Dogs")
-- -- ALBUM:AddPhoto("https://i.imgur.com/UZetyzV.png", "Twitter")

-- TLG_CORE_BOT:MediaGroup(TLG_AMD, ALBUM):Send()
