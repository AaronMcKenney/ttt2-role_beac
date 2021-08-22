if SERVER then
    AddCSLuaFile()

    resource.AddFile("materials/vgui/ttt/icon_beac_lit.vmt")
end

if CLIENT then
	EVENT.title = "title_event_beac_deputize"
	EVENT.icon = Material("vgui/ttt/icon_beac_lit.vmt")
	
	function EVENT:GetText()
		return {
			{
				string = "desc_event_beac_deputize",
				params = {
					name = self.event.beac_name,
					n = GetConVar("ttt2_beacon_deputize_num_buffs"):GetInt()
				},
				translateParams = true
			}
		}
    end
end

if SERVER then
	function EVENT:Trigger(beac)
		self:AddAffectedPlayers(
			{beac:SteamID64()},
			{beac:GetName()}
		)
		
		return self:Add({
			serialname = self.event.title,
			beac_id = beac:SteamID64(),
			beac_name = beac:GetName()
		})
	end
	
	function EVENT:CalculateScore()
		self:SetPlayerScore(self.event.beac_id, {
			score = 1
		})
	end
	
	function EVENT:Serialize()
		return self.event.serialname
	end
end