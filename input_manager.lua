module ( "InputManager", package.seeall )

------------------------------------------------
-- initialize ( )
-- Setups the callback for updating pointer
-- position on both mouse and touches
------------------------------------------------
function InputManager:initialize ()

  function onKeyboardEvent ( key, down )
    if key == 119 then key = 'up' end
    if key == 97 then key = 'left' end
    if key == 100 then key = 'right' end
    if key == 105 then key = 'w' end
    if key == 106 then key = 'a' end
    if key == 107 then key = 's' end
    if key == 108 then key = 'd' end
    Game:keyPressed ( key, down )
  end

  function onLevelEvent(x,y,z)
    print ("Motion: x=".. x .. ", y=".. y .. ", z=".. z)
    if round(x) == 0 and round(y) == 1 then
      print "right"
      Game:keyPressed('d', true)
      Game:keyPressed('d', false)
    elseif round(x) == 1 and round(y) == 0 then
      print "down"
      Game:keyPressed('s', true) 
      Game:keyPressed('s', false) 
    elseif round(x) == -1 and round(y) == 0 then
      print "up"
      Game:keyPressed('w', true)
      Game:keyPressed('w', false)
    elseif round(x) == 0 and round(y) == -1 then
      print "left"
      Game:keyPressed('a', true)
      Game:keyPressed('a', false)
    end

  end


  if MOAIInputMgr.device.keyboard then
    MOAIInputMgr.device.keyboard:setCallback ( onKeyboardEvent )
  else
    MOAIInputMgr.device.level:setCallback(onLevelEvent)

  end
  if MOAIInputMgr.device.pointer then
    MOAIInputMgr.device.mouseLeft:setCallback(
      function(isMouseDown)
        local x, y = MOAIInputMgr.device.pointer:getLoc()
        if isMouseDown then
          HUD:handleClickOrTouch(x,y, true)
        else
          HUD:handleClickOrTouch(x,y, false)
        end

      end
    )
  else
    MOAIInputMgr.device.touch:setCallback(
      function(eventType, idx, x, y, tapCount)
        if eventType == MOAITouchSensor.TOUCH_DOWN then
          HUD:handleClickOrTouch(x, y, true)
        elseif eventType == MOAITouchSensor.TOUCH_UP then
          HUD:handleClickOrTouch(x, y, false)
        end
      end
    )
  end


end