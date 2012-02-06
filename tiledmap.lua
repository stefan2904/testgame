-- TiledMapLoader
-- code by ghoulsblade via love2d forum
-- modified by stefan
-- https://love2d.org/forums/viewtopic.php?f=5&t=2411&p=25929#p25929
-- https://love2d.org/wiki/TiledMapLoader
-- loader for "tiled" map editor maps (.tmx,xml-based) http://www.mapeditor.org/
-- supports multiple layers
-- NOTE : function ReplaceMapTileClass (tx,ty,oldTileType,newTileType,fun_callback) end
-- NOTE : function TransmuteMap (from_to_table) end -- from_to_table[old]=new
-- NOTE : function GetMousePosOnMap () return gMouseX+gCamX-gScreenW/2,gMouseY+gCamY-gScreenH/2 end


kTileSize = 32
kMapTileTypeEmpty = 0
local floor = math.floor
local ceil = math.ceil

function setPlayerPosition(y,x,s)
  gCamX,gCamY = tile2px(x),tile2px(y)
  playerSprite = s
end

function TiledMap_Load (filepath,tilesize,spritepath_removeold,spritepath_prefix)
    debug("loading TileMap "..filepath)
    spritepath_removeold = spritepath_removeold or "../"
    spritepath_prefix = spritepath_prefix or ""
    kTileSize = tilesize or 32
    gTileGfx = {}
    debug("tilesize is "..kTileSize)   
   
    local tiletype,layers = TiledMap_Parse(filepath)
    gMapLayers = layers
    for first_gid,path in pairs(tiletype) do
        path = spritepath_prefix .. string.gsub(path,"^"..string.gsub(spritepath_removeold,"%.","%%."),"")
        debug("load spritefile "..path)
        local raw = love.image.newImageData(path)
        local w,h = raw:getWidth(),raw:getHeight()
        local gid = first_gid
        local e = kTileSize
        for y=0,floor(h/kTileSize)-1 do
        for x=0,floor(w/kTileSize)-1 do
            local sprite = love.image.newImageData(kTileSize,kTileSize)
            sprite:paste(raw,0,0,x*e,y*e,e,e)
            gTileGfx[gid] = love.graphics.newImage(sprite)
            gid = gid + 1
        end
        end
    end
end

function TiledMap_GetMapTile (tx,ty,layerid) -- coords in tiles
    local row = gMapLayers[layerid][ty]
    return row and row[tx] or kMapTileTypeEmpty
end

function TiledMap_DrawNearCam (camx,camy)
    --debug("draw near "..camx.."/"..camy)
    camx,camy = floor(camx),floor(camy)
    local screen_w = love.graphics.getWidth()
    local screen_h = love.graphics.getHeight()
    local minx,maxx = floor((camx-screen_w/2)/kTileSize),ceil((camx+screen_w/2)/kTileSize)
    local miny,maxy = floor((camy-screen_h/2)/kTileSize),ceil((camy+screen_h/2)/kTileSize)
    for z = 1,#gMapLayers do
    for x = minx,maxx do
    for y = miny,maxy do
        local gfx = gTileGfx[TiledMap_GetMapTile(x,y,z)]
        if (gfx) then
            local sx = x*kTileSize - camx + screen_w/2
            local sy = y*kTileSize - camy + screen_h/2
            love.graphics.draw(gfx,sx,sy) -- x, y, r, sx, sy, ox, oy
        end
    end
    end
    end
end

-- ***** ***** ***** ***** ***** xml parser


