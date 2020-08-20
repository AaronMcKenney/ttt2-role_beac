local L = LANG.GetLanguageTableReference("english")

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