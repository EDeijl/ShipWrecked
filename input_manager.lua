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

  MOAIInputMgr.device.keyboard:setCallback ( onKeyboardEvent )
end