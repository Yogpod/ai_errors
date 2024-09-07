net.Receive("ai_errors", function()
	local action = net.ReadString()
	if action == "config" then
		ai_errors.apiKey = net.ReadString()
		ai_errors.clientsideErrors = net.ReadBool()
		vgui.Create("AIErrorsConfig")
	elseif action == "msg" then
		local msg = net.ReadString()
		chat.AddText(Color(255, 60, 60), "[AI Errors] ", Color(255, 255, 255), msg)
	end
end)

concommand.Add("ai_errors_config", function()
	if not LocalPlayer():IsSuperAdmin() then
		return
	end

	net.Start("ai_errors")
	net.WriteString("askconfig")
	net.SendToServer()
end)