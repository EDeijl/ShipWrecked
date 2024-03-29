require 'character'
require 'collectible'
require 'door'
require 'button'
require 'managers/physics_manager'
require 'hud'
require 'managers/map_manager'

module ( "Game", package.seeall )



-- We'll define our resources here
local resource_definitions = {


  character = {
    type = RESOURCE_TYPE_TILED_IMAGE,
    fileName = 'character/charsheet.png',
    tileMapSize = {24, 14},
    width = 128, height = 128,
  },

  hudFont = {
    type = RESOURCE_TYPE_FONT,
    fileName = 'fonts/redfive.ttf',
    glyphs = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.?!",
    fontSize = 26,
    dpi = 160
  },
  button_right = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/button_right.png',
    width = CONTROL_WORLD_SCALE * SCREEN_RESOLUTION_X, height = CONTROL_WORLD_SCALE * SCREEN_RESOLUTION_X
  },
  pause = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/pause.png',
    width = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X, height = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X
  }, 
  button_level_background_back = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/button_level_background_back.png',
    width = 163, height = 61
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
  door = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'collectibles/door.png',
    width = 64, height = 128
  },

  button_notpressed = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'collectibles/button.png',
    width = 64, height = 64
  },
  button_pressed = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'collectibles/button_pressed.png',
    width = 64, height = 64
  },
  endgame = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'collectibles/endpoint.png',
    width = 63, height = 103
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
  },
  col2_active = {
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
  },

  button_level_background = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/button_level_background.png',
    width = 163, height = 121
  },
  menu_background = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/bluesquare.png',
    width = .8* SCREEN_RESOLUTION_X, height = .8 *SCREEN_RESOLUTION_Y
  },
  human = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/human.png',
    width = 29, height = 85
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

