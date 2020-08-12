--ConVar syncing
CreateConVar("ttt2_beacon_min_buffs", "0", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_beacon_max_buffs", "5", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_beacon_deputize_num_buffs", "3", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_beacon_search_mode", "0", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_beacon_judgement", "20", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_beacon_speed_boost", "0.20", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_beacon_jump_boost", "0.20", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_beacon_resist_boost", "0.15", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_beacon_armor_boost", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_beacon_hp_regen_boost", "0.2", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_beacon_damage_boost", "0.15", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicBeaconCVars", function(tbl)
	tbl[ROLE_BEACON] = tbl[ROLE_BEACON] or {}
	
	--"The number of buffs that the beacon starts with (Def: 0)"
	table.insert(tbl[ROLE_BEACON], {
		cvar = "ttt2_beacon_min_buffs",
		slider = true,
		min = 0,
		max = 10,
		decimal = 0,
		desc = "ttt2_beacon_min_buffs (Def: 0)"
	})
	--"The maximum number of buffs that the beacon can achieve (Def: 5)"
	table.insert(tbl[ROLE_BEACON], {
		cvar = "ttt2_beacon_max_buffs",
		slider = true,
		min = 0,
		max = 10,
		decimal = 0,
		desc = "ttt2_beacon_max_buffs (Def: 5)"
	})
	--"Upon receiving this many buffs, the beacon lights up, revealing their role (like a detective) (Def: 3)"
	table.insert(tbl[ROLE_BEACON], {
		cvar = "ttt2_beacon_deputize_num_buffs",
		slider = true,
		min = 0,
		max = 11,
		decimal = 0,
		desc = "ttt2_beacon_deputize_num_buffs (Def: 3)"
	})
	--"Beacon gains buff when these players are confirmed dead: {0: team mates, 1: non team mates, 2: anyone} (Def: 0)"
	table.insert(tbl[ROLE_BEACON], {
		cvar = "ttt2_beacon_search_mode",
		combobox = true,
		desc = "ttt2_beacon_search_mode (Def: 0)",
		choices = {
			"0 - Buff on confirmed team mate death",
			"1 - Buff on confirmed non team mate death",
			"2 - Buff on all confirmed deaths"
		},
		numStart = 0
	})
	--"The damage the beacon receives if they kill one of their mates (Def: 20)"
	table.insert(tbl[ROLE_BEACON], {
		cvar = "ttt2_beacon_judgement",
		slider = true,
		min = 0,
		max = 100,
		decimal = 0,
		desc = "ttt2_beacon_judgement (Def: 20)"
	})
	--"The speed boost the beacon gets per buff (Def: 0.20)"
	table.insert(tbl[ROLE_BEACON], {
		cvar = "ttt2_beacon_speed_boost",
		slider = true,
		min = 0.0,
		max = 3.5,
		decimal = 2,
		desc = "ttt2_beacon_speed_boost (Def: 0.20)"
	})
	--"The jump height boost the beacon gets per buff (Def: 0.20)"
	table.insert(tbl[ROLE_BEACON], {
		cvar = "ttt2_beacon_jump_boost",
		slider = true,
		min = 0.0,
		max = 3.5,
		decimal = 2,
		desc = "ttt2_beacon_jump_boost (Def: 0.20)"
	})
	--"The flat damage resistance boost the beacon gets per buff (Def: 0.15)"
	table.insert(tbl[ROLE_BEACON], {
		cvar = "ttt2_beacon_resist_boost",
		slider = true,
		min = 0.0,
		max = 0.9,
		decimal = 2,
		desc = "ttt2_beacon_resist_boost (Def: 0.15)"
	})
	--"The armor boost the beacon gets per buff (Def: 20)"
	table.insert(tbl[ROLE_BEACON], {
		cvar = "ttt2_beacon_armor_boost",
		slider = true,
		min = 0,
		max = 100,
		decimal = 0,
		desc = "ttt2_beacon_armor_boost (Def: 20)"
	})
	--"The health regen per second the beacon gets per buff (Def: 0.2)"
	table.insert(tbl[ROLE_BEACON], {
		cvar = "ttt2_beacon_hp_regen_boost",
		slider = true,
		min = 0.0,
		max = 5.0,
		decimal = 2,
		desc = "ttt2_beacon_hp_regen_boost (Def: 0.2)"
	})
	--"The damage boost the beacon gets per buff (Def: 0.15)"
	table.insert(tbl[ROLE_BEACON], {
		cvar = "ttt2_beacon_damage_boost",
		slider = true,
		min = 0.0,
		max = 3.5,
		decimal = 2,
		desc = "ttt2_beacon_damage_boost (Def: 0.15)"
	})
end)

hook.Add("TTT2SyncGlobals", "AddBeaconGlobals", function()
	SetGlobalInt("ttt2_beacon_min_buffs", GetConVar("ttt2_beacon_min_buffs"):GetInt())
	SetGlobalInt("ttt2_beacon_max_buffs", GetConVar("ttt2_beacon_max_buffs"):GetInt())
	SetGlobalInt("ttt2_beacon_deputize_num_buffs", GetConVar("ttt2_beacon_deputize_num_buffs"):GetInt())
	SetGlobalInt("ttt2_beacon_search_mode", GetConVar("ttt2_beacon_search_mode"):GetInt())
	SetGlobalInt("ttt2_beacon_judgement", GetConVar("ttt2_beacon_judgement"):GetInt())
	SetGlobalFloat("ttt2_beacon_speed_boost", GetConVar("ttt2_beacon_speed_boost"):GetFloat())
	SetGlobalFloat("ttt2_beacon_jump_boost", GetConVar("ttt2_beacon_jump_boost"):GetFloat())
	SetGlobalFloat("ttt2_beacon_resist_boost", GetConVar("ttt2_beacon_resist_boost"):GetFloat())
	SetGlobalInt("ttt2_beacon_armor_boost", GetConVar("ttt2_beacon_armor_boost"):GetInt())
	SetGlobalFloat("ttt2_beacon_hp_regen_boost", GetConVar("ttt2_beacon_hp_regen_boost"):GetFloat())
	SetGlobalFloat("ttt2_beacon_damage_boost", GetConVar("ttt2_beacon_damage_boost"):GetFloat())
end)

cvars.AddChangeCallback("ttt2_beacon_min_buffs", function(name, old, new)
	SetGlobalInt("ttt2_beacon_min_buffs", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_beacon_max_buffs", function(name, old, new)
	SetGlobalInt("ttt2_beacon_max_buffs", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_beacon_deputize_num_buffs", function(name, old, new)
	SetGlobalInt("ttt2_beacon_deputize_num_buffs", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_beacon_search_mode", function(name, old, new)
	SetGlobalInt("ttt2_beacon_search_mode", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_beacon_judgement", function(name, old, new)
	SetGlobalInt("ttt2_beacon_judgement", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_beacon_speed_boost", function(name, old, new)
	SetGlobalFloat("ttt2_beacon_speed_boost", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_beacon_jump_boost", function(name, old, new)
	SetGlobalFloat("ttt2_beacon_jump_boost", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_beacon_resist_boost", function(name, old, new)
	SetGlobalFloat("ttt2_beacon_resist_boost", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_beacon_armor_boost", function(name, old, new)
	SetGlobalInt("ttt2_beacon_armor_boost", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_beacon_hp_regen_boost", function(name, old, new)
	SetGlobalFloat("ttt2_beacon_hp_regen_boost", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_beacon_damage_boost", function(name, old, new)
	SetGlobalFloat("ttt2_beacon_damage_boost", tonumber(new))
end)
