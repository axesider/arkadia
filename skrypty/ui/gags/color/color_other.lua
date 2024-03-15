two_word_mobs = misc.counter.utils.two_word_mobs

function get_mob_types()
    local sql_query = "select distinct text from counter2_log"
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

function misc_counter_add_total_killed(linijka)
    local races = misc.counter2:get_races()   
    local race = get_mob_race(linijka)
    if races[race] == nil then
        races[race] = -1
    end
    races[race] = races[race] +1
    return races[race]
end

function trigger_func_skrypty_ui_gags_color_color_other_zabiles_color()
    local counter = 1
    if misc.counter.killed_amount["JA"] then
        counter = misc.counter.killed_amount["JA"]
    end
    local counter_str = "<tomato> (" .. tostring(counter) .. " / " .. tostring(misc.counter.all_kills) .. ")"
    local counter_str = counter_str.." <green>["..(misc_counter_add_total_killed(matches[4])).."]"
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
