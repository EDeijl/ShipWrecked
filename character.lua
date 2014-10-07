module ( "Character", package.seeall )

require "physics_manager"
require "hud"
-- This will define all the initialization
-- parameters for the character, including its
-- position and animations.
local character_object = {
  position = { 0, 0 },
  animations = {
    idle = {
      startFrame = 1,
      frameCount = 1,
      time = 0.1,
      mode = MOAITimer.LOOP
    },

    run = {
      startFrame = 289,
      frameCount = 24,
      time = 0.03,
      mode = MOAITimer.LOOP
    },

    jump = {
      startFrame = 193,
      frameCount = 8,
      time = 0.05,
      mode = MOAITimer.NORMAL
    },

    hover = {
      startFrame = 200,
      frameCount = 1,
      time = 0.1,
      mode = MOAITimer.LOOP
    }
  }
}
local lives = 3
local timer = 0
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
  self.move = {
    left = false,
    right = false
  }
  self.onGround = false
  self.platform = nil

  --Fix the problem with wanting to touch the first object twice
  self.currentContactCount = 0
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
  print "in initialize"
  self:startAnimation ( 'idle' )

  -- Initialize physics
  self:initializePhysics ()
  Game:updateHud(lives)
  self.movingdirection = 1
  self.isIdle = true
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
  print ("startanimation: " .. name)
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
  local x, y = unpack ( character_object.position )
  self.physics.body:setTransform ( x+150,y-100)
  self.physics.body:setAwake(true)
  -- Then we need to create the shape for it.
  -- We'll use a rectangle, since we're not being fancy here.
  self.physics.fixture = self.physics.body:addRect( -30, -32, 30, 64  )
  self.physics.fixture.name = "player"
  --Create a foot fixture
  --Used to check if the player is on the ground
  self.physics.footfixture = self.physics.body:addRect( -29.8, 65, 29.8, 63  )
  self.physics.footfixture.name = "foot"
  -- Now we need to bind our prop with the physics object.
  self.prop:setParent ( self.physics.body )
  -- Lastly we set a method that will handle collisions
  self.physics.fixture:setCollisionHandler ( onCollide, MOAIBox2DArbiter.BEGIN )
  self.physics.footfixture:setCollisionHandler ( onFootCollide, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END )
end

function Character:run()
  local dx, dy = self.physics.body:getLinearVelocity()
--  print ("left: ")
--  print(self.move.left)
--  print("right: ")
--  print(self.move.right)
--  print("onground: ")
--  print(self.onGround)
  print("currentContactCount: " .. self.currentContactCount)
  local direction = PhysicsManager:getGravityDirection()
  if self.onGround then
    if self.move.right and not self.move.left then

      self:startAnimation('run')
      if direction == 'up' or direction == 'down' then
        dx = 200
      else
        dy = 200
      end
      self.movingdirection = 1
    elseif self.move.left and not self.move.right then
      self:startAnimation('run')
      if direction == 'up' or direction == 'down' then
        dx = -200
      else
        dy = -200
      end
      self.movingdirection = -1
    else 
      --print "in run function if on ground"
      self:startAnimation('idle')
      if direction == 'up' or direction == 'down' then
        dx = 0
      else
        dy = 0
      end

    end
  else
    self:startAnimation('hover')
  end


  if self.platform then
    dx = dx + self.platform:getLinearVelocity()
  end
  if self.onGround then
    print ("dx: " ..dx)
    print ("dy: " ..dy)
    self.prop:setScl(self.movingdirection, -1)
    if direction == "down" then
      self.physics.body:setLinearVelocity(dx, dy)

    elseif direction == "up" then
      self.physics.body:setLinearVelocity(-dx, dy)

    elseif direction == "left" then
      self.physics.body:setLinearVelocity(dx, dy)

    elseif direction == "right" then
      self.physics.body:setLinearVelocity(dx, -dy)

    else
      print "in run if not on ground"
      self:startAnimation('idle')
    end
  end
end


function Character:moveLeft ( keyDown)
  self.move.left = keyDown
  self:run()
end

function Character:moveRight ( keyDown)
  self.move.right = keyDown
  self:run()
end


function Character:stopMoving ()
  if not self.jumps then
    self.physics.body:setLinearVelocity ( 0, 0 )
    print "in stop moving"
    self:startAnimation ( 'idle' )
  end
