# Get Starting
In your Computer Craft turtle terminal run the following
```
pastebin get xVjG8Q7M sync
sync
```

## Comand Directory
I'd recomend creating a folder for these scripts. Before running the above, first run.
```
mkdir castle
cd castle
```

## Enable HTTP
In order to use the Computer Craft pastebin command, you must first set `enable_http=true` in the computercraft server toml config

## Pastebin Packaging
`download.lua` defines all files uploaded to pastebin. If these files go offline you can upload each of them and update the `download.lua` pastebin URL ID.

# Power
The turtle requires power. Place a stack of coal (or another smelting item) in the turtle and run
```
refuel all
```

# Movement
If you need to move your turtle after placing it, you the `go` command. You can chain direction and add numbers after directions to specify distance
```
go forward 3
```

```
go back left forward right
```

# Set Up
1. Pick your build block.
2. Build your base layer. All blocks must be connected. Diagonals are allowed.
3. Place your turtle on top of the starting block. It must be facing another block in your base layer.
4. Place your restock chest (or other inventory object) behind the turtle and one below. (Your starting block cannot be in front of another base block)
5. Fill the first 12 slots of the inventory of the turle with your block (the rest can be used for fuel)
6. Fill the inventory of the restock chest with your block

# Running
```
castle <height>
```
height: does not include the base layer

# Building
The turtle will return to the restock chest if it needs more blocks. Do not block the path to it.

When finished, it will return to the restock chest.

# Config and Future Work
- Currently, the program requires a path of 3 or more blocks to consider a valid path. You can change that in the `generate_path` call in `caste.lua`
- To allow for fuel slots, the program only uses the first 12 slots of the turtle's inventory. This can be change by adjusting the `BLOCK_SLOTS` in `turtleInventory.lua`
