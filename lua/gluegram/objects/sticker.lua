-- https://core.telegram.org/bots/api#sticker
local MT = TLG.NewObjectBase("Sticker")

-- !!
function MT:ID()
	return self.file_id
end

-- !!
function MT:Size()
	return self.width, self.height
end

function MT:Thumb()
	return TLG.SetMeta(self.thumb, "PhotoSize")
end

function MT:NameOfSet()
	return self.set_name
end

-- emoji mask_position file_size
