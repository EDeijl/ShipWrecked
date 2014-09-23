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
    Game:keyPressed ( key, down )
  end

  MOAIInputMgr.device.keyboard:setCallback ( onKeyboardEvent )
end