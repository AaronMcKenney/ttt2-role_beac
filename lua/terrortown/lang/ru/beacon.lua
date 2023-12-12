local L = LANG.GetLanguageTableReference("ru")

-- GENERAL ROLE LANGUAGE STRINGS
L[BEACON.name] = "Маяк"
L["info_popup_" .. BEACON.name] = [[Вы маяк! Маяк - это невиновный, который со временем может стать сильнее.

Убив невиновного, вы потеряете свою роль.]]
L["body_found_" .. BEACON.abbr] = "Он был маяком."
L["search_role_" .. BEACON.abbr] = "Этот человек был маяком!"
L["target_" .. BEACON.name] = "Маяк"
L["ttt2_desc_" .. BEACON.name] = [[Вы маяк! Маяк - это невиновный, который со временем может стать сильнее.

Убив невиновного, вы потеряете свою роль.]]

-- OTHER ROLE LANGUAGE STRINGS
L["buffs_received_" .. BEACON.name] = "Получено усилений: "
L["max_power_" .. BEACON.name] = " (МАКС. МОЩЬ!)"

-- CONVAR STRINGS
--L["label_beacon_min_buffs"] = "# buffs the Beacon starts with"
--L["label_beacon_max_buffs"] = "Max # buffs the Beacon can achieve"
--L["label_beacon_deputize_num_buffs"] = "Beacon is revealed upon reaching this # of buffs"
--L["label_beacon_search_mode"] = "Beacon gains buffs on death confirmation of:"
--L["label_beacon_search_mode_0"] = "0: teammates"
--L["label_beacon_search_mode_1"] = "1: non-teammates"
--L["label_beacon_search_mode_2"] = "2: Everyone"
--L["label_beacon_search_mode_3"] = "3: No one"
--L["label_beacon_buff_on_death"] = "Give Beacon buffs without confirming deaths"
--L["label_beacon_buff_every_x_seconds"] = "Beacon receives a buff every x seconds (disabled if 0)"
--L["label_beacon_judgement"] = "Damage the Beacon receives if they kill their own teammates"
--L["label_beacon_demotion_enable"] = "Demote Beacon to Innocent if they kill an Innocent"
--L["label_beacon_buff_requires_in_person"] = "Beacon must personally confirm death to receive buff"
--L["label_beacon_speed_boost"] = "Speed boost per buff"
--L["label_beacon_stamina_boost"] = "Stamina boost per buff"
--L["label_beacon_stamina_regen_boost"] = "Stamina regeneration boost per buff"
--L["label_beacon_jump_boost"] = "Jump boost per buff"
--L["label_beacon_resist_boost"] = "Flat damage resistance boost per buff"
--L["label_beacon_armor_boost"] = "Armor received for each buff"
--L["label_beacon_hp_regen_boost"] = "HP Regeneration boost per each buff"
--L["label_beacon_damage_boost"] = "Damage boost per buff"
--L["label_beacon_fire_rate_boost"] = "Fire rate boost per buff"
