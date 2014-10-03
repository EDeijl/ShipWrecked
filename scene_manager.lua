module("SceneManager", package.seeall)

local curState = nil
local loadedStates = {}
local stateStack = {}

local updateThread = MOAIThread.new()

local function updateFunction()
  while true do
    coroutine.yield()
    if curState then
      if type(curState.onInput) == "function" then
        curState:onInput()
      end

      if type(curState.onUpdate) == "function" then
        curState:onUpdate()
      end

    else
      print( "WARNING = There is no current state. please call state.push/state/swap to add a state.")
    end
  end
end

local function addStateLayers(state, stackLoc)
  if not state.layerTable then print ("WARNING -state: ".. state.stateFilename .. " does not have a layerTable" ) end

  -- This grabs the layer set from the state that corresponds to the position in the stack that the state currently is.
  -- If the state is the top most state, it wil grab layerSet[1] and so forth.
  local stackPos = (#stateStack - stateLoc) + 1
  if state.layerTable [stackPos] then
    for j, layer in ipairs(state.layerTable[stackPos]) do
      MOAIRenderMgr.pushRenderPass(layer)
    end

  end
end

local function rebuildRenderStack()
  MOAIRenderMgr.clearRenderStack()
  MOAISim.forceGC()
  for i, state in ipairs (stateStack) do
    addStateLayers(state, i)
  end
end

local function loadState(stateFile)
  if not loadedStates[stateFile] then
    local newState = dofile (stateFile)
    loadedStates[stateFile] = newState
    loadedStates[stateFile].stateFilename = stateFile
  end

  return loadedStates[stateFile]
end

function begin()
  updateThread:run(updateFunction)
end

function getCurState()
  return curState
end

function makePopup(state)
  state.isPopup = true
end

function pop()
  -- do the state's onLoseFocus
  if type(curstate.onLoseFocus) == "function" then
    curState:onLoseFocus()
  end

  -- do the state's onUnload
  if type(curState.onUnload) == "function" then
    curState:onUnload()
  end

  curState = nil
  table.remove(stateStack, #stateStack)
  curState = stateStack[#stateStack]

  rebuildRenderStack()
  MOAISim.forceGC()

  if type(curState.onFocus) == "function" then
    curState:onFocus()
  end

end

function push(stateFile, ...)
  if curState then
    if type ( curState.onLoseFocus ) == "function" then
      curState:onLoseFocus ( )
    end
  end

  -- update the current state to the new one
  local newState = loadState ( stateFile )
  table.insert ( stateStack, newState )	
  curState = stateStack [ #stateStack ]

  -- do the state's onLoad
  if type ( curState.onLoad ) == "function" then		
    curState:onLoad ( ... )
  end

  -- do the state's onFocus
  if type ( curState.onFocus ) == "function" then	
    curState:onFocus ()
  end

  if curState.isPopup then

    addStateLayers ( curState, #stateStack )
  else

    rebuildRenderStack ()
  end
end
function stop ( )

  updateThread:stop ()
end

function swap ( stateFile, ... )

  pop ()
  push ( stateFile, ... )
end


