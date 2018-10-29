local BOT_MT = TLG.GetMeta("BOT")
local METHOD = TLG.NewMethod("sendChatAction")

function METHOD:SendTo(chat_id)
	return self:SetParam("chat_id", chat_id)
end

function METHOD:Set(action)
	return self:SetParam("action", action)
end




TLG.ACT_TYPING   = "typing"
TLG.ACT_PHOTO    = "upload_photo"
TLG.ACT_VIDEO    = "record_video"
TLG.ACT_AUDIO    = "record_audio"
TLG.ACT_DOCUMENT = "upload_document"
TLG.ACT_LOCATION = "find_location"

function BOT_MT:ChatAction(chat_id, action)
	return self:Request(METHOD):Set(action):SendTo(chat_id)
end

-- TLG_CORE_BOT:ChatAction(TLG_AMD, TLG.ACT_PHOTO):Send(prt)
