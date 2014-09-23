require 'character'
require 'physics_manager'
require 'hud'
require 'map_manager'

module ( "Game", package.seeall )


MapManager:initialize('assets/maps/test.lua')

-- We'll define our resources here
-- Look at chapter 6 if you have
-- any doubt on these definitions.
local resource_definitions = {
 
  background = {
    type = RESOURCE_TYPE_IMAGE, 
    fileName = 'background/background_parallax.png', 
    width = 797, height = 197,
  },
  
  farAway = {
    type = RESOURCE_TYPE_IMAGE, 
    fileName = 'background/far_away_parallax.png', 
    width = 625, height = 205,
  },

  main = {
    type = RESOURCE_TYPE_IMAGE, 
    fileName = 'background/main_parallax.png', 
    width = 975, height = 171,
  },

  character = {
    type = RESOURCE_TYPE_TILED_IMAGE,
    fileName = 'character/character.png',
    tileMapSize = {20, 6},
    width = 64, height = 64,
  },
  
  hudFont = {
    type = RESOURCE_TYPE_FONT,
    fileName = 'fonts/tuffy.ttf',
    glyphs = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.?!",
    fontSize = 26,
    dpi = 160
  },
}


-- define some properties for
-- the background layers.
-- The position will handle
-- offsets on the image placement
-- and parallax will be used
-- to modify the movement
-- speed when the camera
-- moves.
local background_objects = MapManager:getBackgroundObjects()
--local background_objects = {
  
--  background = {
--    position = { 0, 70 },
--    parallax = { 0.05, 0.05 }
--  },
  
--  farAway = {
--    position = { 0, 50 },
--    parallax = { 0.1, 0.1 }
--  },
  
--  main = {
--    position = { 0, -75 },
--    parallax = { 1, 1 }
--  },
  
--}

local scene_objects = MapManager.mapObjects
--local scene_objects = {
--  floor = {
--    type = MOAIBox2DBody.STATIC,
--    position = { 0, -WORLD_RESOLUTION_Y/2 },
--    size = { 2 * WORLD_RESOLUTION_X, 10}
--  },
  
--  platform1 = {
--    type = MOAIBox2DBody.STATIC,
--    position = { 100, -50 },
--    size = {100, 20}
--  },

--  platform2 = {
--    type = MOAIBox2DBody.STATIC,
--    position = { -100, 100 },
--    size = {150, 20}
--  },
--}

------------------------------------------------
-- start ( )
-- initializes the game. this should be
-- called from main.lua
------------------------------------------------
function Game:start ()
  
  -- Do the initial setup
  self:initialize ()
  
  while ( true ) do
  
    self:updateCamera ()
    
    -- Updating the hud
    -- on each frame.
    HUD:update ()
    
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
  Character:initialize ( self.layers.main )
  
  -- Initialize the HUD
  HUD:initialize ()
  
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
  local renderTable = {
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
  
end

function Game:updateCamera ()
  x, y = Character.physics.body:getPosition ()
  
  minBorderX, minBorderX = self.layers.background:wndToWorld ( 0, 0 )
  maxBorderX, maxBorderY = self.layers.background:wndToWorld ( SCREEN_RESOLUTION_X, SCREEN_RESOLUTION_Y )
  
  if math.abs ( x - minBorderX ) < 10 then
    MOAICoroutine.blockOnAction ( self.camera:moveLoc(-50, 0, 1, MOAIEaseType.LINEAR) )
  end
    
  if math.abs ( x - maxBorderX ) < 100 then
    MOAICoroutine.blockOnAction ( self.camera:moveLoc(50, 0, 1, MOAIEaseType.LINEAR) )
  end
  
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
