-- Description: Configuration file for the AI Errors addon

ai_errors.clientsideErrors = false -- Set to true to report clientside errors
ai_errors.apiKey = ""
ai_errors.webhook = "" -- https://discord.com/api/webhooks/1234567/abcdefg
ai_errors.webhookName = "AI Errors"
ai_errors.webhookAvatar = "https://i.imgur.com/i5kQFmy.jpeg"
ai_errors.embedTitle = "AI Error Analysis"
ai_errors.embedColor = 15158332 -- https://www.spycolor.com/
ai_errors.embedFooterText = "AI Errors Reporter"
ai_errors.embedFooterAvatar = "https://i.imgur.com/i5kQFmy.jpeg"

ai_errors.saveConfig = function()
	local config = {
		clientsideErrors = ai_errors.clientsideErrors,
		apiKey = ai_errors.apiKey
	}

	file.Write("ai_errors_config.txt", util.TableToJSON(config))
end

if file.Exists("ai_errors_config.txt", "DATA") then
	local config = util.JSONToTable(file.Read("ai_errors_config.txt", "DATA"))

	ai_errors.clientsideErrors = config.clientsideErrors
	ai_errors.apiKey = config.apiKey
end