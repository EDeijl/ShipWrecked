require 'character'
require 'collectible'
require 'door'
require 'button'
require 'physics_manager'
require 'hud'
require 'map_manager'

module ( "Game", package.seeall )



-- We'll define our resources here
-- Look at chapter 6 if you have
-- any doubt on these definitions.
local resource_definitions = {


  character = {
    type = RESOURCE_TYPE_TILED_IMAGE,
    fileName = 'character/charsheet.png',
    tileMapSize = {24, 14},
    width = 128, height = 128,
  },

  hudFont = {
    type = RESOURCE_TYPE_FONT,
    fileName = 'fonts/tuffy.ttf',
    glyphs = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.?!",
    fontSize = 26,
    dpi = 160
  },
  button_right = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/button_right.png',
    width = CONTROL_WORLD_SCALE * SCREEN_RESOLUTION_X, height = CONTROL_WORLD_SCALE * SCREEN_RESOLUTION_X
  },
  collectibles = 
  {
    type = RESOURCE_TYPE_TILED_IMAGE,
    fileName = 'collectibles/colsheet.png',
    tileMapSize = {24, 3},
    width = 32, height = 32,
  },
  box = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'collectibles/box.png',
    width = 64, height = 64
  },
  col1_active = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/col1_active.png',
    width = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X, height = HUD_WORLD_SCALE *SCREEN_RESOLUTION_X
  },
  col1_nonactive = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/col1_nonactive.png',
    width = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X, height = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X
    },col2_active = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/col2_active.png',
    width = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X, height = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X
  },
  col2_nonactive = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/col2_nonactive.png',
    width = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X, height = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X
  },
  col3_active = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/col3_active.png',
    width = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X, height = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X
  },
  col3_nonactive = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/col3_nonactive.png',
    width = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X, height = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X
  },
  life = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/life.png',
    width = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X, height = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X
  }
}

-- define some properties for
-- the background layers.
-- The position will handle
-- offsets on the image placement
-- and parallax will be used
-- to modify the movement
-- speed when the camera
-- moves.
local background_objects ={}

local scene_objects = {}


--------------------------------
-- build( levelfilepath)
-- builds the scene from a tiled map lua file
--------------------------------

function Game:build(levelFilePath)
  MapManager:initialize(levelFilePath)
  background_objects = MapManager:getBackgroundObjects()


  scene_objects = MapManager.mapObjects

  -- Do the initial setup
  self:initialize ()
  return self
end
collectibleTable = {}
doorTable = {}
buttonTable = {}
function Game:getTable(tableName)
  if tableName == 'collectiblesTable' then
    return collectibleTable
  elseif tableName == 'buttonTable' then
    return buttonTable
  elseif tableName == 'doorTable' then
    return doorTable
  end

end

------------------------------------------------
-- start ( )
-- initializes the game. this should be
-- called from main.lua
------------------------------------------------
function Game:update ()
  while ( true ) do

    self:updateCamera ()
    self.hud:update()

    coroutine.yield ()    
  end
end

------------------------------------------------
-- initialize ( )
-- does all the initial setup for the game
------------------------------------------------
function Game:initialize ()  
  -- Initialize camera


  self.camera = MOAICamera2D.new ()

  -- We need multiple layers
  -- in order to use parallax
  -- so we set them up in 
  -- an auxiliary method
  self:setupLayers ()

  -- Initialize input manager
  InputManager:initialize ()

  -- We load all our resources
  ResourceDefinitions:setDefinitions ( resource_definitions )

  -- load the backgrounds
  self:loadBackground ()

  -- Initialize physics simulation
  PhysicsManager:initialize ( self.layers.walkBehind )

  -- Load all the physics objects
  self:loadScene ()

  -- Initialize the character and display
  -- it on the main layer.
  local position = scene_objects["startGame"].position
  local x, y = unpack(position)
  self.hud = HUD:initialize()
  Character:initialize ( self.layers.main, position )
  self.camera:setLoc((x-WORLD_RESOLUTION_X/2),(y-WORLD_RESOLUTION_Y/2))
  print (self.camera:getLoc())
  print (self.camera:getWorldLoc())
  -- Initialize the HUD

  SceneManager.pushScene(hud)
  -- Initialize Audio
  --  AudioManager:initialize ()

  --  AudioManager:play ( 'backgroundMusic' )

end

