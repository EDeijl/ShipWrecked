module ( "HUD", package.seeall )

------------------------------------------------
-- initialize ( )
-- initializes the hud
------------------------------------------------

function HUD:initialize ()
  -- Set the countdowntimer in seconds
  self.countdownTime = 130
  self.isOverlay = true
  self.font = MOAIFont.new ()
  self.font = ResourceManager:get ( "hudFont" )
  self.xMargin = WORLD_RESOLUTION_X / 10
  self.yMarginControls = WORLD_RESOLUTION_Y / 5
  self.yMargin = WORLD_RESOLUTION_Y / 7
  self.xyScale = WORLD_RESOLUTION_Y / WORLD_RESOLUTION_X
  self.controlSize = CONTROL_WORLD_SCALE * SCREEN_RESOLUTION_X
  self.hudIconSize = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X

  self.countdownTimer = MOAITimer.new()
  self.paused = false
  -- Since we want the hud to be 
  -- independent of the world coordinates
  -- and be more window based, we create 
  -- a new viewport for it.
  self.viewport = MOAIViewport.new ()

  -- To make this viewport more intuitive,
  -- we'll put the (0,0) in the top left corner
  -- and make the y axis grow to the bottom

  viewport:setSize ( SCREEN_RESOLUTION_X, SCREEN_RESOLUTION_Y )

  -- Make the y axis increase as you go down by
  -- scaling it by -1 (inverting it)
  viewport:setScale ( SCREEN_RESOLUTION_X, -SCREEN_RESOLUTION_Y )

  -- Use offset projection to move the
  -- center from the middle of the screen
  -- to the top right.
  viewport:setOffset ( -1, 1 )

  -- A new layer as well, and add it
  -- to the viewport.
  self.layer = MOAILayer2D.new ()
  self.layer:setViewport ( self.viewport )
  partition = MOAIPartition.new()
  -- Now we need to render the layer.


  -- Add left and right indicator
  --self:initializeDebugHud ()
  self:startTimer()
  -- Add controls
  self.root = MOAITransform.new()
  self:initializeControls()
  layer:setPartition(partition)
  return self
end

function HUD:getLayers()
  return self.layer
end

------------------------------------------------
-- initializeDebugHud ( )
-- initializes the debug notifications.
------------------------------------------------
function HUD:initializeDebugHud ()

  -- Load font using the resource manager
  self.font = MOAIFont.new ()
  self.font = ResourceManager:get ( "hudFont" )

  -- We'll use leftRightIndicator textbox
  -- in order to display the direction 
  -- the character is facing.
  self.leftRightIndicator = self:newDebugTextBox ( 30, {10, 10, 100, 50} )

  -- Position indicator will show
  -- the character's current position 
  -- in world coordinates.
  self.positionIndicator = self:newDebugTextBox ( 30, {10, 50, 200, 100} )

end

function HUD:initializeControls()
  self.humanProps = {}

  -- make clickable buttons
  for i = 1, 10 do
    local name = 'human' .. i
    local human = self:makeInterfaceElement('human', name, i*self.xMargin, SCREEN_RESOLUTION_Y - self.yMargin, 1)
    layer:insertProp(human)
    partition:insertProp(human)
    table.insert(self.humanProps, human)
  end

  self.pauseButton = self:makeButton('pause', 'pause', SCREEN_RESOLUTION_X - self.xMargin, self.yMargin, 1, layer)



  -- build other non clickable interface elements
  self.col1 = self:makeInterfaceElement('col1_nonactive', 'col1', SCREEN_RESOLUTION_X - self.xMargin - self.hudIconSize ,  self.yMargin, 1)
  self.col2 = self:makeInterfaceElement('col2_nonactive', 'col2', SCREEN_RESOLUTION_X - self.xMargin - 2*self.hudIconSize, self.yMargin, 1)
  self.col3 = self:makeInterfaceElement('col3_nonactive', 'col3', SCREEN_RESOLUTION_X - self.xMargin - 3*self.hudIconSize, self.yMargin, 1)
  layer:insertProp(self.col1)
  partition:insertProp(self.col1)  
  layer:insertProp(self.col2)
  partition:insertProp(self.col2)  
  layer:insertProp(self.col3)
  partition:insertProp(self.col3)
  self.life1 = self:makeInterfaceElement('life', 'life1', self.xMargin,                      self.yMargin, 1)
  self.life2 = self:makeInterfaceElement('life', 'life2', self.xMargin + self.hudIconSize,   self.yMargin, 1)
  self.life3 = self:makeInterfaceElement('life', 'life3', self.xMargin + 2*self.hudIconSize, self.yMargin, 1)

 end

