function misc.counter2:add_item(original_text, item)
    local type = misc.counter.utils:get_entry_key(item)

    local hour = getTime(true, "hh:mm:ss")
    local year = getTime(true, "yyyy")
    local month = getTime(true, "MM")
    local day = getTime(true, "dd")

    misc.counter2:add_log(original_text, year, month, day, hour)
    misc.counter2:add_sum(item, year, month, day, type)
end

function misc.counter2:add_log(original_text, year, month, day, hour)
    local ret = db:add(misc.counter2.db_log.counter2_log, {
        year = year,
        month = month,
        day = day,
        text = original_text,
        hour = hour,
        character = scripts.character_name
    })

    if not ret then
        scripts:print_log("Cos poszlo nie tak z zapisem do globalnych zabitych", true)
    end
end

function misc.counter2:add_sum(item, year, month, day, type)
    -- first, update for this type this date
    local retrieved = db:fetch(misc.counter2.db_daysum.counter2_daysum,
        {
            db:eq(misc.counter2.db_daysum.counter2_daysum.year, year),
            db:eq(misc.counter2.db_daysum.counter2_daysum.month, month),
            db:eq(misc.counter2.db_daysum.counter2_daysum.day, day),
            db:eq(misc.counter2.db_daysum.counter2_daysum.character, scripts.character_name),
            db:eq(misc.counter2.db_daysum.counter2_daysum.type, type)
        })


    if not retrieved or table.size(retrieved) == 0 then
        local ret = db:add(misc.counter2.db_daysum.counter2_daysum, {
            year = year,
            month = month,
            day = day,
            type = type,
            amount = 1,
            character = scripts.character_name
        })

        if not ret then
            scripts:print_log("Cos poszlo nie tak z zapisem do globalnych zabitych", true)
        end

    elseif table.size(retrieved) == 1 then
        local update_item = retrieved[1]
        local count = tonumber(update_item["amount"])
        update_item["amount"] = count + 1
        db:update(misc.counter2.db_daysum.counter2_daysum, update_item)

    else
        scripts:print_log("Cos poszlo nie tak z zapisem do globalnych zabitych", true)
        return
    end

    -- now do 'all' (count for day)
    local retrieved = db:fetch(misc.counter2.db_daysum.counter2_daysum,
        {
            db:eq(misc.counter2.db_daysum.counter2_daysum.year, year),
            db:eq(misc.counter2.db_daysum.counter2_daysum.month, month),
            db:eq(misc.counter2.db_daysum.counter2_daysum.day, day),
            db:eq(misc.counter2.db_daysum.counter2_daysum.type, "all")
        })

    if not retrieved or table.size(retrieved) == 0 then
        local ret = db:add(misc.counter2.db_daysum.counter2_daysum, {
            year = year,
            month = month,
            day = day,
            type = "all",
            amount = 1,
            character = scripts.character_name
        })

        if not ret then
            scripts:print_log("Cos poszlo nie tak z zapisem do globalnych zabitych", true)
        end
    elseif table.size(retrieved) == 1 then
        local update_item = retrieved[1]
        local count = tonumber(update_item["amount"])
        update_item["amount"] = count + 1
        db:update(misc.counter2.db_daysum.counter2_daysum, update_item)
    else
        scripts:print_log("Cos poszlo nie tak z zapisem do globalnych zabitych", true)
        return
    end
end

misc.counter.utils.two_word_mobs = {
    "czarnego orka",
    "dzikiego orka",
    "kamiennego trolla",
    "konia bojowego",
    "krasnoluda chaosu",
    "lodowego trolla",
    "rycerza chaosu",
    "smoczego ogra",
    "smoka chaosu",
    "straznika wiezy",
    "tancerza wojny",
    "trolla gorskiego",
    "trolla jaskiniowego",
    "zjawe kobiety",
    "zywiolaka ognia",
    "zywiolaka powietrza",
    "zywiolaka wody",
    "zywiolaka ziemi"
}


