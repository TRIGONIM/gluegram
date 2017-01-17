local PS = TLG.NewObjectBase("PhotoSize")

-- !! String
function PS:ID()
	return self.file_id
end

-- !! int
function PS:Width()
	return self.width
end

-- !! int
function PS:Height()
	return self.height
end

-- int
function PS:Size()
	return self.file_size
end