------------------------------------------------
-- newDebugTextBox ( )
-- Returns a textbox that is inserted on
-- the HUD layer.
-- Size is the font size, rectangle is a table
-- with 4 numbers that delimit the boundaries
-- of the textbox.
------------------------------------------------
function HUD:newDebugTextBox ( size, rectangle )
  -- We create the textbox
  local textBox = MOAITextBox.new ()

  -- we preloaded the font 
  -- in initializeDebugHud
  -- but we could have a parameter
  -- if needed
  textBox:setFont ( self.font )

  -- we set the size of the font
  -- using the 'size' parameter
  textBox:setTextSize ( size )

  -- we transform the rectangle
  -- table in the necessary
  -- parameters to setRect
  textBox:setRect ( unpack ( rectangle ) )

  -- We add the textbox to
  -- the HUD's layer
  layer:insertProp ( textBox )
  partition:insertProp(textBox)
  -- And finally return it
  return textBox

end

function HUD:newTextBox ( size, rectangle, layer )
  -- We create the textbox
  local textBox = MOAITextBox.new ()

  -- we preloaded the font 
  -- in initializeDebugHud
  -- but we could have a parameter
  -- if needed
  textBox:setFont ( self.font )

  -- we set the size of the font
  -- using the 'size' parameter
  textBox:setTextSize ( size )

  -- we transform the rectangle
  -- table in the necessary
  -- parameters to setRect
  textBox:setRect ( unpack ( rectangle ) )

  -- We add the textbox to
  -- the HUD's layer
  layer:insertProp ( textBox )
  partition:insertProp(textBox)
  -- And finally return it
  return textBox

end

------------------------------------------------
-- update ( )
-- This method is used to update the text boxes
-- on each frame. It's called on the game loop
-- inside Game:initialize
------------------------------------------------
function HUD:update ()

  -- To update the left/right
  -- indicator, we get the scale
  -- of the character's prop.
  local x, y = Character.prop:getScl ()

  self:rotateHud()
end

function HUD:setCollected(collectible)
  if collectible.name == 'collectible_1' then
    self.col2:setDeck(ResourceManager:get('col2_active'))
  elseif collectible.name == 'collectible_2' then
    self.col1:setDeck(ResourceManager:get('col1_active'))
  elseif collectible.name == 'collectible_3' then
    self.col3:setDeck(ResourceManager:get('col3_active'))
  end
end

function HUD:updateHumans(humans)
   for k, v in pairs(self.humanProps) do
    layer:removeProp(v)
  end

  for i = 1, humans do
    layer:insertProp(self.humanProps[i])
  end
end

function HUD:setLives(lives)
  lifePropList = { self.life1, self.life2, self.life3}
  for k, v in pairs(lifePropList) do
    print("k: " .. k)
    layer:removeProp(v)
  end

  for i = 1, lives do
    local key = 'life' .. i
    print ("key: "..key)
    layer:insertProp(lifePropList[i])
  end

end

