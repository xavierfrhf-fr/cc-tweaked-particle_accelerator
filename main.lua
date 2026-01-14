--Code for CC:Tweaked to manage an oritech particle accelerator system
-- v1.1.3
-- DEBUG FUNCTION
local function print_table(table)
    for key, value in ipairs(table) do
        print("key : " .. key .. ", value : " .. value)
    end
end

-- TABLES
local pulseLen = {
    O = 0.2,
    E = 0.5
} -- seconds

local verbose = {
    periph = true,
    speed = false
}

local craft = {
    A1 = {
        n_item = 0,
        R1 = {
            speed_target = 5,
            collisions = false,
            upper_ring = true,
            item_injection = false
        },
        R2 = {
            speed_target = 12,
            collisions = true,
            upper_ring = false,
            item_injection = false
        }
    },
    A2 = {
        n_item = 1,
        R1 = {
            speed_target = 5,
            collisions = false,
            upper_ring = true,
            item_injection = false
        },
        R2 = {
            speed_target = 12,
            collisions = false,
            upper_ring = false,
            item_injection = true
        }

    }
} -- might be generated later in the initialization phase

local periph_name = {
    A1R1I1 = "redstone_relay_4",
    A1R1O1 = "redstone_relay_5",
    A2R1I1 = "redstone_relay_6",
    A2R1O1 = "redstone_relay_20",
    A1R2O2 = "redstone_relay_8",
    A1R2I1 = "redstone_relay_9",
    A1R2O1 = "redstone_relay_10",
    A2R2O2 = "redstone_relay_11",
    A2R2I1 = "redstone_relay_12",
    A2R2O1 = "redstone_relay_13",
    A2R1O2 = "redstone_relay_14",
    A1R1O2 = "redstone_relay_15",
    A2R1E1 = "redstone_relay_16",
    A1R1E1 = "redstone_relay_17",
    A1R2E1 = "redstone_relay_18",
    A2R2E1 = "redstone_relay_22"
}

