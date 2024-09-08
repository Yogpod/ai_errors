util.AddNetworkString("ai_errors")
function ai_errors.PlyMsg(ply, msg)
	net.Start("ai_errors")
	net.WriteString("msg")
	net.WriteString(msg)
	net.Send(ply)
end

net.Receive("ai_errors", function(len, ply)
	local action = net.ReadString()
	if action == "error" and ai_errors.clientsideErrors then
		local error = net.ReadString()
		local stack = net.ReadString()
		stack = util.JSONToTable(stack)
		if not istable(stack) then return end
		ai_errors.reportError(error, "client", stack, nil, nil, ply)
	elseif action == "askconfig" then
		if not ply:IsSuperAdmin() then return end
		net.Start("ai_errors")
		net.WriteString("config")
		net.WriteString(ai_errors.apiKey)
		net.WriteBool(ai_errors.clientsideErrors)
		net.WriteString(ai_errors.webhook)
		net.WriteString(ai_errors.webhookName)
		net.WriteString(ai_errors.webhookAvatar)
		net.WriteString(ai_errors.embedTitle)
		net.WriteUInt(ai_errors.embedColor, 32)
		net.WriteString(ai_errors.embedFooterText)
		net.WriteString(ai_errors.embedFooterAvatar)
		net.Send(ply)
	elseif action == "config" then
		if not ply:IsSuperAdmin() then return end
		--this can be done better but i do not really care about this addon's UI
		local apiKey = net.ReadString()
		local clientsideErrors = net.ReadBool()
		local webhook = net.ReadString()
		local webhookName = net.ReadString()
		local webhookAvatar = net.ReadString()
		local embedTitle = net.ReadString()
		local embedColor = net.ReadUInt(32)
		local embedFooterText = net.ReadString()
		local embedFooterAvatar = net.ReadString()
		ai_errors.apiKey = apiKey
		ai_errors.clientsideErrors = clientsideErrors
		ai_errors.webhook = webhook
		ai_errors.webhookName = webhookName
		ai_errors.webhookAvatar = webhookAvatar
		ai_errors.embedTitle = embedTitle
		ai_errors.embedColor = embedColor
		ai_errors.embedFooterText = embedFooterText
		ai_errors.embedFooterAvatar = embedFooterAvatar
		ai_errors.saveConfig()
		ai_errors.PlyMsg(ply, "Configuration saved.")
	end
end)