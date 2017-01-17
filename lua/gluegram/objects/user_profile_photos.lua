--[[-------------------------------------------------------------------------
{
    ['photos']      = {
        [1] = {
            [1] = {
                ['file_id']   = 'AgADAgADqqcxGyOJMwVezQOVQ0hDs5YbgyoABCv*****************',
                ['width']     = 160,
                ['file_size'] = 9504,
                ['height']    = 160,
            },
            [2] = {
                ['file_id']   = 'AgADAgADqqcxGyOJMwVezQOVQ0hDs5YbgyoABF6*****************',
                ['width']     = 320,
                ['file_size'] = 20568,
                ['height']    = 320,
            },
            [3] = {
                ['file_id']   = 'AgADAgADqqcxGyOJMwVezQOVQ0hDs5YbgyoABF1*****************',
                ['width']     = 640,
                ['file_size'] = 59005,
                ['height']    = 640,
            },
        },
    },
    ['total_count'] = 1,
}
---------------------------------------------------------------------------]]


local UPP = TLG.NewObjectBase("UserProfilePhotos")

-- int
function UPP:Total()
	return self.total_count
end

function UPP:Photos()
	for photo_id = 1,#self.photos do
		for size_id = 1,#self.photos[photo_id] do
			TLG.SetMeta(self.photos[photo_id][size_id],"PhotoSize")
		end
	end

	return self.photos
end