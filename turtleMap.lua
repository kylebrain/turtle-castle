function init(dir)
    os.loadAPI(dir.."/turtleMovement")
    os.loadAPI(dir.."/turtleInventory")
end

function distance(start, destination)
    local dif = destination - start
    return dif:length()
end

function closest_block(turtleMove, blocks)
    -- Defer to front or back
    local front = turtleMove.position + turtleMovement.get_compass_direction(turtleMove.direction)
    if blocks[hash_vector(front)] ~= nil then
        return front
    end

    local back = turtleMove.position + turtleMovement.get_compass_direction((turtleMove.direction + 4) % 8)
    if blocks[hash_vector(back)] ~= nil then
        return back
    end

    local closest
    local min_distance
    for block_hash, _ in pairs(blocks) do
        local block = unhash_vector(block_hash)
        local distance = distance(turtleMove.position, block)
        if closest == nil or distance < min_distance then
            min_distance = distance
            closest = block
        end
    end

    return closest
end

function get_adjacent(turtleMove)
    adjacent = {}
    for i = 1, 4 do
        local dif = turtleMovement.get_compass_direction((i-1) * 2)
        adjacent[i] = turtleMove.position + dif
    end
    return adjacent
end

function split(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function hash_vector(vector)
    return tostring(vector)
end

function unhash_vector(hash)
    local vector_array = split(hash, ",")
    return vector.new(tonumber(vector_array[1]), tonumber(vector_array[2]), tonumber(vector_array[3]))
end

-- TODO: Check turtle api calls
function map(turtleMove, borderBlock, floor_block_name)

    -- search = { current position }
    local to_search = { }
    local have_searched = {}
    to_search[hash_vector(turtleMove.position)] = true
    while next(to_search) ~= nil do
        local closest = closest_block(turtleMove, to_search)

        -- Remove from search
        to_search[hash_vector(closest)] = nil
        -- Add to searched
        have_searched[hash_vector(closest)] = true

        -- print("Searched: ")
        -- for searched, _ in pairs(have_searched) do
        --     term.write(tostring(searched).."; ")
        -- end
        -- print("")

        -- Move to closest unsearched
        local can_move = turtleMove:move(closest)
        -- If can move there
        if can_move then
            local is_block_below, block_below = turtle.inspectDown()
            --print("border block: "..tostring(borderBlock.name).." below block: "..tostring(block_below.name))
            if borderBlock == nil or not is_block_below or (is_block_below and block_below.name ~= borderBlock.name) then
                -- Dig down
                if is_block_below and block_below.name ~= floor_block_name then
                    turtle.digDown()
                end
                
                -- Equip
                local can_equip = turtleInventory.equipBlock(floor_block_name)
                if not can_equip then
                    return
                end
                -- Place down
                local placed = turtle.placeDown()
                -- If Placed
                if placed then
                    -- Add adj to search list
                    local adj = get_adjacent(turtleMove)
                    --term.write("Adding: ")
                    for i=1, #adj do
                        local hashed_adj = hash_vector(adj[i])
                        if have_searched[hashed_adj] == nil and to_search[hashed_adj] == nil then
                            --term.write(hashed_adj..", ")
                            to_search[hashed_adj] = true
                        end
                    end
                    --print("")
                end
                end
            end

        end

        turtleMove:move(vector.new(0,0,0))


end

function floor(turtleMove)

    turtle.select(1)
    local floor_block = turtle.getItemDetail()
    local floor_block_name
    if floor_block == nil then
        print("First slot must have your floor block")
        return
    else
        print("Floor block is "..tostring(floor_block.name))
        floor_block_name = floor_block.name
    end

    local borderBlock = nil
    local is_block, block = turtle.inspectDown()
    if is_block then
        borderBlock = block
        turtleMove:move_relative(vector.new(0, 1, 0))
    end

    map(turtleMove, borderBlock, floor_block_name)

end
