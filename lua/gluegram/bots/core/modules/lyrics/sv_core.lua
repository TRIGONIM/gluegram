LYR = LYR or {}

LYR.APIHOST = "http://api.musixmatch.com/ws/1.1/"
LYR.APIKEY  = "50fdfd15bb09729321cbf47a50aa7f3d"


-- Скопировано в yandex_pdd
function LYR.processAPI(method,keyvalues,callback)
	for k,v in pairs(keyvalues) do
		keyvalues[k] = tostring(v)
	end

	HTTP({
		url     = LYR.APIHOST .. method .. "?apikey=" .. LYR.APIKEY,
		method  = "get",
		parameters = keyvalues,
		success = function(_,json)
			callback(util.JSONToTable(json))
		end
	})
end

function LYR.searchSong(artist,track,callback)
	LYR.processAPI("track.search",{
		q_track      = track,
		q_artist     = artist,
		f_has_lyrics = 1
	},function(tab)
		local tracks = tab.message.body["track_list"]
		callback(#tracks > 0 and tracks)
	end)
end

function LYR.getLyrics(callback,id)
	LYR.processAPI("track.lyrics.get",{
		track_id = id,
	},function(tab)
		callback(tab.message.body["lyrics"])
	end)
end