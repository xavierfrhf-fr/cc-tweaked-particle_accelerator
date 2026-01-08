--Code for CC:Tweaked to manage an oritech particle accelerator system
-- DEBUG FUNCTION
local function print_table(table)
    for key, value in ipairs(table) do
        print("key : " .. key .. ", value : " .. value)
    end
end

-- TABLES
local verbose = {
    periph = true
    speed = false
}

local craft = {
    number_of_accelerators = 1,
    ring_of_colision = 1
} -- might be generated later in the initialization phase

local periph_name = {
    A1R1I1 = "redstone_relay_4",
    A1R1O1 = "redstone_relay_5",
    A2R1I1 = "redstone_relay_6",
    A2R1O1 = "redstone_relay_7",
}

local hardware_state = {
    A1 = {
        active = false,
        R1 = {
            I1 = 0,
            O1 = true
        },
        R2 = {
            I1 = 0,
            O1 = true,
            O2 = true
        }
    },
    A2 = {
        active = false,
        R1 = {
            I1 = 0,
            O1 = true
        },
        R2 = {
            I1 = 0,
            O1 = true,
            O2 = true
        }
    }
}




local wrapped_periph = {}

-- WRAP PERIPHERALS
local function wrap_peripherals()
    local R
    for name, periph in pairs(periph_name) do
        R = peripheral.wrap(periph)
        if R == nil then
            print("Could not wrap peripheral " .. periph)
        else
            wrapped_periph[name] = R
        end
        if verbose.periph then
            print("Wrapped peripheral " .. periph .. " as " .. name)
        end
    end
end

-- CALLABLE FUNCTIONS
local function pulse_relay()
    -- pulse relay code here
end

local function start_craft()
    -- start craft code here
end


-- MAIN ASYNC FUNCTIONS
local function user_cmd_input()
    while true do
        local input = read()
        if input == "exit" then
            print("Exiting program...")
            os.exit()
        elseif input == "start" then
            if hardware_state.A1.active or hardware_state.A2.active then
                print("Accelerator already running!")
            else
                start_craft()
                print("Starting accelerator...")
            end

        else
            print("Unknown command: " .. input)
        end
        coroutine.yield()
    end

local function observe_speed()
    while true do
        hardware_state.A1.R1.I1 = wrapped_periph.A1R1I1.getAnalogInput('top')
        hardware_state.A2.R1.I1 = wrapped_periph.A2R1I1.getAnalogInput('top')
        coroutine.yield()
    end
end





