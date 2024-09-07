local cachedErrors = {}
local playerErrors = {}
function ai_errors.reportError(error, realm, stack, _, _, ply)
	-- Check if the error has already been reported
	if cachedErrors[error] then return end
	cachedErrors[error] = true
	-- Rudimentary check for if this player has been spamming errors
	if ply then
		local steamid = ply:SteamID()
		playerErrors[steamid] = playerErrors[steamid] or 0
		playerErrors[steamid] = playerErrors[steamid] + 1
		if playerErrors[steamid] > 5 then return end
	end

	ai_errors.Msg(string.format("Error in realm '%s': %s", realm, error))
	local data = {}
	local messages = {
		{
			role = "assistant",
			content = "You are a helpful assistant specialized in diagnosing and fixing code errors, you are short and succint and easy to understand for the technologically less-qualified."
		},
		{
			role = "user",
			content = string.format("There was an error in the realm '%s'. Could you help diagnose and fix it? Here's the error:\n%s", realm, error)
		}
	}

	data.model = "gpt-4o-mini"
	data.messages = messages
	if ply then
		local playerInfo = string.format("The error occurred for the player: %s (ID: %s)", ply:Nick(), ply:SteamID())
		messages[2].content = messages[2].content .. "\n\n" .. playerInfo
	end

	-- Get the lines where the error occurred
	-- if ran from lua_run, dont even report the error
	if stack then
		local errorLines = {}
		for stacknum, line in ipairs(stack) do
			local filePath, lineNumber = line.File, line.Line
			if filePath and lineNumber then
				if filePath:find("lua_run") then
					ai_errors.Msg("Error occurred in lua_run, not reporting to AI.")
					return
				end

				ai_errors.ReadFile(filePath, function(fileContent)
					if fileContent then
						local lines = string.Explode("\n", fileContent)
						local lineNum = tonumber(lineNumber)
						local start = math.max(1, lineNum - 2)
						local finish = math.min(#lines, lineNum + 2)
						for i = start, finish do
							table.insert(errorLines, string.format("%d: %s", i, lines[i]))
						end
					end

					--pyramids of gaza
					if #stack == stacknum then
						messages[2].content = messages[2].content .. "\n\nHere are the relevant code lines around the error:\n" .. table.concat(errorLines, "\n")
						ai_errors.SendMessage(data, function(response)
							local responseTable = util.JSONToTable(response)
							if responseTable and responseTable.choices then
								local choice = responseTable.choices[1]
								if choice then
									local assistantMessage = choice.message
									if assistantMessage then
										if ai_errors.HTTP == HTTP then
											ai_errors.Msg("AI Response: " .. assistantMessage)
										else
											ai_errors.SendToDiscord(assistantMessage)
										end
									end
								end
							end
						end)
					end
				end)
			end
		end
	end
end

function ai_errors.SendToDiscord(response)
	local webhook = ai_errors.webhook
	if not webhook then return end
	local data = {
		username = ai_errors.webhookName,
		avatar_url = ai_errors.webhookAvatar,
		embeds = {
			{
				title = ai_errors.embedTitle,
				description = response.content,
				color = ai_errors.embedColor,
				footer = {
					text = ai_errors.embedFooterText,
					icon_url = ai_errors.embedFooterAvatar
				},
				timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
			}
		}
	}

	ai_errors.HTTP({
		method = "POST",
		url = webhook,
		timeout = 30,
		body = util.TableToJSON(data),
		type = "application/json",
		headers = {
			["User-Agent"] = "AI Errors Reporter"
		},
		success = function(status, body, headers) end,
		failed = function(err, errExt) ai_errors.Msg("Failed to send Discord webhook:", err) end
	})
end

hook.Add("OnLuaError", "ai_errors", ai_errors.reportError)