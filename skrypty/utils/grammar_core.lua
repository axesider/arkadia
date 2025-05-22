Rzeczownik = Rzeczownik or {}
Rzeczownik.__index = Rzeczownik

function Rzeczownik:new(gender, singular_forms, plural_forms)
    local obj = {
        gender = gender,
        declensions = {
            singular = singular_forms or {},
            plural = plural_forms or {}
        }
    }
    setmetatable(obj, self)

    -- Validate declensions
    if not obj:validate_declensions() then
        error("Invalid declensions for noun: " .. (singular_forms[1] or "unknown"))
    end

    return obj
end

function Rzeczownik:validate_declensions()
    local cases = Grammar.CASES
    if #self.declensions.singular ~= #cases then
        return false
    end
    -- Add more validation as needed
    return true
end

function Rzeczownik:get_form(case, number)
    local forms = number and self.declensions.plural or self.declensions.singular
    return forms and forms[case] or self.declensions.singular[1]
end

function Rzeczownik:get_base_form()
    return self.declensions.singular[1]
end

function Rzeczownik:create_compound(modifiers)
    local new_singular = {}
    local new_plural = {}
    local modifier_string = " " .. table.concat(modifiers, " ")

    for i = 1, #Grammar.CASES do
        new_singular[i] = self.declensions.singular[i] .. modifier_string
    end

    if new_plural[1] ~= "" then
        for i = 1, #Grammar.CASES do
            new_plural[i] = self.declensions.plural[i] .. modifier_string
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
               "zenski", "nijaki_osobowy", "nijaki_nieosobowy"},

    -- Constants
    MIA = 1, DOP = 2, CEL = 3, BIE = 4, NAR = 5, MIE = 6,
    MESKI_OS = 1, MESKI_NOS_ZYW = 2, MESKI_NOS_NZYW = 3,
    ZENSKI = 4, NIJAKI_OS = 5, NIJAKI_NOS = 6,

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
                ["non_masculine_personal"] = {"e", "ych", "ym", "e", "ymi", "ych"}
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
                ["non_masculine_personal"] = {"ie", "ich", "im", "ie", "imi", "ich"}
            }
        }
    }

    local pattern_set = patterns[rule_type] or patterns.hard
    local number_set = number and pattern_set.plural or pattern_set.singular
    local gender_set = number_set[gender] or number_set["non_masculine_personal"] or number_set[Grammar.MESKI_OS]

    return gender_set and gender_set[case] or ""
end

function AdjectiveRules:convert_to_base_form(inflected_form, current_gender)
    -- Simple heuristic to convert inflected adjective back to base masculine form
    -- This is a simplified version - in reality, this would need more sophisticated rules
    local last_char = inflected_form:sub(-1)
    local base = inflected_form
    
    if current_gender == Grammar.ZENSKI then
        if last_char == "a" then
            base = inflected_form:sub(1, -2) .. "y"
        end
    elseif current_gender == Grammar.NIJAKI_OS or current_gender == Grammar.NIJAKI_NOS then
        if last_char == "e" then
            base = inflected_form:sub(1, -2) .. "y"
        end
    end
    
    return base
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

function Dictionary:add_noun(singular_forms, var1, var2)
    if type(singular_forms) ~= "table" or #singular_forms ~= Grammar.MIE then
        if scripts and scripts.print_log then
            scripts:print_log("Nieprawidlowy parametr <singular_forms>.")
        end
        return 
    end
    
    local plural_forms = {"","","","","",""}
    local gender = Grammar.MESKI_OS
    
    if type(var1) == "table" then
        plural_forms = var1
        gender = var2 or Grammar.MESKI_OS
    elseif type(var1) == "number" then
        gender = var1
        plural_forms = var2 or {"","","","","",""}
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
        
        if not self.cache.noun_lookups[singular_form] then
            self.cache.noun_lookups[singular_form] = {}
        end
        table.insert(self.cache.noun_lookups[singular_form], {noun = noun, case = case, number = false})
        
        if plural_form ~= "" then
            if not self.cache.noun_lookups[plural_form] then
                self.cache.noun_lookups[plural_form] = {}
            end
            table.insert(self.cache.noun_lookups[plural_form], {noun = noun, case = case, number = true})
        end
    end
