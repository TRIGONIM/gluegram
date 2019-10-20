local PS = TLG.NewObjectBase("PhotoSize")

-- !! String
function PS:ID()
	return self.file_id
end

-- !! int
function PS:Size()
	return self.width, self.height
end

-- int
function PS:FileSize()
	return self.file_size
end
