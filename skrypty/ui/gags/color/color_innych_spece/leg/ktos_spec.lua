function trigger_func_skrypty_ui_gags_color_color_innych_spece_leg_ktos_spec()
    local dmg = matches["damage"]
    local value = -1
        if dmg == "Cios" then value = 0
    elseif dmg == "Slaby" then value = 1
    elseif dmg == "Niezbyt" then value = 2
    elseif dmg == "Silny" then value = 3
    elseif dmg == "Potezny" then value = 4
    elseif dmg == "Mocny" then value = 5
    elseif dmg == "Bezlitosny" then value = 6
    end

    scripts.gags:gag_spec("LEG", value, 6, "innych_spece")
end
