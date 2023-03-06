BLOCK_SLOTS = 12

function getLayerCount(heightDiff, path_length)
    local layerHeight = math.min(heightDiff, 3)
    return path_length * layerHeight
end

function inventoryCount()
    local count = 0
    for i = 1, BLOCK_SLOTS do
        count = count + turtle.getItemCount(i)
    end
    return count
end

function needsRestock(currentHeight, desiredHeight, path_length, is_line)
    local margin = 16

    local heightDiff = desiredHeight - currentHeight
    local layerCount = getLayerCount(heightDiff, path_length)

    if is_line then
        local nextHeightDiff = desiredHeight - currentHeight - 3
        if nextHeightDiff > 0 then
            layerCount = layerCount + getLayerCount(nextHeightDiff, path_length)
        end
    end

    layerCount = layerCount + margin

    local inventoryCount = inventoryCount()
    print("Inventory: "..tostring(inventoryCount)..". Next pass needs: "..tostring(layerCount))

    return layerCount > inventoryCount
end

function restock(suck_action)
    for i = 1, BLOCK_SLOTS do
        turtle.select(i)
        if suck_action == nil then
            turtle.suckDown(turtle.getItemSpace())
        else
            suck_action(turtle.getItemSpace())
        end
    end
    turtle.select(1)
end

function slot_has_items(block_name)
    return turtle.getItemCount() > 0 and (block_name == nil or (block_name == turtle.getItemDetail().name))
end

function equipBlock(block_name)
    if not slot_has_items(block_name) then
        for i = 1, BLOCK_SLOTS do
            turtle.select(i)
            
            if slot_has_items(block_name) then
                return true
            end

        end
        print("Out of resources")
        return false
    end

    return true
end
