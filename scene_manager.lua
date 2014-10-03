module("SceneManager", package.seeall)

local scenes = {}

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


function SceneManager.pushScene(scene)
  if not scene.isOverlay then
    table.insert(scenes, scene)
    scenes[#scenes]:initialize()
    setScene(scenes[#scenes])
  else
    scene:initialize()
    setScene(scene)
  end

end

function SceneManager.popScene()
  scenes[#scenes]:cleanup()
  table.remove(scenes, #scenes)
  if #scenes > 0 then
    setScene(scenes[#scenes])
  else
    setScene(nil)
  end
end

function SceneManager.update()
  if #scenes > 0 then
    scenes[#scenes]:update()
  end
end