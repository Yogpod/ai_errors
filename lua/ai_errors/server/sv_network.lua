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
		net.Send(ply)
	elseif action == "config" then
		if not ply:IsSuperAdmin() then return end

		local apiKey = net.ReadString()
		local clientsideErrors = net.ReadBool()

		ai_errors.apiKey = apiKey
		ai_errors.clientsideErrors = clientsideErrors

		ai_errors.saveConfig()
		ai_errors.PlyMsg(ply, "Configuration saved")
	end
end)