local class = require 'external/middleclass'

Button = class('Button')

------------------------------------------------
-- initialize(name, body, fixture, linkedObject, layer, position)
-- constructor of the button
------------------------------------------------
function Button:initialize(name,body, fixture, linkedObject, layer, position)
  self.name = name
  self.physics = {}
  self.physics.body = body
  self.physics.fixture = fixture
  self.linkedObject = linkedObject
  self.layer = layer
  self.position = position
  self.activated = false
  self:initializePhysics()
end

------------------------------------------------
-- initializePhysics()
-- start physics simulation on this object
------------------------------------------------
function Button:initializePhysics()

  self.prop = MOAIProp2D.new ()
  self.prop:setScl(1,-1)

  self.prop:setDeck(ResourceManager:get('button'))
  self.layer:insertProp ( self.prop )
  self.physics.fixture:setSensor(true)
  self.physics.fixture:setCollisionHandler ( Button.onCollide, MOAIBox2DArbiter.BEGIN )
  self.prop:setParent ( self.physics.body )
  self.prop:setLoc(0,-27)


end

------------------------------------------------
-- act()
-- called when a player is pushing the button
------------------------------------------------
function Button:act()
  if self.activated == false then
    self.deck = ResourceManager:get('button_pressed')
    self.prop:setDeck(self.deck)
    self.linkedObject:act()
    self.activated = true
  else
  end

end


------------------------------------------------
-- onCollide(phase, fixtureA, fixtureB, arbiter)
-- acts upon collision with the button and checks
-- what objects collide with it
------------------------------------------------
function Button.onCollide (phase, fixtureA, fixtureB, arbiter)
  if fixtureB.name == "player" or fixtureB.name == "foot" or fixtureB.name == "box" then
    print "HIEROOOO"
    local table = Game:getTable('buttonTable')
    table[fixtureA.name]:act()
  end
end

