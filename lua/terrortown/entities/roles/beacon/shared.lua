AddCSLuaFile()

if SERVER then
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_beac.vmt")
end

function ROLE:PreInitialize()
	self.color = Color(255, 255, 153, 255)
	self.abbr = "beac" -- abbreviation
	
	self.surviveBonus = 0.5 -- bonus multiplier for every survive when another player was killed
	self.scoreKillsMultiplier = 1 -- multiplier for kill of player of another team
	self.scoreTeamKillsMultiplier = -16 -- multiplier for teamkill
	
	self.unknownTeam = true -- disables team voice chat.
	self.disableSync = false -- Do tell the player about his role

	self.defaultTeam = TEAM_INNOCENT -- the team name: roles with same team name are working together
	self.defaultEquipment = INNO_EQUIPMENT -- here you can set up your own default equipment

	-- ULX ConVars
	self.conVarData = {
		pct = 0.15, -- necessary: percentage of getting this role selected (per player)
		maximum = 1, -- maximum amount of roles in a round
		minPlayers = 6, -- minimum amount of players until this role is able to get selected
		credits = 0, -- the starting credits of a specific role
		shopFallback = SHOP_DISABLED,
		togglable = true, -- option to toggle a role for a client if possible (F1 menu)
		random = 30
	}
end

function ROLE:Initialize()
	roles.SetBaseRole(self, ROLE_INNOCENT)
end

