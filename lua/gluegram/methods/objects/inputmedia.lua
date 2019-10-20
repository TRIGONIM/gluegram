-- https://core.telegram.org/bots/api#inputmedia
-- Пример в sendmediagroup.lua

local MEDIA_MT = {}
MEDIA_MT.__index = MEDIA_MT

function MEDIA_MT:AddPhoto(photo, caption, parse_mode)
	table.insert(self,{
		type = "photo",
		media = photo, -- url or tlg id
		caption = caption, -- 1024 chars. Был utf8sub, но с ним чет телега ругалась на битое сообщение
		parse_mode = parse_mode, -- html, markdown
	})
end

function MEDIA_MT:AddVideo(photo, caption, parse_mode)
	table.insert(self,{
		type = "video",
		media = photo,
		caption = caption,
		parse_mode = parse_mode,

		-- width,height,duration,supports_streaming
	})
end




function TLG.InputMedia() -- 2-10 items
	return setmetatable({},MEDIA_MT)
end
