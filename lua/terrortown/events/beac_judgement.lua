if SERVER then
    AddCSLuaFile()

    resource.AddFile("materials/vgui/ttt/vskin/events/beac_judgement.vmt")
end

if CLIENT then
	EVENT.title = "title_event_beac_judgement"
	EVENT.icon = Material("vgui/ttt/vskin/events/beac_judgement.vmt")
	
	function EVENT:GetText()
		return {
			{
				string = "desc_event_beac_judgement",
				params = {
					name1 = self.event.beac_name,
					name2 = self.event.victim_name,
					x = GetConVar("ttt2_beacon_judgement"):GetInt()
				},
				translateParams = true
			}
		}
    end
end

if SERVER then
	function EVENT:Trigger(beac, victim)
		self:AddAffectedPlayers(
			{beac:SteamID64(), victim:SteamID64()},
			{beac:GetName(), victim:GetName()}
		)
		
		return self:Add({
			serialname = self.event.title,
			beac_name = beac:GetName(),
			beac_id = beac:SteamID64(),
			beac_team = beac:GetTeam(),
			victim_name = victim:GetName()
		})
	end
	
	function EVENT:CalculateScore()
		if self.event.beac_team == TEAM_INNOCENT then
			self:SetPlayerScore(self.event.beac_id, {
				score = -1
			})
		else
			self:SetPlayerScore(self.event.beac_id, {
				score = 0
			})
		end
	end
	
	function EVENT:Serialize()
		return self.event.serialname
	end
end