AddCSLuaFile()

if SERVER then
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_beac.vmt")
	util.AddNetworkString("TTT2UpdateNumBeaconBuffs")
	util.AddNetworkString("TTT2BeaconRateOfFireUpdate")
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
	--CONSTANTS
	--Hardcoded default that everyone uses.
	local DEFAULT_JUMP_POWER = 160
	--ttt2_beacon_search_mode enum
	local SEARCH_MODE = {MATES = 0, OTHER = 1, ANY = 2}
	--enum for how the beacon's stats will be updated.
	local UPDATE_MODE = {ONE = 0, ALL = 1}
	
	local function ResetBeacon()
		for i, ply_i in ipairs(player.GetAll()) do
			--Initialize player data that only the server must know about
			ply_i.beac_sv_data = {}
			ply_i.beac_sv_data.had_buffs_removed = false
			ply_i.beac_sv_data.has_killed_inno = false
			ply_i.beac_sv_data.last_healed = 0
			ply_i.beac_sv_data.hp_bank = 0
			ply_i.beac_sv_data.buff_providers = {}
			ply_i.beac_sv_data.num_buffs = 0
			
			--Initialize player data that anyone can pick up from the server at any time.
			ply_i:SetNWBool("IsDetectiveBeacon", false)
		end
	end
	--Do not reset beacon on TTTEndRound, because that will set num_buffs to 0 before RemoveRoleLoadout() is called.
	hook.Add("TTTPrepareRound", "ResetBeacon", ResetBeacon)
	hook.Add("TTTBeginRound", "ResetBeacon", ResetBeacon)
	
	local function RoundHasNotBegun()
		--Don't do anything if the round hasn't started yet (beac_sv_data may not exist)
		return (GetRoundState() == ROUND_WAIT or GetRoundState() == ROUND_PREP)
	end
	
	local function GetObservedTeam(ply)
		local team = ply:GetTeam()
		
		--Role-specific edge cases: Certain roles may actively lie about what their role actually is.
		--However, this is only truly reflected after the info on the corpse has been compiled and sent.
		if ply:GetSubRole() == ROLE_SPY and GetConVar("ttt2_spy_confirm_as_traitor"):GetBool() then
			team = TEAM_TRAITOR
		end
		
		return team
	end
	
	--UNCOMMENT FOR DEBUGGING
	--local function PrintBeaconStats(prefix_str, ply)
	--	local n = ply.beac_sv_data.num_buffs
	--	local speed = 1 + n * GetConVar("ttt2_beacon_speed_boost"):GetFloat()
	--	local resist = n * GetConVar("ttt2_beacon_resist_boost"):GetFloat()
	--  local hp_regen = n * GetConVar("ttt2_beacon_hp_regen_boost"):GetFloat()
	--	local dmg = 1 + n * GetConVar("ttt2_beacon_damage_boost"):GetFloat()
	--  local fire_rate = 1 + n * GetConVar("ttt2_beacon_fire_rate_boost"):GetFloat()
	--	print(prefix_str, "name=", ply:GetName(), ", num_buffs=", n, ", speed=", speed, ", jump=", ply:GetJumpPower(), ", resist=", resist, ", armor=", ply:GetArmor(), ", hp_regen=", hp_regen, ", dmg=", dmg, ", fire_rate=", fire_rate)
	--end
	
	--WeaponSpeed functionality taken and modified from TTT2 Super Soda mod
	local function ApplyWeaponSpeedForBeacon(wep, n)
		local ply = wep.Owner
		if RoundHasNotBegun() or not IsValid(wep) or not IsValid(ply) then
			return
		end
		
		if (wep.Kind == WEAPON_MELEE or wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL) then
			if not wep.beac_modded then
				wep.beac_modded = true
			end
			
			--UNCOMMENT FOR DEBUGGING
			print("BEAC_DEBUG ApplyWeaponSpeedForBeacon Before: ", wep.Primary.Delay)
			
			wep.Primary.Delay = wep.Primary.Delay / (1 + n * GetConVar("ttt2_beacon_fire_rate_boost"):GetFloat())
			
			--UNCOMMENT FOR DEBUGGING
			print("BEAC_DEBUG ApplyWeaponSpeedForBeacon After: ", wep.Primary.Delay)

			net.Start("TTT2BeaconRateOfFireUpdate")
			net.WriteEntity(wep)
			net.WriteFloat(wep.Primary.Delay)
			net.Send(ply)
		end
	end
	
	local function DisableWeaponSpeedForBeacon(ply, wep, n)
		if not IsValid(wep) or not IsValid(ply) then
			return
		end
		
		--Only remove speed if the weapon was tinkered with by the beacon.
		--Prevents issue where the weapon may otherwise get stats removed multiple times on player death (Due to Drop and Switch being called).
		if wep.beac_modded and (wep.Kind == WEAPON_MELEE or wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL) then
			--UNCOMMENT FOR DEBUGGING
			print("BEAC_DEBUG DisableWeaponSpeedForBeacon Before: ", wep.Primary.Delay)
			
			wep.Primary.Delay = wep.Primary.Delay * (1 + n * GetConVar("ttt2_beacon_fire_rate_boost"):GetFloat())
			
			--UNCOMMENT FOR DEBUGGING
			print("BEAC_DEBUG DisableWeaponSpeedForBeacon After: ", wep.Primary.Delay)
			
			net.Start("TTT2BeaconRateOfFireUpdate")
			net.WriteEntity(wep)
			net.WriteFloat(wep.Primary.Delay)
			net.Send(ply)
			
			wep.beac_modded = nil
		end
	end
	
	hook.Add("PlayerSwitchWeapon", "UpdateWeaponOnSwitchForBeacon", function(ply, old, new)
		if RoundHasNotBegun() or not IsValid(old) or not IsValid(new) or not IsValid(ply) or ply:GetSubRole() ~= ROLE_BEACON then
			return
		end
		
		--UNCOMMENT FOR DEBUGGING
		print("BEAC_DEBUG UpdateWeaponOnSwitchForBeacon")
		
		DisableWeaponSpeedForBeacon(ply, old, ply.beac_sv_data.num_buffs)
		ApplyWeaponSpeedForBeacon(new, ply.beac_sv_data.num_buffs)
	end)
	
	hook.Add("PlayerDroppedWeapon", "UpdateWeaponOnDropForBeacon", function(ply, wep)
		if RoundHasNotBegun() or not IsValid(wep) or not IsValid(ply) or ply:GetSubRole() ~= ROLE_BEACON then
			return
		end
		
		--UNCOMMENT FOR DEBUGGING
		print("BEAC_DEBUG UpdateWeaponOnDropForBeacon")

		DisableWeaponSpeedForBeacon(ply, wep, ply.beac_sv_data.num_buffs)
	end)
	
	local function UpdateBeaconStats(ply, update_mode)
		--Speed is handled in TTTPlayerSpeedModifier handle.
		--Damage and Resistance is handled in EntityTakeDamage handle.
		--Health Regen is handled in Think handle.
		
		local n = 1
		if update_mode == UPDATE_MODE.ALL then
			n = ply.beac_sv_data.num_buffs
			
			ApplyWeaponSpeedForBeacon(ply:GetActiveWeapon(), n)
		else
			if ply.beac_sv_data.num_buffs > 0 then
				--This probably isn't the best method, but currently in order for the numbers to line up properly, need to remove the previous rate of fire buff and replace it with the new one.
				--Specifically this is done to avoid quirks with division and multiplication. Would be easier if subtraction and addition could be used here.
				DisableWeaponSpeedForBeacon(ply, ply:GetActiveWeapon(), ply.beac_sv_data.num_buffs - 1)
				ApplyWeaponSpeedForBeacon(ply:GetActiveWeapon(), ply.beac_sv_data.num_buffs)
			else
				--First time we're buffing the beacon, just give them the one buff.
				ApplyWeaponSpeedForBeacon(ply:GetActiveWeapon(), 1)
			end
		end
		
		ply:SetJumpPower(ply:GetJumpPower() + n * (DEFAULT_JUMP_POWER * GetConVar("ttt2_beacon_jump_boost"):GetFloat()))
		ply:GiveArmor(n * GetConVar("ttt2_beacon_armor_boost"):GetInt())
		
		--Only give no fall damage if beacon runs risk of hurting themselves merely from jumping
		if ply:GetJumpPower() > DEFAULT_JUMP_POWER and not ply:HasEquipmentItem("item_ttt_nofalldmg") then
			ply:GiveEquipmentItem("item_ttt_nofalldmg")
		end
		
		if ply.beac_sv_data.num_buffs >= GetConVar("ttt2_beacon_deputize_num_buffs"):GetInt() then
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
		if ply.beac_sv_data.num_buffs >= GetConVar("ttt2_beacon_max_buffs"):GetInt() then
			return
		end
		
		--Beacon can't be their own provider
		if ply:SteamID64() == provider_id then
			return
		end
		
		--Only buff the given beacon if they have not already been buffed by the provider.
		if ply.beac_sv_data.buff_providers[provider_id] == nil then
			--UNCOMMENT FOR DEBUGGING
			--PrintBeaconStats("BEAC_DEBUG UpdateBeaconStats Before: ", ply)
			
			--Increment even if the player isn't a beacon, in case they become one (ex. amnesiac).
			ply.beac_sv_data.num_buffs = ply.beac_sv_data.num_buffs + 1
			
			--Send the updated number of buffs to the client
			net.Start("TTT2UpdateNumBeaconBuffs")
			net.WriteInt(ply.beac_sv_data.num_buffs, 16)
			net.Send(ply)
			
			--Don't directly modify the stats of dead beacons or non-beacons.
			if ply:Alive() and ply:GetSubRole() == ROLE_BEACON then
				UpdateBeaconStats(ply, UPDATE_MODE.ONE)
			end
			
			--Ensure that duplicate buffs aren't given.
			ply.beac_sv_data.buff_providers[provider_id] = true
			
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
		
		local n = ply.beac_sv_data.num_buffs
		
		--Speed is handled in TTTPlayerSpeedModifier handle.
		--Damage and Resistance is handled in EntityTakeDamage handle.
		--Health Regeneration is handled in Think handle.
		ply:SetJumpPower(ply:GetJumpPower() - n * (DEFAULT_JUMP_POWER * GetConVar("ttt2_beacon_jump_boost"):GetFloat()))
		ply:RemoveArmor(n * GetConVar("ttt2_beacon_armor_boost"):GetInt())
		DisableWeaponSpeedForBeacon(ply, ply:GetActiveWeapon(), n)
		
		if ply:HasEquipmentItem("item_ttt_nofalldmg") then
			ply:RemoveEquipmentItem("item_ttt_nofalldmg")
		end
		
		--Do not alter num_buffs here, in case they become a beacon later on (ex. admin ulx)
		
		ply:SetNWBool("IsDetectiveBeacon", false)
		
		ply.beac_sv_data.had_buffs_removed = true
		
		--UNCOMMENT FOR DEBUGGING
		--PrintBeaconStats("BEAC_DEBUG DebuffABeacon After: ", ply)
	end
	
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		if RoundHasNotBegun() then
			return
		end
		
		--Prevents edge case where murderous amnesiac is quickly given beacon buffs before becoming innocent
		if not ply.beac_sv_data.has_killed_inno then
			--UNCOMMENT FOR DEBUGGING
			--print("BEAC_DEBUG GiveRoleLoadout")
			
			UpdateBeaconStats(ply, UPDATE_MODE.ALL)
			
			--Allow for the beacon to lose their stats again.
			ply.beac_sv_data.had_buffs_removed = false
		end
	end

	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		if RoundHasNotBegun() then
			return
		end
		
		--Sometimes RemoveRoleLoadout is called multiple times in a row, so here's a workaround.
		if not ply.beac_sv_data.had_buffs_removed then
			--UNCOMMENT FOR DEBUGGING
			--print("BEAC_DEBUG RemoveRoleLoadout")
			
			DebuffABeacon(ply)
		end
	end
	
	hook.Add("TTTPlayerSpeedModifier", "BeaconModifySpeed", function(ply, _, _, no_lag)
		if RoundHasNotBegun() then
			return
		end
		
		if IsValid(ply) and ply:IsPlayer() and ply:GetSubRole() == ROLE_BEACON then
			no_lag[1] = no_lag[1] * (1 + ply.beac_sv_data.num_buffs * GetConVar("ttt2_beacon_speed_boost"):GetFloat())
		end
	end)
	
	hook.Add("EntityTakeDamage", "BeaconModifyDamage", function(target, dmg_info)
		if RoundHasNotBegun() then
			return
		end
		
		local attacker = dmg_info:GetAttacker()
		
		if not IsValid(target) or not target:IsPlayer() or not IsValid(attacker) or not attacker:IsPlayer() then
			return
		end
		
		--UNCOMMENT FOR DEBUGGING
		--if target:GetSubRole() == ROLE_BEACON or attacker:GetSubRole() == ROLE_BEACON then
		--	print("BEAC_DEBUG BeaconModifyDamage Target Name=" .. target:GetName() .. ", Attacker Name=" .. attacker:GetName())
		--	print("BEAC_DEBUG BeaconModifyDamage Before: " .. dmg_info:GetDamage())
		--end
		
		if target:GetSubRole() == ROLE_BEACON then
			dmg_info:SetDamage(dmg_info:GetDamage() * (1 - attacker.beac_sv_data.num_buffs * GetConVar("ttt2_beacon_resist_boost"):GetFloat()))
		end
		
		if attacker:GetSubRole() == ROLE_BEACON then
			dmg_info:SetDamage(dmg_info:GetDamage() * (1 + attacker.beac_sv_data.num_buffs * GetConVar("ttt2_beacon_damage_boost"):GetFloat()))
		end
		
		--UNCOMMENT FOR DEBUGGING
		--if target:GetSubRole() == ROLE_BEACON or attacker:GetSubRole() == ROLE_BEACON then
		--	print("BEAC_DEBUG BeaconModifyDamage After: " .. dmg_info:GetDamage())
		--end
	end)
	
	hook.Add("Think", "BeaconHealthRegen", function()
		if RoundHasNotBegun() then
			return
		end
		
		local cur_time = CurTime()
		for _, ply in ipairs(player.GetAll()) do
			local ply_is_valid_beac = (IsValid(ply) and ply:IsPlayer() and ply:Alive() and ply:GetSubRole() == ROLE_BEACON)
			local ply_can_be_healed = ((ply.beac_sv_data.last_healed) + 1 <= cur_time) and ply:Health() < ply:GetMaxHealth()
			local healing_enabled_for_ply = (ply.beac_sv_data.num_buffs * GetConVar("ttt2_beacon_hp_regen_boost"):GetFloat() > 0)
			if ply_is_valid_beac and ply_can_be_healed and healing_enabled_for_ply then
				ply.beac_sv_data.last_healed = cur_time
				ply.beac_sv_data.hp_bank = ply.beac_sv_data.hp_bank + ply.beac_sv_data.num_buffs * GetConVar("ttt2_beacon_hp_regen_boost"):GetFloat()
				
				--UNCOMMENT FOR DEBUGGING
				--print("BEAC_DEBUG BeaconHealthRegen: hp_bank=" .. ply.beac_sv_data.hp_bank)
				
				if ply.beac_sv_data.hp_bank >= 1 then
					--Since HP Regen ConVar is most likely a fraction, add it to a running total, and only heal when the total exceeds 1.
					local heal = math.floor(ply.beac_sv_data.hp_bank)
					ply:SetHealth(ply:Health() + heal)
					ply.beac_sv_data.hp_bank = ply.beac_sv_data.hp_bank - heal
				end
			end
		end
	end)
	
	hook.Add("TTT2PostPlayerDeath", "JudgeTheBeacon", function(victim, inflictor, attacker)
		if RoundHasNotBegun() then
			return
		end
		
		if not IsValid(victim) or not victim:IsPlayer() or not IsValid(attacker) or not attacker:IsPlayer() then
			return
		end
		
		--It is ok for the beacon to murder the guilty
		if GetObservedTeam(victim) ~= TEAM_INNOCENT then
			return
		end
		
		--It is ok if the beacon suicides (especially since it was likely an accident)
		if victim:SteamID64() == attacker:SteamID64() then
			return
		end
		
		--UNCOMMENT FOR DEBUGGING
		--print("BEAC_DEBUG BeaconUpdateOnDeath: Preventing inno-killer from being beacon.")
		
		--Prevent any role (ex. amnesiac) from becoming a beacon if they kill an innocent.
		attacker.beac_sv_data.has_killed_inno = true
		
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
			attacker.beac_sv_data.had_buffs_removed = true
		end
	end)
	
	hook.Add("TTTCanSearchCorpse", "BeaconUpdateOnCorpseSearch", function(ply, rag, isCovert, isLongRange)
		if RoundHasNotBegun() then
			return
		end
		
		local dead_ply = player.GetBySteamID64(rag.sid64)
		
		--Don't do anything if the player searching the corpse isn't actively participating
		if not IsValid(dead_ply) or not IsValid(ply) or not ply:Alive() then
			return
		end
		
		local team = GetObservedTeam(dead_ply)
		local do_buff = false
		if GetConVar("ttt2_beacon_search_mode"):GetInt() == SEARCH_MODE.MATES then
			do_buff = (team == TEAM_INNOCENT)
		elseif GetConVar("ttt2_beacon_search_mode"):GetInt() == SEARCH_MODE.OTHER then
			do_buff = (team ~= TEAM_INNOCENT)
		else --SEARCH_MODE.ANY
			do_buff = true
		end
		
		if do_buff then
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
		if RoundHasNotBegun() then
			return
		end
		
		if oldSubrole ~= ROLE_BEACON and subrole == ROLE_BEACON then
			--Looks like someone thinks they can be a beacon.
			if self.beac_sv_data.has_killed_inno then
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
		if ply:IsTerror() and ply:Alive() and ply:GetSubRole() == ROLE_BEACON and ply:GetNWBool("IsDetectiveBeacon") then
			--Resend this player's role info to everyone, as the info is lost when a role change occurs.
			SendPlayerToEveryone(ply)
		end
	end)
end

if CLIENT then
	local function ResetBeaconForClient()
		--Initialize data that this client needs to know, but must be kept secret from other clients.
		local client = LocalPlayer()
		client.beac_cl_data = {}
		client.beac_cl_data.num_buffs = 0
	end
	
	--Do not reset beacon on TTTEndRound, because that will set num_buffs to 0 before RemoveRoleLoadout() is called.
	hook.Add("TTTPrepareRound", "ResetBeacon", ResetBeaconForClient)
	hook.Add("TTTBeginRound", "ResetBeacon", ResetBeaconForClient)

	net.Receive("TTT2UpdateNumBeaconBuffs", function()
		local num_buffs = net.ReadInt(16)
		LocalPlayer().beac_cl_data.num_buffs = num_buffs
	end)

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
	
	net.Receive("TTT2BeaconRateOfFireUpdate", function()
		local wep = net.ReadEntity()
		wep.Primary.Delay = net.ReadFloat()
	end)
end