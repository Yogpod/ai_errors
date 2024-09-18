util.AddNetworkString("ai_errors")
function ai_errors.PlyMsg(ply, msg)
	net.Start("ai_errors")
	net.WriteString("msg")
	net.WriteString(msg)
	net.Send(ply)
end

net.Receive("ai_errors", function(len, ply)
	local action = net.ReadString()
	if action == "error" and ai_errors.clientsideerrors then
		local error = net.ReadString()
		local stack = net.ReadString()
		stack = util.JSONToTable(stack)
		if not istable(stack) then return end
		ai_errors.reportError(error, "client", stack, nil, nil, ply)
	elseif action == "askconfig" then
		if not ply:IsSuperAdmin() then return end
		net.Start("ai_errors")
		net.WriteString("config")
		net.WriteString(ai_errors.apikey)
		net.WriteString(ai_errors.model)
		net.WriteBool(ai_errors.clientsideerrors)
		net.WriteBool(ai_errors.useanthropic)
		net.WriteString(ai_errors.webhook)
		net.WriteString(ai_errors.webhookname)
		net.WriteString(ai_errors.webhookavatar)
		net.WriteString(ai_errors.embedtitle)
		net.WriteUInt(ai_errors.embedcolor, 32)
		net.WriteString(ai_errors.embedfootertext)
		net.WriteString(ai_errors.embedfooteravatar)
		net.Send(ply)
	elseif action == "config" then
		if not ply:IsSuperAdmin() then return end
		--this can be done better but i do not really care about this addon's UI
		local apikey = net.ReadString()
		local model = net.ReadString()
		local clientsideerrors = net.ReadBool()
		local useanthropic = net.ReadBool()
		local webhook = net.ReadString()
		local webhookname = net.ReadString()
		local webhookavatar = net.ReadString()
		local embedtitle = net.ReadString()
		local embedcolor = net.ReadUInt(32)
		local embedfootertext = net.ReadString()
		local embedfooteravatar = net.ReadString()
		ai_errors.apikey = apikey
		ai_errors.model = model
		ai_errors.clientsideerrors = clientsideerrors
		ai_errors.useanthropic = useanthropic
		ai_errors.webhook = webhook
		ai_errors.webhookname = webhookname
		ai_errors.webhookavatar = webhookavatar
		ai_errors.embedtitle = embedtitle
		ai_errors.embedcolor = embedcolor
		ai_errors.embedfootertext = embedfootertext
		ai_errors.embedfooteravatar = embedfooteravatar
		ai_errors.saveConfig()
		ai_errors.PlyMsg(ply, "Configuration saved.")
	end
end)

local allowed = {
	["apikey"] = true,
	["clientsideerrors"] = true,
	["webhook"] = true,
	["webhookname"] = true,
	["webhookavatar"] = true,
	["embedtitle"] = true,
	["embedcolor"] = true,
	["embedfootertext"] = true,
	["embedfooteravatar"] = true
}

local translate = {
	key = "apikey",
	cl = "clientsideerrors",
	wh = "webhook",
	whn = "webhookname",
	wha = "webhookavatar",
	et = "embedtitle",
	ec = "embedcolor",
	ef = "embedfootertext",
	efa = "embedfooteravatar"
}

concommand.Add("ai_errors", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	if not args[1] then return end
	local action = args[1]:lower()
	if action == "set" then
		if not args[2] or not args[3] then
			if IsValid(ply) then
				ai_errors.PlyMsg(ply, "Usage: ai_errors set <key> <value>")
				ai_errors.PlyMsg(ply, "Allowed keys: apikey, clientsideerrors, webhook, webhookname, webhookavatar, embedtitle, embedcolor, embedfootertext, embedfooteravatar")
				ai_errors.PlyMsg(ply, "Example: ai_errors set apikey sk-openai-1234567890")
				ai_errors.PlyMsg(ply, "Aliases: key = apikey, cl = clientsideerrors, wh = webhook, whn = webhookname, wha = webhookavatar, et = embedtitle, ec = embedcolor, ef = embedfootertext, efa = embedfooteravatar")
				ai_errors.PlyMsg(ply, "Note: You can use the aliases instead of the full key name.")
			else
				ai_errors.Msg("Usage: ai_errors set <key> <value>")
				ai_errors.Msg("Allowed keys: apikey, clientsideerrors, webhook, webhookname, webhookavatar, embedtitle, embedcolor, embedfootertext, embedfooteravatar")
				ai_errors.Msg("Example: ai_errors set apikey sk-openai-1234567890")
				ai_errors.Msg("Aliases: key = apikey, cl = clientsideerrors, wh = webhook, whn = webhookname, wha = webhookavatar, et = embedtitle, ec = embedcolor, ef = embedfootertext, efa = embedfooteravatar")
				ai_errors.Msg("Note: You can use the aliases instead of the full key name.")
			end
			return
		end

		local key = args[2]:lower()
		if translate[key] then key = translate[key] end
		if not allowed[key] then return end
		local value = table.concat(args, " ", 3)
		ai_errors[key] = value
		ai_errors.saveConfig()
		ai_errors.PlyMsg(ply, "Configuration saved.")
	end
end)