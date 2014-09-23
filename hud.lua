module ( "HUD", package.seeall )

------------------------------------------------
-- initialize ( )
-- initializes the hud
------------------------------------------------

function HUD:initialize ()
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
  
  -- Now we need to render the layer.
  local renderTable = MOAIRenderMgr.getRenderTable ()
  table.insert ( renderTable, self.layer )
  MOAIRenderMgr.setRenderTable ( renderTable )
  
  -- Add left and right indicator
  self:initializeDebugHud ()
  
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
    self.leftRightIndicator:setString ( "Left" )
  else
    self.leftRightIndicator:setString ( "Right" )
  end
  
  -- To update the character position
  -- we need to query its Box2D body.
  -- We get its position and create
  -- a string in the format of (x,y).
  x, y = Character.physics.body:getPosition ()
  self.positionIndicator:setString ( "( " .. 
      math.floor ( x ) .. " , " .. 
      math.floor ( y ) .. " )" )

end


























--  -- setup
--  self:setupMousePosition ()
--  self:setupMemory ()
--  
--end
--
--
--function setupMousePosition ( self )
--  mouseWorldPositionTextbox:setFont ( font )
--  mouseWorldPositionTextbox:setTextSize ( 12 )
--  mouseWorldPositionTextbox:setYFlip( true )
--  mouseWorldPositionTextbox:setRect ( - SCREEN_RESOLUTION_X / 2 + 5 , SCREEN_RESOLUTION_Y / 2 + 10, - SCREEN_RESOLUTION_X / 2 + 120, SCREEN_RESOLUTION_Y / 2 + 10 - 14)
--  layer:insertProp ( mouseWorldPositionTextbox )
--  
--  mouseWindowPositionTextbox:setFont ( font )
--  mouseWindowPositionTextbox:setTextSize ( 12 )
--  mouseWindowPositionTextbox:setYFlip( true )
--  mouseWindowPositionTextbox:setRect ( - SCREEN_RESOLUTION_X / 2 + 5 , SCREEN_RESOLUTION_Y / 2 - 10, - SCREEN_RESOLUTION_X / 2 + 120, SCREEN_RESOLUTION_Y / 2 - 10 - 14)
--  layer:insertProp ( mouseWindowPositionTextbox )
--end
--
--function setupMemory( self )
--  memoryTextbox:setFont ( font )
--  memoryTextbox:setTextSize ( 12 )
--  memoryTextbox:setYFlip( true )
--  memoryTextbox:setRect ( - SCREEN_RESOLUTION_X / 2 + 5 , SCREEN_RESOLUTION_Y / 2 - 30, - SCREEN_RESOLUTION_X / 2 + 120, SCREEN_RESOLUTION_Y / 2 - 30 - 14)
--  layer:insertProp ( memoryTextbox )
--
--  self.memoryTimer = MOAITimer.new ()
--  self.memoryTimer:setSpan (0.01)
--  self.memoryTimer:setMode (MOAITimer.LOOP)
--  self.memoryTimer:setListener ( MOAITimer.EVENT_TIMER_LOOP, displayMemory)
--  self.memoryTimer:start ()
--end
--
--
--function setMouseWorldPosition(self, x,y)
--  mouseWorldPositionTextbox:setString ( "World: (" .. math.floor(x) .. "," .. math.floor(y) .. ")" )
--end
--
--function setMouseWindowPosition(self, x,y)
--  mouseWindowPositionTextbox:setString ( "Window: (" .. x .. "," .. y .. ")" )
--end
--
--function displayMemory ( timer, n)
--  memoryTextbox:setString ("Memory: " .. checkMem( true ) .. " MB ") 
--end
--function getLayer ()
--  return layer
--end
--