local dir = shell.dir()
os.loadAPI(dir.."/turtleMovement")
os.loadAPI(dir.."/wallBuild")
wallBuild.init(dir)
os.loadAPI(dir.."/pathFind")
pathFind.init(dir)
os.loadAPI(dir.."/turtleInventory")


local function getArgs(args)
    local heightArg = args[1]
    if heightArg == nil then
        print("Usage castle <height>")
        return false
    end
    
    local height = tonumber(heightArg)

    return true, height
end

local function main(args)
    local argsOk, height = getArgs(args)
    if not argsOk then
        return
    end

    local has_blocks = turtleInventory.equipBlock()
    if not has_blocks then
        return
    end
    local movement = turtleMovement.new(vector.new(0, 0, 0), 0)
    local success, path = pathFind.generate_path(movement, 3)
    if success then
        pathFind.output_path(path)
        print("Build starting...")
        local buildSucess = wallBuild.build(movement, path, height)
        if not buildSucess then
            print("Build failed")
            return
        end

        print("Build done")
    end
end



local args = {...}
main(args)
