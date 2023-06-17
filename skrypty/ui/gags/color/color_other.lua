two_word_mobs = {
    "czarnego orka",
    "dzikiego orka",
    "elfiego egzekutora",
    "elfiego tancerza wojny",
    "krasnoluda chaosu",
    "rycerza chaosu",
    "smoka chaosu",
    "smoczego ogra",
    "trolla jaskiniowego",
    "konia bojowego",
    "szkielet goblina",
    "szkielet krasnoluda",
    "szkielet orka",
    "zywiolaka wody",
    "zywiolaka powietrza",
    "zywiolaka ognia",
    "zywiolaka ziemi"
}

function get_mob_types()
    local sql_query = "select text from counter2_log"
    local retrieved = db:fetch_sql(misc.counter2.db_log.counter2_log, sql_query)
    types={}
    lista = {}
    for k, v in pairs(retrieved) do
        t = v["text"]
        t_lines = string.split(t, " ")
        branch = types
        for i=2, #t_lines do
            s = t_lines[#t_lines-i+2]
            if branch[s] then  else
                branch[s] = {["cnt"]=0}
            end
            
            branch = branch[s]
            branch["cnt"] = branch["cnt"] + 1
        end
    end
    for k, v in pairs(types) do
        entry = k
        lista[entry] = v.cnt
        for k1, v1 in pairs(v) do
            if k1 ~= "cnt" then
                entry = k1 .." " .. k
                lista[entry] = v1.cnt
                for k2, v2 in pairs(v1) do
                    if k2 ~= "cnt" then
                        entry = k2 .. " " .. k1 .. " " ..k
                        lista[entry] = v2.cnt
                    end
                end
            end
        end
    end

    local ids = {}
    for id in pairs(lista) do
        table.insert(ids, id)
    end

    table.sort(ids, function(a, b) return lista[a] > lista[b] end)
    for i = 1, 20 do
        local name = ids[i]
        local entry = lista[name]
        echo(i.." " .. entry.." " ..name.. "\n")
    end
    
end

function get_kill_count(linijka)
    local bestigory = {"poteznego","rogatego","gigantycznego","ogromnego","gargantuicznego","przerazajacego","muskularnego","umiesnionego"}
    local Oneadj_two_word_mobs = {"kamiennego trolla","lodowego trolla"}
    local l_keys = string.split(linijka, " ")
   
    if table.size(l_keys) == 3 and l_keys[3] == "zwierzoczleka" and (table.contains(bestigory, l_keys[1]:lower()) or table.contains(Bestigor.Adjectives, l_keys[2]:lower())) then
        local retrieved = db:fetch_sql(misc.counter2.db_log.counter2_log, "select count(*) as day from counter2_log where character='" .. scripts.character_name .. "' AND text like '%zwierzoczleka%' and (text like '%poteznego%' or  text like '%rogatego%' or  text like '%gigantycznego%' or  text like '%ogromnego%' or text like '%gargantuicznego%' or text like '%przerazajacego%' or text like '%muskularnego%' or text like '%umiesnionego%')")
        for k, v in pairs(retrieved) do
            if v["day"] then return v["day"] end
            break
        end
    elseif table.size(l_keys)==3 and table.contains(Oneadj_two_word_mobs, l_keys[2] .. " " .. l_keys[3]) then
            local opis = l_keys[2] .. " " .. l_keys[3]
            local sql_query = "select count(*) as day from counter2_log where character='" .. scripts.character_name .. "' AND text like '%".. opis .. "%'"
            local retrieved = db:fetch_sql(misc.counter2.db_log.counter2_log, sql_query)
            for k, v in pairs(retrieved) do
                if v["day"] then return v["day"] end
                break
            end
    else
        local npc = misc.counter.utils:get_entry_key(linijka)
        local sql_query = "SELECT sum(amount)as amount FROM counter2_daysum WHERE character=\"" .. scripts.character_name .. "\" AND type=\"".. npc .."\""
        local retrieved = db:fetch_sql(misc.counter2.db_daysum.counter2_daysum, sql_query)
        local Total = ""
        for k, v in pairs(retrieved) do
            if v["amount"] then return v["amount"] end
            break
        end
    end
    return -1
end

function trigger_func_skrypty_ui_gags_color_color_other_zabiles_color()
    local counter = 1
    if misc.counter.killed_amount["JA"] then
        counter = misc.counter.killed_amount["JA"]
    end
    local counter_str = "<tomato> (" .. tostring(counter) .. " / " .. tostring(misc.counter.all_kills) .. ")"
    local counter_str = counter_str.." <green>["..(get_kill_count(matches[4])+1).."]"
    selectCurrentLine()
    creplaceLine("\n\n<tomato>[  " .. matches[3]:upper() .. "  ] <grey>" .. matches[2] .. counter_str .. "\n\n")
    scripts.inv.collect:killed_action()
    raiseEvent("killed_action", matches[4])
    resetFormat()
end

function trigger_func_skrypty_ui_gags_color_color_other_zabil_color()
    selectCurrentLine()
    local counter_str = nil

    if ateam.team_names[matches[3]] then
        local counter = 1
        if misc.counter.killed_amount[matches[3]] then
            counter = misc.counter.killed_amount[matches[3]]
        end
        counter_str = " (" .. tostring(counter) .. " / " .. tostring(misc.counter.all_kills) .. ")"
    end

    if counter_str then
        creplaceLine("\n\n<tomato>[   " .. matches[4]:upper() .. "   ] <grey>" .. matches[2] .. counter_str .. "\n\n")
    else
        creplaceLine("\n\n<tomato>[   " .. matches[4]:upper() .. "   ] <grey>" .. matches[2] .. "\n\n")
    end
    scripts.inv.collect:team_killed_action(matches[3])
    resetFormat()
end

function trigger_func_skrypty_ui_gags_color_color_other_mozesz_dobywac()
    raiseEvent("playBeep")
    raiseEvent("canWieldAfterKnockOff")
    creplaceLine("<green>\n\n[    BRON    ]<cornsilk> Mozesz dobyc broni klawiszem '" .. scripts.keybind:keybind_tostring("functional_key") .."'\n\n")
    resetFormat()
    scripts.utils.bind_functional(scripts.inv.weapons.wield)
    scripts.ui:info_action_update("DOBADZ")
    scripts.ui.info_action_bind = scripts.inv.weapons.wield
end

function trigger_func_skrypty_ui_gags_color_color_other_wytracenie_tobie()
    raiseEvent("playBeep")
    raiseEvent("weaponKnockedOff")
    raiseEvent("weapon_state", false)
    creplaceLine("\n\n<tomato>[    BRON    ] " .. matches[2] .. "\n\n")
    resetFormat()
    scripts.ui:info_action_update("WYTRACENIE")
end

function trigger_func_skrypty_ui_gags_color_color_other_przelamanie()
    local team_break = ateam.team_names[matches[3]] or ateam.team_names[string.lower(matches[3])]
    local color = team_break and "green" or "red"
    creplaceLine("\n\n<".. color ..">[ KTOS LAMIE ] " .. matches[2] .. "\n\n")
    ateam:may_setup_broken_defense(matches[4])
    resetFormat()

    if team_break then
        scripts.utils.echobind("zabij cel ataku", nil, "zabij cel ataku", "attack_target", 0)
    end
end

function trigger_func_skrypty_ui_gags_color_color_other_przelamanie_ty()
    creplaceLine("<green>\n\n[ TY LAMIESZ ] " .. matches[2] .. "\n\n")
    ateam:may_setup_broken_defense(matches[3])
    resetFormat()
end

function trigger_func_skrypty_ui_gags_color_color_other_nie_przelamanie_ty()
    creplaceLine("<tomato>\n\n[ NIE LAMIESZ ] " .. matches[2] .. "\n\n")
    resetFormat()
end

function trigger_func_skrypty_ui_gags_color_color_other_nie_przelamanie()
    creplaceLine("<tomato>\n\n[ NIE LAMIE  ] " .. matches[2] .. "\n\n")
    resetFormat()
end

function trigger_func_skrypty_ui_gags_color_color_other_nekro_tilea()
    raiseEvent("playBeep")
    raiseEvent("weaponKnockedOffNekroTilea")
    creplaceLine("<green>\n\n[    BRON    ]<cornsilk> Wez bron i dobadz jej\n\n")
    resetFormat()
    scripts.utils.bind_functional(scripts.inv.weapons.wield)
    scripts.ui:info_action_update("WEZ BRON/DOBADZ")
    scripts.ui.info_action_bind = scripts.inv.weapons.wield
end

function trigger_func_team_leadership()
    fg("DarkGoldenrod")
    prefix("\n[   DRUZYNA   ]  ")
    echo("\n\n")
    resetFormat()
end
