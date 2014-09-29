module ( "Bullet", package.seeall )

require "physics_manager"

function Bullet:initialize (layer, position)
  
  -- We load the character resource
  --this.position = position
  --self.deck = ResourceManager:get ( 'character' )

  -- We now create a prop and assign the
  -- correct deck
  self.prop = MOAIProp2D.new ()
  --self.prop:setDeck ( self.deck )

  -- We set the location using the 'character_object'
  -- configuration table

  self.prop:setLoc (0,0 )
  self.prop:setScl(1,-1)
  -- We insert the prop into the layer
  -- that was passed as parameter
  layer:insertProp ( self.prop )
  
  self.physics = {}

  -- First of all we add a dynamic body
  -- that will represent our character
  self.physics.body = PhysicsManager.world:addBody ( MOAIBox2DBody.KINEMATIC )
  
  local x, y = unpack(position)
  self.physics.body:setTransform ( x,y-120 )
  self.physics.body:setBullet(true)
  -- Then we need to create the shape for it.
  -- We'll use a rectangle, since we're not being fancy here.
  self.physics.fixture = self.physics.body:addCircle(10,10,5)
  self.physics.fixture.name = "bullet"
  self.prop:setParent ( self.physics.body )
  self.prop:moveLoc(200,40,0,1.5)
  self.physics.body:applyForce(4000,0)
  -- Lastly we set a method that will handle collisions
  self.physics.fixture:setCollisionHandler ( onCollide, MOAIBox2DArbiter.BEGIN )
  print ("x: "..x.." y:"..y)
  print ('pew')
 end
 
function onCollide (  phase, fixtureA, fixtureB, arbiter )
 print('collide')
 fixtureA:destroy()
end