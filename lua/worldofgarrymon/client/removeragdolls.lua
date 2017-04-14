-- you don't want a beautiful map littered by rotting corpses, right? Exactly.
function RemoveDeadRag(ent)
	if (ent == NULL) or (ent == nil) then return end
	if (ent:GetClass() == "class C_ClientRagdoll") then 
		if ent:IsValid() and !(ent == NULL) then
			SafeRemoveEntityDelayed(ent,5) 
		end
	end 
	
end
hook.Add("OnEntityCreated", "RemoveDeadRag", RemoveDeadRag)