-- LoadXML from http://lua-users.org/wiki/LuaXml
function LoadXML(s)
  local function LoadXML_parseargs(s)
    local arg = {}
    string.gsub(s, "(%w+)=([\"'])(.-)%2", function (w, _, a)
    arg[w] = a
    end)
    return arg
  end
  local stack = {}
  local top = {}
  table.insert(stack, top)
  local ni,c,label,xarg, empty
  local i, j = 1, 1
  while true do
    ni,j,c,label,xarg, empty = string.find(s, "<(%/?)([%w:]+)(.-)(%/?)>", i)
    if not ni then break end
    local text = string.sub(s, i, ni-1)
    if not string.find(text, "^%s*$") then
      table.insert(top, text)
    end
    if empty == "/" then  -- empty element tag
      table.insert(top, {label=label, xarg=LoadXML_parseargs(xarg), empty=1})
    elseif c == "" then   -- start tag
      top = {label=label, xarg=LoadXML_parseargs(xarg)}
      table.insert(stack, top)   -- new level
    else  -- end tag
      local toclose = table.remove(stack)  -- remove top
      top = stack[#stack]
      if #stack < 1 then
        error("nothing to close with "..label)
      end
      if toclose.label ~= label then
        error("trying to close "..toclose.label.." with "..label)
      end
      table.insert(top, toclose)
    end
    i = j+1
  end
  local text = string.sub(s, i)
  if not string.find(text, "^%s*$") then
    table.insert(stack[#stack], text)
  end
  if #stack > 1 then
    error("unclosed "..stack[stack.n].label)
  end
  return stack[1]
end


-- ***** ***** ***** ***** ***** parsing the tilemap xml file

local function getTilesets(node)
    local tiles = {}
    for k, sub in ipairs(node) do
        if (sub.label == "tileset") then
            tiles[tonumber(sub.xarg.firstgid)] = sub[1].xarg.source
            debug("adding tileset "..sub[1].xarg.source.." at tiles offset "..tonumber(sub.xarg.firstgid))
             
            if #sub > 1 then
               
               for l, child in ipairs(sub) do
                 if l > 1 then
                   debug(child[1][1].xarg.name.." = "..tonumber(sub.xarg.firstgid)+child.xarg.id)
                   for kk=1, #child[1] do
                    --gplayerSprite[child[1][1].xarg.name] = tonumber(sub.xarg.firstgid)+child.xarg.id
                    if child[1][kk].xarg.name == "player_up" then
                      playerSprite_up = tonumber(sub.xarg.firstgid)+child.xarg.id
                    elseif child[1][kk].xarg.name == "player_down" then
                      playerSprite_down = tonumber(sub.xarg.firstgid)+child.xarg.id
                    elseif child[1][kk].xarg.name == "player_left" then
                      playerSprite_left = tonumber(sub.xarg.firstgid)+child.xarg.id
                    elseif child[1][kk].xarg.name == "player_right" then
                      playerSprite_right = tonumber(sub.xarg.firstgid)+child.xarg.id
                    end  
                    end
                 end
              end
              
            end
            
        end
    end
    return tiles
end

local function getLayers(node)
    local layers = {}
    for k, sub in ipairs(node) do
        if (sub.label == "layer") then --  and sub.xarg.name == layer_name
            debug("adding layer "..sub.xarg.name.." at id "..#layers+1)
            
            local layer = {}
            table.insert(layers,layer)
            width = tonumber(sub.xarg.width)
            i = 1
            j = 1
            
            offset = 1
            if sub[1].label == "properties" then
              
               for l, child in ipairs(sub[offset]) do

                  if child.xarg.name == "isPlayer" and (child.xarg.value == "1" or child.xarg.value == "true") then
                    -- found the player layer!
                    playerLayer = #layers
                    debug("found player layer at id "..playerLayer)
                    ignoreCollision[#ignoreCollision+1] = #layers
                  end

                  if child.xarg.name == "ignoreCollision" and (child.xarg.value == "1" or child.xarg.value == "true") then
                    debug("added "..sub.xarg.name.." layer at id "..#layers.." to ignoreCollision-list")
                    --TODO: add to ignoreCollision list/array/set
                    ignoreCollision[#ignoreCollision+1] = #layers
                  end

                end
              
             offset = offset + 1
            end
            
            for l, child in ipairs(sub[offset]) do
                if (j == 1) then
                    layer[i] = {}
                end
                layer[i][j] = tonumber(child.xarg.gid)
                -- debug("tile "..layer[i][j].." at "..i.."/"..j.." on layer "..sub.xarg.name)
                
                if (#layers == playerLayer) then -- is player-layer
                  if (layer[i][j] ~= 0) then -- is not nothing
                    debug("player at "..j.."/"..i.." using sprite "..layer[i][j])
                    setPlayerPosition(i,j,layer[i][j])
                  end
                end
                
                j = j + 1
                if j > width then
                    j = 1
                    i = i + 1
                end
            end
        end
    end
    return layers
end

function TiledMap_Parse(filename)
    debug("parsing TildeMap..")
   -- print(xml)
    local xml = LoadXML(love.filesystem.read(filename))
    local tiles = getTilesets(xml[2])
    local layers = getLayers(xml[2])
    return tiles, layers
end