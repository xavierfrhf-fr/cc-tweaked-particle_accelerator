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
}

local periph_name = {
    A1R1I1 = "redstone_relay_4",
    A1R1O1 = "redstone_relay_5",
    A2R1I1 = "redstone_relay_6",
    A2R1O1 = "redstone_relay_7",
}

local hardware_state = {
    A1 = {
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


-- MAIN ASYNC FUNCTIONS

local function observe_speed()
    while true do
        hardware_state.A1.R1.I1 = wrapped_periph.A1R1I1.getAnalogInput('top')
        hardware_state.A2.R1.I1 = wrapped_periph.A2R1I1.getAnalogInput('top')
        coroutine.yield()
    end
end





