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
  while self.playing == true do
    coroutine.yield ()    
  end
end

function MainMenu:initialize()

  self.playing = true
  ResourceDefinitions:setDefinitions ( resource_definitions )
  InputManager:initialize()
  self.renderTable = {}
  self.camera = MOAICamera2D.new()

  self.layer = MOAILayer2D.new()
  self.partition = MOAIPartition.new()
  self.layer:setViewport ( viewport )
  self.layer:setCamera ( self.camera )
  self.layer:setPartition(self.partition)

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
  self.layer:insertProp(prop)
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
  self.layer:insertProp (button)
  self.partition:insertProp(button)

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
  self.layer:insertProp(textBox)
  self.partition:insertProp(textBox)
  return textBox
end

function MainMenu:getLayers()
  return self.renderTable
end

function MainMenu:handleClickOrTouch(x, y, isDown)
  local pickedProp = self.partition:propForPoint(self.layer:wndToWorld(x,y))
  print (pickedProp.name)
  if pickedProp then
    if pickedProp.name == 'play' then
      switchScene(level_files.level1)
    end
  end
end

function MainMenu:cleanup()
  self.playing = false
end

