PLAYER = FindMetaTable("Player")

function PLAYER:SetPokemonTable(tbl)
	self.PokemonTable = tbl
end

function PLAYER:GetPokemonTable()
	return self.PokemonTable or false
end

function PLAYER:WMessage(str)
	net.Start("WMessage")
	net.WriteString(str)
	net.Send(self)
end