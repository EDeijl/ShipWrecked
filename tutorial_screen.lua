module ("TutorialScreen", package.seeall)

local resource_definitions = {
  background = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/level_select_background.png',
    width = WORLD_RESOLUTION_X, height = WORLD_RESOLUTION_Y
  },
  button = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/button_level_background.png',
    width = 163, height = 61
  },
  font = {
    type = RESOURCE_TYPE_FONT,
    fileName = 'fonts/redfive.ttf',
    glyphs = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.?!",
    fontSize = 26,
    dpi = 160
  },
  col1_active = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/col1_active.png',
    width = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X, height = HUD_WORLD_SCALE *SCREEN_RESOLUTION_X
  },
 
  col2_active = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/col2_active.png',
    width = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X, height = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X
  },
  
  col3_active = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'gui/col3_active.png',
    width = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X, height = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X
  },
  endgame = {
    type = RESOURCE_TYPE_IMAGE,
    fileName = 'collectibles/endpoint.png',
    width = 63, height = 103
  }
}

function TutorialScreen:build()
    self:initialize()
    return self
end

function TutorialScreen:update()
    while self.playing == true do 
        coroutine.yield()
    end
end

function TutorialScreen:initialize()
   self.playing = true
  self.hudIconSize = HUD_WORLD_SCALE * SCREEN_RESOLUTION_X
  ResourceDefinitions:setDefinitions ( resource_definitions )
  InputManager:initialize()
  self.renderTable = {}
  self.camera = MOAICamera2D.new()
  self.gridMarginsX = (WORLD_RESOLUTION_X / 30)
  self.gridMarginsY = (WORLD_RESOLUTION_Y / 30)
  self.layer = MOAILayer2D.new()
  self.partition = MOAIPartition.new()
  self.layer:setViewport ( viewport )
  self.layer:setCamera ( self.camera )
  self.layer:setPartition(self.partition)

  self:initializeBackground()
  self:createTextLayout()
 self:initializeButtons()


  self.renderTable = {
    self.layer
  }
  MOAIRenderMgr.setRenderTable(self.renderTable)

end

function TutorialScreen:initializeButtons()
    local buttonmainMenu = self:makeButton('back', 9*self.gridMarginsX , self.gridMarginsY * 25)
    local buttonDef = ResourceDefinitions:get('button')
    local textBoxMainMenu = self:makeText(20, 'back', 
        {9*self.gridMarginsX - buttonDef.width/2,
        self.gridMarginsY * 25 - buttonDef.height/2,
        9*self.gridMarginsX + buttonDef.width/2, 
        25 *self.gridMarginsY + buttonDef.height/2}, {0,0,0})

    self.buttonContinue = self:makeButton('continue', 25*self.gridMarginsX, 25 * self.gridMarginsY)
    self.textBoxContinue = self:makeText(20, 'continue', {25*self.gridMarginsX - buttonDef.width/2, 25*gridMarginsY - buttonDef.height/2, 25*self.gridMarginsX + buttonDef.width/2, 25*self.gridMarginsY + buttonDef.height/2}, {0,0,0})


end

function TutorialScreen:createTextLayout()
    self.font = MOAIFont.new()
    self.font = ResourceManager:get("font")
    local leftMargin =self.gridMarginsX* 7
    local topMargin = self.gridMarginsY * 8
    local rightMargin = self.gridMarginsX * 27
    local bottomMargin = self.gridMarginsY * 22

    local tutorialText = "3503 AD. A terrible spacewar has waged between the Human race and the Zalari. The last fallout almost obliterated the human forces. But some ships are not quite dead yet. The crew, clinging on their last breath depends on you. S.C.R.A.P. SpaceCraft Repair Android Personel.\n\n Your task is to repair these ships. Find the three items needed to repair them, and place them into the Machine.\n\n Hurry, they are depending on you!"
    self.textBox = self:makeText(20, tutorialText, {leftMargin, topMargin, rightMargin, bottomMargin}, {0,0,0}, {1,0})
end


function TutorialScreen:initializeBackground()
  local deck = ResourceManager:get('background')
  local prop = MOAIProp2D.new()
  prop:setDeck(deck)
  print("resolution: " .. WORLD_RESOLUTION_X .. " ," .. WORLD_RESOLUTION_Y)
  prop:setLoc(WORLD_RESOLUTION_X / 2, WORLD_RESOLUTION_Y/2)
  print("background: " .. prop:getLoc())
  self.layer:insertProp(prop)
end

function TutorialScreen:getLayers()
    return self.renderTable
end

function TutorialScreen:handleClickOrTouch(x, y, isDown)
end

function TutorialScreen:cleanup()
     self.playing = false
  for k, v in pairs(resource_definitions) do
    print ("k:"..k)
    ResourceDefinitions:remove(k)
    ResourceManager:unload(k)
  end
end

