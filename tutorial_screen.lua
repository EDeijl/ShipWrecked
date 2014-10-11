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

    local buttonContinue = self:makeButton('continue', 25*self.gridMarginsX, 25 * self.gridMarginsY)
    local textBoxContinue = self:makeText(20, 'continue', {25*self.gridMarginsX - buttonDef.width/2, 25*gridMarginsY - buttonDef.height/2, 25*self.gridMarginsX + buttonDef.width/2, 25*self.gridMarginsY + buttonDef.height/2}, {0,0,0})


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

function TutorialScreen:handleClickOrTouch( x, y, isDown )
    local pickedProp = self.partition:propForPoint(self.layer:wndToWorld(x, y))

    if pickedProp then
        if pickedProp.name == 'continue' then
            AudioManager:play('shoot', false)
            switchScene(GAME_LEVEL, level_files['level1'], 'level1')
        elseif pickedProp.name == 'back' then
            switchScene(MAIN_MENU)
        end
    end
end     