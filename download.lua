-- Get started:
-- pastebin get xVjG8Q7M sync
-- sync

local packages =
{
    sync = "xVjG8Q7M",
    turtleMovement = "UwAqXj8t",
    castle = "d69f3Vbj",
    pathFind = "KzzvJr3u",
    wallBuild = "ZDgMJGFp",
    turtleInventory = "M9eJH1MW"
    --queue = "RNj78LMd",
}

for module, sha in pairs(packages) do
    shell.run("rm", module)
    shell.run("pastebin", "get", sha, module)
end
