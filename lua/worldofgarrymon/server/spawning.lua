-- do I really need to explain what this method does?
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
				if (gmType.Class == "npc_antlionguard") then continue end

				-- sorry, but the birds are fucking useless
				if (gmType.Class == "npc_seagull") then continue end
				if (gmType.Class == "npc_crow") then continue end
				if (gmType.Class == "npc_pigeon") then continue end

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