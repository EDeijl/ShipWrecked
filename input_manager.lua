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
    if x <= 3 and x >= -3 and y >= 7 then
      Game:keyPressed('d', true)
      Game:keyPressed('d', false)
    elseif x>=7 and y <= 3 and y >= -3 then
      Game:keyPressed('s', true) 
      Game:keyPressed('s', false) 
    elseif x <= -7 and y >= -3 and y <= 3 then
      Game:keyPressed('w', true)
      Game:keyPressed('w', false)
    elseif x <=3 and x >= -3 and y <=-7 then
      Game:keyPressed('a', true)
      Game:keyPressed('a', false)
    end
    
  end


  if MOAIInputMgr.device.keyboard then
    MOAIInputMgr.device.keyboard:setCallback ( onKeyboardEvent )
  end

  if MOAIInputMgr.device.level then
    MOAIInputMgr.device.level:setCallback(onLevelEvent)
  end


end