module ( "Character", package.seeall )

-- This will define all the initialization
-- parameters for the character, including its
-- position and animations.
local character_object = {
  position = { 100, 0 },
  animations = {
    idle = {
      startFrame = 1,
      frameCount = 9,
      time = 0.1,
      mode = MOAITimer.LOOP
    },
    
    run = {
      startFrame = 41,
      frameCount = 16,
      time = 0.03,
      mode = MOAITimer.LOOP
    },
     
    jump = {
      startFrame = 89,
      frameCount = 3,
      time = 0.1,
      mode = MOAITimer.NORMAL
    },
  }
}

------------------------------------------------
-- initialize ( MOAILayer2D: layer )
-- sets everything up in order to use the 
-- character. Loads the animations, and uses
-- the 'layer' parameter to show the character 
-- on that layer
------------------------------------------------
function Character:initialize ( layer, position )
  -- We load the character resource
  character_object.position = position
  self.deck = ResourceManager:get ( 'character' )
  
  -- We now create a prop and assign the
  -- correct deck
  self.prop = MOAIProp2D.new ()
  self.prop:setDeck ( self.deck )
  
  -- We set the location using the 'character_object'
  -- configuration table
  
  self.prop:setLoc (0,0 )
  self.prop:setScl(1,-1)
  -- We insert the prop into the layer
  -- that was passed as parameter
  layer:insertProp ( self.prop )
  
  -- We create a remapper to use
  -- for indexing the deck on our
  -- animations
  self.remapper = MOAIDeckRemapper.new ()
  
  -- Since we'll only remap one value
  -- (the index of the deck) we reserve
  -- just one remapper
  self.remapper:reserve ( 1 )
  
  -- And set the remapper to work
  -- with the character's prop
  self.prop:setRemapper ( self.remapper )
  
  -- We'll store all our animations
  -- in Character.animations
  self.animations = {}
  
  -- We now iterate through all the animations
  -- that were defined on character_object ...
  for name, def in pairs ( character_object.animations ) do
    
    -- ... and add them to the character.
    self:addAnimation ( name, def.startFrame, def.frameCount, def.time, def.mode )
  end
  
  -- To see if it's working, let's start the idle
  -- animation.
  self:startAnimation ( 'idle' )
  
  -- Initialize physics
  self:initializePhysics ()
end


------------------------------------------------
-- addAnimation ( 
--   string: name, 
--   number: startFrame, 
--   number: frameCount, 
--   number: time,
--   number: mode )
-- 
-- Adds an animation to the animations table
-- indexed by 'name'. It will use 'startFrame'
-- as the first frame, and add 'frameCount' 
-- frames after it. The 'time' parameter is how
-- many seconds pass between each frame (it can
-- be a decimal number, for example 0.1) and
-- 'mode' is one of MOAITimer constants.
------------------------------------------------
function Character:addAnimation ( name, startFrame, frameCount, time, mode )
  
  -- We initialize an animation curve that
  -- we'll use to interpolate the values
  -- we need for our animation
  local curve = MOAIAnimCurve.new ()
  
  -- We'll use just two specified points (keys)
  -- in that curve, the start and the end.
  curve:reserveKeys ( 2 )
  
  -- We use set key to define each point.
  -- The first parameter is the key number,
  -- The second one is at which time of the animation
  -- the key is used, then the value for the key,
  -- and the interpolation type.
 
  -- The first one is easy, time 0, since it's the 
  -- begining of the curve, startFrame as the value
  -- and a linear interpolation.
  curve:setKey ( 1, 0, startFrame, MOAIEaseType.LINEAR )
  
  -- For the second one we take into account that we'll be
  -- at the end of the animation. We use the time per frame 
  -- times 'frameCount' for the time, and startFrame plus 
  -- frameCout for the value of the frame. Again, we use
  -- a linear interpolation.
  curve:setKey ( 2, time * frameCount, startFrame + frameCount, MOAIEaseType.LINEAR )
  
  -- Now we create the animation
  local anim = MOAIAnim:new ()
  
  -- We'll use only one connection between curve and remapper
  -- so reserve one link.
  anim:reserveLinks ( 1 )
  
  -- Here we say that when the animation starts
  -- it will retrieve each value needed from the curve
  -- and tell the remapper to use that value
  -- to display the correct image on the prop.
  -- The last parameter passed is the index of the
  -- remapper, and since we reserved just one slot
  -- on the remapper, we pass one.
  anim:setLink ( 1, curve, self.remapper, 1 )
  
  -- Now we set the mode for 
  -- the animation. This has to
  -- be one of MOAITimer constants.
  anim:setMode ( mode )
  
  -- And lastly, we store the animation
  -- on the animations table indexed by 'name'.
  self.animations[name] = anim
  
