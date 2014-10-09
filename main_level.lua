module ("MenuLevel", package.seeall)

local resource_definitions = {
  background = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/level_select_background.png',
    width = WORLD_RESOLUTION_X, height = WORLD_RESOLUTION_Y
  },
  button_level_background = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/button_level_background.png',
    width = 163, height = 121
  },
  button_level_background_back = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/button_level_background_back.png',
    width = 163, height = 61
  },
  font = {
    type = RESOURCE_TYPE_FONT,
    fileName = 'fonts/redfive.ttf',
    glyphs = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.?!",
    fontSize = 26,
    dpi = 160
  }
}

function MenuLevel:build()
  self:initialize()
  return self
end

function MenuLevel:update()
  while self.playing == true do
    coroutine.yield ()    
  end
end

function MenuLevel:initialize()

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

function MenuLevel:initializeBackground()
  local deck = ResourceManager:get('background')
  local prop = MOAIProp2D.new()
  prop:setDeck(deck)
  print("resolution: " .. WORLD_RESOLUTION_X .. " ," .. WORLD_RESOLUTION_Y)
  prop:setLoc(WORLD_RESOLUTION_X / 2, WORLD_RESOLUTION_Y/2)
  print("background: " .. prop:getLoc())
  self.layer:insertProp(prop)
end

function MenuLevel:initializeButtons()
  
  local amountOfLevels = #level_files
  print ("amountOfLevels: "..amountOfLevels)
  
  self:createLevelLayout(4,1)
  local resourceX  = resource_definitions.button_level_background.width 
  local resourceY = resource_definitions.button_level_background.height
  button = self:makeButton('back', WORLD_RESOLUTION_X / 10 , WORLD_RESOLUTION_Y / 10 , 'button_level_background_back')
  textBox = self:makeText(25, 'back', {WORLD_RESOLUTION_X / 10 - resourceX/2, WORLD_RESOLUTION_Y / 10 - resourceY/2 ,WORLD_RESOLUTION_X / 10 + resourceX/2, WORLD_RESOLUTION_Y / 10 + resourceY/2},{0,0,0})
  textBox = self:makeText(35, 'L E V E L S E L E C T', {WORLD_RESOLUTION_X/11 - 25, WORLD_RESOLUTION_Y/2 - 200, WORLD_RESOLUTION_X/11 + 25, WORLD_RESOLUTION_Y/2 + 200}, {1,1,1})
end

function MenuLevel:createLevelLayout(NoWidth, NoHeight)
  self.noLevels = NoWidth * NoHeight
  self.font = MOAIFont.new ()
  self.font = ResourceManager:get ( "font" )
  local resourceX  = resource_definitions.button_level_background.width 
  local resourceY =  resource_definitions.button_level_background.height
  local posX = (WORLD_RESOLUTION_X / 30) * 8
  local posY = (WORLD_RESOLUTION_Y / 30) * 8
  local xMargin = 100
  local yMargin = 75
  local position = 50
  for i = 0, NoHeight-1 do
    for j = 1, NoWidth do
      local name = "level"..(j + NoWidth*i)
      --print (name)
      button = self:makeButton(name, (posX - xMargin) + (resourceX/2 * j) + (xMargin * j), (posY) + (resourceY/2 * i) + (yMargin * i), 'button_level_background')
      textBox = self:makeText(25, name, {(posX - xMargin) + (resourceX/2 * j) + (xMargin * j) - resourceX/2, (posY) + (resourceY/2 * i) + (yMargin * i) - resourceY/2, (posX - xMargin) + (resourceX/2 * j) + (xMargin * j) + resourceX/2, (posY) + (resourceY/2 * i) + (yMargin * i) + resourceY/2}, {0,0,0})
    end
  end
end


function MenuLevel:makeButton(name, xpos, ypos, resource)
  local buttonGFX = ResourceManager:get(resource)
  local  button = MOAIProp2D.new()
  button.name = name
  button:setDeck (buttonGFX)
  button:setLoc (xpos,ypos)
  self.layer:insertProp (button)
  self.partition:insertProp(button)

  return button
end

function MenuLevel:makeText(size, text, rectangle, color)
  local textBox = MOAITextBox.new()
  textBox:setFont(self.font)
  textBox:setTextSize(size)
  textBox:setString(text)
  textBox.name = text
  textBox:setAlignment(1, 1)
  textBox:setRect(unpack(rectangle))
  textBox:setColor(unpack(color))
  self.layer:insertProp(textBox)
  self.partition:insertProp(textBox)
  return textBox
end

function MenuLevel:getLayers()
  return self.renderTable
end

function MenuLevel:handleClickOrTouch(x, y, isDown)
  local pickedProp = self.partition:propForPoint(self.layer:wndToWorld(x,y))
  print "handleClickorTouch check"

  if pickedProp and isDown == true then
    print (pickedProp.name)
    print (self.noLevels)
    for i=1, self.noLevels do
      print ("i: "..i)
      local levelNo = 'level'..i

      if pickedProp.name == levelNo and level_files[levelNo] ~= nil then
        AudioManager:play('shoot', false)

        print "level wordt ingeladen"
        switchScene(GAME_LEVEL, level_files[levelNo], levelNo)
      elseif pickedProp.name == levelNo and level_files[levelNo] == nil then
        print "level bestaat niet"
      end
    end

  end
  if pickedProp and isDown == true then
    if pickedProp.name == 'back' then
      switchScene(MAIN_MENU)
    end
  end
end

function MenuLevel:cleanup()
  self.playing = false
  for k, v in pairs(resource_definitions) do
    print ("k:"..k)
    ResourceDefinitions:remove(k)
    ResourceManager:unload(k)
  end
end