-- Rotates the hud based on the gravity direction.
-- Maybe needs a little bit of cleanup?
function HUD:rotateHud()
  if PhysicsManager:getGravityDirection() == "down" then
    for k, v in pairs(self.humanProps) do
      k = k-1
      self:rotateProp(v, {self.xMargin + k*ResourceDefinitions:get('human').width, SCREEN_RESOLUTION_Y - self.yMargin }, 0,-1,-1)
    end

    self:rotateProp(self.pauseButton, {SCREEN_RESOLUTION_X - self.xMargin, self.yMargin}, 0,1,1)

    self:rotateProp(self.col1, {SCREEN_RESOLUTION_X - self.xMargin - self.hudIconSize, self.yMargin}, 0,1,1)
    self:rotateProp(self.col2, {SCREEN_RESOLUTION_X - self.xMargin - 2*self.hudIconSize, self.yMargin}, 0,1,1)
    self:rotateProp(self.col3, {SCREEN_RESOLUTION_X - self.xMargin - 3*self.hudIconSize, self.yMargin}, 0,1,1)

    self:rotateProp(self.life1, {self.xMargin, self.yMargin}, 180,1,1)
    self:rotateProp(self.life2, {self.xMargin + self.hudIconSize, self.yMargin}, 180,1,1)
    self:rotateProp(self.life3, {self.xMargin + 2*self.hudIconSize, self.yMargin}, 180,1,1)

  elseif PhysicsManager:getGravityDirection() == "left" then
    for k, v in pairs(self.humanProps) do
      k = k -1
      self:rotateProp(v, {self.yMargin, self.yMargin + k*ResourceDefinitions:get('human').width }, 90,-1,-self.xyScale)
    end
    self:rotateProp(self.pauseButton, {SCREEN_RESOLUTION_X - self.yMargin, SCREEN_RESOLUTION_Y - self.yMargin}, 90,1,self.xyScale)
    
    self:rotateProp(self.col1, {SCREEN_RESOLUTION_X - self.yMargin, SCREEN_RESOLUTION_Y - self.yMargin - self.hudIconSize*self.xyScale}, 90,1,self.xyScale)
    self:rotateProp(self.col2, {SCREEN_RESOLUTION_X - self.yMargin, SCREEN_RESOLUTION_Y - self.yMargin - 2*self.hudIconSize*self.xyScale}, 90,1,self.xyScale)
    self:rotateProp(self.col3, {SCREEN_RESOLUTION_X - self.yMargin, SCREEN_RESOLUTION_Y - 3*self.hudIconSize*self.xyScale -self.yMargin}, 90,1,self.xyScale)

    self:rotateProp(self.life1, {SCREEN_RESOLUTION_X - self.yMargin, self.yMargin}, 270,1,self.xyScale)
    self:rotateProp(self.life2, {SCREEN_RESOLUTION_X - self.yMargin,  self.yMargin + self.hudIconSize*self.xyScale}, 270,1,self.xyScale)
    self:rotateProp(self.life3, {SCREEN_RESOLUTION_X - self.yMargin,  self.yMargin + 2*self.hudIconSize*self.xyScale}, 270,1,self.xyScale)

  elseif PhysicsManager:getGravityDirection() == "right" then
    for k, v in pairs(self.humanProps) do
      k = k -1
      self:rotateProp(v, {SCREEN_RESOLUTION_X - self.yMargin, SCREEN_RESOLUTION_Y - self.yMargin - k*ResourceDefinitions:get('human').width }, 270,-1,-self.xyScale)
    end

    self:rotateProp(self.pauseButton, {self.yMargin, self.yMargin}, 270, 1, self.xyScale)


    self:rotateProp(self.col1, {self.yMargin, self.yMargin +self.hudIconSize*self.xyScale}, 270,1,self.xyScale)
    self:rotateProp(self.col2, {self.yMargin, self.yMargin +2* self.hudIconSize*self.xyScale}, 270,1,self.xyScale)
    self:rotateProp(self.col3, {self.yMargin, self.yMargin +3* self.hudIconSize*self.xyScale}, 270,1,self.xyScale)

    self:rotateProp(self.life1, {self.yMargin, SCREEN_RESOLUTION_Y - self.yMargin}, 90,1,self.xyScale)
    self:rotateProp(self.life2, {self.yMargin, SCREEN_RESOLUTION_Y - self.yMargin - self.hudIconSize*self.xyScale}, 90,1,self.xyScale)
    self:rotateProp(self.life3, {self.yMargin, SCREEN_RESOLUTION_Y - self.yMargin - 2* self.hudIconSize*self.xyScale}, 90,1,self.xyScale)

  elseif PhysicsManager:getGravityDirection() == "up" then
    for k, v in pairs(self.humanProps) do
      k = k -1
      self:rotateProp(v, {SCREEN_RESOLUTION_X - self.xMargin - k*ResourceDefinitions:get('human').width, self.yMargin }, 180,-1,-1)
    end
    self:rotateProp(self.pauseButton, {self.xMargin, SCREEN_RESOLUTION_Y - self.yMargin}, 180, 1, 1)
    
    
    self:rotateProp(self.col1, {self.xMargin +self.hudIconSize, SCREEN_RESOLUTION_Y - self.yMargin}, 180,1,1)
    self:rotateProp(self.col2, {self.xMargin +2*self.hudIconSize, SCREEN_RESOLUTION_Y - self.yMargin}, 180,1,1)
    self:rotateProp(self.col3, {self.xMargin+3* self.hudIconSize, SCREEN_RESOLUTION_Y - self.yMargin}, 180,1,1)

    self:rotateProp(self.life1, {SCREEN_RESOLUTION_X - self.xMargin, SCREEN_RESOLUTION_Y - self.yMargin}, 0,1,1)
    self:rotateProp(self.life2, {SCREEN_RESOLUTION_X - self.xMargin -self.hudIconSize, SCREEN_RESOLUTION_Y - self.yMargin}, 0,1,1)
    self:rotateProp(self.life3, {SCREEN_RESOLUTION_X - self.xMargin -2*self.hudIconSize, SCREEN_RESOLUTION_Y - self.yMargin}, 0,1,1)

  end
