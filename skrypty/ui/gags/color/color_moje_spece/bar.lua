function trigger_func_skrypty_ui_gags_color_color_moje_spece_bar_ja_spec_ja_spec_0()
    scripts.gags:gag_own_spec(0, 6)
end

function trigger_func_skrypty_ui_gags_color_color_moje_spece_bar_ja_spec()
    local dmg = matches["damage"]
    local value = -1
        if dmg == "kaleczac"   then value = 1
    elseif dmg == "obijajac"   then value = 2
    elseif dmg == "tlukac"     then value = 3
    elseif dmg == "gruchoczac" then value = 4
    elseif dmg == "druzgoczac" then value = 5
    elseif dmg == "miazdzac"   then value = 6
    else
        cecho("\n        <red>ZGLOS BRAK OPISU SPECA BARBA: <yellow>" .. opis .."<reset>\n")
    end
    scripts.gags:gag_own_spec(value, 6)
    if matches[7] then
        trigger_func_skrypty_ui_gags_color_color_moje_spece_bar_ja_spec_ja_ogluch()
    end
end

function trigger_func_skrypty_ui_gags_color_color_moje_spece_bar_ja_fin()
    scripts.gags:gag_prefix("JA FIN", "moje_spece")
end

function trigger_func_skrypty_ui_gags_color_color_moje_spece_bar_ja_granit()
    scripts.gags:gag_prefix("GRA OGL", "moje_spece")
    ateam:may_setup_paralyzed_name(matches[2])
end

function trigger_func_skrypty_ui_gags_color_color_moje_spece_bar_ja_spec_ja_ogluch()
    scripts.gags:gag_own_spec("OGL")
    ateam:may_setup_paralyzed_name(matches[2])
end


