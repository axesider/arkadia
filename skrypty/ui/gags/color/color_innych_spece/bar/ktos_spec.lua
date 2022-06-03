function trigger_func_skrypty_ui_gags_color_color_innych_spece_bar_ktos_spec_ktos_spec_0()
    scripts.gags:gag_spec("BAR", 0, 6, "innych_spece")
end

function trigger_func_skrypty_ui_gags_color_color_innych_spece_bar_ktos_spec_ktos_spec()
    local dmg = matches[6]
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
        scripts.gags:gag_prefix("BAR OGL", "innych_spece")
        ateam:may_setup_paralyzed_name(matches["target"])
    end
end

function trigger_func_skrypty_ui_gags_color_color_innych_spece_bar_ktos_spec_ktos_spec_6()
    scripts.gags:gag_spec("BAR", 6, 6, "innych_spece")
end

