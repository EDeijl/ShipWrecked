local class = require 'external/middleclass'

Door = class('Door')

function Door:initialize(name,body, fixture, resource, direction,rect, layer)
  self.name = name
  self.direction = direction
  self.size = rect
  self.deck = resource
  self.layer = layer
  self.position = position
  self.physics = {}
  self.physics.body = body
  self.physics.fixture = fixture
  self:initializePhysics()
end

function Door:act()
 
 self:moveDoor()
end

function Door:moveDoor()
  local timer = MOAITimer.new()
  timer:setSpan(2)
  timer:setMode(MOAITimer.NORMAL)
  timer:setListener(MOAITimer.EVENT_TIMER_BEGIN_SPAN, function()
      self.physics.body:setLinearVelocity(100,0)
    end
  )
  timer:setListener(MOAITimer.EVENT_TIMER_END_SPAN, function()
      self.physics.body:setLinearVelocity(0,0)
    end
  )
    timer:start()

end


function Door:initializePhysics()

  self.prop = MOAIProp2D.new ()
  self.prop:setDeck ( self.deck )
  self.prop:setLoc(self.physics.body:getWorldLoc())
  self.prop:setScl(1,-1)

  self.layer:insertProp ( self.prop )
  self.physics.fixture:setCollisionHandler ( onCollide, MOAIBox2DArbiter.BEGIN )
--  self.prop:setParent ( self.physics.body )
end

