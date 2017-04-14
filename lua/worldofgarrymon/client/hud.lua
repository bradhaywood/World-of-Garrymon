surface.CreateFont("AmmoFont", {
	font = "Komika Axis",
	extended = false,
	size = 40,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false
})

surface.CreateFont("WeaponFont", {
	font = "Komika Axis",
	extended = false,
	size = 28,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false
})

surface.CreateFont("TextFont", {
	font = "Komika Axis",
	extended = false,
	size = 20,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false
})

local healthBGfull = Color(138,155,15)
local armorBGfull = Color(0,160,176)
local inTheRed    = Color(189,21,80)

local function WAGHud()
	if (LocalPlayer():Alive()) then
		local health = LocalPlayer():Health()
		local hudWidth = 300
		local hudX = (ScrW() / 2) - (hudWidth / 2)
		local hudY = ScrH() - 15 - 20
		local alertHealth = 35
		local weapon = LocalPlayer():GetActiveWeapon()
		local clip1 = -1
		local mag = -1
		local printname = "Unknown"
		if (IsValid(weapon)) then
			clip1 = weapon:Clip1()
			mag   = LocalPlayer():GetAmmoCount(weapon:GetPrimaryAmmoType())
			printname = weapon:GetPrintName()
		end
		if (mag < 0) then mag = "-" end
		if (clip1 < 0) then clip1 = "-" end
		local weapStr = clip1 .. " / " .. mag
		-- weapon hud
		draw.RoundedBox(4, hudX, ScrH() - 145, hudWidth, 100, Color(0, 0, 0, 125))
		draw.DrawText(weapStr, "AmmoFont", hudX+40, ScrH() - 130, Color(255, 255, 255))
		draw.DrawText(string.upper(printname), "WeaponFont", hudX+40, ScrH() - 90, Color(255, 255, 255))

		-- health hud
		-- red
		draw.RoundedBorderedBox(4, hudX, hudY, hudWidth, 20, inTheRed, 1, Color(255, 255, 255, 90))

		if (health < 100) then
			-- green
			local width = hudWidth * math.Clamp( health / 100, 0, 1 )
			draw.RoundedBox(4, hudX, hudY, width, 20, healthBGfull)
		else
			draw.RoundedBorderedBox(4, hudX, hudY, hudWidth, 20, healthBGfull, 1, Color(255, 255, 255, 90))
		end
		surface.SetFont("TextFont")
		if (health < 0) then health = 0 end
		local healthtext = "%" .. health
		local healthtextSz = surface.GetTextSize(healthtext)+20
		draw.DrawText(healthtext, "TextFont", (hudX+hudWidth)-healthtextSz, hudY-1, Color(255, 255, 255))
		-- armor hud
		local armor = LocalPlayer():Armor()
		if (armor > 0) then
			local armorHudWidth = 25
			local armorHudHeight = 130
			local alertArmor = 35
			local armorX = hudX-35
			local armorY = hudY-110
			draw.RoundedBorderedBox(4, armorX, armorY, armorHudWidth, armorHudHeight, inTheRed, 1, Color(255, 255, 255))
			if (armor < 100) then
				local height = armorHudHeight * math.Clamp( armor / 100, 0, 1 );
				draw.RoundedBox(0, armorX, armorY, armorHudWidth, height, armorBGfull)
			else
				draw.RoundedBorderedBox(4, armorX, armorY, armorHudWidth, armorHudHeight, armorBGfull, 1, Color(255, 255, 255))
			end
		end
	end
end

hook.Add("HUDPaint", "WAGHud", WAGHud)

-- Nameplates
local function GetScreenCenterBounce(bounce)
	return ScrW() / 2 + 20, (ScrH() / 2) + 32 + (math.sin(CurTime()) * (bounce or 0) )
end

hook.Add("HUDDrawTargetID", "Proto PlayerNameplate", function()
	if (LocalPlayer():Alive()) then
		local fadeDistance = 100
		local tr = LocalPlayer():GetEyeTrace();
		if ( tr.Entity:IsPlayer() or tr.Entity:IsNPC()) then
			local alpha = math.Clamp(255 - ((255 / fadeDistance) * (LocalPlayer():GetPos():Distance(tr.Entity:GetPos()))), 0, 255)
			
			local x, y = GetScreenCenterBounce()
		
			local hudWidth = 100
			local health = tr.Entity:Health()
			draw.RoundedBorderedBox(2, x, y+20, hudWidth, 10, Color(249,38,114), 1, Color(255, 255, 255, 255))
			if (health < 100) then
				local width = hudWidth * math.Clamp( health / 100, 0, 1 );
				draw.RoundedBox(2, x, y+20, width, 10, Color(166,226,46))
			else
				draw.RoundedBorderedBox(2, x, y+20, hudWidth, 10, Color(166,226,46), 1, Color(255, 255, 255, 255))
			end
			local entname = (function()
				if tr.Entity:IsPlayer() then return tr.Entity:Name() end
				return ""
			end)()
			y = draw.DrawText(entname, "WeaponFont", x, y-10, Color(255, 255, 255), alpha)
		end
	end

	return true
end)

-- hide the default stuff
local hide = {
	CHudHealth = true,
	CHudBattery = true,
	CHudAmmo = true,
	CHudSecondaryAmmo = true,
	CHudWeaponSelection = true
}

hook.Add("HUDShouldDraw", "HideHUD", function(name)
	if ( hide[ name ] ) then return false end
end)