local dir = shell.dir()

os.loadAPI(dir.."/turtleInventory")
os.loadAPI(dir.."/turtleMovement")

os.loadAPI(dir.."/turtleMap")
turtleMap.init(dir)

local function getArgs(args)
    return true
end

local function main(args)
    local argsOk = getArgs(args)
    if not argsOk then
        return
    end

    local has_blocks = turtleInventory.equipBlock()
    if not has_blocks then
        return
    end
    local movement = turtleMovement.new(vector.new(0, 0, 0), 0)
    print("Flooring!")
    turtleMap.floor(movement)
    print("Floor finished")
end



local args = {...}
main(args)