-- Description: Configuration file for the AI Errors addon
ai_errors.clientsideerrors = false -- Set to true to report clientside errors
ai_errors.apikey = ""
--claude-3-5-sonnet-20240620	claude-3-opus-20240229	claude-3-sonnet-20240229	claude-3-haiku-20240307
--gpt-4o-mini-2024-07-18	gpt-4o-2024-08-06	o1-preview-2024-09-12	o1-mini-2024-09-12	gpt-3.5-turbo
ai_errors.model = "gpt-4o-mini"
ai_errors.webhook = "" -- https://discord.com/api/webhooks/1234567/abcdefg
ai_errors.webhookname = "AI Errors"
ai_errors.webhookavatar = "https://i.imgur.com/i5kQFmy.jpeg"
ai_errors.embedtitle = "AI Error Analysis"
ai_errors.embedcolor = 15158332 -- https://www.spycolor.com/
ai_errors.embedfootertext = "AI Errors Reporter"
ai_errors.embedfooteravatar = "https://i.imgur.com/i5kQFmy.jpeg"
ai_errors.saveConfig = function(o)
	ai_errors.useanthropic = ai_errors.apikey:sub(1, 10) == "sk-ant-api"
	if ai_errors.useanthropic and not ai_errors.model:match("claude") then
		ai_errors.model = "claude-3-haiku-20240307" --claude-3-5-sonnet is expensive
	elseif not ai_errors.useanthropic and ai_errors.model:match("claude") then
		ai_errors.model = "gpt-4o-mini"
	end

	local config = {
		clientsideerrors = ai_errors.clientsideerrors,
		useanthropic = ai_errors.useanthropic,
		apikey = ai_errors.apikey,
		model = ai_errors.model,
		webhook = ai_errors.webhook,
		webhookname = ai_errors.webhookname,
		webhookavatar = ai_errors.webhookavatar,
		embedtitle = ai_errors.embedtitle,
		embedcolor = ai_errors.embedcolor,
		embedfootertext = ai_errors.embedfootertext,
		embedfooteravatar = ai_errors.embedfooteravatar
	}

	if not o then
		ai_errors.Msg("Configuration Saved.")
		ai_errors.Msg("Clientside errors: " .. (ai_errors.clientsideerrors and "enabled" or "disabled"))
		ai_errors.Msg("Using AI Service: " .. (ai_errors.useanthropic and "Anthropic" or "OpenAI"))
		ai_errors.Msg("API Key: " .. ai_errors.apikey:sub(1, 10) .. string.rep("*", #ai_errors.apikey - 10))
		ai_errors.Msg("Model: " .. ai_errors.model)
		ai_errors.Msg("Webhook: " .. ai_errors.webhook:sub(1, 10) .. string.rep("*", #ai_errors.webhook - 10))
	end

	file.Write("ai_errors_config.txt", util.TableToJSON(config))
end

if file.Exists("ai_errors_config.txt", "DATA") then
	local config = util.JSONToTable(file.Read("ai_errors_config.txt", "DATA"))
	ai_errors.clientsideerrors = config.clientsideerrors
	ai_errors.useanthropic = config.useanthropic
	ai_errors.apikey = config.apikey
	ai_errors.model = config.model
	ai_errors.webhook = config.webhook
	ai_errors.webhookname = config.webhookname
	ai_errors.webhookavatar = config.webhookavatar
	ai_errors.embedtitle = config.embedtitle
	ai_errors.embedcolor = config.embedcolor
	ai_errors.embedfootertext = config.embedfootertext
	ai_errors.embedfooteravatar = config.embedfooteravatar
end

ai_errors.useanthropic = ai_errors.apikey:match("sk-ant-api") ~= nil
ai_errors.model = ai_errors.useanthropic and "claude-3-haiku-20240307" or "gpt-4o-mini" --"claude-3-5-sonnet" sonnet is kinda expensive
ai_errors.saveConfig(true)
ai_errors.Msg("Configuration Loaded.")
ai_errors.Msg("Clientside errors: " .. (ai_errors.clientsideerrors and "enabled" or "disabled"))
ai_errors.Msg("Using AI Service: " .. (ai_errors.useanthropic and "Anthropic" or "OpenAI"))
ai_errors.Msg("API Key: " .. ai_errors.apikey:sub(1, 10) .. string.rep("*", #ai_errors.apikey - 10))
ai_errors.Msg("Model: " .. ai_errors.model)
ai_errors.Msg("Webhook: " .. ai_errors.webhook:sub(1, 10) .. string.rep("*", #ai_errors.webhook - 10))