local cachedErrors = {}
local playerErrors = {}
function ai_errors.SendMessage(data, cb)
	local apikey = ai_errors.apikey
	local useanthropic = ai_errors.useanthropic
	if not apikey or apikey == "" then
		ai_errors.Msg("No API key set, cannot send message")
		return
	end

	if useanthropic then
		ai_errors.SendMessageToAnthropic(data, cb)
	else
		ai_errors.SendMessageToOpenAI(data, cb)
	end
end

--TODO: Make this use the messages api instead of the chat api
function ai_errors.SendMessageToOpenAI(data, cb)
	data.temperature = 0.7
	data = util.TableToJSON(data)
	ai_errors.HTTP({
		url = "https://api.openai.com/v1/chat/completions",
		method = "POST",
		parameters = data,
		headers = {
			["Content-Type"] = "application/json",
			["Authorization"] = "Bearer " .. ai_errors.apikey
		},
		body = data,
		success = function(code, body, headers)
			local response = util.JSONToTable(body)
			if response.error then
				ai_errors.Msg("Error from OpenAI: " .. response.error.message)
				return
			end

			cb(response)
		end,
		failed = function(reason) ai_errors.Msg("Failed to send message to OpenAI: " .. reason) end
	})
end

function ai_errors.SendMessageToAnthropic(data, cb)
	local messages = data.messages
	messages[1].role = "user"
	messages[1].content = messages[1].content .. "\n\n" .. messages[2].content
	messages[2] = nil
	local jsonBody = util.TableToJSON({
		max_tokens = 4096,
		model = data.model, --"claude-3.5-sonnet" or "gpt-4o-mini" or whatever it's set to
		messages = messages
	})

	jsonBody = jsonBody:gsub("4096.0", "4096") --thanks gmod, https://wiki.facepunch.com/gmod/util.TableToJSON
	ai_errors.HTTP({
		url = "https://api.anthropic.com/v1/messages",
		method = "POST",
		headers = {
			["Content-Type"] = "application/json",
			["X-API-Key"] = ai_errors.apikey,
			["anthropic-version"] = "2023-06-01"
		},
		body = jsonBody,
		success = function(code, body, headers)
			if cb then
				local response = util.JSONToTable(body)
				if response.error then
					ai_errors.Msg("Error from Anthropic: " .. response.error.message)
					return
				end

				--match the response format of OpenAI
				local newResponse = {
					choices = {
						{
							message = {
								content = response.content[1].text
							}
						}
					}
				}

				cb(newResponse)
			end
		end,
		failed = function(reason) ai_errors.Msg("Failed to send message to Anthropic: " .. reason) end
	})
end

function ai_errors.reportError(error, realm, stack, _, _, ply)
	if not ai_errors.apikey or ai_errors.apikey == "" then
		ai_errors.Msg(string.format("No %s API key set, cannot send message", ai_errors.useanthropic and "Anthropic" or "OpenAI"))
		return
	end

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

	--ai_errors.Msg(string.format("Error in realm '%s': %s", realm, error))
	local data = {}
	local messages = {
		{
			role = "assistant",
			content = "You are a helpful assistant specialized in diagnosing and fixing code errors, you are short and succint and easy to understand for the technologically less-qualified."
		},
		{
			role = "user",
			content = string.format("There was an error in the Garry's Mod code in the realm '%s'. Could you help diagnose and fix it? Here's the error:\n%s\nInclude a formatted block containing the error at the beginning of your response.", realm, error)
		}
	}

	data.model = ai_errors.model
	data.messages = messages
	if ply then
		local playerInfo = string.format("The error occurred for the player: %s (ID: %s) Include this information near the top of your response below the error.", ply:Nick(), ply:SteamID())
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
					--ai_errors.Msg("Error occurred in lua_run, not reporting to AI.")
					return
				end

				ai_errors.ReadFile(filePath, function(fileContent, status)
					if fileContent then
						local lines = string.Explode("\n", fileContent)
						local lineNum = tonumber(lineNumber)
						local start = math.max(1, lineNum - 2)
						local finish = math.min(#lines, lineNum + 2)
						for i = start, finish do
							table.insert(errorLines, string.format("%d: %s", i, lines[i]))
						end
					else
						ai_errors.Msg("Failed to read file: " .. filePath .. " (" .. status .. ")")
					end

					--pyramids of gaza
					if #stack == stacknum then
						messages[2].content = messages[2].content .. "\n\nHere are the relevant code lines around the error, be specific and concise about your solution to my issue:\n" .. table.concat(errorLines, "\n")
						ai_errors.SendMessage(data, function(response)
							if responseTable and responseTable.choices then
								local assistantMessage = responseTable.choices[1] and responseTable.choices[1].message
								if assistantMessage then
									ai_errors.SendToDiscord(assistantMessage)
									ai_errors.Msg("Error reported to AI: " .. error)
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
	if not webhook or not webhook:find("discord.com/api/webhooks/") then
		ai_errors.Msg(response.content)
		return
	end

	local data = {
		username = ai_errors.webhookname,
		avatar_url = ai_errors.webhookavatar,
		embeds = {
			{
				title = ai_errors.embedtitle,
				description = response.content,
				color = ai_errors.embedcolor,
				footer = {
					text = ai_errors.embedfootertext,
					icon_url = ai_errors.embedfooteravatar
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