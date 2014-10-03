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

-- Open main screen
MOAISim.openWindow ( "Shipwrecked in spesh", SCREEN_RESOLUTION_X, SCREEN_RESOLUTION_Y )

-- Setup viewport
viewport = MOAIViewport.new ()
viewport:setSize ( SCREEN_RESOLUTION_X, SCREEN_RESOLUTION_Y )
viewport:setScale ( WORLD_RESOLUTION_X, -WORLD_RESOLUTION_Y )
viewport:setOffset(-1,1)

require 'audio_manager'
require 'game'

level1 = Game:build('assets/maps/demo_level.lua')

SceneManager.pushScene(level1)

function mainLoop ()
  SceneManager.update()
end

gameThread = MOAICoroutine.new ()
gameThread:run ( mainLoop )

function switchScene(key, down)
  if down then
    SceneManager.popScene(level1)
    level2 = Game:build('assets/maps/demo_chains.lua')
    SceneManager.pushScene(level2)
  end
end
