AddCSLuaFile "shared.lua"
AddCSLuaFile "cl_init.lua"
include "server/nodegraphs.lua"
include "server/spawning.lua"
include "server/player_extension.lua"
AddCSLuaFile "client/wmessage.lua"
AddCSLuaFile "client/removeragdolls.lua"

if (WAG.Hud) then
	AddCSLuaFile "client/hud.lua"
	AddCSLuaFile "client/weaponswitch.lua"
end