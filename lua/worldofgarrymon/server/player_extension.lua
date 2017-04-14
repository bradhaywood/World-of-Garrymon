PLAYER = FindMetaTable("Player")

function PLAYER:WMessage(str)
	net.Start("WMessage")
	net.WriteString(str)
	net.Send(self)
end