end


function HUD:makeInterfaceElement(resource, name, xloc, yloc, scale)
  local elementGFX = ResourceManager:get(resource)
  local elementProp = MOAIProp2D.new()
  elementProp:setDeck(elementGFX)
  elementProp:setLoc(xloc, yloc)
  elementProp.name = name
  elementProp:setScl(scale)

  return elementProp
end

function HUD:rotateProp(prop, location, rotation, inverted, scale)
  local x, y = unpack(location)
  prop:setLoc(x,y)
  prop:setRot(rotation)
  prop:setScl(inverted*scale, scale)
end

function HUD:rotateTimer(timer, rect, rotation, inverted, scale)
  local xMin, yMin, xMan, yMax = unpack(rect)
  timer:setRect(xMin, yMin, xMan, yMax)
  timer:setRot(rotation)
  timer:setScl(inverted*scale, scale)
end


function HUD:makeButton (resource, name, xloc, yloc,scale, layer)
  local buttonGFX =ResourceManager:get(resource)
  local  button = MOAIProp2D.new()
  button:setDeck (buttonGFX)
  button:setLoc (xloc,yloc)
  button:setScl(scale, 1)
  button.name = name
  layer:insertProp (button)
  partition:insertProp(button)

  return button

end

function HUD:pause(input)
  print(self.paused)
  self.paused = not self.paused
  if self.paused == true then
    if(input == 'pause') then
      self:showPauseMenu()
    end
    Game:pause(self.paused)
    self.countdownTimer:pause()
  else
    Game:pause(self.paused)
    self.countdownTimer:start()
    if(input == 'pause') then
      self:hidePauseMenu()
    end
  end
end

