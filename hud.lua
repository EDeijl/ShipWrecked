module ( "HUD", package.seeall )

------------------------------------------------
-- initialize ( )
-- initializes the hud
------------------------------------------------

function HUD:initialize ()
  -- Set the countdowntimer in seconds
  self.countdownTime = 300
  self.isOverlay = true

  self.xMargin = SCREEN_RESOLUTION_X / 30
  self.yMargin = SCREEN_RESOLUTION_Y / 17
  self.xyScale = SCREEN_RESOLUTION_Y / SCREEN_RESOLUTION_X
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
  self:initializeDebugHud ()
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

  self.timerIndictator = self:newDebugTextBox ( 30, {10, 90, 300, 150 } )


end
function HUD:initializeControls()

  -- make clickable buttons
  self.leftButton = self:makeButton('button_right', 'left',self.xMargin + 50 , SCREEN_RESOLUTION_Y - 20 - self.yMargin, -1, 'left')
  self.rightButton = self:makeButton('button_right', 'right',self.xMargin + 160 , SCREEN_RESOLUTION_Y - 20 - self.yMargin, 1, 'right')

  -- build other non clickable interface elements
  self.col1 = self:makeInterfaceElement('col1_nonactive', 'col1', SCREEN_RESOLUTION_X - self.xMargin , 20 + self.yMargin, 1)
  self.col2 = self:makeInterfaceElement('col2_nonactive', 'col2', SCREEN_RESOLUTION_X - self.xMargin - 100, 20 + self.yMargin, 1)
  self.col3 = self:makeInterfaceElement('col3_nonactive', 'col3', SCREEN_RESOLUTION_X - self.xMargin - 200, 20 + self.yMargin, 1)
  layer:insertProp(self.col1)
  partition:insertProp(self.col1)  
  layer:insertProp(self.col2)
  partition:insertProp(self.col2)  
  layer:insertProp(self.col3)
  partition:insertProp(self.col3)
  self.life1 = self:makeInterfaceElement('life', 'life1', self.xMargin, 20+self.yMargin, 1)
  self.life2 = self:makeInterfaceElement('life', 'life2', self.xMargin + 100, 20+self.yMargin, 1)
  self.life3 = self:makeInterfaceElement('life', 'life3', self.xMargin + 200, 20+self.yMargin, 1)

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

  -- If the x scale is > 0 we know it's
  -- facing left, and if it's < 0, it's 
  -- inverted, so it has to be facing
  -- right.
  if x > 0 then
    self.leftRightIndicator:setString ( "Right" )
  else
    self.leftRightIndicator:setString ( "Left" )
  end

  -- To update the character position
  -- we need to query its Box2D body.
  -- We get its position and create
  -- a string in the format of (x,y).
  x, y = Character.physics.body:getPosition ()
  self.positionIndicator:setString ( "( " .. 
    math.floor ( x ) .. " , " .. 
    math.floor ( y ) .. " )" )
  self:rotateHud()
end

function HUD:setCollected(collectible)
  if collectible.name == 'collectible_1' then
    self.col1:setDeck(ResourceManager:get('col1_active'))
  elseif collectible.name == 'collectible_2' then
    self.col2:setDeck(ResourceManager:get('col2_active'))
  elseif collectible.name == 'collectible_3' then
    self.col3:setDeck(ResourceManager:get('col3_active'))
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


