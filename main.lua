love.filesystem.load("debug.lua")()
love.filesystem.load("config.lua")()
love.filesystem.load("helper.lua")()
love.filesystem.load("tiledmap.lua")()
love.filesystem.load("collision.lua")()

DEBUG = true -- wenn false, dann kein debug-output

gKeyPressed = {} -- aktuell gedrueckte keys
gCamX,gCamY = 0,0 -- die position der kamera
--gplayerSprite = {}
playerSprite_up = 0 -- sprite, der an player position gemalt wird
playerSprite_down = 0 -- sprite, der an player position gemalt wird
playerSprite_left = 0 -- sprite, der an player position gemalt wird
playerSprite_right = 0 -- sprite, der an player position gemalt wird
ignoreCollision = {} -- layers to ignore in collision controll (background, etc)
playerLayer = 0
curMap      = firstMap

function love.draw()
  -- initGUI
  
  local screen_w = love.graphics.getWidth()
  local screen_h = love.graphics.getHeight()
  
  centerX = screen_w/2
  centerY = screen_h/2
  a       = 10
  
  love.graphics.setBackgroundColor(0,0,0)
  --love.graphics.setColor(255, 255, 255)
  love.graphics.print("Welcome to "..gamename.." "..version.."!", 10, 10)
  love.graphics.print("Center is at ("..centerX.."/"..centerY..")", 10, 22)
  love.graphics.print("Cam is at ("..gCamX.."/"..gCamY..") = ("..px2tile(gCamX) .."/"..px2tile(gCamY) ..")", 10, 34)
  
  TiledMap_DrawNearCam(gCamX,gCamY)
  
  centerX = screen_w/2
  centerY = screen_h/2
  a       = 16
  
  -- debug quad auf der mitte des fensters
  -- love.graphics.quad("fill", centerX-a, centerY-a, centerX+a, centerY-a, centerX+a, centerY+a, centerX-a, centerY+a)
  
end

function love.keypressed( key, unicode )
    gKeyPressed[key] = true
end

function love.keyreleased( key )
    gKeyPressed[key] = nil
end


function love.update( dt )
   -- local s = 200*dt
    local s = kTileSize
    
    gMapLayers[playerLayer][px2tile(gCamY)][px2tile(gCamX)] = 0
    
    -- backup the position
    tmpgCamY = gCamY
    tmpgCamX = gCamX
    
    if (gKeyPressed.up) then gCamY = gCamY - s end
    if (gKeyPressed.down) then gCamY = gCamY + s end
    if (gKeyPressed.left) then gCamX = gCamX - s end
    if (gKeyPressed.right) then gCamX = gCamX + s end
    
    if tmpgCamY ~= gCamY or  tmpgCamX ~= gCamX then -- position changed
      
      playerSprite = getPlayerSprite(gCamX, gCamY, tmpgCamX, tmpgCamY)
      
      if isValidPos(px2tile(gCamX), px2tile(gCamY)) then -- everything ok
        
        love.timer.sleep(100/player_speed) -- minimieren, um den spieler schneller zu machen
        
      else -- Collision!
        
        debug("invalid movement!")
        -- undo movement
        gCamY = tmpgCamY
        gCamX = tmpgCamX
        
      end
    end
    
    gMapLayers[playerLayer][px2tile(gCamY)][px2tile(gCamX)] = playerSprite
    
end

function love.load()
    love.graphics.setCaption(gamename.." "..version)
    TiledMap_Load("map/"..curMap)
end

function loadMap(mapName)
  curMap      = mapName
end