local function ends_with(str, ending)
   return str:sub(-#ending) == ending
end

--- Funckja zwraca rase
-- @param text "Zabil[ae]s foo bar"
function get_mob_race(text)
    if ends_with(text, "ze skrzynia na grzbiecie") then text = text:sub(1,-26) end
    result = {}
    for _, mob in pairs(misc.counter.utils.two_word_mobs) do
        if ends_with(text, mob) then
            return mob
        end
    end
    local l_keys = string.split(text, " ")
    local last = table.size(l_keys)
    local mob = l_keys[last]
    if mob == "zwierzoczleka" then
        local bestigory = {"poteznego","rogatego","gigantycznego","ogromnego","gargantuicznego","przerazajacego","muskularnego","umiesnionego"}
        if table.contains(bestigory, l_keys[last-1]) or table.contains(bestigory, l_keys[last-2]) then
            return "bestigora"
        end
    end
    if l_keys[last-1] == "szkielet" then
        return l_keys[last-1] .. " " .. mob
    end
    if last>4 then
        debugc(mob.."|"..text.."|")
    end
    return mob
end

function misc.counter2:get_races_fromdb()
    local sql_query = "SELECT count(text)as day, text FROM counter2_log WHERE character='" .. scripts.character_name .. "' group by text"
    local retrieved = db:fetch_sql(misc.counter2.db_log.counter2_log, sql_query)
    local result = {}
    for k, v in pairs(retrieved) do
        local mob = get_mob_race(v.text)
        result[mob] = (result[mob] or 0) + v.day
    end
    return result
end

function misc.counter2:get_races()
    if self.races == nil then
        self.races = self:get_races_fromdb()
    end
    return self.races
end

function misc.counter2:show_short()
    if not scripts.character_name then
        scripts:print_log("Korzystanie z bazy zabitych po ustawieniu 'scripts.character_name' w configu")
        return
    end

    local sql_query = "SELECT count(text)as day, text FROM counter2_log WHERE character='" .. scripts.character_name .. "' group by text"
    local retrieved = db:fetch_sql(misc.counter2.db_log.counter2_log, sql_query)

    
    local count_dict = {}
    for k, v in pairs(retrieved) do
        local mob = get_mob_type(v.text)
        count_dict[mob] = (count_dict[mob] or 0) + v.day
    end

    cecho("<grey>+---------------------------------------------------------+\n")
    cecho("<grey>|                                                         |\n")
    local name = string.sub(scripts.character_name .. "                    ", 1, 20)
    cecho("<grey>|  POSTAC: <yellow>" .. name .. "<grey>                           |\n")
    cecho("<grey>|                                                         |\n")

    local sum = 0

    for k, v in spairs(count_dict) do
        local name = string.sub(k .. "<grey> ......................", 1, 29)
        local color = misc.counter.utils:is_rare(k) and "<orange>" or "<LawnGreen>"
        local amount = v
        local amount_str = tostring(amount)
        local l = string.len(amount_str)
        amount_str = string.rep(".", 7-l) .. " " .. amount_str
        sum = sum + amount
        local line = "<grey>|  " .. color .. name .. amount_str .. "                        |\n"
        cecho(line)
    end

    cecho("<grey>|                                                         |\n")
    cecho("<grey>|       ------------------------------------              |\n")
    cecho("<grey>|                                                         |\n")
    local sum_global_str = string.sub(tostring(sum) .. " zabitych           ", 1, 20)
    cecho("<grey>|  <pink>WSZYSTKICH DO TEJ PORY: <LawnGreen>" .. sum_global_str .. "<grey>           |\n")
    cecho("<grey>|                                                         |\n")
    cecho("<grey>+---------------------------------------------------------+\n")
end

function misc.counter2:show_long()
    if not scripts.character_name then
        scripts:print_log("Korzystanie z bazy zabitych po ustawieniu 'scripts.character_name' w configu")
        return
    end

    local sql_query = "SELECT * FROM counter2_daysum WHERE character=\"" .. scripts.character_name .. "\" AND type!=\"all\" ORDER BY _row_id ASC"
    local retrieved = db:fetch_sql(misc.counter2.db_daysum.counter2_daysum, sql_query)

    cecho("<grey>+---------------------------------------------------------+\n")
    cecho("<grey>|                                                         |\n")
    local name = string.sub(scripts.character_name .. "                    ", 1, 20)
    cecho("<grey>|  POSTAC: <yellow>" .. name .. "<grey>                           |\n")
    cecho("<grey>|                                                         |\n")

    local current_date = nil
    local sum = 0
    local global_sum = 0

    for k, v in pairs(retrieved) do
        local this_date = v["year"] .. "/" .. v["month"] .. "/" .. v["day"]

        local date = string.sub(v["year"] .. "/" .. v["month"] .. "/" .. v["day"] .. "     ", 1, 11)
        local name = string.sub(v["type"] .. " ...................................", 1, 23)
        local color = misc.counter.utils:is_rare(name) and "<orange>" or "<LawnGreen>"
        local amount = string.sub(v["amount"] .. "       ", 1, 7)

        if current_date and current_date ~= this_date then
            local sum_str = string.sub(tostring(sum) .. " zabitych        ", 1, 17)
            cecho("<grey>|                                                         |\n")
            cecho("<grey>|  SUMA: <LawnGreen>" .. sum_str .. "<grey>                                |\n")
            cecho("<grey>|                                                         |\n")
            sum = 0
        end

        if this_date ~= current_date then
            cecho("<grey>|  <orange>" .. date .. "<grey>                                            |\n")
            cecho("<grey>|  ----------                                             |\n")
            current_date = this_date
        end

        cecho("<grey>|     - " .. color .. name .. " " .. amount .. "                   <grey>|\n")
        sum = sum + tonumber(v["amount"])
        global_sum = global_sum + tonumber(v["amount"])
    end

    local sum_str = string.sub(tostring(sum) .. " zabitych        ", 1, 17)
    cecho("<grey>|                                                         |\n")
    cecho("<grey>|  SUMA: <LawnGreen>" .. sum_str .. "<grey>                                |\n")
    cecho("<grey>|                                                         |\n")
    cecho("<grey>|       ------------------------------------              |\n")
    cecho("<grey>|                                                         |\n")
    local sum_global_str = string.sub(tostring(global_sum) .. " zabitych           ", 1, 20)
    cecho("<grey>|  <pink>WSZYSTKICH DO TEJ PORY: <LawnGreen>" .. sum_global_str .. "<grey>           |\n")
    cecho("<grey>|                                                         |\n")
    cecho("<grey>+---------------------------------------------------------+\n")
end

function misc.counter2:show_logs(year, month, day)
    if not scripts.character_name then
        scripts:print_log("Korzystanie z bazy zabitych po ustawieniu 'scripts.character_name' w configu")
        return
    end

    if( (year == '' or year == nil) and (month == '' or month == nil) and (day == '' or day == nil)) then
        misc.counter2:show_short()
        return
    end

    local date = ""..year
    local sql_query = "SELECT * FROM counter2_log WHERE character=\"" .. scripts.character_name ..
             "\" AND year=\"" .. year .. "\" "
             
    if month ~= nil then
        date = date .. "/" .. month;
        sql_query = sql_query .. " AND month=\"" .. month .. "\" "
        if day ~= nil then
            date = date .. "/" .. day;
            sql_query = sql_query .. " AND day=\"" .. day .. "\" "
        end
    end
    sql_query = sql_query .. " ORDER BY _row_id ASC"

    local retrieved = db:fetch_sql(misc.counter2.db_log.counter2_log, sql_query)

    local date = string.sub(date .. "               ", 1, 11)

    cecho("<grey>+---------------------------------------------------------------+\n")
    cecho("<grey>|                                                               |\n")
    local name = string.sub(scripts.character_name .. "                    ", 1, 20)
    cecho("<grey>|  POSTAC: <yellow>" .. name .. "<grey>                                 |\n")
    cecho("<grey>|                                                               |\n")
    cecho("<grey>|  Logi z <LawnGreen>" .. date .. "<grey>                                           |\n")
    cecho("<grey>|                                                               |\n")

    local sum = 0


    for k, v in pairs(retrieved) do
        local text = string.sub(v["text"] .. "                                                       ", 1, 46)
        
        local kill_date = "";
        if month == nil or day == nil then
            kill_date = v["month"] .. "/" .. v["day"] .. " " .. v["hour"]
        else
            kill_date = v["hour"]
        end

        local kill_date_str = string.sub(kill_date .. "            ", 1, 14)

        
        cecho("<grey>|<orange>  " .. kill_date_str .. " <grey>" .. text .. "<grey>|\n")
        sum = sum + 1
    end

    local sum_str = string.sub(tostring(sum) .. " zabitych        ", 1, 17)
    cecho("<grey>|                                                               |\n")
    cecho("<grey>|  SUMA: <LawnGreen>" .. sum_str .. "<grey>                                      |\n")
    cecho("<grey>|                                                               |\n")
    cecho("<grey>+---------------------------------------------------------------+\n")
end

function misc.counter2:reset()
    if not scripts.character_name then
        scripts:print_log("Korzystanie z bazy zabitych po ustawieniu 'scripts.character_name' w configu")
        return
    end

    if not misc.counter2.retried then
        scripts:print_log("Probujesz wykasowac cala baze zabitych, od tego nie ma odwrotu. Aby wykonac, powtorz komende")
        misc.counter2.retried = true
    else
        db:delete(misc.counter2.db_log.counter2_log, db:eq(misc.counter2.db_log.counter2_log.character, scripts.character_name))
        db:delete(misc.counter2.db_daysum.counter2_daysum, db:eq(misc.counter2.db_daysum.counter2_daysum.character, scripts.character_name))
        scripts:print_log("Ok")
    end

    tempTimer(5, function() misc.counter2.retried = nil end)
end

