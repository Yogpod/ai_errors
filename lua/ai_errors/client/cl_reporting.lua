local function sendError(error, stack)
	net.Start("ai_errors")
	net.WriteString("error")
	net.WriteString(error)
	net.WriteString(util.TableToJSON(stack))
	net.SendToServer()
end

hook.Add("OnLuaError", "ai_errors", function(err, realm, stack)
	sendError(err, stack)
end)