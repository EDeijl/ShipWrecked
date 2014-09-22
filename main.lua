require 'config'
map = require 'test'
MOAISim.openWindow("Shipwrecked in Spesh", SCREEN_RESOLUTION_X, SCREEN_RESOLUTION_Y)

viewport = MOAIViewport.new()
viewport:setSize(SCREEN_RESOLUTION_X, SCREEN_RESOLUTION_Y)
viewport:setScale(WORLD_RESOLUTION_X, WORLD_RESOLUTION_Y)

layer = MOAILayer2D.new()
layer:setViewport(viewport)
MOAIRenderMgr.pushRenderPass(layer)



------------------------
-- initialize a game map
------------------------

gameMap =
{
  tileDeck = MOAITileDeck2D.new(),
  mapGrids = {},
  mapProps = {},
  mapTiles = {},
  mapFlags = {["blockingTile"]=1},
  world = MOAIBox2DWorld.new()
}

function gameMap:init(layer)
  self.layer = layer
  self.tileDeck:setTexture(map.tilesets[1].image)
  self.width = map.width*map.tilewidth
  self.height = map.height * map.tileheight
  self.tileDeck:setSize(map.tilesets[1].imagewidth / map.tilewidth, map.tilesets[1].imageheight / map.tileheight)
  self.world:setGravity(0, -GRAVITY)
  self.world:setUnitsToMeters(1/32)
  for key,mapLayer in pairs(map.layers) do
    if mapLayer.type == "tilelayer" then
      self:addGrid(mapLayer)
    elseif mapLayer.type == "objectgroup" then
      self:addObject(mapLayer)
    end
  end
  for key, mapGrid in pairs(self.mapGrids) do
    self:addProp(mapGrid,key)
  end
  
  self.layer:setBox2DWorld(self.world)
end

function gameMap:addGrid(mapLayer)
  mapGrid = MOAIGrid.new()
  mapGrid:setSize (map.width,map.height,map.tilewidth,map.tileheight)
  for i = 1, map.height do
    for j = 1, map.width do
      local tileData = mapLayer.data[(map.height-i)*map.width+j]
      mapGrid:setTile(j,i,tileData)

    end
  end
  self.mapGrids[mapLayer.name] = mapGrid 
end


function gameMap:addProp(mapGrid, key)
  local prop = MOAIProp2D.new()
  prop:setDeck(self.tileDeck)
  prop:setGrid(mapGrid)
  prop:setLoc(-WORLD_RESOLUTION_X/2, -WORLD_RESOLUTION_Y / 2)
  self.layer:insertProp(prop)

end

function gameMap:addObject(mapLayer)
  for key, object in pairs(mapLayer.objects) do
    body = self.world:addBody(MOAIBox2DBody.STATIC)
    if object.shape == "rectangle" then
      fixture = body:addRect(-object.width/2, object.height/2, object.width/2, -object.height/2)
--      xRatio = (math.abs(self.width - 0))/(math.abs(WORLD_RESOLUTION_X/2 - -WORLD_RESOLUTION_X/2))
--      yRatio = (math.abs(self.height -0))/(math.abs(WORLD_RESOLTUION_Y/2 - - 
      normalizedX = normalize(-object.width/2, 0, self.width)
      normalizedY = normalize(object.height/2, self.height, 0)
      print("normalizedX: " .. normalizedX .. ", normalizedY: " .. normalizedY)
      
      destX = normalizedX*(math.abs(WORLD_RESOLUTION_X/2 - - WORLD_RESOLUTION_X/2)) + -WORLD_RESOLUTION_X/2
      destY = normalizedY*(math.abs(WORLD_RESOLUTION_Y/2 - - WORLD_RESOLUTION_Y/2)) + -WORLD_RESOLUTION_Y/2
      print("destX: " .. destX .. ", destY: " .. destY)
      body:setTransform(destX, destY, object.rotation)
    end
  end
end

function normalize(value, min, max)
  return math.abs((value - min) / (max - min))
end


gameMap:init(layer)
gameMap.world.start()