------------------------------------------------
-- setupLayers ( )
-- creates all the layers that are needed
-- in this game and places them in order
-- in the render table.
------------------------------------------------
function Game:setupLayers ()

  -- First we create all the layers
  -- needed for the different
  -- depth planes.
  self.layers = {}
  self.layers.background = MOAILayer2D.new ()
  self.layers.farAway = MOAILayer2D.new ()
  self.layers.main = MOAILayer2D.new ()
  self.layers.walkBehind = MOAILayer2D.new ()

  -- Now we assign the viewport and the camera
  -- to them
  for key, layer in pairs ( self.layers ) do
    layer:setViewport ( viewport )
    layer:setCamera ( self.camera )
  end

  -- We create a render table that
  -- has all the layers in order.
  self.renderTable = {
    self.layers.background,
    self.layers.farAway,
    self.layers.main,
    self.layers.walkBehind
  }

  -- Make that render table active
  MOAIRenderMgr.setRenderTable( renderTable )

end

------------------------------------------------
-- loadBackground ( )
-- adds all the images needed for the different
-- background layers and sets their parallax
-- offsets.
------------------------------------------------
function Game:loadBackground ()

  -- We create a table to store backgrounds
  self.background = {}

  -- We iterate through all the background_objects
  -- we defined.
  for name, attributes in pairs ( background_objects ) do

    -- We create the needed image, and prop.
    local b = {}
    b.prop = MOAIProp2D.new ()
    b.prop:setDeck ( attributes.deck )
    b.prop:setGrid(attributes.mapGrid)
    b.prop:setLoc( unpack ( attributes.position ) )

    -- we insert the prop in the correct
    -- layer ...
    self.layers[name]:insertProp ( b.prop )

    -- ... and set the parallax defined in
    -- the attributes table.
    self.layers[name]:setParallax( unpack ( attributes.parallax ) )

    -- Finally, we store it in the background
    -- table.
    self.background[name] = b
  end

end


function Game:loadScene ()
  self.objects = {}
  for key, attr in pairs ( scene_objects ) do

    local body = PhysicsManager.world:addBody( attr.type )
    body:setTransform( unpack ( attr.position ) );
    width, height = unpack ( attr.size );

    local fixture = body:addRect ( -width/2, -height/2, width/2, height/2 )
    --print (attr.name)

    if string.find(attr.name, "collectible_") then
      --print "check"
      fixture.name = attr.name
      local position = attr.position
      local animStart = tonumber(attr.properties.animStart)
      local animStop = tonumber(attr.properties.animStop)
      local collectible = Collectible:new(attr.name, animStart, animStop, self.layers.main, position)
      collectibleTable[attr.name] = collectible
    else
      fixture.name = attr.name
    end
    fixture:setFriction( 0 )

    self.objects[key] = { body = body, fixture = fixture }
  end
end


function Game:belongsToScene ( fixture )
  for key, object in pairs ( self.objects ) do
    if object.fixture == fixture then
      return true
    end
  end
  return false
end


function Game:keyPressed ( key, down )

  if key == 'right' then Character:moveRight ( down ) end
  if key == 'left' then Character:moveLeft ( down ) end
  if key == 'up' then Character:jump ( down ) end

  if key == 'w' then Character:changeGrav ( key, down ) end
  if key == 'a' then Character:changeGrav ( key, down ) end
  if key == 's' then Character:changeGrav ( key, down ) end
  if key == 'd' then Character:changeGrav ( key, down ) end

  if key == 'm' then switchScene(key, down) end


  --if key == 'space' then Character:shoot() end
end


function Game:updateCamera ()
  x, y = Character.physics.body:getPosition ()

  --print("x: "..x.." y: "..y)
  self.camera:setLoc((x-WORLD_RESOLUTION_X/2),(y-WORLD_RESOLUTION_Y/2))

  minBorderX, minBorderY = self.layers.background:wndToWorld ( 0, 0 )
  maxBorderX, maxBorderY = self.layers.background:wndToWorld ( SCREEN_RESOLUTION_X, SCREEN_RESOLUTION_Y )

end



function Game:restart()
  self:start()
end


function Game:endGame()
  HUD:showEndScreen()
end


function Game:getLayers()
  return self.renderTable
end

function Game:cleanup()
  PhysicsManager.world:stop()
end

function Game:updateHud(lives)
  self.hud:setLives(lives)
end
function Game:updateCollectibleHud(collectible)
  self.hud:setCollected(collectible)
end


------------------------------------------------
-- sleepCoroutine  ( time )
-- helper method to freeze the thread for 
-- 'time' seconds.
------------------------------------------------
function sleepCoroutine ( time )
  local timer = MOAITimer.new ()
  timer:setSpan ( time )
  timer:start ()
  MOAICoroutine.blockOnAction ( timer )
end
