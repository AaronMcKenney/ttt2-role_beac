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