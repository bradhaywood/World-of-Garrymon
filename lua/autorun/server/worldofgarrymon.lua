WAG = {} -- our motherfuckin namespace

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

-- Taken from zombie invasion, which was taken from nodegrapher, and now here too
-- sharing is caring
WAG.Nodes = {}

-- just a weird little logging function with disgusting colors to make it stand out
function WAG.Log(str) MsgC(Color(83, 244, 66), "[World of Garrymon] " .. str .. "\n") end

local SIZEOF_INT = 4
local SIZEOF_SHORT = 2
local AINET_VERSION_NUMBER = 37
local function toUShort(b)
	local i = {string.byte(b,1,SIZEOF_SHORT)}
	return i[1] +i[2] *256
end
local function toInt(b)
	local i = {string.byte(b,1,SIZEOF_INT)}
	i = i[1] +i[2] *256 +i[3] *65536 +i[4] *16777216
	if(i > 2147483647) then return i -4294967296 end
	return i
end
local function ReadInt(f) return toInt(f:Read(SIZEOF_INT)) end
local function ReadUShort(f) return toUShort(f:Read(SIZEOF_SHORT)) end

--Taken from nodegraph addon - thx
--Types:
--1 = ?
--2 = info_nodes
--3 = playerspawns
--4 = wall climbers
function WAG:ParseNodeFile()
	if foundain then
		return
	end

	f = file.Open("maps/graphs/"..game.GetMap()..".ain","rb","GAME")
	if(!f) then
		return
	end

	found_ain = true
	local ainet_ver = ReadInt(f)
	local map_ver = ReadInt(f)
	if (ainet_ver != AINET_VERSION_NUMBER) then
		WAG.Log("Unknown graph file")
		return
	end

	local numNodes = ReadInt(f)
	if (numNodes < 0) then
		WAG.Log("Graph file has an unexpected amount of nodes")
		return
	end

	for i = 1,numNodes do
		local v = Vector(f:ReadFloat(),f:ReadFloat(),f:ReadFloat())
		local yaw = f:ReadFloat()
		local flOffsets = {}
		for i = 1,NUM_HULLS do
			flOffsets[i] = f:ReadFloat()
		end
		local nodetype = f:ReadByte()
		local nodeinfo = ReadUShort(f)
		local zone = f:ReadShort()

		if nodetype == 4 then
			continue
		end
		
		local node = {
			pos = v,
			yaw = yaw,
			offset = flOffsets,
			type = nodetype,
			info = nodeinfo,
			zone = zone,
			neighbor = {},
			numneighbors = 0,
			link = {},
			numlinks = 0
		}

		table.insert(WAG.Nodes, node)
	end
end

function WAG:SpawnGarryMon()
	local gmAlive = 0
	for k,v in pairs(ents.FindByClass("npc_*")) do
		if (v.GarryMon) then gmAlive = gmAlive+1 end
	end

	local needed = WAG.MaxGarryMon - gmAlive
	if (needed > 0) then
		WAG.Log("Spawning " .. needed .. " GarryMon")
		for i = 1, needed do
			local getnode = WAG.Nodes[math.random(#WAG.Nodes)]
			if (getnode) then
				local gmType = POKEMON_NPCTable[math.random(#POKEMON_NPCTable)]
				-- let's just let admins spawn these bad boys..
				-- feel free to do the same with birds, because they're fucking useless
				if (gmType.Class == "npc_antlionguard") then continue end

				local pokemon = ents.Create(gmType.Class)
				if (gmType.Weapon) then
					pokemon:SetKeyValue("additionalequipment", POKEMON_WeaponTable[math.random(#POKEMON_WeaponTable)])
				end
				pokemon:SetPos(getnode.pos)
				pokemon:Spawn()
				pokemon.GarryMon = true -- give our spawned pokemon an attribute to tell them apart from other breeds
				WAG.Log("A wild " .. gmType.Name .. " appears!")
			end
		end
	end
end

hook.Add("Initialize", "WAG_Init", function()
	if (POKEMON_NPCTable and #POKEMON_NPCTable > 0) then
		WAG.Log(#POKEMON_NPCTable .. " GarryMon detected")
		WAG.Enabled = true

		-- get the fucking nodes
		WAG:ParseNodeFile()
	else
		WAG.Log("GarryMon addon wasn't found. What the hell is wrong with you?")
	end
end)

hook.Add("PostInitEntity", "WAG_PostInit", function()

	if (WAG.Enabled) then
		if (#WAG.Nodes > 0) then
			-- spawn some bitches once the map loads
			WAG:SpawnGarryMon()
		else
			-- No nodes? No World of Garrymon
			WAG.Log("No nodes found for map '" .. game.GetMap() .. "': Unable to spawn GarryMon")
			WAG.Enabled = false
		end
	end
end)

-- for some reason timers acted really fucking weird inside the post init hook
-- so I'm adding it when the first person joins
-- obviously it checks to make sure it's not already running. You're welcome.

hook.Add("PlayerInitialSpawn", "WAG_PlayerInitSpawn", function(ply)
	if (#player.GetAll() == 1 and not timer.Exists("SpawnGarryMon") and WAG.Enabled) then
		WAG.Log("Starting GarryMon Spawn Timer")
		timer.Create("SpawnGarryMon", WAG.SpawnCheckInterval, 0, function()
			WAG:SpawnGarryMon()
		end)
	end
end)

-- If this is sandbox, stop people from creating AntLion Guards and capturing them like assholes
if (WAG.SandboxSpawnProtection and engine.ActiveGamemode() == "sandbox") then
	WAG.Log("Sandbox Spawn Protection enabled")
	hook.Add("PlayerSpawnNPC", "WAGRestrictNPCs", function(ply, npc, weapon)
		-- admins can do it, because corrupt
		if (ply:IsAdmin()) then return true end
		
		ply:PrintMessage(HUD_PRINTTALK, "NPC spawning is disabled. Use your Pokemon")
		return false
	end)
end