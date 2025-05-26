-- Battle.lua
-- Reads and displays basic information about the current battle state in Pokemon Red.

local Battle = {}

--------------------------------------------------------------------------------
-- BizHawk API Assumptions
-- Please verify and update these with actual BizHawk Lua function names if different.
--------------------------------------------------------------------------------
-- For reading an unsigned 8-bit integer:
local bizhawk_read_u8 = memory.read_u8
-- For reading an unsigned 16-bit integer (Little Endian - common for HP/stats):
local bizhawk_read_u16_le = memory.read_u16_le
-- For console output:
-- local print = print -- Standard Lua print is usually available.

--------------------------------------------------------------------------------
-- WRAM Addresses for Battle Data (Pokemon Red - International)
--------------------------------------------------------------------------------
-- Player's Active Pokemon
local WRAM_PLAYER_BATTLE_SPECIES_ID = 0xD014 -- 1 byte: Species ID
local WRAM_PLAYER_BATTLE_CURRENT_HP = 0xD015 -- 2 bytes (LE): Current HP
local WRAM_PLAYER_BATTLE_STATUS = 0xD018     -- 1 byte: Status condition
local WRAM_PLAYER_BATTLE_LEVEL = 0xD022      -- 1 byte: Level
local WRAM_PLAYER_BATTLE_MAX_HP = 0xD023     -- 2 bytes (LE): Max HP
local WRAM_PLAYER_BATTLE_MOVE1 = 0xD01C      -- 1 byte: Move 1 ID
local WRAM_PLAYER_BATTLE_MOVE2 = 0xD01D      -- 1 byte: Move 2 ID
local WRAM_PLAYER_BATTLE_MOVE3 = 0xD01E      -- 1 byte: Move 3 ID
local WRAM_PLAYER_BATTLE_MOVE4 = 0xD01F      -- 1 byte: Move 4 ID
local WRAM_PLAYER_BATTLE_PP1 = 0xD02D        -- 1 byte: PP for Move 1
local WRAM_PLAYER_BATTLE_PP2 = 0xD02E        -- 1 byte: PP for Move 2
local WRAM_PLAYER_BATTLE_PP3 = 0xD02F        -- 1 byte: PP for Move 3
local WRAM_PLAYER_BATTLE_PP4 = 0xD030        -- 1 byte: PP for Move 4

-- Opponent's Active Pokemon
local WRAM_OPPONENT_BATTLE_SPECIES_ID = 0xCFE5 -- 1 byte: Species ID
local WRAM_OPPONENT_BATTLE_CURRENT_HP = 0xCFE6 -- 2 bytes (LE): Current HP
local WRAM_OPPonent_BATTLE_STATUS = 0xCFE9     -- 1 byte: Status condition
local WRAM_OPPONENT_BATTLE_LEVEL = 0xCFE8      -- 1 byte: Level
local WRAM_OPPONENT_BATTLE_MAX_HP = 0xCFF4     -- 2 bytes (LE): Max HP
local WRAM_OPPONENT_BATTLE_MOVE1 = 0xCFED      -- 1 byte: Move 1 ID
local WRAM_OPPONENT_BATTLE_MOVE2 = 0xCFEE      -- 1 byte: Move 2 ID
local WRAM_OPPONENT_BATTLE_MOVE3 = 0xCFEF      -- 1 byte: Move 3 ID
local WRAM_OPPONENT_BATTLE_MOVE4 = 0xCFF0      -- 1 byte: Move 4 ID
local WRAM_OPPONENT_BATTLE_PP1 = 0xCFFE        -- 1 byte: PP for Move 1
local WRAM_OPPONENT_BATTLE_PP2 = 0xCFFF        -- 1 byte: PP for Move 2
local WRAM_OPPONENT_BATTLE_PP3 = 0xD000        -- 1 byte: PP for Move 3
local WRAM_OPPONENT_BATTLE_PP4 = 0xD001        -- 1 byte: PP for Move 4

--------------------------------------------------------------------------------
-- Helper function to parse the status condition byte
-- Returns a table of strings representing status conditions.
--------------------------------------------------------------------------------
function Battle.parse_status_byte(status_byte)
    local status_conditions = {}
    if status_byte == 0 then return { "OK" } end -- No status

    -- Bits 0-2: Sleep counter (1-7 turns if asleep)
    local sleep_turns = status_byte & 0x07
    if sleep_turns > 0 then
        table.insert(status_conditions, "SLP (" .. sleep_turns .. ")")
    end
    -- Bit 3: Poisoned
    if (status_byte & 0x08) > 0 then table.insert(status_conditions, "PSN") end
    -- Bit 4: Burned
    if (status_byte & 0x10) > 0 then table.insert(status_conditions, "BRN") end
    -- Bit 5: Frozen
    if (status_byte & 0x20) > 0 then table.insert(status_conditions, "FRZ") end
    -- Bit 6: Paralyzed
    if (status_byte & 0x40) > 0 then table.insert(status_conditions, "PAR") end
    -- Bit 7 is typically unused for these common statuses.

    if #status_conditions == 0 and status_byte ~= 0 then
        -- This case should ideally not be reached if parsing is complete for known statuses
        return { "OK (Unknown status bits: " .. string.format("0x%X", status_byte) .. ")" }
    elseif #status_conditions == 0 and status_byte == 0 then
         return { "OK" } -- Should have been caught by the first line
    end
    return status_conditions
end

