function init(dir)
    os.loadAPI(dir.."/turtleMovement")
end


local function find_next_block(turtleMovementObject, current_block, previous_block)
    if turtle.getItemCount() == 0 then
        print("No item in current slot, can't compare")
        return false
    end
    -- Start right and make a loop around the block	
    local originalPosition = turtleMovementObject.position
    -- local originalDirection = turtleMovementObject.direction
    local enteredDirection = turtleMovement.get_direction(previous_block, current_block)
    if enteredDirection == -1 then
        print(tostring(previous_block).." to "..tostring(current_block).."must be 1 away including diagonal")
        return false
    end

    local circleOffsets
    local diagonal = enteredDirection % 2 == 1

    if not diagonal then
        -- forward, back, right, then sweap left
        circleOffsets = {0, -1, 2, 1, 0, 7, 6}
    else
        -- right forward, then right, then sweap left
        circleOffsets = {1, 2, 1, 0, 7, 6}
    end
    
    for _, directionOffset in ipairs(circleOffsets) do
        local desiredDirection = -1
        if directionOffset ~= -1 then
            desiredDirection = (directionOffset + enteredDirection) % 8
        end
        local destination = originalPosition + turtleMovement.get_compass_direction(desiredDirection)

        local moveSucess = turtleMovementObject:move(destination)

        if not moveSucess then
            print("find_next_block move failed")
            return false
        end
            
        if turtle.compareDown() and turtleMovementObject.position ~= current_block and turtleMovementObject.position ~= previous_block then
            return true
        end
    end
    
    print("No block found")
    return false
end

-- Generate path -> success, path array
function generate_path(turtleMovement, min_length)
    local path = {}
    local previous_block = turtleMovement.position + vector.new(0, -1, 0)
    local current_block = turtleMovement.position
    local block_found = true
    local index = 1
    while block_found do
        -- Add current position to path array
        path[index] = current_block
        index = index + 1
        -- TODO Place block
        -- Find the next block
        
        block_found = find_next_block(turtleMovement, current_block, previous_block)
        
        if block_found then
            print(turtleMovement.position)
        
            previous_block = current_block
            current_block = turtleMovement.position

            -- We have a loop, add it to the end
            if current_block == path[1] then
                print("Found a loop!")
                path[index] = current_block
                block_found = false
            end
        end
    end

    -- Path must be longer than min_length
    if #path < min_length then
        print("Path length "..#path.." was shorter than min_length of "..min_length)
        return false, nil
    end

    return true, path
end

function output_path(path)
    print("Path:")
    for i = 1, #path do
        term.write(tostring(path[i]).."; ")
        if(i % 4 == 0) then
            print("")
        end
    end
    print("")
end
