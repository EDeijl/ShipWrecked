module ("MainMenu", package.seeall)

local resource_definitions = {
  background = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/menu_background.png',
    width = WORLD_RESOLUTION_X, height = WORLD_RESOLUTION_Y
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
local saveFile = savefiles.get ( "save" )
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
  print("resolution: " .. WORLD_RESOLUTION_X .. " ," .. WORLD_RESOLUTION_Y)
  prop:setLoc(WORLD_RESOLUTION_X / 2, WORLD_RESOLUTION_Y/2)
  print("background: " .. prop:getLoc())
  self.layer:insertProp(prop)
end

function MainMenu:initializeButtons()
  self.font = MOAIFont.new ()
  self.font = ResourceManager:get ( "font" )
  button = self:makeButton('play', WORLD_RESOLUTION_X/2, WORLD_RESOLUTION_Y/2)
  textBox = self:makeText(40, 'play', {WORLD_RESOLUTION_X/2 - resource_definitions.button_background.width/2, WORLD_RESOLUTION_Y/2 - resource_definitions.button_background.height/2, WORLD_RESOLUTION_X/2 + resource_definitions.button_background.width/2, WORLD_RESOLUTION_Y/2 + resource_definitions.button_background.height/2})textBox = self:makeText(40, 'play', {WORLD_RESOLUTION_X/2 - resource_definitions.button_background.width/2, WORLD_RESOLUTION_Y/2 - resource_definitions.button_background.height/2, WORLD_RESOLUTION_X/2 + resource_definitions.button_background.width/2, WORLD_RESOLUTION_Y/2 + resource_definitions.button_background.height/2})
  textBox = self:makeText(40, 'SHIPWRECKED IN SPACE', {WORLD_RESOLUTION_X/2 - 200, WORLD_RESOLUTION_Y/8 - 50, WORLD_RESOLUTION_X/2 + 200, WORLD_RESOLUTION_Y/8 + 50})
  print("button: " .. button:getLoc())
end


function MainMenu:makeButton(name, xpos, ypos)
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
      AudioManager:play('shoot', false)
--      print ("save file:")
--      print (savefiles.get ( "save" ).fileexist)
      if not savefiles.get ( "save" ).fileexist then
--        print "check"
        saveFile.data = savefiles.createNewData()
        print ("Save file data: " .. tostring(saveFile.data))
        saveFile:saveGame()
      end
      switchScene(MENU_LEVEL)
    end
  end
end

function MainMenu:cleanup()
  self.playing = false
  for k, v in pairs(resource_definitions) do
    ResourceDefinitions:remove(k)
    ResourceManager:unload(k)
  end
end

