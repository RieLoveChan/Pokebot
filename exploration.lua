-- Pokemon Red (USA/Japan) Exploration and Basic Movement Script for BizHawk
-- Version: 0.2.0
--
-- Purpose:
-- This script reads the player's current X and Y coordinates, map ID, and facing
-- direction from Pokemon Red's memory (WRAM). It then prints this information
-- to the BizHawk Lua console. It also includes basic functions to attempt to
-- move the player character up, down, left, or right by simulating D-pad presses.
-- This serves as a foundational script for developing more complex exploration bots.
--
-- How to Use in BizHawk:
-- 1. Load Pokemon Red (USA or Japan version) in BizHawk.
-- 2. Open the Lua Console (usually found under Tools > Lua Console or similar).
-- 3. In the Lua Console, click 'Script' > 'Open Script...' and select this 'exploration.lua' file.
-- 4. The script will execute:
--    a. It will print the initial player coordinates and map ID.
--    b. It will then attempt to perform a sequence of test movements (e.g., move right, move down).
--    c. Player data will be printed after each attempted move.
--    d. Check the Lua console for output and any error messages.
--
-- Memory Addresses Used (for Pokemon Red USA/Japan - WRAM):
-- - Player X Coordinate: 0xD362
-- - Player Y Coordinate: 0xD361
-- - Current Map ID:     0xD35E
-- - Player Facing:      0xC109 (Sprite 0)
--
-- Important Notes & API Assumptions:
-- - This script relies on ASSUMED BizHawk Lua functions. These may need verification
--   and adjustment based on the actual BizHawk Lua API:
--   - `memory.read_u8(address)`: Assumed for reading game memory. Referenced via `bizhawk_read_u8`.
--   - `joypad.set({button_name = true/false}, controller_number)`: Assumed for controller input.
--     Referenced via `bizhawk_joypad_set`. Assumes controller 1.
--   - `emu.frameadvance()`: Assumed for advancing the emulator by one frame.
--     Referenced via `bizhawk_emu_frameadvance`.
--   - `print()`: Standard Lua function for console output.
--   Consult the official BizHawk Lua documentation to confirm these.
--
-- - Movement:
--   - Movement functions (`move_up`, `move_down`, etc.) press a D-pad button for a
--     set number of frames (`MOVEMENT_FRAMES`). This duration might need tuning.
--   - Successful movement depends on the game state (e.g., not in a battle, menu, or facing an obstacle).
--
-- - Script Execution:
--   - The script currently runs once, performs the predefined test movements, and then stops.
--   - For continuous bot behavior, the main logic would need to be placed in a function
--     called repeatedly by a BizHawk frame-based event (e.g., `emu.registerafter()`).
--     See comments in the main execution block at the end of the script.
--

-- Step 1: Define/Verify BizHawk Lua API assumptions
-- These are assumed functions based on common emulator Lua APIs.
-- Please verify and update these with actual BizHawk Lua function names if different.
-- For example, consult the BizHawk Lua Functions List online.

-- Memory reading: Assumed to be memory.read_u8 for an unsigned 8-bit integer.
-- Used in the get_player_data() function.
local bizhawk_read_u8 = memory.read_u8

-- Joypad input: Assumed to be joypad.set({button_name = true/false}, controller_number)
-- We'll assume controller 1 for the player.
-- Example: joypad.set({Up = true, A = true}, 1)
local bizhawk_joypad_set = function(buttons)
    joypad.set(buttons, 1) -- Assuming joypad.set and controller 1
end

-- Frame advancement: Assumed to be emu.frameadvance()
local bizhawk_emu_frameadvance = function()
    emu.frameadvance() -- Assuming emu.frameadvance()
end

-- Utility function to press a button for a duration of frames
-- Note: Pokemon Red runs at ~60 FPS. A step takes roughly 10-15 frames.
local press_button_for_frames = function(button_table, num_frames)
    bizhawk_joypad_set(button_table)
    for _ = 1, num_frames do
        bizhawk_emu_frameadvance()
    end
    bizhawk_joypad_set({}) -- Release all buttons
    -- Small delay after release to ensure game processes it
    for _ = 1, 2 do 
        bizhawk_emu_frameadvance()
    end
end

-- Update the read_u8 variable in get_player_data to use bizhawk_read_u8
-- (This part requires modifying the existing get_player_data function)

-- (Existing Lua code follows this header)
-- exploration.lua for Pokemon Red (USA/Japan)
-- Step 2: Implement Lua function to read player data

