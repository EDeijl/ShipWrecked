module ( "PhysicsManager", package.seeall )

------------------------------------------------
-- initialize ( string: layer )
-- Initializes the physics engine using 'layer'
-- for debug output. If layer is nil then no
-- layer is set.
------------------------------------------------
function PhysicsManager:initialize ( layer )
  
  -- Create the Box2D world
  self.world = MOAIBox2DWorld.new ()
  
  -- We set the relationship between 
  -- world units and meters.
  -- We calculated this value using
  -- a proportion from the main
  -- character asset.
  self.world:setUnitsToMeters ( 1/32 )
  
  -- We set the gravity to something
  -- that is not realistic but is useful
  -- for our game
  self.world:setGravity ( 0, -100 )
  
  -- We start the simulation so objects
  -- begin to interact.
  self.world:start ()
  
  -- If a debug layer is passed use
  -- it to display the objects that
  -- our world is using in the 
  -- simulation.
  if layer then
    layer:setBox2DWorld ( self.world )
  end
  
end
