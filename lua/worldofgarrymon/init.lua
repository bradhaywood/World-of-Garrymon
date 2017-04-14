include "shared.lua"
include "sv_manifest.lua"

-- add resources
resource.AddFile("resource/fonts/komikax.ttf")
resource.AddFile("sound/worldofgarrymon/weaponselection/switch1.wav")
resource.AddFile("sound/worldofgarrymon/weaponselection/switch2.wav")
resource.AddFile("sound/worldofgarrymon/weaponselection/switch3.wav")
resource.AddFile("sound/worldofgarrymon/weaponselection/switch4.wav")
resource.AddFile("sound/worldofgarrymon/weaponselection/switch5.wav")
resource.AddFile("sound/worldofgarrymon/weaponselection/switch6.wav")

util.AddNetworkString("WAGSelectWeapon")
util.AddNetworkString("WMessage")

net.Receive("WAGSelectWeapon", function(len, ply)
	local swep = net.ReadString()
	ply:SelectWeapon(swep)
end)