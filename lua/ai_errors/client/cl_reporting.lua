local function sendError(error, _, stack)
	net.Start("ai_errors")
	net.WriteString("error")
	net.WriteString(error)
	net.WriteString(util.TableToJSON(stack))
	net.SendToServer()
end

hook.Add("OnLuaError", "ai_errors", sendError)