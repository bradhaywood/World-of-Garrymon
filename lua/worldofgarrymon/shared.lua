-- I didn't use WOG for the namespace as it's politically incorrect towards Italians
WAG = {}

-- enable the World of Garrymon hud and weapon switching? (WIP)
WAG.Hud = false

 -- whether or not WAG is enabled. Durrr.
 -- this gets set to true if the pokemon npc table and nodes exist for the map
WAG.Enabled = false

-- how many garrymon can be roaming around the world at one time
-- I could have rounded it off to 10, but fuck you
WAG.MaxGarryMon = 11

-- how many seconds we check to see if we need to spawn new pokemon
WAG.SpawnCheckInterval = 30

-- if running in sandbox, do we stop assholes from spawning their own npcs
WAG.SandboxSpawnProtection = true

-- enable the quick slot mechanic using the 'q' menu?
WAG.QuickDraw = true

-- a table to hold the nodes
WAG.Nodes = {}

-- just a weird little logging function with disgusting colors to make it stand out
function WAG.Log(str) MsgC(Color(83, 244, 66), "[World of Garrymon] " .. str .. "\n") end

-- add some borders to stuff
-- Josh 'Acecool' Moser
if (CLIENT) then
	GRADIENT_HORIZONTAL = 0;
	GRADIENT_VERTICAL = 1;
	function draw.LinearGradient(x,y,w,h,from,to,dir,res)
		dir = dir or GRADIENT_HORIZONTAL;
		if dir == GRADIENT_HORIZONTAL then res = (res and res <= w) and res or w;
		elseif dir == GRADIENT_VERTICAL then res = (res and res <= h) and res or h; end
		for i=1,res do
			surface.SetDrawColor(
				Lerp(i/res,from.r,to.r),
				Lerp(i/res,from.g,to.g),
				Lerp(i/res,from.b,to.b),
				Lerp(i/res,from.a,to.a)
			);
			if dir == GRADIENT_HORIZONTAL then surface.DrawRect(x + w * (i/res), y, w/res, h );
			elseif dir == GRADIENT_VERTICAL then surface.DrawRect(x, y + h * (i/res), w, h/res ); end
		end
	end


	function draw.RoundedBorderedBox(cornerDepth, x, y, w, h, color, borderSize, borderColor)
		local _corners = (isnumber(cornerDepth) && cornerDepth > 0 && cornerDepth % 2 == 0) && true || false;
		return draw.RoundedBorderedBoxEx(cornerDepth, x, y, w, h, color, borderSize, borderColor, _corners, _corners, _corners, _corners);
	end

	-- Helper-function which gives a "border" effect by drawing two objects over eachother - Josh 'Acecool' Moser
	function draw.RoundedBorderedBoxEx(cornerDepth, x, y, w, h, color, borderSize, borderColor, topleft, topright, bottomleft, bottomright)
		draw.RoundedBoxEx(cornerDepth, x - borderSize, y - borderSize, w + borderSize * 2, h + borderSize * 2, borderColor, topleft, topright, bottomleft, bottomright);
		draw.RoundedBoxEx(cornerDepth, x, y, w, h, color, topleft, topright, bottomleft, bottomright);
	end

  -- csd icons based on hold type
	WAG.WeaponIcons = {
		pistol 		= "u",
	  smg				= "l",
	  grenade 	= "h",
		ar2				= "v",
		shotgun		= "k",
		rpg				= "m",
		physgun		= "m",
		crossbow 	= "r",
	  melee			= "j",
		slam			= "O",
	  normal 		= "H",
	  fist 			= "H",
	  melee2 		= "j",
	  passive 	= "H",
	  knife			= "j",
	  duel 			= "s",
	  camera 		= "G",
	  magic			= "J",
	  revolver 	= "a"
	}
end