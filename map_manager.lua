require 'config'

module("MapManager", package.seeall)

function MapManager:initialize(mapFile)
  self.tileDeck = MOAITileDeck2D.new()
  self.mapGrids = {}
  self.mapProps = {}
  self.mapTiles = {}
  self.mapObjects = {}
  self.map = dofile(mapFile)
  self:setup()
end

function MapManager:setup()
  self.tileDeck:setTexture(self.map.tilesets[1].image)
  self.width = self.map.width* self.map.tilewidth
  self.height = self.map.height * self.map.tileheight
  self.tileDeck:setSize(self.map.tilesets[1].imagewidth / self.map.tilewidth, self.map.tilesets[1].imageheight / self.map.tileheight)
  self.tileDeck:setRect(-0.5, 0.5, 0.5, -0.5)
  for key, mapLayer in pairs(self.map.layers) do
    if mapLayer.type == "tilelayer" then
      self:addGrid(mapLayer)
    elseif mapLayer.type == "objectgroup" then
      self:addObject(mapLayer)
    end
  end
end

function MapManager:addGrid(mapLayer)
  mapGrid = MOAIGrid.new()
  mapGrid:setSize(self.map.width, self.map.height, self.map.tilewidth, self.map.tileheight)
  for i = 0, self.map.height-1 do
    for j = 1, self.map.width do
      local tileData = mapLayer.data[j + map.width*i]
      mapGrid:setTile(j,i,tileData)
    end
  end
  self.mapGrids[mapLayer.name] = mapGrid
end

function MapManager:addObject(mapLayer)
  for key, object in pairs(mapLayer.objects) do
    if object.type == "dynamic" then
      self:buildObject(object, MOAIBox2DBody.DYNAMIC)
    elseif object.type == "kinematic" then
      self:buildObject(object, MOAIBox2DBody.KINEMATIC)
    elseif object.type == "static" or "" then
      self:buildObject(object, MOAIBox2DBody.STATIC)
    end
  end
end

function MapManager:buildObject(object, objectType)
  local mapObject = {
    type = objectType,
  }
  if object.shape == "rectangle" then
    mapObject = {
      name = object.name,
      type = objectType,
      shape = object.shape,
      position = {object.x  + object.width / 2, (object.y + object.height/2) - self.map.tileheight },
      size = { object.width, object.height },
      properties = object.properties 
    }    
  elseif object.shape == "polyline" then
    mapObject = {
      name = object.name,
      type = objectType,
      shape = object.shape,
      position = {object.x + object.width / 2, -object.y - object.height/2 },
      size = {object.width, object.height},
      shapeData = object.polyline
    }
  elseif object.shape == "polygon" then
    -- TODO
  elseif object.shape == "elipse" then
    -- TODO
  end


  mapObjects[object.name] = mapObject
end

function MapManager:getBackgroundObjects()
  local backgroundObjects = {}
  for name, mapGrid in pairs(self.mapGrids) do
    local object = {
      position = {0,0},
      parallax = {1,1},
      deck = self.tileDeck,
      mapGrid = mapGrid,
      name = name
    }
    backgroundObjects[name] = object
  end
  return backgroundObjects
end



