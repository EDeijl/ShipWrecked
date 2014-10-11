require 'config'
require 'resource_definitions'
require 'managers/resource_manager'
require 'managers/input_manager'
require 'managers/scene_manager'
require 'managers/savefile-manager'
require 'managers/utils'
------------------------------------------------
-- Resource type constants
------------------------------------------------
RESOURCE_TYPE_IMAGE = 0
RESOURCE_TYPE_TILED_IMAGE = 1
RESOURCE_TYPE_FONT = 25
RESOURCE_TYPE_SOUND = 3

MAIN_MENU = 0
MENU_LEVEL = 1
GAME_LEVEL = 2
TUTORIAL_LEVEL = 3


local gameOver = false
-- level files
level_files = {
  level1 = 'assets/maps/demo_level.lua'
}
function numberOfLevels()
  local nLevels = 0
  for k, v in pairs(level_files) do
    print(v)
    nLevels = nLevels + 1
  end
  return nLevels
end

-- Open main screen
MOAISim.openWindow ( "Shipwrecked in spesh", SCREEN_RESOLUTION_X, SCREEN_RESOLUTION_Y )

-- Setup viewport
viewport = MOAIViewport.new ()
viewport:setSize ( SCREEN_RESOLUTION_X, SCREEN_RESOLUTION_Y )
viewport:setScale ( WORLD_RESOLUTION_X, -WORLD_RESOLUTION_Y )
viewport:setOffset(-1,1)

require 'managers/audio_manager'
require 'game'
require 'main_menu'
require 'main_level'
require 'tutorial_screen'

savefiles.get ( "save" )

currentScene = MainMenu:build()
SceneManager.pushScene(currentScene)


function mainLoop ()
  while not gameOver do
    SceneManager.update()
    coroutine.yield()
  end
end



-------------------------------------
-- switchScene(sceneType, sceneData)
-- sceneType can have values MAIN_MENU, MENU_LEVEL, GAME_LEVEL
-- sceneData can hold a level file, or specific menu
------------------------------------


function switchScene(sceneType, ...)
  SceneManager.popScene()

  if sceneType == MAIN_MENU then
    currentScene = MainMenu:build()
  elseif sceneType == MENU_LEVEL then
    currentScene = MenuLevel:build()
  elseif sceneType == GAME_LEVEL then
    currentScene = Game:build(...)
    elseif sceneType == TUTORIAL_LEVEL then
      currentScene = TutorialScreen:build()
  end
  SceneManager.pushScene(currentScene)
end



gameThread = MOAICoroutine.new ()
gameThread:run ( mainLoop )