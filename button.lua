local class = require 'external/middleclass'

Button = class('Button')

function Button:initialize(name, linkedObject, layer, position)
  self.name = name
  self.linkedObject = linkedObject
  self.layer = layer
  self.position = position
  self.activated = false
  self:initializePhysics()
end

function Button:initializePhysics()

  self.prop = MOAIProp2D.new ()
  self.prop:setDeck ( self.deck )
  self.prop:setLoc (0,0 )
  self.prop:setScl(1,-1)

  self.layer:insertProp ( self.prop )

  self.physics = {}
  self.physics.body = PhysicsManager.world:addBody ( MOAIBox2DBody.KINEMATIC )
  local x, y = unpack ( self.position )
  self.physics.body:setTransform ( x,y )

  self.physics.fixture = self.physics.body:addRect(-32,-5,32,5)
  self.physics.fixture.name = self.name
  self.physics.fixture:setCollisionHandler ( Button.onCollide, MOAIBox2DArbiter.BEGIN )

  self.prop:setParent ( self.physics.body )


end

function Button:act()
  self.linkedObject:act()
end



function Button.onCollide (phase, fixtureA, fixtureB, arbiter)
  if fixtureB.name == "player" or fixtureB.name == "foot" or fixtureB.name == "box" then
    print "HIEROOOO"
    local table = Game:getTable('buttonTable')
    table[fixtureA.name]:act()
  end
end

