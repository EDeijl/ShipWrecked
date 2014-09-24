require 'config'
require 'resource_definitions'
require 'resource_manager'
require 'input_manager'

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
viewport:setScale ( WORLD_RESOLUTION_X, WORLD_RESOLUTION_Y )

require 'audio_manager'
require 'game'

function mainLoop ()
  Game:start ()
end

gameThread = MOAICoroutine.new ()
gameThread:run ( mainLoop )