function HUD:showEndScreen(liveLeft, timeLeft)
  self:pause('end')
  
  self.endLayerBackground = MOAILayer2D.new()
  self.endLayerBackground:setViewport(viewport)
  
  self.endLayer = MOAILayer2D.new()
  self.endLayer:setPartition(partition)
  self.endLayer:setViewport(viewport)
  --self.endLayer:setClearColor(0.5,0.5,0.5,0.1)
  
  local resourceX  = ResourceDefinitions:get('button_level_background').width 
  local resourceY =  ResourceDefinitions:get('button_level_background').height 
  
  self.endProp = MOAIProp2D.new()
  local deck = ResourceManager:get('menu_background')

  self.endProp:setLoc(SCREEN_RESOLUTION_X/2,SCREEN_RESOLUTION_Y/2)
  self.endProp:setDeck(deck)
  self.endLayer:insertProp(self.endProp)
  
  self.complete = self:makeText(25, 'LEVEL COMPLETE', {SCREEN_RESOLUTION_X/2 - 200, SCREEN_RESOLUTION_Y/5, SCREEN_RESOLUTION_X/2 + 200, SCREEN_RESOLUTION_Y/5+30},{0,0,0}, self.endLayer)
  self.timeLeft = self:makeText(25, 'TIME LEFT: '..timeLeft, {SCREEN_RESOLUTION_X/5 - 150 ,SCREEN_RESOLUTION_Y/12 * 4, SCREEN_RESOLUTION_X/5 + 200, SCREEN_RESOLUTION_Y/12* 4 +50}, {0,0,0}, self.endLayer)
  self.livesLeftText = self:makeText(25, 'HUMANS SAVED: ', {SCREEN_RESOLUTION_X/4 - 200 ,SCREEN_RESOLUTION_Y/12 * 5, SCREEN_RESOLUTION_X/5 + 200, SCREEN_RESOLUTION_Y/12* 5+50}, {0,0,0}, self.endLayer)

  self.retryButton = self:makeButton('button_level_background', 'retryButton', SCREEN_RESOLUTION_X/6 * 2 , SCREEN_RESOLUTION_Y/6 * 4 , 1 ,self.endLayer )
  self.retryText = self:makeText(25, 'RETRY', {SCREEN_RESOLUTION_X/6 * 2 - resourceX/2 ,SCREEN_RESOLUTION_Y/6 * 4 - resourceY/2, SCREEN_RESOLUTION_X/6 * 2 + resourceX/2, SCREEN_RESOLUTION_Y/6 * 4 + resourceY/2}, {0,0,0}, self.endLayer)

  self.menuButton = self:makeButton('button_level_background', 'menuButton', SCREEN_RESOLUTION_X/6 * 4 , SCREEN_RESOLUTION_Y/6 * 4 , 1 ,self.endLayer )
  self.menuText = self:makeText(25, 'MAIN MENU', {SCREEN_RESOLUTION_X/6 * 4 - resourceX/2 ,SCREEN_RESOLUTION_Y/6 * 4 - resourceY/2, SCREEN_RESOLUTION_X/6 * 4 + resourceX/2, SCREEN_RESOLUTION_Y/6 * 4+resourceY/2}, {0,0,0}, self.endLayer)
  local humanWidth = ResourceDefinitions:get('human').width
  print(liveLeft)
  for i = 1, liveLeft do
    local humanProp = MOAIProp2D.new()
    humanProp:setDeck(ResourceManager:get('human'))
    humanProp:setLoc(SCREEN_RESOLUTION_X/4 +100 + i * humanWidth+5*i,SCREEN_RESOLUTION_Y/12 * 5.5 )
    humanProp:setScl(1,-1)
    self.endLayer:insertProp(humanProp)
  end
  
  
  local layers = MOAIRenderMgr.getRenderTable()
  table.insert(layers, self.endLayer)
  
  MOAIRenderMgr.setRenderTable(layers)
  

end

function HUD:showGameOverScreen()
  layer:removeProp(self.restartButton)
  partition:removeProp(self.restartButton)
end

