-- Pokedex.lua
-- Contains Pokemon data and Gen 1 type chart.

local Pokedex = {}

--------------------------------------------------------------------------------
-- GEN 1 TYPE CHART
-- Multipliers: 2 = Super Effective, 1 = Normal Damage, 0.5 = Not Very Effective, 0 = No Effect
--------------------------------------------------------------------------------
Pokedex.type_chart = {
    NORMAL = {
        NORMAL = 1, FIRE = 1, WATER = 1, ELECTRIC = 1, GRASS = 1, ICE = 1, FIGHTING = 1, POISON = 1, GROUND = 1, FLYING = 1, PSYCHIC = 1, BUG = 1, ROCK = 0.5, GHOST = 0, DRAGON = 1
    },
    FIRE = {
        NORMAL = 1, FIRE = 0.5, WATER = 0.5, ELECTRIC = 1, GRASS = 2, ICE = 2, FIGHTING = 1, POISON = 1, GROUND = 1, FLYING = 1, PSYCHIC = 1, BUG = 2, ROCK = 0.5, GHOST = 1, DRAGON = 0.5
    },
    WATER = {
        NORMAL = 1, FIRE = 2, WATER = 0.5, ELECTRIC = 1, GRASS = 0.5, ICE = 1, FIGHTING = 1, POISON = 1, GROUND = 2, FLYING = 1, PSYCHIC = 1, BUG = 1, ROCK = 2, GHOST = 1, DRAGON = 0.5
    },
    ELECTRIC = {
        NORMAL = 1, FIRE = 1, WATER = 2, ELECTRIC = 0.5, GRASS = 0.5, ICE = 1, FIGHTING = 1, POISON = 1, GROUND = 0, FLYING = 2, PSYCHIC = 1, BUG = 1, ROCK = 1, GHOST = 1, DRAGON = 0.5
    },
    GRASS = {
        NORMAL = 1, FIRE = 0.5, WATER = 2, ELECTRIC = 1, GRASS = 0.5, ICE = 1, FIGHTING = 1, POISON = 0.5, GROUND = 2, FLYING = 0.5, PSYCHIC = 1, BUG = 0.5, ROCK = 2, GHOST = 1, DRAGON = 0.5
    },
    ICE = {
        NORMAL = 1, FIRE = 0.5, WATER = 0.5, ELECTRIC = 1, GRASS = 2, ICE = 0.5, FIGHTING = 1, POISON = 1, GROUND = 2, FLYING = 2, PSYCHIC = 1, BUG = 1, ROCK = 1, GHOST = 1, DRAGON = 2
    },
    FIGHTING = {
        NORMAL = 2, FIRE = 1, WATER = 1, ELECTRIC = 1, GRASS = 1, ICE = 2, FIGHTING = 1, POISON = 0.5, GROUND = 1, FLYING = 0.5, PSYCHIC = 0.5, BUG = 0.5, ROCK = 2, GHOST = 0, DRAGON = 1
    },
    POISON = {
        NORMAL = 1, FIRE = 1, WATER = 1, ELECTRIC = 1, GRASS = 2, ICE = 1, FIGHTING = 1, POISON = 0.5, GROUND = 0.5, FLYING = 1, PSYCHIC = 1, BUG = 2, ROCK = 0.5, GHOST = 0.5, DRAGON = 1
    },
    GROUND = {
        NORMAL = 1, FIRE = 2, WATER = 1, ELECTRIC = 2, GRASS = 0.5, ICE = 1, FIGHTING = 1, POISON = 2, GROUND = 1, FLYING = 0, PSYCHIC = 1, BUG = 0.5, ROCK = 2, GHOST = 1, DRAGON = 1
    },
    FLYING = {
        NORMAL = 1, FIRE = 1, WATER = 1, ELECTRIC = 0.5, GRASS = 2, ICE = 1, FIGHTING = 2, POISON = 1, GROUND = 1, FLYING = 1, PSYCHIC = 1, BUG = 2, ROCK = 0.5, GHOST = 1, DRAGON = 1
    },
    PSYCHIC = {
        NORMAL = 1, FIRE = 1, WATER = 1, ELECTRIC = 1, GRASS = 1, ICE = 1, FIGHTING = 2, POISON = 2, GROUND = 1, FLYING = 1, PSYCHIC = 0.5, BUG = 2, ROCK = 1, GHOST = 0, DRAGON = 1
    },
    BUG = {
        NORMAL = 1, FIRE = 0.5, WATER = 1, ELECTRIC = 1, GRASS = 2, ICE = 1, FIGHTING = 0.5, POISON = 0.5, GROUND = 1, FLYING = 0.5, PSYCHIC = 2, BUG = 1, ROCK = 1, GHOST = 0.5, DRAGON = 1
    },
    ROCK = {
        NORMAL = 1, FIRE = 2, WATER = 1, ELECTRIC = 1, GRASS = 1, ICE = 2, FIGHTING = 0.5, POISON = 1, GROUND = 0.5, FLYING = 2, PSYCHIC = 1, BUG = 2, ROCK = 1, GHOST = 1, DRAGON = 1
    },
    GHOST = { -- Ghost-type MOVES vs other types.
        NORMAL = 0, FIRE = 1, WATER = 1, ELECTRIC = 1, GRASS = 1, ICE = 1, FIGHTING = 0, POISON = 1, GROUND = 1, FLYING = 1, PSYCHIC = 0, BUG = 1, ROCK = 1, GHOST = 2, DRAGON = 1
    },
    DRAGON = {
        NORMAL = 1, FIRE = 1, WATER = 1, ELECTRIC = 1, GRASS = 1, ICE = 1, FIGHTING = 1, POISON = 1, GROUND = 1, FLYING = 1, PSYCHIC = 1, BUG = 1, ROCK = 1, GHOST = 1, DRAGON = 2
    }
}

