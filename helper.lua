-- helper functions

-- rechnet eine absolute pixel-koordinate in eine map-koordinate um
function px2tile(px)
  return (px/kTileSize)-0.5
end

-- rechnet eine map-koordinate in eine absolute pixel-koordinate  um
function tile2px(px)
  return (px+0.5)*kTileSize
end

function getPlayerSprite(x, y, oldx, oldy)
  if y < oldy then
    return playerSprite_up
  elseif y > oldy then
    return playerSprite_down
  elseif x  < oldx then
    return playerSprite_left
  else
    return playerSprite_right
  end
end