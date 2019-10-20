local BOT_MT = TLG.GetBot("base")
local METHOD = TLG.NewMethod("sendMediaGroup")

-- reply_to_message_id

function METHOD:Mute(bMute)
	return self:SetParam("disable_notification", bMute ~= false)
end

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