end

function Character:jump ( keyDown )
  local jumpforce = 140
  if keyDown and self.onGround then
    local direction = PhysicsManager:getGravityDirection()
    print("direction: " .. direction)
    local x,y = self.physics.body:getLinearVelocity()
    if direction == "down" then 
      self.physics.body:setLinearVelocity(x, 0)
      self.physics.body:applyLinearImpulse(0,-jumpforce)
    elseif direction == "up" then
      self.physics.body:setLinearVelocity(x, 0)
      self.physics.body:applyLinearImpulse(0, jumpforce)
    elseif direction == "left" then
      self.physics.body:setLinearVelocity(0, y)
      self.physics.body:applyLinearImpulse(jumpforce,0)
    elseif direction == "right" then
      self.physics.body:setLinearVelocity(0, y)
      self.physics.body:applyLinearImpulse(-jumpforce,0)
    end
    self:startAnimation ( 'jump' )
  end
end


function Character:changeGrav ( key, keyDown )
  local x, y = self.physics.body:getPosition()
  self.physics.body:setAwake(true)
  if key == 'a' then 
    PhysicsManager:changeGravity("left")     
    self.physics.body:setTransform (x, y, 90 )
  elseif key == 'w' then
    PhysicsManager:changeGravity("up")   
    self.physics.body:setTransform (x, y, 180 )
  elseif key == 'd' then
    PhysicsManager:changeGravity("right")  
    self.physics.body:setTransform (x, y, 270 )
  elseif key == 's' then
    PhysicsManager:changeGravity("down")
    self.physics.body:setTransform (x, y, 0 )

  end
  self.prop:setScl(self.movingdirection,-1)
  if self.onGround == false then
    self:startAnimation ( 'hover' )
  end
end

--function Character:shoot()
--    Bullet:initialize(Game.layers.main, character_object.position)
--end

function Character:damage()
  print "got damage"
  if timer == 0 then
    print "life - 1"
    lives = lives - 1
    Game:updateHud(lives)
    self:setKickBack()
    Character:startDamageTimer()
  end
  if lives == 0 then
    Character:die()
  end
end

function Character:setKickBack()
  local dx, dy = self.physics.body:getLinearVelocity()
  self.physics.body:setLinearVelocity(.2*-dx, .2*-dy)
end


function Character:startDamageTimer()
  print "started timer"
  timer = 50
  damageTimer = MOAITimer.new()
  damageTimer:setMode( MOAITimer.LOOP)
  damageTimer:setSpan(0.1)
  local visible = false
  damageTimer:setListener( MOAITimer.EVENT_TIMER_LOOP, function()
      timer = timer - 1
      self.prop:setVisible(visible)
      visible = not visible
      
      if (timer == 0) then
        damageTimer:stop()

      end
    end
  )
  damageTimer:start()

end


function Character:die()
  print("player died")
  switchScene(MAIN_MENU)
end


function onCollide (  phase, fixtureA, fixtureB, arbiter )
  if fixtureA.name == "player" and string.find(fixtureB.name, "spikes_") and phase == MOAIBox2DArbiter.BEGIN then
    Character:damage()
  end

end

function Character:getLives()
  print("lives: " .. lives)
  return lives
end


function onFootCollide (  phase, fixtureA, fixtureB, arbiter )
  if phase == MOAIBox2DArbiter.BEGIN then
    print ("fixB start: "..fixtureB.name)
    Character.currentContactCount = Character.currentContactCount + 1
    print("currentContactCount: " .. Character.currentContactCount)
    if fixtureB.name == 'platform' then
      Character.platform = fixtureB:getBody()
    end
  end
  if phase == MOAIBox2DArbiter.END then
    print ("fixB end: "..fixtureB.name)
    Character.currentContactCount = Character.currentContactCount - 1
    print("currentContactCount: " .. Character.currentContactCount)
    if fixtureB.name == 'platform' then
      Character.platform = nil
    end
  end
  if string.find(fixtureB.name, "spikes_") and phase == MOAIBox2DArbiter.BEGIN then
    Character:damage()
  end

  if Character.currentContactCount == 0 then
    Character.onGround = false
  else
    Character.onGround = true
    Character:run()
  end

end
