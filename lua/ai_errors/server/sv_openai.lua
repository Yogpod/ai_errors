function ai_errors.SendMessage(data, cb)
	local apiKey = ai_errors.apiKey
	if not apiKey or apiKey == "" then
		ai_errors.Msg("No API key set, cannot send message")
		return
	end

	data.temperature = 0.7
	data = util.TableToJSON(data)

	ai_errors.HTTP({
		url = "https://api.openai.com/v1/chat/completions",
		method = "POST",
		parameters = data,
		headers = {
			["Content-Type"] = "application/json",
			["Authorization"] = "Bearer " .. apiKey
		},
		body = data,
		success = function(code, body, headers)
			if cb then
				cb(body)
			end
		end,
		failed = function(reason)
			ai_errors.Msg("Failed to send message: " .. reason)
		end
	})
end