end

------------------------------------------------
-- getAnimation ( string: name )
-- returns the animation named 'name'.
------------------------------------------------
function Character:getAnimation ( name )
  return self.animations[name]
end


------------------------------------------------
-- stopCurrentAnimation ( )
-- if there is an animation running, it stops
-- it.
------------------------------------------------
function Character:stopCurrentAnimation ()
  
  if self.currentAnimation then
    self.currentAnimation:stop ()
  end
  
end

------------------------------------------------
-- startAnimation ( string: name )
-- stops the current animation and starts the
-- animation called 'name'.
------------------------------------------------
function Character:startAnimation ( name )
  self:stopCurrentAnimation ()
  
  self.currentAnimation = self:getAnimation ( name )
  
  self.currentAnimation:start ()
  
  return self.currentAnimation
  
end

------------------------------------------------
-- initializePhysics ( )
-- Creates all the objects needed to include
-- the main character in the physics simulation.
------------------------------------------------
function Character:initializePhysics ()
  
  self.physics = {}
  
  -- First of all we add a dynamic body
  -- that will represent our character
  self.physics.body = PhysicsManager.world:addBody ( MOAIBox2DBody.DYNAMIC )
  
  -- Now, we position it using our position definition.
  -- In this way we know our physics object will start at
  -- the same position that our rendered object.
  self.physics.body:setTransform ( unpack ( character_object.position ) )
  
  -- Then we need to create the shape for it.
  -- We'll use a rectangle, since we're not being fancy here.
  self.physics.fixture = self.physics.body:addRect( -32, -32, 32, 32  )

  -- Now we need to bind our prop with the physics object.
  self.prop:setParent ( self.physics.body )
  
  -- Lastly we set a method that will handle collisions
  self.physics.fixture:setCollisionHandler ( onCollide, MOAIBox2DArbiter.BEGIN )

end

function Character:run ( direction, keyDown ) 
  
  if keyDown then
    self.prop:setScl ( direction, -1 )
   
    velX, velY = self.physics.body:getLinearVelocity ()
    self.physics.body:setLinearVelocity ( direction * 100, velY )
      
    if ( self.currentAnimation ~= self:getAnimation ( 'run' ) ) and not self.jumping then
      self:startAnimation ( 'run' )
    end
  
  else
  
    if not self.jumping then
      self:stopMoving ()
    end
    
  end

end


function Character:moveLeft ( keyDown )
  self:run ( -1, keyDown )
end

function Character:moveRight ( keyDown )
  self:run ( 1, keyDown )
end


function Character:stopMoving ()
  if not self.jumping then
    self.physics.body:setLinearVelocity ( 0, 0 )
    self:startAnimation ( 'idle' )
  end
  
end

function Character:jump ( keyDown )
  if keyDown and not self.jumping then
    --AudioManager:play ( 'jump' )
    self.physics.body:applyForce ( 0, -8000 )
    self.jumping = true
    self:startAnimation ( 'jump' )
  end
end

function Character:stopJumping ()
  self.jumping = false
  self:stopMoving ()
end

function onCollide (  phase, fixtureA, fixtureB, arbiter )

  if Game:belongsToScene(fixtureB) then
    Character:stopJumping ()
  end
  
end
