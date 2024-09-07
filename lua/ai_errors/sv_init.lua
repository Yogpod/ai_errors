if util.IsBinaryModuleInstalled("reqwest") then
	require("reqwest")
elseif util.IsBinaryModuleInstalled("chttp") then
	require("chttp")
end

--this wont work with discord messages if it's HTTP
ai_errors.HTTP = reqwest or CHTTP or HTTP
function ai_errors.Msg(msg)
	MsgC(Color(255, 60, 60), "[AI Errors] ", Color(255, 255, 255), msg, "\n")
end

include("ai_errors/server/sv_config.lua")
include("ai_errors/server/sv_luacache.lua")
include("ai_errors/server/sv_network.lua")
include("ai_errors/server/sv_openai.lua")
include("ai_errors/server/sv_reporting.lua")

AddCSLuaFile("ai_errors/cl_init.lua")
AddCSLuaFile("ai_errors/client/cl_gui.lua")
AddCSLuaFile("ai_errors/client/cl_net.lua")