-- Define WRAM addresses
local WRAM_PLAYER_X = 0xD362
local WRAM_PLAYER_Y = 0xD361
local WRAM_MAP_ID = 0xD35E
local WRAM_PLAYER_FACING = 0xC109 -- For player sprite (sprite 0)

---
-- Reads player's current X, Y coordinates, map ID, and facing direction.
-- @return number: Player's X coordinate.
-- @return number: Player's Y coordinate.
-- @return number: Current Map ID.
-- @return number: Player's facing direction (0=down, 4=up, 8=left, 12=right).
function get_player_data()
    -- Use the globally defined (or module-level) bizhawk_read_u8
    local player_x = bizhawk_read_u8(WRAM_PLAYER_X)
    local player_y = bizhawk_read_u8(WRAM_PLAYER_Y)
    local map_id = bizhawk_read_u8(WRAM_MAP_ID)
    local facing_direction = bizhawk_read_u8(WRAM_PLAYER_FACING)

    return player_x, player_y, map_id, facing_direction
end

---
-- Displays the player's data in the BizHawk console.
-- @param player_x number: Player's X coordinate.
-- @param player_y number: Player's Y coordinate.
-- @param map_id number: Current Map ID.
-- @param facing_direction number: Player's facing direction.
function display_player_data(player_x, player_y, map_id, facing_direction)
    local direction_text = "Unknown"
    if facing_direction == 0 then
        direction_text = "Down"
    elseif facing_direction == 4 then
        direction_text = "Up"
    elseif facing_direction == 8 then
        direction_text = "Left"
    elseif facing_direction == 12 then
        direction_text = "Right"
    end

    print(string.format("Player X: %d, Y: %d, Map ID: %d, Facing: %s (%d)",
                        player_x, player_y, map_id, direction_text, facing_direction))
end

-- Step 2: Implement Basic Movement Functions

local MOVEMENT_FRAMES = 15 -- Number of frames to hold a direction button for one step. Adjust if necessary.

---
-- Attempts to move the player character one step up.
function move_up()
    print("Attempting to move UP...")
    press_button_for_frames({Up = true}, MOVEMENT_FRAMES)
    local px, py, mapid, dir = get_player_data()
    display_player_data(px, py, mapid, dir)
    print("Move UP finished.")
end

---
-- Attempts to move the player character one step down.
function move_down()
    print("Attempting to move DOWN...")
    press_button_for_frames({Down = true}, MOVEMENT_FRAMES)
    local px, py, mapid, dir = get_player_data()
    display_player_data(px, py, mapid, dir)
    print("Move DOWN finished.")
end

---
-- Attempts to move the player character one step left.
function move_left()
    print("Attempting to move LEFT...")
    press_button_for_frames({Left = true}, MOVEMENT_FRAMES)
    local px, py, mapid, dir = get_player_data()
    display_player_data(px, py, mapid, dir)
    print("Move LEFT finished.")
end

---
-- Attempts to move the player character one step right.
function move_right()
    print("Attempting to move RIGHT...")
    press_button_for_frames({Right = true}, MOVEMENT_FRAMES)
    local px, py, mapid, dir = get_player_data()
    display_player_data(px, py, mapid, dir)
    print("Move RIGHT finished.")
end

-- Main Execution Block (Script Start)

print("------------------------------------------------------")
print("exploration.lua: Script started.")
print("Reading initial player data...")
local p_x, p_y, m_id, p_dir = get_player_data()
display_player_data(p_x, p_y, m_id, p_dir)
print("------------------------------------------------------")

-- Test basic movement functions
-- You can comment these out or change them as needed.
print("Testing movement functions...")

move_right() -- Test moving right
move_down()  -- Test moving down
-- move_left() -- Example: Test moving left (currently commented out)
-- move_up()   -- Example: Test moving up (currently commented out)

print("------------------------------------------------------")
print("exploration.lua: Movement tests finished.")
print("Script execution complete.")
print("------------------------------------------------------")

-- To make this script run its logic continuously (e.g., for a bot),
-- you would typically register a function to an event that fires every frame.
-- For example, using BizHawk's emu.registerafter():
--
-- local function main_loop()
--     -- Bot logic would go here, e.g.:
--     -- decide_next_move()
--     -- execute_move()
--     -- display_player_data(get_player_data())
--
--     print("In main_loop - current X: " .. get_player_data()) -- Example debug
-- end
--
-- emu.registerafter(main_loop)
--
-- Note: The actual BizHawk API for registering a per-frame callback might be different
-- (e.g., event.onframeend(), etc.). Please consult BizHawk documentation.
-- For now, this script runs once and performs the predefined test movements.
