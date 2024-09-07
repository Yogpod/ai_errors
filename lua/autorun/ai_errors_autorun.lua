ai_errors = ai_errors or {}

if SERVER then
	include("ai_errors/sv_init.lua")
else
	include("ai_errors/cl_init.lua")
end