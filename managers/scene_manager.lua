module("SceneManager", package.seeall)

local scenes = {}

------------------------------------------------
-- setScene(scene)
-- set's the given scene to be the scene to render
------------------------------------------------
local function setScene(scene)
  local layers = {}
  if scene then
    layers = scene:getLayers()
    if layers then 
      if scene.isOverlay then
        currentLayers = MOAIRenderMgr.getRenderTable()
        table.insert(currentLayers, layers)

        MOAIRenderMgr.setRenderTable(layers)
      else
        MOAIRenderMgr.setRenderTable(layers)
      end

    else
      MOAIRenderMgr.setRenderTable({})
    end
  end

end

------------------------------------------------
-- pushScene(scene)
-- pushes the given scene on top of the scene stack
------------------------------------------------
function SceneManager.pushScene(scene)
  if not scene.isOverlay then
    table.insert(scenes, scene)
--    scenes[#scenes]:initialize()
    setScene(scenes[#scenes])
  else
--    scene:initialize()
    setScene(scene)
  end

end

------------------------------------------------
-- popScene()
-- pops the top scene from the stack
------------------------------------------------
function SceneManager.popScene()
  scenes[#scenes]:cleanup()
  table.remove(scenes, #scenes)
  if #scenes > 0 then
    setScene(scenes[#scenes])
  else
    setScene(nil)
  end
end

------------------------------------------------
-- update()
-- call the update function on the top scene
------------------------------------------------
function SceneManager.update()
  if #scenes > 0 then
    scenes[#scenes]:update()
  end
end