-- Gen 1 specific adjustments (already incorporated above for PSYCHIC vs BUG/GHOST, and POISON vs BUG)
-- Pokedex.type_chart["PSYCHIC"]["BUG"] = 2; -- Bug moves are super effective against Psychic type.
-- Pokedex.type_chart["PSYCHIC"]["GHOST"] = 0; -- Ghost moves have no effect on Psychic type.
-- Pokedex.type_chart["POISON"]["BUG"] = 0.5; -- Poison attacks are Not Very Effective (0.5x) against Bug type.

--------------------------------------------------------------------------------
-- POKEMON DATA (Examples - Gen 1)
-- Structure: id, name, type1, type2 (nil if none), base_stats = {hp, attack, defense, speed, special}
--------------------------------------------------------------------------------
Pokedex.pokemon_data = {
    [1] = {
        id = 1, name = "BULBASAUR", type1 = "GRASS", type2 = "POISON",
        base_stats = {hp = 45, attack = 49, defense = 49, speed = 45, special = 65}
    },
    [4] = {
        id = 4, name = "CHARMANDER", type1 = "FIRE", type2 = nil,
        base_stats = {hp = 39, attack = 52, defense = 43, speed = 65, special = 50}
    },
    [7] = {
        id = 7, name = "SQUIRTLE", type1 = "WATER", type2 = nil,
        base_stats = {hp = 44, attack = 48, defense = 65, speed = 43, special = 50}
    },
    [16] = {
        id = 16, name = "PIDGEY", type1 = "NORMAL", type2 = "FLYING",
        base_stats = {hp = 40, attack = 45, defense = 40, speed = 56, special = 35}
    },
    [25] = {
        id = 25, name = "PIKACHU", type1 = "ELECTRIC", type2 = nil,
        base_stats = {hp = 35, attack = 55, defense = 30, speed = 90, special = 50}
    }
    -- More Pokemon can be added here, using their Pokedex number as the key.
}

--------------------------------------------------------------------------------
-- Helper function to get a Pokemon's data by its Pokedex ID
--------------------------------------------------------------------------------
function Pokedex.get_pokemon_by_id(id)
    return Pokedex.pokemon_data[id]
end

--------------------------------------------------------------------------------
-- Helper function to get type effectiveness
-- attack_type: string, e.g., "FIRE"
-- defend_type1: string, e.g., "GRASS"
-- defend_type2: string or nil, e.g., "POISON"
-- Returns overall multiplier (e.g., 4, 2, 1, 0.5, 0.25, 0)
--------------------------------------------------------------------------------
function Pokedex.get_effectiveness(attack_type, defend_type1, defend_type2)
    if not Pokedex.type_chart[attack_type] then
        print("Warning: Unknown attacking type: " .. tostring(attack_type))
        return 1 -- Default to normal effectiveness if attacker type is unknown
    end

    local multiplier = 1

    -- Effectiveness against first type
    if Pokedex.type_chart[attack_type][defend_type1] ~= nil then
        multiplier = multiplier * Pokedex.type_chart[attack_type][defend_type1]
    else
        print("Warning: Unknown defending type1: " .. tostring(defend_type1))
    end

    -- Effectiveness against second type, if it exists
    if defend_type2 and defend_type2 ~= "" then
        if Pokedex.type_chart[attack_type][defend_type2] ~= nil then
            multiplier = multiplier * Pokedex.type_chart[attack_type][defend_type2]
        else
            print("Warning: Unknown defending type2: " .. tostring(defend_type2))
        end
    end
    
    return multiplier
end

return Pokedex