end

function Dictionary:find_noun(form, case_hint)
    -- Fast lookup using indexed forms
    local candidates = self.cache.noun_lookups[form]
    if not candidates then return nil end
    
    if case_hint then
        for _, candidate in ipairs(candidates) do
            if candidate.case == case_hint then
                return candidate.noun, candidate.case, candidate.number
            end
        end
    end
    
    return candidates[1].noun, candidates[1].case, candidates[1].number
end

function Dictionary:create_compound_noun(base_noun, modifiers)
    local compound = base_noun:create_compound(modifiers)
    local compound_key = compound:get_base_form()
    
    if not self.compounds[compound_key] then
        self.compounds[compound_key] = compound
        self:index_noun_forms(compound)
        print("Auto-created compound noun: " .. compound_key)
    end
    
    return self.compounds[compound_key]
end

-- =====================================================
-- PHRASE PARSER
-- =====================================================

PhraseParser = PhraseParser or {
    dictionary = Dictionary
}

function PhraseParser:parse(phrase, case_hint, number_hint)
    local result = {
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
    local noun, noun_start_idx = self:find_base_noun(words, case_hint)

    if noun and noun_start_idx then
        -- Check if we need to create compound noun
        if noun_start_idx < #words then
            local modifiers = {unpack(words, noun_start_idx + 1, #words)}
            noun = self.dictionary:create_compound_noun(noun, modifiers)
        end

        result.noun = noun

        -- Parse adjectives
        for i = 1, noun_start_idx - 1 do
            local adj_base = AdjectiveRules:convert_to_base_form(words[i], noun.gender)
            table.insert(result.adjectives, adj_base)
        end
    else
        -- Fallback: assume last word is unknown noun
        result.noun = words[#words]
        for i = 1, #words - 1 do
            table.insert(result.adjectives, words[i])
        end
    end

    return result
end

function PhraseParser:tokenize(phrase)
    local words = {}
    for word in phrase:gmatch("[^ ]+") do
        table.insert(words, word)
    end
    return words
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

function PhraseParser:find_base_noun(words, case_hint)
    for i = #words, 1, -1 do
        local noun, found_case, number = self.dictionary:find_noun(words[i], case_hint)
        if noun then
            return noun, i
        end
    end
    return nil, nil
end

-- =====================================================
-- MAIN SLOWNIK CLASS (FACADE)
-- =====================================================

Slownik = Slownik or {
    dictionary = Dictionary,
    parser = PhraseParser,
    version = "2.0"
}

-- Compatibility methods
function Slownik:add_noun(gender, singular_forms, plural_forms)
    return self.dictionary:add_noun(singular_forms, plural_forms, gender)
end

function Slownik:split_short(phrase, case_hint, number_hint)
    local parsed = self.parser:parse(phrase, case_hint, number_hint)

    return {
        przym = parsed.adjectives,
        rzecz = parsed.noun and (type(parsed.noun) == "table" and parsed.noun:get_base_form() or parsed.noun) or phrase,
        post = parsed.post_phrase
    }
end

function Slownik:decline_adjective(adjective, case, gender, number)
    local adj = Przymiotnik:new(adjective)
    return adj:decline(case, gender, number)
end

function Slownik:decline_phrase(adjectives, noun, case, number)
    local noun_obj = self.dictionary.nouns[noun]
    if not noun_obj then return nil end

    local result = {}
    for _, adj in ipairs(adjectives) do
        local adj_obj = Przymiotnik:new(adj)
        table.insert(result, adj_obj:decline(case, noun_obj.gender, number))
    end

    table.insert(result, noun_obj:get_form(case, number))
    return table.concat(result, " ")
end
