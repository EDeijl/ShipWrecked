require 'config'
require 'resource_definitions'
require 'resource_manager'
require 'input_manager'
require 'scene_manager'
require 'utils'
------------------------------------------------
-- Resource type constants
------------------------------------------------
RESOURCE_TYPE_IMAGE = 0
RESOURCE_TYPE_TILED_IMAGE = 1
RESOURCE_TYPE_FONT = 2
RESOURCE_TYPE_SOUND = 3

-- level files
level_files = {
  level1 = 'assets/maps/demo_level.lua'
}



-- Open main screen
MOAISim.openWindow ( "Shipwrecked in spesh", SCREEN_RESOLUTION_X, SCREEN_RESOLUTION_Y )

-- Setup viewport
viewport = MOAIViewport.new ()
viewport:setSize ( SCREEN_RESOLUTION_X, SCREEN_RESOLUTION_Y )
viewport:setScale ( WORLD_RESOLUTION_X, -WORLD_RESOLUTION_Y )
viewport:setOffset(-1,1)

require 'audio_manager'
require 'game'
require 'main_menu'


currentScene = MainMenu:build()
SceneManager.pushScene(currentScene)

function mainLoop ()
  SceneManager.update()
end

gameThread = MOAICoroutine.new ()
gameThread:run ( mainLoop )

function switchScene(level)
    SceneManager.popScene(currentScene)
    currentScene = Game:build(level)
    SceneManager.pushScene(currentScene)
end