local hardware_state = {
    A1 = {
        active = false,
        R1 = {
            I1 = 0,
            O1 = {
                actual = true,
                default = true,
            }, 
            O2 = {
                actual = true,
                default = true
            },
            E1 = {
                actual = true,
                default = true
            }
        },
        R2 = {
            I1 = 0,
            O1 = {
                actual = true,
                default = true
            },
            O2 = {
                actual = true,
                default = true
            },
            E1 = {
                actual = true,
                default = true
            }
        }
    },
    A2 = {
        active = false,
        R1 = {
            I1 = 0,
            O1 = {
                actual = true,
                default = true
            },
            O2 = {
                actual = true,
                default = true
            },
            E1 = {
                actual = true,
                default = true

            }
        },
        R2 = {
            I1 = 0,
            O1 = {
                actual = true,
                default = true,
            },
            O2 = {
                actual = true,
                default = true,
            },
            E1 = {
                actual = true,
                default = true,
            }
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
local function pulse_relay(relay_name)
    if wrapped_periph[relay_name] == nil then
        print("Cannot pulse relay " .. relay_name .. ": not wrapped!")
        return false
    else
        
        relay_accelerator = relay_name:sub(1,2)
        relay_ring = relay_name:sub(3,4)
        relay_type = relay_name:sub(5, 6)
        default_state = hardware_state[relay_accelerator][relay_ring][relay_type].default
        actual_state = hardware_state[relay_accelerator][relay_ring][relay_type].actual
        if verbose.periph then
            print("Pulsing relay " .. relay_name .. " for " .. pulseLen[relay_type:sub(1,1)] .. " seconds.")
            if actual_state ~= default_state then
                print("Warning: relay " .. relay_name .. " actual state (" .. tostring(actual_state) .. ") differs from default state (" .. tostring(default_state) .. ")!")
            end
        relay = wrapped_periph[relay_name]
        hardware_state[relay_accelerator][relay_ring][relay_type].actual = not default_state
        relay.setOutput('top', not default_state)
        os.sleep(pulseLen[relay_type:sub(1,1)])
        relay.setOutput('top', default_state)
        hardware_state[relay_accelerator][relay_ring][relay_type].actual = default_state
        return true
        end
    end        
end

local function pulse_2_relays(relay_name1, relay_name2)
    --Send pulse to both relays simultaneously
    if wrapped_periph[relay_name1] == nil then
        print("Cannot pulse relay " .. relay_name1 .. ": not wrapped!")
        return false
    end
    if wrapped_periph[relay_name2] == nil then
        print("Cannot pulse relay " .. relay_name2 .. ": not wrapped!")
        return false
    end
    relay_accelerator1 = relay_name1:sub(1,2)
    relay_ring1 = relay_name1:sub(3,4)
    relay_type1 = relay_name1:sub(5, 6)
    default_state1 = hardware_state[relay_accelerator1][relay_ring1][relay_type1].default
    relay_accelerator2 = relay_name2:sub(1,2)
    relay_ring2 = relay_name2:sub(3,4)
    relay_type2 = relay_name2:sub(5, 6)
    default_state2 = hardware_state[relay_accelerator2][relay_ring2][relay_type2].default
    if verbose.periph then
        print("Pulsing relays " .. relay_name1 .. " and " .. relay_name2 .. " simultaneously for " .. math.max(pulseLen[relay_type1:sub(1,1)], pulseLen[relay_type2:sub(1,1)]) .. " seconds.")
    end
    relay1 = wrapped_periph[relay_name1]
    relay2 = wrapped_periph[relay_name2]
    hardware_state[relay_accelerator1][relay_ring1][relay_type1].actual = not default_state1
    hardware_state[relay_accelerator2][relay_ring2][relay_type2].actual = not default_state2
    relay1.setOutput('top', not default_state1)
    relay2.setOutput('top', not default_state2)
    os.sleep(math.max(pulseLen[relay_type1:sub(1,1)], pulseLen[relay_type2:sub(1,1)]))
    relay1.setOutput('top', default_state1)
    relay2.setOutput('top', default_state2)
    hardware_state[relay_accelerator1][relay_ring1][relay_type1].actual = default_state1
    hardware_state[relay_accelerator2][relay_ring2][relay_type2].actual = default_state2
    return true
end




local function plan_craft()
    -- plan craft code here
end

local function start_craft()
    if craft.A1.n_item <= 0 and craft.A2.n_item <= 0 then
        print("No items to process in either accelerator!")
        return false
    elseif craft.A1.n_item > 0 and craft.A2.n_item > 0 then
        craft.A1.n_item = craft.A1.n_item - 1
        craft.A2.n_item = craft.A2.n_item - 1
        pulse_2_relays("A1R1E1", "A2R1E1")
        hardware_state.A1.active = true
        hardware_state.A2.active = true
        print("Starting craft in Accelerator A1 with " .. craft.A1.n_item .. " items.")

    elseif craft.A1.n_item > 0 then
        craft.A1.n_item = craft.A1.n_item - 1
        pulse_relay("A1R1E1")
        hardware_state.A1.active = true
    elseif craft.A2.n_item > 0 then
        craft.A2.n_item = craft.A2.n_item - 1
        pulse_relay("A2R1E1")   
        hardware_state.A2.active = true
    end
end

-- INITIALIZATION FUNCTIONS
local function init_relays()
    for name, periph in pairs(periph_name) do
        relay_accelerator = name:sub(1,2)
        relay_ring = name:sub(3,4)
        relay_type = name:sub(5, 6)
        if relay_type:sub(1,1) == "I" then
            if verbose.periph then
                print("Skipping initialization of input relay " .. name)
            end
        elseif relay_type:sub(1,1) == "O" or relay_type:sub(1,1) == "E" then
            default_state = hardware_state[relay_accelerator][relay_ring][relay_type].default
            if wrapped_periph[name] ~= nil and relay_type:sub(1,1) ~= "I" then
                wrapped_periph[name].setOutput('top', default_state)
                hardware_state[relay_accelerator][relay_ring][relay_type].actual = default_state
                if verbose.periph then
                    print("Initialized relay " .. name .. " to default state: " .. tostring(default_state))
                end
            else
                print("Cannot initialize relay " .. name .. ": not wrapped!")
            end
        else
            print("Cannot initialize relay " .. name .. ": unknown type " .. relay_type)
        end
    end
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
end

local function observe_speed()
    while true do
        hardware_state.A1.R1.I1 = wrapped_periph.A1R1I1.getAnalogInput('top')
        hardware_state.A2.R1.I1 = wrapped_periph.A2R1I1.getAnalogInput('top')
        hardware_state.A1.R2.I1 = wrapped_periph.A1R2I1.getAnalogInput('top')
        hardware_state.A2.R2.I1 = wrapped_periph.A2R2I1.getAnalogInput('top')
        if verbose.speed then
            print("A1R1I1 speed: " .. hardware_state.A1.R1.I1)
            print("A2R1I1 speed: " .. hardware_state.A2.R1.I1)
        end
        coroutine.yield()
    end
end

local function event_manager()
    while true do
        ready_to_collide = false
        if hardware_state.A1.active then
            if hardware_state.A1.R1.I1 >= craft.A1.R1.speed_target then
                print("A1R1 reached target speed!")
                if craft.A1.R1.item_injection then
                    print("Injecting item into A1R1...")
                    print("Not implemented yet.")
                elseif craft.A1.R1.upper_ring then
                    print("Activating upper ring for A1R1...")
                    pulse_relay("A1R1O1")
                elseif craft.A1.R1.collisions then
                    ready_to_collide = true
                    print("Managing collisions for A1R1...")
                end
            elseif hardware_state.A1.R2.I1 >= craft.A1.R2.speed_target then
                print("A1R2 reached target speed!")
                if craft.A1.R2.item_injection then
                    print("Injecting item into A1R2...")
                    pulse_relay("A1R2E1")
                    print("Not implemented yet.")
                elseif craft.A1.R2.upper_ring then
                    print("Activating upper ring for A1R2...")
                    print("Not implemented yet.")
                elseif craft.A1.R2.collisions then
                    ready_to_collide = true
                    print("A1R2 Ready for collision...")
                end
            end
        end
        if hardware_state.A2.active then
            if hardware_state.A2.R1.I1 >= craft.A2.R1.speed_target then
                print("A2R1 reached target speed!")
                if craft.A2.R1.item_injection then
                    print("Injecting item into A2R1...")
                elseif craft.A2.R1.upper_ring then
                    print("Activating upper ring for A2R1...")
                elseif craft.A2.R1.collisions then
                    ready_to_collide = true
                    print("Managing collisions for A2R1...")
                end
            elseif hardware_state.A2.R2.I1 >= craft.A2.R2.speed_target then
                print("A2R2 reached target speed!")
                if craft.A2.R2.item_injection then
                    print("Injecting item into A2R2...")
                    pulse_relay("A2R2E1")
                elseif craft.A2.R2.upper_ring then
                    print("Activating upper ring for A2R2...")
                elseif craft.A2.R2.collisions then
                    if ready_to_collide then
                        print("Both accelerators ready to collide! Initiating collision sequence...")
                        pulse_2_relays("A1R1O1", "A2R1O1")
                    else
                        print("A2R2 ready for collision, but A2R1 not ready yet.")
                    end
                    
                end
            end
        end
        coroutine.yield()
    end
end


    


-- MAIN PROGRAM
wrap_peripherals()
init_relays()
parallel.waitForAll(
    user_cmd_input,
    observe_speed,
    event_manager
)


