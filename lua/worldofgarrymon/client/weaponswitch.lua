WAGWeap = {}
WAGWeap.Cache = {}
WAGWeap.ShowSelection = false
WAGWeap.Opened = CurTime()+3
WAGWeap.SlotSelection = 1
WAGWeap.LastSlotChecked = 1
WAGWeap.SelectedWeapon = false

WAGWeap.Icons = {}
surface.CreateFont("WeapFont", {
	font = "Komika Axis",
	extended = false,
	size = 22,
	weight = 400,
	antialias = true
})

surface.CreateFont("WeapIcon", {
	font = "csd",
	extended = false,
	size = 70,
	weight = 400,
	antialias = true
})

local hudBG = Color(0,160,176)
local hudBGselected = Color(237,201,81)

function WAGWeap:DrawSelection()
	local itemWidth = 250
	local hudColor  = hudBG
	local iconColor = Color(255, 255, 255)
	local hudX = 5
	local hudY = 100
	local icontbl = {}
	local textColor = Color(255, 255, 255)

	-- draw weapons
	for k,v in pairs(WAGWeap.Cache) do
		if (k == WAGWeap.SlotSelection) then
			hudColor = hudBGselected
			textColor = Color(39,40,34)
			WAGWeap.SelectedWeapon = k
			iconColor = Color(39, 40, 34)
		end

		draw.RoundedBorderedBox(10, hudX, hudY, itemWidth, 100, hudColor, 4, Color(255, 255, 255, 255))
		draw.DrawText(v:GetPrintName(), "WeapFont", hudX+10, hudY+10, textColor)

		local holdType = v:GetHoldType() or "o"
		local icon = WAG.WeaponIcons[holdType] or (function()
			local cls = v:GetPrintName()
			if (string.match(cls, "Magnum")) then return "a" end
			if (string.match(cls, "Sniper")) then return "i" end
			return "w"
		end)()
		draw.DrawText(icon, "WeapIcon", hudX+40, hudY+40, iconColor)

		hudY = hudY + 115
		hudColor = hudBG
		textColor = Color(255, 255, 255)
		iconColor = Color(255, 255, 255)
	end
end

function WAGWeap:CheckSlot(idx)
	local slottbl = {}
	local weptbl = LocalPlayer():GetWeapons()
	for k,v in pairs(weptbl) do
		if v:GetSlot() == idx then table.insert(slottbl, v) end
	end

	if (#slottbl > 0) then
		--WAGWeap.BankSelected = idx
		if (#WAGWeap.Icons > 0) then for k,v in pairs(WAGWeap.Icons) do v:Remove() end end
		if (WAGWeap.ShowSelection) then
			if (WAGWeap.LastSlotChecked != idx) then WAGWeap.SlotSelection = 0 end
			local nextidx = WAGWeap.SlotSelection+1
			if (nextidx <= #WAGWeap.Cache) then
				WAGWeap.SlotSelection = nextidx
			else
				WAGWeap.SlotSelection = 1
			end
		end
		WAGWeap.Cache = slottbl
		WAGWeap.ShowSelection = true
		WAGWeap.Opened = CurTime()+3
		WAGWeap.LastSlotChecked = idx
		local sndNum = WAGWeap.SlotSelection
		if (WAGWeap.SlotSelection > 6) then sndNum = math.random(1, 6) end
		surface.PlaySound("sandplox/weaponselection/switch" .. sndNum .. ".wav")
		return true
	else
		-- no weapons found in this slot
		return false
	end
end

hook.Add("PlayerBindPress", "WAG WeaponSwap", function(ply, bind, pressed)
	if string.sub(bind, 1, 4) == "slot" and pressed then
    local idx = tonumber(string.sub(bind, 5, -1)) or 1
    WAGWeap:CheckSlot(idx-1)
  elseif (bind == "+attack" and WAGWeap.ShowSelection and pressed) then
  	local swep = WAGWeap.Cache[WAGWeap.SelectedWeapon]
  	net.Start("WAGSelectWeapon")
  	net.WriteString(swep:GetClass())
  	net.SendToServer()
  	--surface.PlaySound("")
  	WAGWeap.SlotSelection = 1
  	WAGWeap.ShowSelection = false
  	return true
  end
end)

local function ShowSelection()
	if WAGWeap.ShowSelection and CurTime() > WAGWeap.Opened then
		WAGWeap.SlotSelection = 1
		WAGWeap.ShowSelection = false
	end
	if not WAGWeap.ShowSelection and #WAGWeap.Icons > 0 then
		for k,v in pairs(WAGWeap.Icons) do v:Remove() end
		WAGWeap.Icons = {}
	end
	if WAGWeap.ShowSelection then WAGWeap:DrawSelection() end
end

hook.Add("HUDPaint", "WeaponSelection", ShowSelection)