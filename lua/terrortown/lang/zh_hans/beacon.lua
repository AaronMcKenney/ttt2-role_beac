local L = LANG.GetLanguageTableReference("zh_hans")

-- GENERAL ROLE LANGUAGE STRINGS
L[BEACON.name] = "灯泡"
L["info_popup_" .. BEACON.name] = [[你是一个灯泡!灯泡是一个无辜的人,随着时间的推移,他会变得更强大.

杀死一个无辜的人会让你失去你的角色.]]
L["body_found_" .. BEACON.abbr] = "他们是灯泡."
L["search_role_" .. BEACON.abbr] = "这个人是一个灯泡!"
L["target_" .. BEACON.name] = "灯泡"
L["ttt2_desc_" .. BEACON.name] = [[你是一个灯泡!灯泡是一个无辜的人,随着时间的推移,他会变得更强大.

杀死一个无辜的人会让你失去你的角色.]]

-- OTHER ROLE LANGUAGE STRINGS
L["buffs_received_" .. BEACON.name] = "增益Buff: "
L["max_power_" .. BEACON.name] = " (最大Buff!)"

-- EVENT STRINGS
-- Need to be very specifically worded, due to how the system translates them.
L["title_event_beac_deputize"] = "一个灯泡被派去了"
L["desc_event_beac_deputize"] = "{name} 累积 {n} Buffs并且点亮!"
L["tooltip_beac_deputize_score"] = "点亮: {score}"
L["beac_deputize_score"] = "点亮:"
L["title_event_beac_judgement"] = "一个灯泡杀死了无辜者"
L["desc_event_beac_judgement"] = "{name1}作为灯泡杀死另一个灯泡{name2}.他们受到{x}伤害."
L["tooltip_beac_judgement_score"] = "判断的灯泡: {score}"
L["beac_judgement_score"] = "判断的灯泡:"