function HUD:rotateHud()
  if PhysicsManager:getGravityDirection() == "down" then

    self.leftButton:setLoc( 50  + self.xMargin, SCREEN_RESOLUTION_Y - self.yMargin - 20)
    self.leftButton:setRot(0)
    self.rightButton:setLoc( 155  + self.xMargin, SCREEN_RESOLUTION_Y - self.yMargin - 20)
    self.rightButton:setRot(0)

    self.col1:setLoc(SCREEN_RESOLUTION_X - self.xMargin , self.yMargin + 20)
    self.col2:setLoc(SCREEN_RESOLUTION_X - self.xMargin -100 , self.yMargin + 20)
    self.col3:setLoc(SCREEN_RESOLUTION_X - self.xMargin -200 , self.yMargin + 20)

    self.col1:setRot(0)
    self.col2:setRot(0)
    self.col3:setRot(0)

    self.life1:setLoc(self.xMargin, self.yMargin +20)
    self.life2:setLoc(self.xMargin +100, self.yMargin +20)
    self.life3:setLoc(self.xMargin + 200, self.yMargin +20)

    self.life1:setRot(180)
    self.life2:setRot(180)
    self.life3:setRot(180)

  elseif PhysicsManager:getGravityDirection() == "left" then

    self.leftButton:setLoc( 20 + self.yMargin, self.xMargin + 50)
    self.leftButton:setRot(90)
    self.rightButton:setLoc( 20 + self.yMargin, 155 + self.xMargin)
    self.rightButton:setRot(90)

    self.col1:setLoc(SCREEN_RESOLUTION_X - self.yMargin -20, SCREEN_RESOLUTION_Y - self.xMargin)
    self.col2:setLoc(SCREEN_RESOLUTION_X - self.yMargin -20, SCREEN_RESOLUTION_Y - self.xMargin- 100)
    self.col3:setLoc(SCREEN_RESOLUTION_X - self.yMargin -20, SCREEN_RESOLUTION_Y - self.xMargin- 200)
    self.col1:setRot(90)
    self.col2:setRot(90)
    self.col3:setRot(90)

    self.life1:setLoc(SCREEN_RESOLUTION_X - self.yMargin - 20, self.xMargin)
    self.life2:setLoc(SCREEN_RESOLUTION_X - self.yMargin - 20,  self.xMargin + 100)
    self.life3:setLoc(SCREEN_RESOLUTION_X - self.yMargin - 20,  self.xMargin + 200)

    self.life1:setRot(270)
    self.life2:setRot(270)
    self.life3:setRot(270)

  elseif PhysicsManager:getGravityDirection() == "right" then

    self.leftButton:setLoc(SCREEN_RESOLUTION_X - 20 - self.yMargin, SCREEN_RESOLUTION_Y - self.xMargin - 50)
    self.leftButton:setRot(270)
    self.rightButton:setLoc(SCREEN_RESOLUTION_X - 20 - self.yMargin, SCREEN_RESOLUTION_Y - self.xMargin - 155)
    self.rightButton:setRot(270)

    self.col1:setLoc(20+self.yMargin, self.xMargin)
    self.col2:setLoc(20+self.yMargin, self.xMargin +100)
    self.col3:setLoc(20+self.yMargin, self.xMargin +200)

    self.col1:setRot(270)
    self.col2:setRot(270)
    self.col3:setRot(270)

    self.life1:setLoc(self.yMargin, SCREEN_RESOLUTION_Y - self.xMargin)
    self.life2:setLoc(self.yMargin, SCREEN_RESOLUTION_Y - self.xMargin - 100)
    self.life3:setLoc(self.yMargin, SCREEN_RESOLUTION_Y - self.xMargin - 200)

    self.life1:setRot(90)
    self.life2:setRot(90)
    self.life3:setRot(90)

  elseif PhysicsManager:getGravityDirection() == "up" then

    self.leftButton:setLoc(SCREEN_RESOLUTION_X - 50 - self.xMargin, self.yMargin + 20)
    self.leftButton:setRot(180)
    self.rightButton:setLoc(SCREEN_RESOLUTION_X - 155 - self.xMargin, self.yMargin + 20)
    self.rightButton:setRot(180)

    self.col1:setLoc(self.xMargin, SCREEN_RESOLUTION_Y - self.yMargin -20)
    self.col2:setLoc(self.xMargin +100, SCREEN_RESOLUTION_Y - self.yMargin -20)
    self.col3:setLoc(self.xMargin+200, SCREEN_RESOLUTION_Y - self.yMargin -20)

    self.col1:setRot(180)
    self.col2:setRot(180)
    self.col3:setRot(180)

    self.life1:setLoc(SCREEN_RESOLUTION_X - self.xMargin, SCREEN_RESOLUTION_Y - self.yMargin -20)
    self.life2:setLoc(SCREEN_RESOLUTION_X - self.xMargin -100, SCREEN_RESOLUTION_Y - self.yMargin -20)
    self.life3:setLoc(SCREEN_RESOLUTION_X - self.xMargin -200, SCREEN_RESOLUTION_Y - self.yMargin -20)

    self.life1:setRot(0)
    self.life2:setRot(0)
    self.life3:setRot(0)
  end
end


function HUD:makeInterfaceElement(resource, name, xloc, yloc, scale)
  local elementGFX = ResourceManager:get(resource)
  local elementProp = MOAIProp2D.new()
  elementProp:setDeck(elementGFX)
  elementProp:setLoc(xloc, yloc)
  elementProp.name = name
  elementProp:setScl(scale*0.2, 0.2)

  return elementProp
end


function HUD:makeButton (resource, name, xloc, yloc,scale, text)
  local buttonGFX =ResourceManager:get(resource)
  local  button = MOAIProp2D.new()
  button:setDeck (buttonGFX)
  button:setLoc (xloc,yloc)
  button:setScl(scale*0.2, 0.2)
  button.name = name
  layer:insertProp (button)
  partition:insertProp(button)

  return button

end


function HUD:showEndScreen()
  self.restartButton = HUD:makeButton('restart', SCREEN_RESOLUTION_X / 2, SCREEN_RESOLUTION_Y / 2, 'restart')
end

function HUD:removeEndScreen()
  layer:removeProp(self.restartButton)
  partition:removeProp(self.restartButton)
end


function HUD:addTextbox ( top, height, alignment, yflip, textinput)

  textbox = MOAITextBox.new ()
  textbox:setString ( textinput )
  textbox:setFont ( font )
  textbox:setTextSize ( 12, 326 )
  textbox:setRect ( -280, top - height, 280, top )
  textbox:setAlignment ( alignment )
  textbox:setYFlip ( true )
  layer:insertProp ( textbox )
  return textbox
end


function HUD:handleClickOrTouch(x, y, down)
  local pickedProp = partition:propForPoint(layer:wndToWorld(x,y))
  if pickedProp then
    if pickedProp.name == 'left' then
      Game:keyPressed ( 'left', down )
    elseif pickedProp.name == 'right' then
      Game:keyPressed ('right', down)
    elseif pickedProp.name == 'restart' then
      Game:restart()
    end
  else
    Game:keyPressed ('up', down)
  end
end


function HUD:moveProp(prop, targetX, targetY, targetRot)
  xProp, yProp = prop:getLoc()
  propRot = prop:getRot()
  prop:setLoc(targetX - xProp, targetY - yProp, 0, MOAIEaseType.SMOOTH)
  prop:setLoc(targetRot - propRot)
end

function HUD:startTimer()
  countdownTimer = MOAITimer.new()
  countdownTimer:setMode( MOAITimer.LOOP)
  countdownTimer:setSpan(1)
  countdownTimer:setListener( MOAITimer.EVENT_TIMER_LOOP, function()
      self.countdownTime = self.countdownTime - 1
      self.timerIndictator:setString( "Time left: "..self.countdownTime )
      if (countdownTime == 0) then
        countdownTimer:stop()
        switchScene(MAIN_MENU)
      end
    end
  )
  countdownTimer:start()
end

function HUD:cleanup()
end
