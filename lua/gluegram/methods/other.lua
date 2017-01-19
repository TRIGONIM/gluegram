
TLG_ACT_TYPING   = 1
TLG_ACT_PHOTO    = 2
TLG_ACT_VIDEO    = 3
TLG_ACT_AUDIO    = 4
TLG_ACT_DOCUMENT = 5
TLG_ACT_LOCATION = 6

local acts = {}
acts[TLG_ACT_TYPING  ] = "typing"
acts[TLG_ACT_PHOTO   ] = "upload_photo"
acts[TLG_ACT_VIDEO   ] = "record_video"
acts[TLG_ACT_AUDIO   ] = "record_audio"
acts[TLG_ACT_DOCUMENT] = "upload_document"
acts[TLG_ACT_LOCATION] = "find_location"

TLG.RegisterMethod("sendChatAction",{})
	:AddParam("chat_id", tostring )
	:AddParam("action", function(id)
		return acts[id] or id
	end)