-- Czarny smukly kordelas

function trigger_func_skrypty_ui_gags_ciosy_czarny_smukly_kordelas()
    local target = "moje_ciosy"
    if matches["attacker"] then
        target = matches["target"] == "cie" and "innych_ciosy_we_mnie" or "innych_ciosy"
    end

    local dmg = matches["damage"]
    local value = -1
        if dmg == "trafiajac" then value = 1
    elseif dmg == "zamach" then value = 3
    elseif dmg == "powaznie" then value = 4
    elseif dmg == "bardzo ciezko" then value = 5
    elseif dmg == "poszarpana rane" then value = 6
    end
    scripts.gags:gag(value, 6, target)
end

function trigger_func_skrypty_ui_gags_ciosy_czarny_smukly_kordelas_1os()
    local target = "moje_ciosy"
    local dmg = matches["damage"]
    local value = -1
        if dmg == "wyparowany" or dmg == "oslania sie" or dmg == "paruje" then value = 0
    elseif dmg == "Uderzasz"  then value = 1
    elseif dmg == "raniac"  then value = 2
    elseif dmg == "ranisz" then value = 3
    elseif dmg == "poszarpana" then value = 4
    elseif dmg == "powaznie" then value = 5
    elseif dmg == "ciezko" then value = 6
    elseif dmg == "poteznie" then
        return scripts.gags:gag_prefix(scripts.gags.fin_prefix, target)
    end
    scripts.gags:gag(value, 6, target)
end

-- Lodowy lsniacy sztylet

function trigger_func_skrypty_ui_gags_ciosy_lodowy_lsniacy_sztylet_1os()
    local target = "moje_ciosy"
    local dmg = matches["damage"]
    local value = -1
        if dmg == "mija"  then value = 0
    elseif dmg == "jedynie nieznaczne" or dmg == "zmrozona" or dmg == "smuge"  then value = 1
    elseif dmg == "jedynie nieduze" or dmg == "szrame"  then value = 2
    elseif dmg == "znaczne" or dmg == "rozcina" then value = 3
    elseif dmg == "bolesne" or dmg == "grymas" then value = 4
    elseif dmg == "bardzo rozlegle" or dmg == "strumien" then value = 5
    elseif dmg == "potworne" or dmg == "szkarlatna" or dmg == "powazne" or dmg == "powazna rane" then value = 6
    elseif dmg == "blyskawicznie" then
        return scripts.gags:gag_prefix(scripts.gags.fin_prefix, target)
    end
    scripts.gags:gag(value, 6, target)
end

-- Polyskujacy zdobiony sztylet

function trigger_func_skrypty_ui_gags_ciosy_polyskujacy_zdobiony_sztylet_1os()
    local target = "moje_ciosy"
    local dmg = matches["damage"]
    local value = -1
        if dmg == "mija" then value = 0
    elseif dmg == "muskajac"  then value = 1
    elseif dmg == "raniac"  then value = 2
    elseif dmg == "trafiasz" then value = 3
    elseif dmg == "zaglebiajac" then value = 4
    elseif dmg == "powazne" then value = 5
    elseif dmg == "zaglebiajac" then value = 6
    elseif dmg == "celne" then
        return scripts.gags:gag_prefix(scripts.gags.fin_prefix, target)
    end
    scripts.gags:gag(value, 6, target)
end

-- Stalowe smocze pazury

function trigger_func_skrypty_ui_gags_ciosy_stalowe_smocze_pazury_1os()
    local target = "moje_ciosy"
    local dmg = matches["damage"]
    local value = -1
        if dmg == "wyparowuje" then value = 0
    elseif dmg == "lekko" then value = 1
    elseif dmg == "celnie"  then value = 2
    elseif dmg == "bolesny" then value = 3
    elseif dmg == "paskudna" then value = 4
    elseif dmg == "tniesz" or dmg == "ciezko" then value = 5
    elseif dmg == "gleboko" then value = 6
    elseif dmg == "." then
        return scripts.gags:gag_prefix(scripts.gags.fin_prefix, target)
    end
    scripts.gags:gag(value, 6, target)
end
