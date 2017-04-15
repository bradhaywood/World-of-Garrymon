hook.Add("PlayerBindPress", "WAG QuickDraw", function(ply, bind, pressed)
	if (bind == "+menu" and pressed) then
		if (LocalPlayer():Alive()) then
			local swep = LocalPlayer():GetActiveWeapon()
			if (swep:GetClass() == "weapon_pokeball") then
				net.Start("QuickSlotPokemon")
				net.SendToServer()
				return true
			end
		end
	end
end)