--------------------------------------------------------------------------------
-- Function to get player's active Pokemon battle data
--------------------------------------------------------------------------------
function Battle.get_player_pokemon_battle_data()
    local data = {}
    data.species_id = bizhawk_read_u8(WRAM_PLAYER_BATTLE_SPECIES_ID)
    data.current_hp = bizhawk_read_u16_le(WRAM_PLAYER_BATTLE_CURRENT_HP)
    data.max_hp = bizhawk_read_u16_le(WRAM_PLAYER_BATTLE_MAX_HP)
    data.level = bizhawk_read_u8(WRAM_PLAYER_BATTLE_LEVEL)
    data.status_byte = bizhawk_read_u8(WRAM_PLAYER_BATTLE_STATUS)
    data.status_conditions = Battle.parse_status_byte(data.status_byte)
    data.moves = {
        bizhawk_read_u8(WRAM_PLAYER_BATTLE_MOVE1),
        bizhawk_read_u8(WRAM_PLAYER_BATTLE_MOVE2),
        bizhawk_read_u8(WRAM_PLAYER_BATTLE_MOVE3),
        bizhawk_read_u8(WRAM_PLAYER_BATTLE_MOVE4)
    }
    data.pps = {
        bizhawk_read_u8(WRAM_PLAYER_BATTLE_PP1),
        bizhawk_read_u8(WRAM_PLAYER_BATTLE_PP2),
        bizhawk_read_u8(WRAM_PLAYER_BATTLE_PP3),
        bizhawk_read_u8(WRAM_PLAYER_BATTLE_PP4)
    }
    -- Later, we can use Pokedex.lua to get names for species_id and moves
    return data
end

--------------------------------------------------------------------------------
-- Function to get opponent's active Pokemon battle data
--------------------------------------------------------------------------------
function Battle.get_opponent_pokemon_battle_data()
    local data = {}
    data.species_id = bizhawk_read_u8(WRAM_OPPONENT_BATTLE_SPECIES_ID)
    data.current_hp = bizhawk_read_u16_le(WRAM_OPPONENT_BATTLE_CURRENT_HP)
    data.max_hp = bizhawk_read_u16_le(WRAM_OPPONENT_BATTLE_MAX_HP)
    data.level = bizhawk_read_u8(WRAM_OPPONENT_BATTLE_LEVEL)
    data.status_byte = bizhawk_read_u8(WRAM_OPPONENT_BATTLE_STATUS)
    data.status_conditions = Battle.parse_status_byte(data.status_byte)
    data.moves = {
        bizhawk_read_u8(WRAM_OPPONENT_BATTLE_MOVE1),
        bizhawk_read_u8(WRAM_OPPONENT_BATTLE_MOVE2),
        bizhawk_read_u8(WRAM_OPPONENT_BATTLE_MOVE3),
        bizhawk_read_u8(WRAM_OPPONENT_BATTLE_MOVE4)
    }
    data.pps = {
        bizhawk_read_u8(WRAM_OPPONENT_BATTLE_PP1),
        bizhawk_read_u8(WRAM_OPPONENT_BATTLE_PP2),
        bizhawk_read_u8(WRAM_OPPONENT_BATTLE_PP3),
        bizhawk_read_u8(WRAM_OPPONENT_BATTLE_PP4)
    }
    return data
end

--------------------------------------------------------------------------------
-- Function to display the collected battle data
--------------------------------------------------------------------------------
function Battle.display_battle_data(player_data, opponent_data)
    print("--- Player Active Pokemon ---")
    print(string.format("  Species ID: %d, Level: %d", player_data.species_id, player_data.level))
    print(string.format("  HP: %d / %d", player_data.current_hp, player_data.max_hp))
    print("  Status: " .. table.concat(player_data.status_conditions, ", "))
    print(string.format("  Move IDs: %3d, %3d, %3d, %3d", player_data.moves[1], player_data.moves[2], player_data.moves[3], player_data.moves[4]))
    print(string.format("  PPs:      %3d, %3d, %3d, %3d", player_data.pps[1], player_data.pps[2], player_data.pps[3], player_data.pps[4]))

    print("--- Opponent Active Pokemon ---")
    print(string.format("  Species ID: %d, Level: %d", opponent_data.species_id, opponent_data.level))
    print(string.format("  HP: %d / %d", opponent_data.current_hp, opponent_data.max_hp))
    print("  Status: " .. table.concat(opponent_data.status_conditions, ", "))
    -- For brevity, not printing opponent's raw move IDs and PPs by default in console, but they are readable.
    -- print(string.format("  Move IDs: %s, %s, %s, %s", unpack(opponent_data.moves)))
    -- print(string.format("  PPs:      %s, %s, %s, %s", unpack(opponent_data.pps)))
    print("-----------------------------")
end

--------------------------------------------------------------------------------
-- Main Execution Block (for testing this script)
-- To use: Load this script in BizHawk's Lua console while in a Pokemon battle.
--------------------------------------------------------------------------------
local function run_battle_diagnostics()
    print("Battle.lua: Attempting to read and display current battle data...")
    local player_battle_data = Battle.get_player_pokemon_battle_data()
    local opponent_battle_data = Battle.get_opponent_pokemon_battle_data()
    Battle.display_battle_data(player_battle_data, opponent_battle_data)
    print("Battle.lua: Data displayed. Script execution finished for this frame/call.")
end

-- If you want this to run automatically when the script is loaded (runs once):
-- run_battle_diagnostics()

-- If you want this to run every frame (continuous update):
-- emu.registerafter(run_battle_diagnostics)
-- Note: The exact BizHawk API for frame-based callbacks might differ.

-- For now, to make it easy to call from console or other scripts:
-- Battle.run_diagnostics = run_battle_diagnostics 
-- You can then call Battle.run_diagnostics() from the Lua console after loading the script.

return Battle