function TutorialScreen:makeButton(name, xpos, ypos)
  local buttonGFX =ResourceManager:get('button')
  local  button = MOAIProp2D.new()
  button.name = name
  button:setDeck (buttonGFX)
  button:setLoc (xpos,ypos)
  self.layer:insertProp (button)
  self.partition:insertProp(button)

  return button
end

function TutorialScreen:makeText(size, text, rectangle, color, alignment)
  local textBox = MOAITextBox.new()
  textBox:setFont(self.font)
  textBox:setTextSize(size)
  textBox:setString(text)
  textBox.name = text
  if alignment then
    textBox:setAlignment(unpack(alignment))
  else
    textBox:setAlignment(1,1)
  end

  textBox:setRect(unpack(rectangle))
  textBox:setColor(unpack(color))
  self.layer:insertProp(textBox)
  self.partition:insertProp(textBox)
  return textBox
end

function TutorialScreen:makeInterfaceElement(resource, name, xloc, yloc, scale)
  local elementGFX = ResourceManager:get(resource)
  local elementProp = MOAIProp2D.new()
  elementProp:setDeck(elementGFX)
  elementProp:setLoc(xloc, yloc)
  elementProp.name = name
  elementProp:setScl(scale)

  return elementProp
end

function TutorialScreen:setMoreInfo()
  text = "This game is played by tilting your phone \n\nYour task is to collect some items and bring them to the repair station to repair the ship. \n\n Each item is located in its own department, coded by color."
  self.textBox:setString(text)
  local buttonDef = ResourceDefinitions:get('button')
  self.buttonContinue = self:makeButton('play', 25*self.gridMarginsX, 25 * self.gridMarginsY)
  self.textBoxContinue = self:makeText(20, 'play', {25*self.gridMarginsX - buttonDef.width/2, 25*gridMarginsY - buttonDef.height/2, 25*self.gridMarginsX + buttonDef.width/2, 25*self.gridMarginsY + buttonDef.height/2}, {0,0,0})
   
  -- build other non clickable interface elements
  local colDefinition = ResourceDefinitions:get('col1_active')
   self.col1 = self:makeInterfaceElement('col1_active', 'col1', 9*self.gridMarginsX, 20*self.gridMarginsY, -1)
  local textBoxCircuitboard = self:makeText(15, 'circuit board', {self.gridMarginsX *9- colDefinition.width/2, 20*self.gridMarginsY - colDefinition.height/2 - 20,self.gridMarginsX *9+ colDefinition.width/2, 20*self.gridMarginsY - colDefinition.height/2 }, {0,0,0}, {0,0})
  self.col2 = self:makeInterfaceElement('col2_active', 'col2', 18*self.gridMarginsX  - self.hudIconSize,  20*self.gridMarginsY, -1)
  local textBoxPowerCell = self:makeText(15, 'power cell', { 18*self.gridMarginsX- colDefinition.width/2 - self.hudIconSize, 20*self.gridMarginsY - colDefinition.height/2 - 20, 18*self.gridMarginsX+ colDefinition.width/2, 20*self.gridMarginsY - colDefinition.height/2 }, {0,0,0}, {0,0})
  self.col3 = self:makeInterfaceElement('col3_active', 'col3', 24*self.gridMarginsX- self.hudIconSize,  20*self.gridMarginsY, -1)
  local textBoxWarpDrive = self:makeText(15, 'warp drive', {24*self.gridMarginsX- colDefinition.width/2 - self.hudIconSize, 20*self.gridMarginsY - colDefinition.height/2 - 20,24*self.gridMarginsX+ colDefinition.width/2, 20*self.gridMarginsY- colDefinition.height/2 }, {0,0,0}, {0,0})
  self.endgame = self:makeInterfaceElement('endgame', 'endgame',28*self.gridMarginsX- self.hudIconSize, 20*self.gridMarginsY, -1)
  local textBoxRepairStation = self:makeText(15, 'repair station', {28*self.gridMarginsX - colDefinition.width/2 - self.hudIconSize,20*self.gridMarginsY - colDefinition.height/2 - 20,28*self.gridMarginsX+ colDefinition.width/2, 20*self.gridMarginsY - colDefinition.height/2 }, {0,0,0}, {0,0})

  layer:insertProp(self.col1)
  partition:insertProp(self.col1)  
  layer:insertProp(self.col2)
  partition:insertProp(self.col2)  
  layer:insertProp(self.col3)
  partition:insertProp(self.col3)
  layer:insertProp(self.endgame)
  partition:insertProp(self.endgame)

end

function TutorialScreen:handleClickOrTouch( x, y, isDown )
    local pickedProp = self.partition:propForPoint(self.layer:wndToWorld(x, y))

    if pickedProp  and isDown == true then
        if pickedProp.name == 'play' then
          AudioManager:play('shoot', false)
          switchScene(GAME_LEVEL, level_files['level1'], 'level1')
        elseif pickedProp.name == 'continue' then
          self:setMoreInfo()
        elseif pickedProp.name == 'back' then
          switchScene(MAIN_MENU)
        end
    end
end     