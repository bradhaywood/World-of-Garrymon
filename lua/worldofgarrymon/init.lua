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
util.AddNetworkString("QuickSlotPokemon")

net.Receive("WAGSelectWeapon", function(len, ply)
	local swep = net.ReadString()
	ply:SelectWeapon(swep)
end)

net.Receive("QuickSlotPokemon", function(len, ply)
	local swep = ply:GetActiveWeapon()
	local poketbl = swep.HoldingPokemon
	local plytbl  = ply:GetPokemonTable()
	-- different type? then save the id
	if (not plytbl) then
		ply:SetPokemonTable(poketbl)
		ply:WMessage(poketbl.Name .. " saved to quick slot!")
	else
		if (poketbl and plytbl.UniqueId ~= poketbl.UniqeId) then
			ply:SetPokemonTable(poketbl)
			ply:WMessage("Updated quick slot to " .. ply:GetPokemonTable().Name)
		-- otherwise load this bad boy
		else
			-- wish this just used the uniqueid instead
			local pokeid = false
			for k,v in pairs(ply.PokeBag.Pokemon) do
				if (v.UniqueId == plytbl.UniqueId) then pokeid = k end
			end

			if (pokeid and IsValid(swep)) then
				swep:EquipPokemon(plytbl)
				PokemonSystem:TakePokemon(ply, pokeid)
				ply:ConCommand("PokeMenu_RebuildPokemon")
			end
		end
	end
end)