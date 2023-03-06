-- local dir = shell.dir()
-- os.loadAPI(dir.."/queue")

local compassDirections = {vector.new(0, 1, 0), vector.new(1, 1, 0), vector.new(1, 0, 0), vector.new(1, -1, 0), vector.new(0, -1, 0), vector.new(-1, -1, 0), vector.new(-1, 0, 0), vector.new(-1, 1, 0)}

function get_compass_direction(direction)
    if direction == -1 then
        return vector.new(0, 0, 0)
    end
    return compassDirections[direction + 1]
end

function get_direction(previous_block, current_block)
    local positionDiff = current_block - previous_block
    -- TODO: Optimize to lookup table
    for direction, compass in ipairs(compassDirections) do
        if compass == positionDiff then
            return direction - 1
        end
    end
    return -1
end

local turtlePlus = {
    turn_towards = function (self, desired_direction)
        local offset = (desired_direction - self.direction) % 8
        if offset == 6 then
            turtle.turnLeft()
        else
            for i = 1, offset / 2 do
                turtle.turnRight()
            end
        end
        self.direction = desired_direction
    end,

    turn_towards_block = function(self, destination)
        --print("curent pos "..tostring(self.position))
        --print("look at "..tostring(destination))
        local direction = get_direction(self.position, destination)
        if direction == -1 or direction % 2 == 1 then
            print("Must be adjecent, excluding diagonals got: "..tostring(direction))
            return false
        end

        self:turn_towards(direction)
        return true
    end,
    
    go_forward = function(self, distance)
        for i = 1, distance do
            local moveResult = turtle.forward()
            if not moveResult then
                return false
            end

            self.position = self.position + get_compass_direction(self.direction)
        end
        
        return true
    end,

    go_back = function(self, distance)
        for i = 1, distance do
            local moveResult = turtle.back()
            if not moveResult then
                return false
            end

            self.position = self.position + get_compass_direction((self.direction + 4) % 8)
        end
        
        return true
    end,

    go_up = function(self, distance)
        for i = 1, distance do
            local moveResult = turtle.up()
            if not moveResult then
                return false
            end

            self.position = self.position + vector.new(0, 0, 1)
        end
        
        return true
    end,

    go_down = function(self, distance)
        for i = 1, distance do
            local moveResult = turtle.down()
            if not moveResult then
                return false
            end

            self.position = self.position + vector.new(0, 0, -1)
        end
        
        return true
    end,
    
    move_distance = function(self, desired_direction, distance)
        -- If I want to move back, just do it
        if (desired_direction - self.direction) % 8 == 4 then
            return self:go_back(distance)
        end

        self:turn_towards(desired_direction)
        return self:go_forward(distance)
    end,
    
    move_vert = function (self, destination, steps_towards)
        local position_diff = destination - self.position
        local vertAmmount = math.abs(position_diff.y)
        if steps_towards ~= nil then
            vertAmmount = min(vertAmmount, steps_towards)
        end
        if position_diff.y ~= 0 then
        
            local desiredDirection
            
            if position_diff.y > 0 then
                desiredDirection = 0 
            else 
                desiredDirection = 4
            end
            
            return self:move_distance(desiredDirection, vertAmmount), vertAmmount
        end
        
        return true, vertAmmount
    end,
    
    move_hor = function(self, destination, steps_towards)
        local position_diff = destination - self.position
        local horizonalAmmount = math.abs(position_diff.x)
        if steps_towards ~= nil then
            horizonalAmmount = min(horizonalAmmount, steps_towards)
        end

        if position_diff.x ~= 0 then
        
            local desiredDirection
            
            if position_diff.x > 0 then
                desiredDirection = 2
            else 
                desiredDirection = 6
            end
            
            return self:move_distance(desiredDirection, horizonalAmmount), horizonalAmmount
        end
        
        return true, horizonalAmmount
    
    end,

    move_up = function(self, destination)
        local position_diff = destination - self.position
        if position_diff.z ~= 0 then
            
            if position_diff.z > 0 then
                return self:go_up(math.abs(position_diff.z))
            else 
                return self:go_down(math.abs(position_diff.z)) 
            end
        end
        
        return true
    end,

    am_i_facing = function(self, destination)
        local position_diff = destination - self.position
        local heading_vector = vector.new(position_diff.x / math.abs(position_diff.x), position_diff.y / math.abs(position_diff.y), 0)

        local compass_vector = get_compass_direction(self.direction)
        if heading_vector.x ~= 0 and heading_vector.x == compass_vector.x then
            return true
        end

        if heading_vector.y ~= 0 and heading_vector.y == compass_vector.y then
            return true
        end

        return false
    end,

    move_order = function(self, destination)
        local facing_x = self.direction == 2 or self.direction == 6

        if facing_x then
            return {self.move_hor, self.move_vert}
        end

        return {self.move_vert, self.move_hor}
    end,
    
    move = function (self, destination, steps_towards)
        -- TODO: Refuel if needed
        -- TODO: steps_towards isn't really tested for anything besides 1
        local firstSuccessUp = self:move_up(destination)
        local cardinal_moves = self:move_order(destination)
        --local move_order = {self.move_up, table.unpack(cardinal_moves)}

        -- TODO: Use a queue to try failed movements again
        local steps = 0
        for _, move in ipairs(cardinal_moves) do
            local success, step_count = move(self, destination, steps_towards)

            steps = steps + step_count
            if steps_towards ~= nil and steps >= steps_towards then
                --print("Stepped "..tostring(steps_towards))
                break
            end
        end

        if steps_towards ~= nil and steps >= steps_towards then
            return true
        end

        for index, _ in ipairs(cardinal_moves) do
            local move = cardinal_moves[#cardinal_moves - index + 1]
            local success, step_count = move(self, destination, steps_towards)
            if not success then
                --print("2D move to "..tostring(destination).." failed")
                return false
            end

            steps = steps + step_count
            if steps_towards ~= nil and steps >= steps_towards then
                --print("Stepped "..tostring(steps_towards))
                break
            end
        end

        

        local secondSuccessUp = self:move_up(destination)

        if not firstSuccessUp and not secondSuccessUp then
            --print("Up move to "..tostring(destination).."failed")
            return false
        end

        return true
    end,

    move_relative = function(self, diff)
        return self:move(self.position + diff)
    end
}


local metatable = {
    __index = turtlePlus
}

function new(startingPosition, startingDirection)
    return setmetatable({
        position = startingPosition,
        direction = startingDirection
    }, metatable)
end
