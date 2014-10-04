module ("MainMenu", package.seeall)

local resource_definitions = {
  background = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/menu_background.png',
    width = SCREEN_RESOLUTION_X, height = SCREEN_RESOLUTION_Y
  },
  button_background = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/button_background.png',
    width = 291, height = 124
  },
  font = {
    type = RESOURCE_TYPE_FONT,
    fileName = 'fonts/redfive.ttf',
    glyphs = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.?!",
    fontSize = 26,
    dpi = 160
  },
}

function MainMenu:build()
  self:initialize()
  return self
end

function MainMenu:update()
  while(true) do
    
    
    coroutine.yield ()    

  end
end

function MainMenu:initialize()


  ResourceDefinitions:setDefinitions ( resource_definitions )
  InputManager:initialize()
  self.renderTable = {}
  self.camera = MOAICamera2D.new()

  layer = MOAILayer2D.new()
  partition = MOAIPartition.new()
  layer:setViewport ( viewport )
  layer:setCamera ( self.camera )
  layer:setPartition(partition)

  self:initializeBackground()
  self:initializeButtons()

  self.renderTable = {
    self.layer
  }
  MOAIRenderMgr.setRenderTable(self.renderTable)

end

function MainMenu:initializeBackground()
  local deck = ResourceManager:get('background')
  local prop = MOAIProp2D.new()
  prop:setDeck(deck)
  prop:setLoc(SCREEN_RESOLUTION_X / 2, SCREEN_RESOLUTION_Y/2)
  layer:insertProp(prop)
end

function MainMenu:initializeButtons()
  self.font = MOAIFont.new ()
  self.font = ResourceManager:get ( "font" )
  button = self:makeButton('play', SCREEN_RESOLUTION_X/2, SCREEN_RESOLUTION_Y/2, 'play')
  textBox = self:makeText(40, 'play', {SCREEN_RESOLUTION_X/2 - resource_definitions.button_background.width/2, SCREEN_RESOLUTION_Y/2 - resource_definitions.button_background.height/2, SCREEN_RESOLUTION_X/2 + resource_definitions.button_background.width/2, SCREEN_RESOLUTION_Y/2 + resource_definitions.button_background.height/2})

end


function MainMenu:makeButton(name, xpos, ypos, text)
  local buttonGFX =ResourceManager:get('button_background')
  local  button = MOAIProp2D.new()
  button.name = name
  button:setDeck (buttonGFX)
  button:setLoc (xpos,ypos)
  layer:insertProp (button)
  partition:insertProp(button)

  return button
end

function MainMenu:makeText(size, text, rectangle)
  local textBox = MOAITextBox.new()
  textBox:setFont(self.font)
  textBox:setTextSize(size)
  textBox:setString(text)
  textBox.name = text
  textBox:setAlignment(1, 1)
  textBox:setRect(unpack(rectangle))
  layer:insertProp(textBox)
  partition:insertProp(textBox)
  return textBox
end

function MainMenu:getLayers()
  return self.renderTable
end

function MainMenu:handleClickOrTouch(x, y, isDown)
  local pickedProp = partition:propForPoint(layer:wndToWorld(x,y))
  print (pickedProp.name)
  if pickedProp then
    if pickedProp.name == 'play' then
      switchScene(level_files.level1)
    end
  end
end

function MainMenu:cleanup()
end

