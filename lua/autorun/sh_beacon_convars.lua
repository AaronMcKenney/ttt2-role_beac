--ConVar syncing
CreateConVar("ttt2_beacon_min_buffs", "0", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_beacon_max_buffs", "5", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_beacon_buff_on_all_searches", "0", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_beacon_judgement", "20", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_beacon_speed_boost", "0.20", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_beacon_jump_boost", "0.20", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_beacon_armor_boost", "10", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_beacon_damage_boost", "0.15", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

hook.Add("TTTUlxDynamicRCVars", "ttt2_ulx_dynamic_beacon_convars", function(tbl)
	tbl[ROLE_BEACON] = tbl[ROLE_BEACON] or {}
	
	--"The number of buffs that the beacon starts with (Def: 0)"
	table.insert(tbl[ROLE_BEACON], {cvar = "ttt2_beacon_min_buffs", slider = true, min = 0, max = 10, decimal = 0, desc = "ttt2_beacon_min_buffs (Def: 0)"})
	--"The maximum number of buffs that the beacon can achieve (Def: 5)"
	table.insert(tbl[ROLE_BEACON], {cvar = "ttt2_beacon_max_buffs", slider = true, min = 0, max = 10, decimal = 0, desc = "ttt2_beacon_max_buffs (Def: 5)"})
	--"If true, provide a buff to the beacon on ANY body search (Def: 0)"
	table.insert(tbl[ROLE_BEACON], {cvar = "ttt2_beacon_buff_on_all_searches", checkbox = true, desc = "ttt2_beacon_buff_on_all_searches (Def: 0)"})
	--"The damage the beacon receives if they kill one of their mates (Def: 20)"
	table.insert(tbl[ROLE_BEACON], {cvar = "ttt2_beacon_judgement", slider = true, min = 0, max = 100, decimal = 0, desc = "ttt2_beacon_judgement (Def: 20)"})
	--"The speed boost the beacon gets per buff (Def: 0.20)"
	table.insert(tbl[ROLE_BEACON], {cvar = "ttt2_beacon_speed_boost", slider = true, min = 0.0, max = 3.5, decimal = 2, desc = "ttt2_beacon_speed_boost (Def: 0.20)"})
	--"The jump height boost the beacon gets per buff (Def: 0.20)"
	table.insert(tbl[ROLE_BEACON], {cvar = "ttt2_beacon_jump_boost", slider = true, min = 0.0, max = 3.5, decimal = 2, desc = "ttt2_beacon_jump_boost (Def: 0.20)"})
	--"The armor boost the beacon gets per buff (Def: 10)"
	table.insert(tbl[ROLE_BEACON], {cvar = "ttt2_beacon_armor_boost", slider = true, min = 0, max = 100, decimal = 0, desc = "ttt2_beacon_armor_boost (Def: 10)"})
	--"The damage boost the beacon gets per buff (Def: 0.15)"
	table.insert(tbl[ROLE_BEACON], {cvar = "ttt2_beacon_damage_boost", slider = true, min = 0.0, max = 3.5, decimal = 2, desc = "ttt2_beacon_damage_boost (Def: 0.15)"})
end)

hook.Add("TTT2SyncGlobals", "AddBeaconGlobals", function()
	SetGlobalInt("ttt2_beacon_min_buffs", GetConVar("ttt2_beacon_min_buffs"):GetInt())
	SetGlobalInt("ttt2_beacon_max_buffs", GetConVar("ttt2_beacon_max_buffs"):GetInt())
	SetGlobalBool("ttt2_beacon_buff_on_all_searches", GetConVar("ttt2_beacon_buff_on_all_searches"):GetBool())
	SetGlobalInt("ttt2_beacon_judgement", GetConVar("ttt2_beacon_judgement"):GetInt())
	SetGlobalFloat("ttt2_beacon_speed_boost", GetConVar("ttt2_beacon_speed_boost"):GetFloat())
	SetGlobalFloat("ttt2_beacon_jump_boost", GetConVar("ttt2_beacon_jump_boost"):GetFloat())
	SetGlobalInt("ttt2_beacon_armor_boost", GetConVar("ttt2_beacon_armor_boost"):GetInt())
	SetGlobalFloat("ttt2_beacon_damage_boost", GetConVar("ttt2_beacon_damage_boost"):GetFloat())
end)

cvars.AddChangeCallback("ttt2_beacon_min_buffs", function(name, old, new)
	SetGlobalInt("ttt2_beacon_min_buffs", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_beacon_max_buffs", function(name, old, new)
	SetGlobalInt("ttt2_beacon_max_buffs", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_beacon_buff_on_all_searches", function(name, old, new)
	SetGlobalBool("ttt2_beacon_buff_on_all_searches", tobool(tonumber(new)))
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
cvars.AddChangeCallback("ttt2_beacon_armor_boost", function(name, old, new)
	SetGlobalInt("ttt2_beacon_armor_boost", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_beacon_damage_boost", function(name, old, new)
	SetGlobalFloat("ttt2_beacon_damage_boost", tonumber(new))
end)