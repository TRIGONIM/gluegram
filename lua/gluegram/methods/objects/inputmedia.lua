-- https://core.telegram.org/bots/api#inputmedia
-- Пример в sendmediagroup.lua

local MEDIA_MT = {}
MEDIA_MT.__index = MEDIA_MT

function MEDIA_MT:AddPhoto(photo, caption, parse_mode)
	if caption then
		caption = (string.utf8sub or string.sub)(caption, 1,200)
	end

	table.insert(self,{
		type = "photo",
		media = photo, -- url or tlg id
		caption = caption,
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
