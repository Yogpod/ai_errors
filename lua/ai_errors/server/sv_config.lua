-- Description: Configuration file for the AI Errors addon
ai_errors.clientsideErrors = false -- Set to true to report clientside errors
ai_errors.apiKey = ""
--claude-3-5-sonnet-20240620	claude-3-opus-20240229	claude-3-sonnet-20240229	claude-3-haiku-20240307
--gpt-4o-mini-2024-07-18	gpt-4o-2024-08-06	o1-preview-2024-09-12	o1-mini-2024-09-12	gpt-3.5-turbo
ai_errors.model = "gpt-4o-mini"
ai_errors.webhook = "" -- https://discord.com/api/webhooks/1234567/abcdefg
ai_errors.webhookName = "AI Errors"
ai_errors.webhookAvatar = "https://i.imgur.com/i5kQFmy.jpeg"
ai_errors.embedTitle = "AI Error Analysis"
ai_errors.embedColor = 15158332 -- https://www.spycolor.com/
ai_errors.embedFooterText = "AI Errors Reporter"
ai_errors.embedFooterAvatar = "https://i.imgur.com/i5kQFmy.jpeg"
ai_errors.saveConfig = function()
	ai_errors.useAnthropic = ai_errors.apiKey:sub(1, 10) == "sk-ant-api"
	if ai_errors.useAnthropic and not ai_errors.model:match("claude") then
		ai_errors.model = "claude-3-haiku-20240307" --claude-3-5-sonnet is expensive
	elseif not ai_errors.useAnthropic and ai_errors.model:match("claude") then
		ai_errors.model = "gpt-4o-mini"
	end

	local config = {
		clientsideErrors = ai_errors.clientsideErrors,
		useAnthropic = ai_errors.useAnthropic,
		apiKey = ai_errors.apiKey,
		model = ai_errors.model,
		webhook = ai_errors.webhook,
		webhookName = ai_errors.webhookName,
		webhookAvatar = ai_errors.webhookAvatar,
		embedTitle = ai_errors.embedTitle,
		embedColor = ai_errors.embedColor,
		embedFooterText = ai_errors.embedFooterText,
		embedFooterAvatar = ai_errors.embedFooterAvatar
	}

	file.Write("ai_errors_config.txt", util.TableToJSON(config))
end

if file.Exists("ai_errors_config.txt", "DATA") then
	local config = util.JSONToTable(file.Read("ai_errors_config.txt", "DATA"))
	ai_errors.clientsideErrors = config.clientsideErrors
	ai_errors.useAnthropic = config.useAnthropic
	ai_errors.apiKey = config.apiKey
	ai_errors.model = config.model
	ai_errors.webhook = config.webhook
	ai_errors.webhookName = config.webhookName
	ai_errors.webhookAvatar = config.webhookAvatar
	ai_errors.embedTitle = config.embedTitle
	ai_errors.embedColor = config.embedColor
	ai_errors.embedFooterText = config.embedFooterText
	ai_errors.embedFooterAvatar = config.embedFooterAvatar
end

ai_errors.useAnthropic = ai_errors.apiKey:match("sk-ant-api") ~= nil
ai_errors.model = ai_errors.useAnthropic and "claude-3-haiku-20240307" or "gpt-4o-mini" --"claude-3-5-sonnet" sonnet is kinda expensive
ai_errors.saveConfig()

ai_errors.Msg("Configuration loaded.")
ai_errors.Msg("Clientside errors: " .. (ai_errors.clientsideErrors and "enabled" or "disabled"))
ai_errors.Msg("Using AI Service: " .. (ai_errors.useAnthropic and "Anthropic" or "OpenAI"))
ai_errors.Msg("API Key: " .. ai_errors.apiKey:sub(1, 10) .. string.rep("*", #ai_errors.apiKey - 10))
ai_errors.Msg("Model: " .. ai_errors.model)