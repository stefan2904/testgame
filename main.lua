love.filesystem.load("debug.lua")()
love.filesystem.load("config.lua")()
love.filesystem.load("tiledmap.lua")()

DEBUG = true

gKeyPressed = {}
gCamX,gCamY = 0,0
playerSprite = 1
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
  love.graphics.print("Cam is at ("..gCamX.."/"..gCamY..") = ("..(gCamX/32)-0.5 .."/"..(gCamY/32)-0.5 ..")", 10, 34)
  
  TiledMap_DrawNearCam(gCamX,gCamY)
  
  centerX = screen_w/2
  centerY = screen_h/2
  a       = 16
  
  love.graphics.quad("fill", centerX-a, centerY-a, centerX+a, centerY-a, centerX+a, centerY+a, centerX-a, centerY+a)
  
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
    if (gKeyPressed.up) then gCamY = gCamY - s end
    if (gKeyPressed.down) then gCamY = gCamY + s end
    if (gKeyPressed.left) then gCamX = gCamX - s end
    if (gKeyPressed.right) then gCamX = gCamX + s end
    love.timer.sleep(100/player_speed) -- minimieren, um den spieler schneller zu machen
end

function love.load()
    love.graphics.setCaption(gamename.." "..version)
    TiledMap_Load("map/"..curMap)
end

function loadMap(mapName)
  curMap      = mapName
end