local L = LANG.GetLanguageTableReference("en")

-- GENERAL ROLE LANGUAGE STRINGS
L[BEACON.name] = "Beacon"
L["info_popup_" .. BEACON.name] = [[You are a Beacon! A beacon is an innocent who can become more powerful over time.

Killing an innocent will cause you to lose your role.]]
L["body_found_" .. BEACON.abbr] = "They were a Beacon."
L["search_role_" .. BEACON.abbr] = "This person was a Beacon!"
L["target_" .. BEACON.name] = "Beacon"
L["ttt2_desc_" .. BEACON.name] = [[You are a Beacon! A beacon is an innocent who can become more powerful over time.

Killing an innocent will cause you to lose your role.]]

-- OTHER ROLE LANGUAGE STRINGS
L["buffs_received_" .. BEACON.name] = "Buffs Received: "
L["max_power_" .. BEACON.name] = " (MAX POWER!)"
L["already_received_" .. BEACON.name] = "You have already received a buff from this body"

-- EVENT STRINGS
-- Need to be very specifically worded, due to how the system translates them.
L["title_event_beac_deputize"] = "A Beacon was deputized"
L["desc_event_beac_deputize"] = "{name} accrued {n} buffs and lit up!"
L["tooltip_beac_deputize_score"] = "Lit up: {score}"
L["beac_deputize_score"] = "Lit up:"
L["title_event_beac_judgement"] = "A Beacon killed a player on the Innocent Team"
L["desc_event_beac_judgement"] = "{name1} killed {name2} as a Beacon. They were dealt {x} damage."
L["tooltip_beac_judgement_score"] = "Beacon Judgement: {score}"
L["beac_judgement_score"] = "Beacon Judgement:"

-- CONVAR STRINGS
L["label_beacon_min_buffs"] = "# buffs the Beacon starts with"
L["label_beacon_max_buffs"] = "Max # buffs the Beacon can achieve"
L["label_beacon_deputize_num_buffs"] = "Beacon is revealed upon reaching this # of buffs"
L["label_beacon_search_mode"] = "Beacon gains buffs on death confirmation of:"
L["label_beacon_search_mode_0"] = "0: teammates"
L["label_beacon_search_mode_1"] = "1: non-teammates"
L["label_beacon_search_mode_2"] = "2: Everyone"
L["label_beacon_search_mode_3"] = "3: No one"
L["label_beacon_buff_on_death"] = "Give Beacon buffs without confirming deaths"
L["label_beacon_buff_every_x_seconds"] = "Beacon receives a buff every x seconds (disabled if 0)"
L["label_beacon_judgement"] = "Damage the Beacon receives if they kill their own teammates"
L["label_beacon_demotion_enable"] = "Demote Beacon to Innocent if they kill an Innocent"
L["label_beacon_buff_requires_in_person"] = "Beacon must personally confirm death to receive buff"
L["label_beacon_speed_boost"] = "Speed boost per buff"
L["label_beacon_stamina_boost"] = "Stamina boost per buff"
L["label_beacon_stamina_regen_boost"] = "Stamina regeneration boost per buff"
L["label_beacon_jump_boost"] = "Jump boost per buff"
L["label_beacon_resist_boost"] = "Flat damage resistance boost per buff"
L["label_beacon_armor_boost"] = "Armor received for each buff"
L["label_beacon_hp_regen_boost"] = "HP Regeneration boost per each buff"
L["label_beacon_damage_boost"] = "Damage boost per buff"
L["label_beacon_fire_rate_boost"] = "Fire rate boost per buff"
