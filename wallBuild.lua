function init(dir)
    os.loadAPI(dir.."/turtleInventory")
end

local function equip_and_place(place_function)

    turtleInventory.equipBlock()
    return place_function()
end

local function place_above_below(current_height, desired_height)
    local placeResult
    -- Only place above if more than 1 away from desired_height
    if desired_height - current_height > 1 then
        placeResult = equip_and_place(turtle.placeUp)
        if not placeResult then
            print("Above place failed")
            return false
        end
    end

    placeResult = equip_and_place(turtle.placeDown)
    if not placeResult then
        print("place_above_below, Below place failed")
        return false
    end

    return true
end

local function get_next_block(current_block_index, path_length, is_line, current_height, iteration_direction)
    current_block_index = current_block_index + iteration_direction
        
    if current_block_index > path_length or current_block_index <= 0 then
        current_height = current_height + 3

        -- TODO: This is a bit fragile
            
        if(is_line) then
            iteration_direction = iteration_direction * -1
            current_block_index = current_block_index + iteration_direction
        else
            current_block_index = 1
        end
    end

    return current_block_index, current_height, iteration_direction
end

local function head_to_stock(turtleMovementObject)
    return turtleMovementObject:move(vector.new(0, -1, 0))
end

local function restock(turtleMovementObject)
    print("Inventory low, restocking...")
    local result = head_to_stock(turtleMovementObject)
    if not result then
        print("Failed to move to stock")
        return false
    end
    turtleInventory.restock()
    return true
end

local function finish_cycle(turtleMovementObject, currentHeight, desiredHeight, next_height, path_length, is_home, is_line)
    for i = 1, math.min(desiredHeight - currentHeight + 1, 3) do
        local placeResult = equip_and_place(turtle.placeDown)
        if not placeResult then
            print("Finish cycle, below place failed")
            return false
        end

        turtleMovementObject:move_relative(vector.new(0, 0, 1))
    end

    if is_home and turtleInventory.needsRestock(next_height, desiredHeight, path_length, is_line) then
        local restockResult = restock(turtleMovementObject)
        if not restockResult then
            return false
        end
    end

    return true
end

local function place_block(turtleMovementObject,
                           path,
                           path_length,
                           current_block_index,
                           current_height,
                           desired_height,
                           iteration_direction,
                           is_line)

    -- Most likely will already be here
    local current_block = path[current_block_index]
    local destination = current_block + vector.new(0, 0, current_height)
    local moveResult = turtleMovementObject:move(destination)
    if not moveResult then
        print("Move failed to"..tostring(destination))
        return false
    end

    -- Get the next block
    local next_block_index, new_height
    next_block_index, new_height, iteration_direction = get_next_block(
        current_block_index, path_length, is_line, current_height, iteration_direction
    )

    if new_height == current_height then
        place_above_below(current_height, desired_height)

        local next_block = path[next_block_index]
        local next_destination = next_block + vector.new(0, 0, current_height)
    
        -- Place behind (only if height allows)
        if desired_height - current_height > 0 then
            turtleMovementObject:move(next_destination, 1)
            local turnResult = turtleMovementObject:turn_towards_block(destination)
            if not turnResult then
                return false
            end
            equip_and_place(turtle.place)
        end


        turtleMovementObject:move(next_destination)
    -- If height move, go upwards
    else
        print("Cycle complete: "..string.format("%.1f", (current_height / desired_height) * 100).."%")
        local is_home = iteration_direction == 1
        local finish_cycle_result = finish_cycle(turtleMovementObject, current_height, desired_height, new_height, path_length, is_home, is_line)
        if not finish_cycle_result then
            print("Finish cycle failed")
            return false
        end
    end
    

    return true, next_block_index, iteration_direction, new_height
end


-- Build(line or loop, path array) -> success?
function build(turtleMovementObject, path, desired_height)
    local current_height = 1
    local path_length = #path
    local is_line = path[1] ~= path[path_length]
    local iteration_direction = 1
    
    local current_block_index = 1
    
    -- Remove the duplicate block in a loop
    if(not is_line) then
        path_length = path_length - 1
    end

    -- Check if we need to restock
    if turtleInventory.needsRestock(current_height, desired_height, path_length, false) then
        restock(turtleMovementObject)
    elseif is_line then
        -- Line needs to start at the end if it didn't need to head back to restock
        current_block_index = path_length
        iteration_direction = -1
    end

    -- While not stuck and current_height < desired_height and not at end
    while current_height <= desired_height do
        -- local move_to_block = path[current_block_index]
        local result
        result, current_block_index, iteration_direction, current_height  = place_block(turtleMovementObject,
                                                                              path,
                                                                              path_length,
                                                                              current_block_index,
                                                                              current_height,
                                                                              desired_height,
                                                                              iteration_direction,
                                                                              is_line)
        if not result then
            return false
        end
    end

    head_to_stock(turtleMovementObject)
    return true
end