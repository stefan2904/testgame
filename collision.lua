-- Kollisionskontrolle
-- (Collision detection)

-- gMapLayers[layer][y][x] -- the layers and tileds
-- ignoreCollision -- ignore-list

function isValidPos(x, y)
  -- debug("running collision detection for "..x.."/"..y)
  for z = 1,#gMapLayers do
    
    if not isIn(z,ignoreCollision) then
      debug(x.."/"..y.." at layer "..z.." is "..gMapLayers[z][y][x])
      if gMapLayers[z][y][x] ~= 0 then
        return false
      end
    end
  end
  
  return true
end