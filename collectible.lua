local class = require 'external/middleclass'

Collectible = class('Collectible')

local collectibles = {
  animations = {
    col_1 = {
      startFrame = 1,
      endFrame = 21,
      time = 0.05,
      mode = MOAITimer.LOOP
    },
    col_2 = {
      startFrame = 25,
      endFrame = 46,
      time = 0.05,
      mode = MOAITimer.LOOP
    },
    col_3 = {
      startFrame = 49,
      endFrame = 70,
      time = 0.05,
      mode = MOAITimer.LOOP
    }
  }
}



------------------------------------------------
-- initialize(name, layer, position)
-- constructor function of Collectible
------------------------------------------------
function Collectible:initialize(name, layer, position)

  self.name = name
  self.start = animStart
  if(name == "collectible_1") then
    self.anim = {
      start = collectibles.animations.col_1.startFrame,
      stop = collectibles.animations.col_1.endFrame
    }
  elseif(name == "collectible_2") then
    self.anim = {
      start = collectibles.animations.col_2.startFrame,
      stop = collectibles.animations.col_2.endFrame
    }
  elseif(name == "collectible_3") then
    self.anim = {
      start = collectibles.animations.col_3.startFrame,
      stop = collectibles.animations.col_3.endFrame
    }
  end
  self.deck = ResourceManager:get ( 'collectibles' )
  self.layer = layer
  self.position = position
  self.animations = {}
  self:initializePhysics ()
  
  self.collected = false
end

------------------------------------------------
-- initializePhysics()
-- start physics simulating the collectible
------------------------------------------------
function Collectible:initializePhysics()

  self.prop = MOAIProp2D.new ()
  self.prop:setDeck ( self.deck )
  self.prop:setLoc (0,0 )
  self.prop:setScl(2,-2)

  self.layer:insertProp ( self.prop )

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



  self.physics = {}
  self.physics.body = PhysicsManager.world:addBody ( MOAIBox2DBody.KINEMATIC )
  local x, y = unpack ( self.position )
  self.physics.body:setTransform ( x,y )

  self.physics.fixture = self.physics.body:addRect( -16,-16,16,16  )
  self.physics.fixture.name = self.name
  self.physics.fixture:setCollisionHandler ( Collectible.onCollide, MOAIBox2DArbiter.BEGIN )

  self.prop:setParent ( self.physics.body )

  self.frameCount = self.anim.stop - self.anim.start + 1
  print ("fcount: "..self.frameCount)
  self:addAnimation ( self.name, self.anim.start, self.frameCount, 0.05, MOAITimer.LOOP )

end


------------------------------------------------
-- addAnimation(name, startFrame, frameCount, time, mode)
-- start an animation on COllectible
------------------------------------------------
function Collectible:addAnimation ( name, startFrame, frameCount, time, mode )

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
  self.animations[name]:start()

end

------------------------------------------------
-- onCollide(phase, fixtureA, fixtureB, arbiter)
-- check collision on the COllectible and act on it
------------------------------------------------
function Collectible.onCollide (  phase, fixtureA, fixtureB, arbiter )
  --print(fixtureA.name)
  if fixtureB.name == "player" or fixtureB.name == "foot" then
    --print "collide"
    local table = Game:getTable('collectiblesTable')
    table[fixtureA.name]:collect()
  end
end

------------------------------------------------
-- called when a Collectible is collected
------------------------------------------------
function Collectible:collect()
  --print (self.name.." collected")
  self.physics.body:destroy()
  self.layer:removeProp(self.prop)
  self.collected = true
  Game:updateCollectibleHud(self)
end
