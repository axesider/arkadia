Rzeczownik = Rzeczownik or {}
Rzeczownik.__index = Rzeczownik

function Rzeczownik:new(gender, singular_forms, plural_forms)
    local obj = {
        gender = gender,
        singular = singular_forms,
        plural = plural_forms
    }
    setmetatable(obj, self)

    -- Validate declensions
    if not obj:validate_declensions() then
        error("Nieprawidlowa odmiana rzeczownika: " .. (singular_forms[1] or "?"))
    end

    return obj
end

function Rzeczownik:validate_declensions()
    local cases = Grammar.CASES
    if #self.singular ~= #cases then
        return false
    end
    if self.plural and #self.plural ~= #cases then
        return false
    end
    return true
end

function Rzeczownik:get_form(case, number)
    local forms = number and self.plural or self.singular
    return forms[case]
end

function Rzeczownik:get_base_form()
    return self.singular[1]
end

function Rzeczownik:create_compound(modifiers)
    local new_singular = {}
    local new_plural = nil
    local modifier_string = " " .. table.concat(modifiers, " ")

    for i = 1, #Grammar.CASES do
        new_singular[i] = self.singular[i] .. modifier_string
    end

    if self.plural ~= nil then
        new_plural = {}
        for i = 1, #Grammar.CASES do
            new_plural[i] = self.plural[i] .. modifier_string
        end
    end

    return Rzeczownik:new(self.gender, new_singular, new_plural)
end

-- =====================================================
-- PRZYMIOTNIK (ADJECTIVE) CLASS
-- =====================================================

Przymiotnik = Przymiotnik or {}
Przymiotnik.__index = Przymiotnik

function Przymiotnik:new(base_form)
    local obj = {
        base_form = base_form,  -- Always masculine singular nominative
        stem = nil,
        declension_rules = nil
    }
    setmetatable(obj, self)

    obj.stem = obj:extract_stem()
    obj.declension_rules = AdjectiveRules:get_rules(base_form)

    return obj
end

function Przymiotnik:extract_stem()
    local last_char = self.base_form:sub(-1)
    if last_char == "y" or last_char == "i" then
        return self.base_form:sub(1, -2)
    end
    return self.base_form
end

function Przymiotnik:decline(case, gender, number)
    return AdjectiveRules:apply_rules(self.stem, case, gender, number, self.declension_rules)
end

function Przymiotnik:detect_gender_from_form(form)
    local last_char = form:sub(-1)
    if last_char == "a" then return Grammar.ZENSKI
    elseif last_char == "e" then return Grammar.NIJAKI_OS
    else return Grammar.MESKI_OS end
end

-- =====================================================
-- GRAMMAR CONSTANTS AND UTILITIES
-- =====================================================

Grammar = Grammar or {
    CASES = {"mianownik", "dopelniacz", "celownik", "biernik", "narzednik", "miejscownik"},
    GENDERS = {"meski_osobowy", "meski_nieosobowy_zywotny", "meski_nieosobowy_niezywotny",
               "zenski", "nijaki_osobowy", "nijaki_nieosobowy","niemeskoosobowy"},

    -- Constants
    MIA = 1, DOP = 2, CEL = 3, BIE = 4, NAR = 5, MIE = 6,
    MESKI_OS = 1, MESKI_NOS_ZYW = 2, MESKI_NOS_NZYW = 3,
    ZENSKI = 4, NIJAKI_OS = 5, NIJAKI_NOS = 6, MESKI_NOS = 7,

    -- Common prepositions that start post-noun phrases
    PREPOSITIONS = {"z", "ze", "w", "na", "o", "do", "od", "dla", "bez", 
                   "przez", "nad", "pod", "przy", "za", "we", "oko"}
}

-- =====================================================
-- ADJECTIVE DECLENSION RULES ENGINE
-- =====================================================

AdjectiveRules = AdjectiveRules or {
    endings = {},
    transformations = {},
    cache = {}
}

function AdjectiveRules:get_rules(adjective)
    -- Determine which declension pattern this adjective follows
    local last_chars = adjective:sub(-2)
    if last_chars == "ki" or last_chars == "gi" then
        return "soft"
    elseif adjective:sub(-1) == "i" then
        return "soft"
    else
        return "hard"
    end
