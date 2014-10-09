local class = require 'external/middleclass'

Door = class('Door')

function Door:initialize(name,body, fixture, direction,rect, layer, rotation)
  self.name = name
  self.direction = direction
  self.size = rect
  self.rotation = rotation
  self.deck = ResourceManager:get('door')
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
  local timeSpan = 2
  timer:setSpan(timeSpan)
  timer:setMode(MOAITimer.NORMAL)
  timer:setListener(MOAITimer.EVENT_TIMER_BEGIN_SPAN, function()
      local xPixelDistance, yPixelDistance = unpack(self.direction)
      local vX  =  xPixelDistance / timeSpan
      local vY = yPixelDistance / timeSpan
      print("vX: " .. vX .. ", vY: " .. vY)
      self.physics.body:setLinearVelocity(vX, vY)
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
  local xMin, yMin, xMax, yMax = unpack(self.size)
  local width = math.abs(xMin) + math.abs(xMax)
  local height = math.abs(yMin) + math.abs(yMax)
  local scaleX = 0
  local scaleY = 0
  if width > height then
    scaleX = height / ResourceDefinitions:get('door').width
    scaleY = width / ResourceDefinitions:get('door').height
  else
    scaleX = width / ResourceDefinitions:get('door').width
    scaleY = height / ResourceDefinitions:get('door').height
  end
  
  print ("width: ".. width .. ", height: " .. height)
  print ("textureWidth: " .. ResourceDefinitions:get('door').width .. ", textureHeight: " .. ResourceDefinitions:get('door').height)
  print("scaleX: " .. scaleX .. ", scaleY: " .. scaleY)
  self.prop:setScl(scaleX *1,scaleY*-1)
  self.prop:setRot(self.rotation)
  self.prop:setDeck(self.deck)
  self.layer:insertProp ( self.prop )
  self.prop:setParent ( self.physics.body )
end

