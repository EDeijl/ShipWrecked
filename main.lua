require 'config'
require 'resource_definitions'
require 'resource_manager'
require 'input_manager'
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
hud = HUD:initialize()
MOAIRenderMgr.setRenderTable( level1:getLayers() )
local renderTable = MOAIRenderMgr.getRenderTable ()
table.insert ( renderTable, hud:getLayers() )
MOAIRenderMgr.setRenderTable ( renderTable )

function mainLoop ()
  level1:start ()
end

gameThread = MOAICoroutine.new ()
gameThread:run ( mainLoop )