end

function AdjectiveRules:apply_rules(stem, case, gender, number, rule_type)
    local cache_key = stem .. "_" .. case .. "_" .. gender .. "_" .. tostring(number)
    if self.cache[cache_key] then
        return self.cache[cache_key]
    end

    local result = self:_decline_adjective(stem, case, gender, number, rule_type)
    self.cache[cache_key] = result
    return result
end

function AdjectiveRules:_decline_adjective(stem, case, gender, number, rule_type)
    -- Implementation of adjective declension rules
    local endings = self:get_endings(case, gender, number, rule_type)
    return stem .. endings
end

function AdjectiveRules:get_endings(case, gender, number, rule_type)
    local patterns = {
        hard = {
            singular = {
                [Grammar.MESKI_OS] = {"y", "ego", "emu", "y", "ym", "ym"},
                [Grammar.MESKI_NOS_ZYW] = {"y", "ego", "emu", "ego", "ym", "ym"},
                [Grammar.MESKI_NOS_NZYW] = {"y", "ego", "emu", "y", "ym", "ym"},
                [Grammar.ZENSKI] = {"a", "ej", "ej", "a", "a", "ej"},
                [Grammar.NIJAKI_OS] = {"e", "ego", "emu", "e", "ym", "ym"},
                [Grammar.NIJAKI_NOS] = {"e", "ego", "emu", "e", "ym", "ym"}
            },
            plural = {
                [Grammar.MESKI_OS] = {"i", "ych", "ym", "ych", "ymi", "ych"},
                [Grammar.MESKI_NOS] = {"e", "ych", "ym", "e", "ymi", "ych"}
            }
        },
        soft = {
            singular = {
                [Grammar.MESKI_OS] = {"i", "iego", "iemu", "i", "im", "im"},
                [Grammar.MESKI_NOS_ZYW] = {"i", "iego", "iemu", "iego", "im", "im"},
                [Grammar.MESKI_NOS_NZYW] = {"i", "iego", "iemu", "i", "im", "im"},
                [Grammar.ZENSKI] = {"ia", "iej", "iej", "ia", "ia", "iej"},
                [Grammar.NIJAKI_OS] = {"ie", "iego", "iemu", "ie", "im", "im"},
                [Grammar.NIJAKI_NOS] = {"ie", "iego", "iemu", "ie", "im", "im"}
            },
            plural = {
                [Grammar.MESKI_OS] = {"i", "ich", "im", "ich", "imi", "ich"},
                [Grammar.MESKI_NOS] = {"ie", "ich", "im", "ie", "imi", "ich"}
            }
        }
    }

    local pattern_set = patterns[rule_type] or patterns.hard
    local number_set = number and pattern_set.plural or pattern_set.singular
    local gender_set = number_set[gender] or number_set[Grammar.MESKI_NOS] or number_set[Grammar.MESKI_OS]

    return gender_set and gender_set[case] or ""
end

