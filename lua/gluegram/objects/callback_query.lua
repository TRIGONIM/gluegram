local CBQ = TLG.NewObjectBase("CallbackQuery")

-- !! string
function CBQ:ID()
	return self.id
end

-- !!
function CBQ:From()
	return TLG.SetMeta(self.from,"User")
end

function CBQ:Message()
	return TLG.SetMeta(self.message,"Message")
end

-- string
function CBQ:Data()
	return pon.decode(self.data)
end
