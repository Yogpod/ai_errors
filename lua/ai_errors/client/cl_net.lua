net.Receive("ai_errors", function()
	local action = net.ReadString()
	if action == "config" then
		ai_errors.apikey = net.ReadString()
		ai_errors.model = net.ReadString()
		ai_errors.clientsideerrors = net.ReadBool()
		ai_errors.useanthropic = net.ReadBool()
		ai_errors.webhook = net.ReadString()
		ai_errors.webhookname = net.ReadString()
		ai_errors.webhookavatar = net.ReadString()
		ai_errors.embedtitle = net.ReadString()
		ai_errors.embedcolor = net.ReadUInt(32)
		ai_errors.embedfootertext = net.ReadString()
		ai_errors.embedfooteravatar = net.ReadString()
		vgui.Create("AIErrorsConfig")
	elseif action == "msg" then
		local msg = net.ReadString()
		chat.AddText(Color(255, 60, 60), "[AI Errors] ", Color(255, 255, 255), msg)
	end
end)

concommand.Add("ai_errors_config", function()
	if not LocalPlayer():IsSuperAdmin() then return end
	net.Start("ai_errors")
	net.WriteString("askconfig")
	net.SendToServer()
end)