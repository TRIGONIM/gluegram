local UPD = TLG.NewObjectBase("Update")

-- int
function UPD:UpdateID()
	return self.update_id
end

function UPD:Message()
	return TLG.SetMeta(self.message,"Message")
end

function UPD:CallbackQuery()
	return self.callback_query and TLG.SetMeta(self.callback_query,"CallbackQuery") or nil
end