function Game:build(levelFilePath, name)
  self.name = name
  MapManager:initialize(levelFilePath)
  background_objects = MapManager:getBackgroundObjects()
  self.levelFilePath = levelFilePath

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
-- update loop
-- this should be called from main
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

  self.savedLives = 10
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
  Character:initialize ( self.layers.platform, position )
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
  self.layers.space = MOAILayer2D.new ()
  self.layers.shipBackground = MOAILayer2D.new ()
  self.layers.shipObjects = MOAILayer2D.new ()
  self.layers.platform = MOAILayer2D.new ()
  self.layers.platformExtra = MOAILayer2D.new ()
  -- Now we assign the viewport and the camera
  -- to them
  for key, layer in pairs ( self.layers ) do
    layer:setViewport ( viewport )
    layer:setCamera ( self.camera )
  end

  -- We create a render table that
  -- has all the layers in order.
  self.renderTable = {
    self.layers.space,
    self.layers.shipBackground,
    self.layers.platformExtra,
    self.layers.shipObjects,
    self.layers.platform
    
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

------------------------------------------------
-- loadScene ()
-- place all objects in the scene
------------------------------------------------
function Game:loadScene ()
  self.objects = {}
  for key, attr in pairs ( scene_objects ) do

    local body = PhysicsManager.world:addBody( attr.type )
    body:setTransform( unpack ( attr.position ));
    if attr.rotation ~= nil then
      print("rotation: " .. attr.rotation)
    end

    local width, height = unpack ( attr.size );

    local fixture = body:addRect ( -width/2, -height/2, width/2, height/2 )
    --print (attr.name)

    if string.find(attr.name, "collectible_") then
      --print "check"
      fixture.name = attr.name
      local position = attr.position
      local collectible = Collectible:new(attr.name, self.layers.platform, position)
      collectibleTable[attr.name] = collectible
    elseif string.find(attr.name, "door_") then
      fixture.name = attr.name
      local position = attr.position
      local rotation = 0
      if width > height then
        rotation = 90
      end
      local size = {width, height}
      local x = tonumber(attr.properties.moveX)
      local y = tonumber(attr.properties.moveY)

      local direction = { x, y}
      local rect = { -width/2, -height/2, width/2, height/2 }
      local door = Door:new(attr.name,body, fixture, direction, rect, self.layers.platform, rotation)
      doorTable[attr.name] = door
    elseif string.find(attr.name, "button_") then
      fixture.name = attr.name 
      local position = attr.position
      local linkedObject = doorTable[attr.properties.control_link]
      local button = Button:new(attr.name,body, fixture, linkedObject, self.layers.platform, position)
      buttonTable[attr.name] = button
    elseif attr.name == "endGame" then
      fixture.name = attr.name 
      local prop = MOAIProp2D.new()
      prop:setDeck(ResourceManager:get('endgame'))
      prop:setScl(1,-1)
      prop:setParent(body)
      self.layers.platform:insertProp(prop)
    else
      

      fixture.name = attr.name
    end
    fixture:setFriction( 0 )

    self.objects[key] = { body = body, fixture = fixture }
  end
end



------------------------------------------------
-- belingsToScene (fixture)
-- checks if a fixture belongs to the scene
------------------------------------------------
function Game:belongsToScene ( fixture )
  for key, object in pairs ( self.objects ) do
    if object.fixture == fixture then
      return true
    end
  end
  return false
end

------------------------------------------------
-- keyPressed(key, down)
-- hands of keypresses to the correct module
------------------------------------------------
function Game:keyPressed ( key, down )

  if key == 'right' then Character:moveRight ( down ) end
  if key == 'left' then Character:moveLeft ( down ) end

  if key == 'w' then Character:changeGrav ( key, down ) end
  if key == 'a' then Character:changeGrav ( key, down ) end
  if key == 's' then Character:changeGrav ( key, down ) end
  if key == 'd' then Character:changeGrav ( key, down ) end

  if key == 'm' then switchScene(key, down) end
  
  if key == 'tab' and down == true then self:endGame() end
  --if key == 'space' then Character:shoot() end
end

------------------------------------------------
-- updateCamera()
-- updates the camera if the character begins moving
-- off screen
------------------------------------------------
function Game:updateCamera ()
  x, y = Character.physics.body:getPosition ()

  --print("x: "..x.." y: "..y)
  self.camera:setLoc((x-WORLD_RESOLUTION_X/2),(y-WORLD_RESOLUTION_Y/2))

  minBorderX, minBorderY = self.layers.shipBackground:wndToWorld ( 0, 0 )
  maxBorderX, maxBorderY = self.layers.shipBackground:wndToWorld ( SCREEN_RESOLUTION_X, SCREEN_RESOLUTION_Y )

end

-------------------------------------------------
-- checkAllCollected()
-- check if all collectibles are collected
------------------------------------------------
function Game:checkAllCollected()
  local allCollected = false
  for k, v in pairs(collectibleTable) do
    if collectibleTable[k].collected == true then
      allcollected = true
    else
      allcollected = false
      break
    end
  end
  return allcollected
end

------------------------------------------------
-- pause(paused)
-- pauses or unpauses the game
------------------------------------------------
function Game:pause(paused)
  PhysicsManager.world:pause(paused)
end
------------------------------------------------
-- restart()
-- restarts the game
------------------------------------------------
function Game:restart()
  switchScene(GAME_LEVEL, self.levelFilePath, self.name)
end

------------------------------------------------
-- endGame()
-- ends the game, saves data, and calls the hud to
-- show the endscreen
------------------------------------------------
function Game:endGame()
  local minTime = 100
  local division = minTime/ self.savedLives
  local timeLeft = self.hud.countdownTime
  local livesLeft =10
  if timeLeft < 100 then
    livesLeft = math.floor(timeLeft/division)
  end
  self:saveData(livesLeft, timeLeft)
  self.hud:showEndScreen(livesLeft, timeLeft)
end

------------------------------------------------
-- saveData(livesLeft, timeLeft)
-- saves data to disk
------------------------------------------------
function Game:saveData( livesLeft, timeLeft )
    local saveFile = savefiles.get("saveGame")
    print(self.name)
    print(saveFile.data)
    saveFile.data.levels[self.name].livesLeft = livesLeft
    saveFile.data.levels[self.name].time = timeLeft
    local levelnr = tonumber(string.match(self.name, "%d+"))
    levelnr = levelnr +1
    local levelname = 'level'..levelnr
    if level_files[levelname] ~= nil then
      saveFile.data.levels[levelname].unlocked = true
    end
    saveFile:saveGame()
end

------------------------------------------------
-- getLayers()
-- get all layers in rendertable
------------------------------------------------
function Game:getLayers()
  return self.renderTable
end

------------------------------------------------
-- cleanup()
-- stops the physics world
------------------------------------------------
function Game:cleanup()
  PhysicsManager.world:stop()
end
------------------------------------------------
-- updateHud(lives, people)
-- update the hud icons
------------------------------------------------
function Game:updateHud(lives, people)
  self.hud:setLives(lives, people)
end

------------------------------------------------
-- updateCollectibleHud(collectible)
-- updates the collectibles part of the hud
------------------------------------------------
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