if SERVER then
	--Constants
	local default_jump_power = 160 --Hardcoded default that everyone uses.
	
	local function ResetBeacon()
		for i, ply_i in ipairs(player.GetAll()) do
			ply_i:SetNWBool("IsDetectiveBeacon", false)
			ply_i:SetNWBool("HadBeaconBuffsRemoved", false)
			ply_i:SetNWBool("HasKilledAnInnocent", false)
			for j, ply_j in ipairs(player.GetAll()) do
				if ply_i:SteamID64() ~= ply_j:SteamID64() then
					ply_i:SetNWBool("HasProvidedBeaconBuff_" .. ply_j:SteamID64(), false)
				end
			end
			ply_i:SetNWInt("NumBeaconBuffs", GetConVar("ttt2_beacon_min_buffs"):GetInt())
		end
	end
	
	--Do not reset beacon on TTTEndRound, because that will set NumBeaconBuffs to 0 before RemoveRoleLoadout() is called.
	hook.Add("TTTPrepareRound", "ResetBeacon", ResetBeacon)
	hook.Add("TTTBeginRound", "ResetBeacon", ResetBeacon)
	
	--UNCOMMENT FOR DEBUGGING
	--local function PrintBeaconStats(prefix_str, ply)
	--	local n = ply:GetNWInt("NumBeaconBuffs")
	--	local speed = 1 + n * GetConVar("ttt2_beacon_speed_boost"):GetFloat()
	--	local dmg = 1 + n * GetConVar("ttt2_beacon_damage_boost"):GetFloat()
	--	print(prefix_str, "name=", ply:GetName(), ", num_buffs=", n, ", speed=", speed, ", jump=", ply:GetJumpPower(), ", armor=", ply:GetArmor(), ", dmg=", dmg)
	--end
	
	local function UpdateBeaconStats(ply, n)
		--Speed is handled in TTTPlayerSpeedModifier handle.
		--Damage is handled in EntityTakeDamage handle.
		ply:SetJumpPower(ply:GetJumpPower() + n * (default_jump_power * GetConVar("ttt2_beacon_jump_boost"):GetFloat()))
		ply:GiveArmor(n * GetConVar("ttt2_beacon_armor_boost"):GetInt())
		
		--Only give no fall damage if beacon runs risk of hurting themselves merely from jumping
		if ply:GetJumpPower() > default_jump_power and not ply:HasEquipmentItem("item_ttt_nofalldmg") then
			ply:GiveEquipmentItem("item_ttt_nofalldmg")
		end
		
		if ply:GetNWInt("NumBeaconBuffs") >= GetConVar("ttt2_beacon_deputize_num_buffs"):GetInt() then
			--Make the beacon known to everyone in game (similar to detective).
			ply:SetNWBool("IsDetectiveBeacon", true)
			SendPlayerToEveryone(ply)
		end
	end
	
	local function BuffABeacon(ply, provider_id)
		if not IsValid(ply) or not ply:IsPlayer() then
			return
		end
		
		--Beacon can only have so many buffs
		if ply:GetNWInt("NumBeaconBuffs") >= GetConVar("ttt2_beacon_max_buffs"):GetInt() then
			return
		end
		
		--Beacon can't be their own provider
		if ply:SteamID64() == provider_id then
			return
		end
		
		--Only buff the given beacon if they have not already been buffed by the provider.
		if not ply:GetNWBool("HasProvidedBeaconBuff_" .. provider_id) then
			--UNCOMMENT FOR DEBUGGING
			--PrintBeaconStats("BEAC_DEBUG UpdateBeaconStats Before: ", ply)
			
			--Increment even if the player isn't a beacon, in case they become one (ex. amnesiac).
			ply:SetNWInt("NumBeaconBuffs", ply:GetNWInt("NumBeaconBuffs") + 1)
			
			if ply:GetSubRole() == ROLE_BEACON then
				UpdateBeaconStats(ply, 1)
			end
			
			--Ensure that duplicate buffs aren't given.
			ply:SetNWBool("HasProvidedBeaconBuff_" .. provider_id, true)
			
			--UNCOMMENT FOR DEBUGGING
			--PrintBeaconStats("BEAC_DEBUG UpdateBeaconStats After: ", ply)
		end
	end
	
	local function BuffAllBeacons(provider_id)
		for _,ply in pairs(player.GetAll()) do
			BuffABeacon(ply, provider_id)
		end
	end
	
	local function DebuffABeacon(ply)
		--When this is called the player may not necessarily be a beacon (ex. on a role change), so don't check for that.
		
		--UNCOMMENT FOR DEBUGGING
		--PrintBeaconStats("BEAC_DEBUG DebuffABeacon Before: ", ply)
		
		local n = ply:GetNWInt("NumBeaconBuffs")
		
		--Speed is handled in TTTPlayerSpeedModifier handle.
		--Damage is handled in EntityTakeDamage handle.
		ply:SetJumpPower(ply:GetJumpPower() - n * (default_jump_power * GetConVar("ttt2_beacon_jump_boost"):GetFloat()))
		ply:RemoveArmor(n * GetConVar("ttt2_beacon_armor_boost"):GetInt())
		
		if ply:HasEquipmentItem("item_ttt_nofalldmg") then
			ply:RemoveEquipmentItem("item_ttt_nofalldmg")
		end
		
		--Do not alter NumBeaconBuffs here, in case they become a beacon later on (ex. admin ulx)
		
		ply:SetNWBool("IsDetectiveBeacon", false)
		
		ply:SetNWBool("HadBeaconBuffsRemoved", true)
		
		--UNCOMMENT FOR DEBUGGING
		--PrintBeaconStats("BEAC_DEBUG DebuffABeacon After: ", ply)
	end
	
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		--Prevents edge case where murderous amnesiac is quickly given beacon buffs before becoming innocent
		if not ply:GetNWBool("HasKilledAnInnocent") then
			--UNCOMMENT FOR DEBUGGING
			--print("BEAC_DEBUG GiveRoleLoadout")
			
			UpdateBeaconStats(ply, ply:GetNWInt("NumBeaconBuffs"))
			
			--Allow for the beacon to lose their stats again.
			ply:SetNWBool("HadBeaconBuffsRemoved", false)
		end
	end

	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		--Sometimes RemoveRoleLoadout is called multiple times in a row, so here's a workaround.
		if not ply:GetNWBool("HadBeaconBuffsRemoved") then
			--UNCOMMENT FOR DEBUGGING
			--print("BEAC_DEBUG RemoveRoleLoadout")
			
			DebuffABeacon(ply)
		end
	end
	
	hook.Add("TTTPlayerSpeedModifier", "BeaconModifySpeed", function(ply, _, _, no_lag)
		if IsValid(ply) and ply:IsPlayer() and ply:GetSubRole() == ROLE_BEACON then
			no_lag[1] = no_lag[1] * (1 + ply:GetNWInt("NumBeaconBuffs") * GetConVar("ttt2_beacon_speed_boost"):GetFloat())
		end
	end)
	
	hook.Add("EntityTakeDamage", "BeaconModifyDamage", function(target, dmg_info)
		local attacker = dmg_info:GetAttacker()
		
		if not IsValid(target) or not target:IsPlayer() or not IsValid(attacker) or not attacker:IsPlayer() then
			return
		end
		
		if attacker:GetSubRole() == ROLE_BEACON then
			dmg_info:SetDamage(dmg_info:GetDamage() * (1 + attacker:GetNWInt("NumBeaconBuffs") * GetConVar("ttt2_beacon_damage_boost"):GetFloat()))
		end
	end)
	
	hook.Add("TTT2PostPlayerDeath", "JudgeTheBeacon", function(victim, inflictor, attacker)
		if not IsValid(victim) or not victim:IsPlayer() or not IsValid(attacker) or not attacker:IsPlayer() then
			return
		end
		
		--It is ok for the beacon to murder the guilty
		if not victim:HasTeam(TEAM_INNOCENT) then
			return
		end
		
		--It is ok if the beacon suicides (especially since it was likely an accident)
		if victim:SteamID64() == attacker:SteamID64() then
			return
		end
		
		--UNCOMMENT FOR DEBUGGING
		--print("BEAC_DEBUG BeaconUpdateOnDeath: Preventing inno-killer from being beacon.")
		
		--Prevent any role (ex. amnesiac) from becoming a beacon if they kill an innocent.
		attacker:SetNWBool("HasKilledAnInnocent", true)
		
		if attacker:GetSubRole() == ROLE_BEACON then
			--Demote the guilty one.
			--Indirectly calls DebuffABeacon()
			attacker:SetRole(ROLE_INNOCENT)
			--Call this whenever a role change occurs during an active round
			SendFullStateUpdate()
			attacker:TakeDamage(GetConVar("ttt2_beacon_judgement"):GetInt(), game.GetWorld())
		else
			--A non-beacon who kills an inno may not receive nor lose beacon buffs.
			--In a sense, their privilege of obtaining beacon buffs is now removed.
			attacker:SetNWBool("HadBeaconBuffsRemoved", true)
		end
	end)
	
	hook.Add("TTTCanSearchCorpse", "BeaconUpdateOnCorpseSearch", function(ply, rag, isCovert, isLongRange)
		local dead_ply = player.GetBySteamID64(rag.sid64)
		
		if not IsValid(dead_ply) or not IsValid(ply) then
			return
		end
		
		--Don't do anything if the round hasn't started yet.
		if GetRoundState() ~= ROUND_ACTIVE then
			return
		end
		
		--Don't do anything if the player searching the corpse isn't actively participating
		if not ply:Alive() then
			return
		end
		
		--Buff all beacons the first time that an innocent player's corpse is searched.
		if dead_ply:GetTeam() == TEAM_INNOCENT or GetConVar("ttt2_beacon_buff_on_all_searches"):GetBool() then
			--UNCOMMENT FOR DEBUGGING
			--print("BEAC_DEBUG BeaconUpdateOnCorpseSearch: isCovert=", isCovert, ", ID=", dead_ply:SteamID64())
			
			if isCovert then
				--Only update the player that's covertly searching the body.
				BuffABeacon(ply, dead_ply:SteamID64())
			else
				BuffAllBeacons(dead_ply:SteamID64())
			end
		end
	end)
	
	hook.Add("TTT2UpdateSubrole", "BeaconBackgroundCheck", function(self, oldSubrole, subrole)
		if oldSubrole ~= ROLE_BEACON and subrole == ROLE_BEACON then
			--Looks like someone thinks they can be a beacon.
			if self:GetNWBool("HasKilledAnInnocent") then
				--UNCOMMENT FOR DEBUGGING
				--print("BEAC_DEBUG BeaconBackgroundCheck: Refusing to change role to Beacon")
				
				--RDM-ers and bad men not allowed.
				self:SetRole(ROLE_INNOCENT)
				--Call this whenever a role change occurs during an active round
				SendFullStateUpdate()
			end
		end
	end)
	
	hook.Add("TTT2SpecialRoleSyncing", "BeaconRoleSync", function(ply, tbl)
		--This hook is needed to maintain a beacon's "glow" if they respawn or briefly change roles.
		for ply_i in pairs(tbl) do
			if ply_i:IsTerror() and ply_i:Alive() and ply_i:GetSubRole() == ROLE_BEACON and ply:GetNWBool("IsDetectiveBeacon") then
				tbl[ply_i] = {ROLE_BEACON, TEAM_INNOCENT}
				
				--Resend this player's role info to everyone, as it is resets when a role change occurs.
				SendPlayerToEveryone(ply)
			end
		end
	end)
	
	--TESTS:
	--beacon is buffed if they search a dead inno publicly.
	--beacon is buffed if someone else searches a dead inno publicly.
	--beacon is buffed if they search a dead inno covertly.
	--beacon is not buffed if someone else searches a dead inno covertly.
	--beacon is buffed if they search a wrath before the wrath revives as a traitor.
	--beacon does not receive multiple buffs if they search a dead inno multiple times.
	--beacon does not receive multiple buffs from an inno who is revived/respawned multiple times.
	--
	--beacon only receives no fall damage item when their jump power > default jump power.
	--
	--multiple beacons in play benefit from public searches of innos.
	--amnesiac who becomes a beacon in the middle of the round receives public beacon buffs.
	--unknown who becomes a beacon in the middle of the round receives public beacon buffs.
	--switching the beacon's role via admin between a different role and beacon maintains the correct buffs (beacon should have same buffs, non-beacon should have no buffs).
	--
	--beacon becomes an inno and loses 20HP if they kill an inno.
	--former beacon is reset at the start of the next round.
	--beacon who commits suicide remains a beacon.
	--beacon who kills themselves via judgement appears as an innocent when searched.
	--amnesiac who kills the beacon and investigates them becomes an innocent.
	--unknown who kills an innocent and then is killed by a beacon becomes an innocent instead.
	--beacon who becomes sidekick via jackal's sidekick deagle loses all of their buffs.
	--
	--beacon receives min_buffs at round start if min_buffs > 0
	--beacon cannot receive more than max_buffs if they search more than max_buffs dead innos bodies
	--If all_searches is disabled, then beacon does not receive buffs on searching traitor/3rd party roles.
	--If all_searches is enabled, then beacon receives buffs on searching traitor/3rd party roles
	--
	--beacon with at least one buff is killed and then quickly revived. They retain their one buff on revival.
	--?beacon with no buffs is killed, and then a different inno role is confirmed dead, and then the beacon is revived. This beacon will respawn with one buff.
	--
	--beacon gains a "glow" when a certain number of dead innos are confirmed.
	--beacon's "glow" is removed if they die.
	--beacon's "glow" is removed if they change roles.
	--beacon's "glow" is returned if they respawn
	--becaon's "glow" is returned if they change to a non-beacon role and back into a beacon.
end

if CLIENT then
	--Modified from Pharoah's Ankh.
	function BeaconDynamicLight(ply, color, brightness)
		-- make sure initial values are set
		if not ply.beac_light_next_state then
			ply.beac_light_next_state = CurTime()
		end

		--Create dynamic light
		local dlight = DynamicLight(ply:EntIndex())
		dlight.r = color.r
		dlight.g = color.g
		dlight.b = color.b
		dlight.brightness = brightness
		dlight.Decay = 1000
		dlight.Size = 200
		dlight.DieTime = CurTime() + 0.1
		dlight.Pos = ply:GetPos() + Vector(0, 0, 35)
	end
	
	hook.Add("Think", "BeaconLightUp", function()
		for _,ply in pairs(player.GetAll()) do
			if IsValid(ply) and ply:IsPlayer() and ply:GetNWBool("IsDetectiveBeacon") then
				BeaconDynamicLight(ply, BEACON.color, 1)
			end
		end
	end)
end