function HUD:showGameOverScreen()
  self:pause('end')
  
  self.endLayerBackground = MOAILayer2D.new()
  self.endLayerBackground:setViewport(viewport)
  
  self.endLayer = MOAILayer2D.new()
  self.endLayer:setPartition(partition)
  self.endLayer:setViewport(viewport)
  
  local resourceX  = ResourceDefinitions:get('button_level_background').width 
  local resourceY =  ResourceDefinitions:get('button_level_background').height 
  
  self.endProp = MOAIProp2D.new()
  local deck = ResourceManager:get('menu_background')

  self.endProp:setLoc(SCREEN_RESOLUTION_X/2,SCREEN_RESOLUTION_Y/2)
  self.endProp:setDeck(deck)
  self.endLayer:insertProp(self.endProp)
  
  self.complete = self:makeText(25, 'GAME OVER', {SCREEN_RESOLUTION_X/2 - 200, SCREEN_RESOLUTION_Y/5, SCREEN_RESOLUTION_X/2 + 200, SCREEN_RESOLUTION_Y/5+30},{0,0,0}, self.endLayer)
 
  self.retryButton = self:makeButton('button_level_background', 'retryButton', SCREEN_RESOLUTION_X/6 * 2 , SCREEN_RESOLUTION_Y/6 * 4 , 1 ,self.endLayer )
  self.retryText = self:makeText(25, 'RETRY', {SCREEN_RESOLUTION_X/6 * 2 - resourceX/2 ,SCREEN_RESOLUTION_Y/6 * 4 - resourceY/2, SCREEN_RESOLUTION_X/6 * 2 + resourceX/2, SCREEN_RESOLUTION_Y/6 * 4 + resourceY/2}, {0,0,0}, self.endLayer)

  self.menuButton = self:makeButton('button_level_background', 'menuButton', SCREEN_RESOLUTION_X/6 * 4 , SCREEN_RESOLUTION_Y/6 * 4 , 1 ,self.endLayer )
  self.menuText = self:makeText(25, 'MAIN MENU', {SCREEN_RESOLUTION_X/6 * 4 - resourceX/2 ,SCREEN_RESOLUTION_Y/6 * 4 - resourceY/2, SCREEN_RESOLUTION_X/6 * 4 + resourceX/2, SCREEN_RESOLUTION_Y/6 * 4+resourceY/2}, {0,0,0}, self.endLayer)
  
  
  local layers = MOAIRenderMgr.getRenderTable()
  table.insert(layers, self.endLayer)
  
  MOAIRenderMgr.setRenderTable(layers)
  

end

function HUD:makeText(size, text, rectangle, color, layer)
  local textBox = MOAITextBox.new()
  textBox:setFont(self.font)
  textBox:setTextSize(size)
  textBox:setString(text)
  textBox.name = text
  textBox:setAlignment(1, 1)
  textBox:setRect(unpack(rectangle))
  textBox:setColor(unpack(color))
  layer:insertProp(textBox)
  partition:insertProp(textBox)
  return textBox
end

function HUD:handleClickOrTouch(x, y, down)
  local pickedProp = partition:propForPoint(layer:wndToWorld(x,y))
  if pickedProp  then
    if pickedProp.name ~= nil then 
      print(pickedProp.name)
    end
    -- if pickedProp.name == 'left' then
    --   Game:keyPressed ( 'left', down )
    -- elseif pickedProp.name == 'right' then

    --   Game:keyPressed ('right', down)
    if pickedProp.name == 'restart' then
      Game:restart()
    elseif pickedProp.name == 'pause' and down == true then
      self:pause('pause')
    elseif pickedProp.name == 'continue' and down == true then
      self:pause('pause')
    elseif pickedProp.name == 'restart' and down == true then
      Game:restart()
    elseif pickedProp.name == 'mainmenu' and down == true then
      switchScene(MENU_LEVEL)
    elseif pickedProp.name == 'RETRY' and down == true then
      Game:restart()
    elseif pickedProp.name == 'MAIN MENU' and down == true then
      switchScene(MENU_LEVEL)
    end

  else
    Game:keyPressed ('up', down)
  end
