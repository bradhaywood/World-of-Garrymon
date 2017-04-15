surface.CreateFont("MessageFont", {
	font = "Komika Axis",
	extended = false,
	size = 22,
	weight = 400,
	antialias = true,
})

WMessage = {}
WMessage.String = nil
WMessage.Displayed = false

--local wHudColor = Color(203, 223, 195)
--local wHudTextColor = Color(36, 98, 121)
function DrawText()
	if (WMessage.String ~= nil and WMessage.Displayed) then
		surface.SetFont("MessageFont")
		local hudW = surface.GetTextSize(WMessage.String)
		local hudH = 43
		local hudCenter = (ScrW() / 2) - (hudW / 2)
		--local hudCenter = ScrW() - (hudW+60)
		local hudCenterH = 20
		draw.RoundedBorderedBox(4, hudCenter, hudCenterH, hudW+25, hudH, Color(249,38,114), 4, Color(255, 255, 255, 255))
		draw.SimpleText(WMessage.String, "MessageFont", hudCenter+12, hudCenterH+8, Color(255,255,255,255))
	end

	if (WMessage.Displayed and CurTime() > WMessage.Displayed+3) then
		WMessage.String = nil
		WMessage.Displayed = false
	end
end

hook.Add("HUDPaint", "DrawText", DrawText);

net.Receive("WMessage", function(len, ply)
	surface.PlaySound("pokemon/menu_select.ogg")
	WMessage.String = net.ReadString()
	WMessage.Displayed = CurTime()
end)