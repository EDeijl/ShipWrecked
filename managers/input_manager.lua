module ( "InputManager", package.seeall )

------------------------------------------------
-- initialize ( )
-- Setups the callback for updating pointer
-- position on both mouse and touches
------------------------------------------------
function InputManager:initialize ()


  function onKeyboardEvent ( key, down )
    -- if key == 119 then key = 'up' end
    -- if key == 97 then key = 'left' end
    -- if key == 100 then key = 'right' end
    if key == 105 then key = 'w' end
    if key == 106 then key = 'a' end
    if key == 107 then key = 's' end
    if key == 108 then key = 'd' end
    if key == 109 then key = 'm' end
    if key == 9 then key = 'tab' end 
    --if key == 32 then key = 'space' end
    Game:keyPressed ( key, down )
  end

  function onLevelEvent(x,y,z)
    if round(x) == 0 and round(y) == 1 then
      Game:keyPressed('d', true)
      Game:keyPressed('d', false)
    elseif round(x) == 1 and round(y) == 0 then
      Game:keyPressed('s', true) 
      Game:keyPressed('s', false) 
    elseif round(x) == -1 and round(y) == 0 then
      Game:keyPressed('w', true)
      Game:keyPressed('w', false)
    elseif round(x) == 0 and round(y) == -1 then
      Game:keyPressed('a', true)
      Game:keyPressed('a', false)
    end

  end
  function onClick(isMouseDown)
    local x, y = MOAIInputMgr.device.pointer:getLoc()
    if currentScene._NAME == 'Game' then

      if isMouseDown then
        HUD:handleClickOrTouch(x,y, true)
      else
        HUD:handleClickOrTouch(x,y, false)
      end

    elseif currentScene._NAME == 'MainMenu' then
      if isMouseDown then
        MainMenu:handleClickOrTouch(x,y, true)
      else
        MainMenu:handleClickOrTouch(x,y,false)
      end
    elseif currentScene._NAME == 'MenuLevel' then
      if isMouseDown then
        MenuLevel:handleClickOrTouch(x,y, true)
      else
        MenuLevel:handleClickOrTouch(x,y,false)
      end
    end

  end

  function onTouch(eventType, idx, x, y, tapCount)
    if currentScene._NAME == 'Game' then

      if eventType == MOAITouchSensor.TOUCH_DOWN then
        print "touch down"
        HUD:handleClickOrTouch(x,y, true)
      elseif eventType == MOAITouchSensor.TOUCH_UP then
        print "touch up"
        HUD:handleClickOrTouch(x,y, false)
      end

    elseif currentScene._NAME == 'MainMenu' then
      if eventType == MOAITouchSensor.TOUCH_DOWN then

        MainMenu:handleClickOrTouch(x,y, true)
      elseif eventType == MOAITouchSensor.TOUCH_UP then
        MainMenu:handleClickOrTouch(x,y,false)
      end
    elseif currentScene._NAME == 'MenuLevel' then
      if eventType == MOAITouchSensor.TOUCH_DOWN then

        MenuLevel:handleClickOrTouch(x,y, true)
      elseif eventType == MOAITouchSensor.TOUCH_UP then
        MenuLevel:handleClickOrTouch(x,y,false)
      end
    end
  end

  if MOAIInputMgr.device.keyboard then
    MOAIInputMgr.device.keyboard:setCallback ( onKeyboardEvent )
  else
    MOAIInputMgr.device.level:setCallback(onLevelEvent)

  end
  if MOAIInputMgr.device.pointer then
    MOAIInputMgr.device.mouseLeft:setCallback(onClick)
  else
    MOAIInputMgr.device.touch:setCallback(onTouch)
  end

end