function AdjectiveRules:convert_to_base_form(inflected_form, current_case, current_gender, current_count)
    -- Determine declension type (hard or soft) based on the inflected form
    local rule_type = self:get_rules(inflected_form)
    
    -- Get the expected ending for the given case, gender, and number
    local expected_ending = self:get_endings(current_case, current_gender, current_count, rule_type)
    
    -- Verify the inflected form ends with the expected ending
    if not inflected_form:match(expected_ending .. "$") then
        -- Fallback to simple heuristic if ending doesn't match
        local last_char = inflected_form:sub(-1)
        if current_gender == Grammar.ZENSKI and last_char == "a" then
            return Przymiotnik:new(inflected_form:sub(1, -2) .. "y")
        elseif (current_gender == Grammar.NIJAKI_OS or current_gender == Grammar.NIJAKI_NOS) and last_char == "e" then
            return Przymiotnik:new(inflected_form:sub(1, -2) .. "y")
        end
        return Przymiotnik:new(inflected_form) -- Return as-is if no match
    end
    
    -- Remove the expected ending to get the stem
    local stem = inflected_form:sub(1, -(#expected_ending + 1))
    
    -- Construct base form (masculine singular nominative)
    local base_ending = (rule_type == "soft") and "i" or "y"
    local base_form = stem .. base_ending
    
    -- Create and return a new Przymiotnik object
    return Przymiotnik:new(base_form)
end

-- =====================================================
-- DICTIONARY MANAGER
-- =====================================================

Dictionary = Dictionary or {
    nouns = {},  -- Base nouns (Rzeczownik objects)
    compounds = {},  -- Auto-generated compound nouns
    adjectives = {},  -- Irregular adjectives
    cache = {
        noun_lookups = {},
        adjective_forms = {}
    }
}

-- Add a noun to the dictionary
-- singular_forms: table of singular forms (e.g., {"kot", "kota", "kotowi", "kota", "kotem", "kocie"})
-- var1: either a table of plural forms or gender number
-- var2: gender number (optional)
function Dictionary:add_noun(singular_forms, var1, var2)
    if type(singular_forms) ~= "table" or #singular_forms ~= Grammar.MIE then
        scripts:print_log("Nieprawidlowy parametr <singular_forms>.")
        display(singular_forms)
        display(var1)
        display(var2)
        return
    end
    
    local plural_forms = nil
    local gender = Grammar.MESKI_OS
    
    if type(var1) == "table" then
        plural_forms = var1
        gender = var2 or Grammar.MESKI_OS
    elseif type(var1) == "number" then
        gender = var1
        plural_forms = var2
    end

    local noun = Rzeczownik:new(gender, singular_forms, plural_forms)
    self.nouns[noun:get_base_form()] = noun
    
    -- Index by all forms for reverse lookup
    self:index_noun_forms(noun)
    return noun
end

function Dictionary:index_noun_forms(noun)
    for case = 1, #Grammar.CASES do
        local singular_form = noun:get_form(case, false)
        local plural_form = noun:get_form(case, true)
        
        -- Direct mapping to noun - much simpler
        self.cache.noun_lookups[singular_form] = noun
        
        if plural_form ~= "" then
            self.cache.noun_lookups[plural_form] = noun
        end
    end
end

function Dictionary:find_noun(form, case)
    -- Simple direct lookup - returns just the noun
    return self.cache.noun_lookups[form]
end

function Dictionary:create_compound_noun(base_noun, modifiers)
    local compound = base_noun:create_compound(modifiers)
    local compound_key = compound:get_base_form()

    if not self.compounds[compound_key] then
        self.compounds[compound_key] = compound
        self:index_noun_forms(compound)
        debugc("Auto-created compound noun: " .. compound_key)
    end

    return self.compounds[compound_key]
end

function Dictionary:load_from_file()
    local filename = getMudletHomeDir() .. "/dict.json"
    local file = io.open(filename, "r")
    if not file then
        scripts:print_log("Nie można otworzyć pliku do odczytu: " .. filename)
        return false
    end

    -- Read entire file content
    local content = file:read("*all")
    file:close()

    local data = yajl.to_value(content)
    if not data then
        scripts:print_log("Nieprawidłowy format JSON w pliku.")
        return false
    end
    self.nouns = {}
    self.cache.noun_lookups = {}

    for _, entry in ipairs(data) do
        if type(entry) == "table" and (#entry == 2 or #entry == 3) then
            if #entry == 2 then
                self:add_noun(entry[1], entry[2])
            else
                self:add_noun(entry[1], entry[2], entry[3])
            end
        end
    end

    return true
end

-- =====================================================
-- PHRASE PARSER
-- =====================================================

PhraseParser = PhraseParser or {
    dictionary = Dictionary
}

function PhraseParser:parse(phrase, case, number_hint)
    local result = {
        phrase = phrase,
        adjectives = {},
        noun = nil,
        post_phrase = ""
    }
    
    if not phrase or phrase:match("^%s*$") then
        return result
    end
    
    local words = self:tokenize(phrase)
    
    -- Extract post-noun phrase
    words, result.post_phrase = self:extract_post_phrase(words)
    
    if #words == 0 then return result end
    
    -- Find the base noun (rightmost known noun)
    local noun, noun_start_idx = self:find_base_noun(words, case)
    
    if noun and noun_start_idx then
        -- Check if we need to create compound noun
        if noun_start_idx < #words then
            local modifiers = {unpack(words, noun_start_idx + 1, #words)}
            noun = self.dictionary:create_compound_noun(noun, modifiers)
        end
        
        result.noun = noun
        
        -- Parse adjectives - now we can determine correct case from the noun form
        for i = 1, noun_start_idx - 1 do
            local przym = AdjectiveRules:convert_to_base_form(words[i], case, noun.gender, number_hint)
            table.insert(result.adjectives, przym)
        end
    else
        -- Fallback: assume last word is unknown noun
        --result.noun = words[#words]
        --for i = 1, #words - 1 do
        --   local przym = Przymiotnik:new(words[i])
        --    table.insert(result.adjectives, przym)
        --end
    end
    
    return result
end


function PhraseParser:get_form(phrase, case, number_hint)
    number_hint = number_hint or false
    local result = ""
    for _, adj in ipairs(phrase.adjectives) do
        result = result .. adj:decline(case, phrase.noun.gender, number_hint) .. " "
    end
    result = result .. phrase.noun:get_form(case, number_hint)
    if phrase.post_phrase ~= "" then
        result = result .. " " .. phrase.post_phrase
    end
    return result
end

function PhraseParser:tokenize(phrase)
    return string.split(phrase, " ")
end

function PhraseParser:extract_post_phrase(words)
    for i, word in ipairs(words) do
        if self:is_preposition(word) then
            local post_phrase = table.concat(words, " ", i)
            local main_words = {unpack(words, 1, i - 1)}
            return main_words, post_phrase
        end
    end
    return words, ""
end

function PhraseParser:is_preposition(word)
    for _, prep in ipairs(Grammar.PREPOSITIONS) do
        if word == prep then return true end
    end
    return false
end

function PhraseParser:find_base_noun(words, case)
    for i = #words, 1, -1 do
        local noun = self.dictionary:find_noun(words[i], case)
        if noun then
            return noun, i
        end
    end
    return nil, nil
end

function PhraseParser:check_trigger()
    local short = multimatches[1]['mia']
    local entry = PhraseParser:parse(short, Grammar.MIA)
    local odmiana = entry.noun
    
    if odmiana == nil then
        -- Extract the noun part (last word before post-phrase)
        local words = self:tokenize(short)
        words, _ = self:extract_post_phrase(words)
        local noun_word = words[#words] or short
        
        -- Build the add_noun command string
        local msg = "[["
        local gender = Grammar.MESKI_OS -- default gender
        
        -- Add all case forms and determine gender from nominative
        for i = 1, Grammar.MIE do
            local case_form = multimatches[i] and multimatches[i][2] or ""
            -- Extract just the noun part from the full phrase
            local case_words = self:tokenize(case_form)
            case_words, _ = self:extract_post_phrase(case_words)
            local noun_form = case_words[#case_words] or case_form
            
            -- Determine gender from nominative form
            if i == Grammar.MIA then
                local last_char = noun_form:sub(-1)
                if last_char == "a" then 
                    gender = Grammar.ZENSKI
                elseif last_char == "e" or last_char == "o" then
                    gender = Grammar.NIJAKI_NOS
                else
                    gender = Grammar.MESKI_OS
                end
            end
            
            msg = msg .. '"' .. noun_form .. '"'
            if i < Grammar.MIE then
                msg = msg .. ','
            end
        end
        
        msg = msg .. "]," .. gender .. "],"
        scripts:print_log(msg)
        return
    end
    
    -- Check existing declensions
    for i = Grammar.DOP, Grammar.MIE do
        local opis = PhraseParser:get_form(entry, i)
        if opis ~= multimatches[i][2] then
            scripts:print_log(Grammar.CASES[i] .. " " .. opis .. " ~= " .. multimatches[i][2])
        end
    end
end

Dictionary:load_from_file()
