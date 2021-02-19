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