end

function HUD:startTimer()

  countdownTimer:setMode( MOAITimer.LOOP)
  countdownTimer:setSpan(1)
  countdownTimer:setListener( MOAITimer.EVENT_TIMER_LOOP, function()
      self.countdownTime = self.countdownTime - 1
      division = 10
      if self.countdownTime < 100 then
        self.humansLeft = math.floor(self.countdownTime/division)
        print(self.humansLeft)
        self:updateHumans(self.humansLeft)
      end
      if (countdownTime == 0) then
        countdownTimer:stop()
        self:showGameOverScreen()
      end
    end
  )
  self.countdownTimer:start()
end

function HUD:cleanup()
end

function HUD:showPauseMenu()
  self.pauseLayer = MOAILayer2D.new()
  self.blueback = MOAIProp2D.new()
  self.pauseLayer:setViewport(viewport)
  self.pauseLayer:setPartition(partition)


  self.blueback = MOAIProp2D.new()
  local deck = ResourceManager:get('menu_background')

  self.blueback:setLoc(SCREEN_RESOLUTION_X/2,SCREEN_RESOLUTION_Y/2)
  self.blueback:setDeck(deck)
  self.pauseLayer:insertProp(self.blueback)

  self.continueButton = self:makeButton('button_level_background', 'continue', SCREEN_RESOLUTION_X/2 - 2*163, SCREEN_RESOLUTION_Y/2, 1,self.pauseLayer)
  self.continueButtonText = self:makeText(20, 'continue', {SCREEN_RESOLUTION_X/2 - 2.5*163, SCREEN_RESOLUTION_Y/2-10, SCREEN_RESOLUTION_X/2 - 1.5*163, SCREEN_RESOLUTION_Y/2+10},{0,0,0}, self.pauseLayer)

  self.restartButton  = self:makeButton('button_level_background', 'restart' , SCREEN_RESOLUTION_X/2, SCREEN_RESOLUTION_Y/2, 1, self.pauseLayer)
  self.restartButtonText = self:makeText(20, 'restart', {SCREEN_RESOLUTION_X/2 - 0.5*163, SCREEN_RESOLUTION_Y/2-10, SCREEN_RESOLUTION_X/2 + 0.5*163, SCREEN_RESOLUTION_Y/2+10},{0,0,0}, self.pauseLayer)

  self.mainMenuButton = self:makeButton('button_level_background', 'mainmenu', SCREEN_RESOLUTION_X/2 + 2*163, SCREEN_RESOLUTION_Y/2, 1,self.pauseLayer)
  self.mainMenuButtonText = self:makeText(20, 'main menu', {SCREEN_RESOLUTION_X/2 + 1.5*163, SCREEN_RESOLUTION_Y/2-10, SCREEN_RESOLUTION_X/2 + 2.5*163, SCREEN_RESOLUTION_Y/2+10},{0,0,0}, self.pauseLayer)

 


  local layers = MOAIRenderMgr.getRenderTable()
  table.insert(layers,self.pauseLayer)
  table.insert(layers, self.pauseButtonLayer)
  MOAIRenderMgr.setRenderTable(layers)
end


function HUD:hidePauseMenu()

  self.pauseLayer:removeProp(self.continueButton)
  self.pauseLayer:removeProp(self.continueButtonText)
  self.pauseLayer:removeProp(self.restartButton)
  self.pauseLayer:removeProp(self.restartButtonText)
  self.pauseLayer:removeProp(self.mainMenuButton)
  self.pauseLayer:removeProp(self.mainMenuButtonText)
  self.pauseLayer:removeProp(self.blueback)
  local layers = MOAIRenderMgr.getRenderTable()
  table.remove(layers)
  MOAIRenderMgr.setRenderTable(layers)
end