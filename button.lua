local class = require 'external/middleclass'

Button = class('Button')

function Button:initialize(name, linkedObject, layer, position)
  self.name = name
  self.linkedObject = linkedObject
  self.layer = layer
  self.position = position
  self.activated = false
end

function onCollide (phase, fixtureA, fixtureB, arbiter)
  if fixtureB.name == "player" or fixtureB.name == "foot" or fixtureB.name == "box" then
    self.activated = not self.activated
    self.linkedObject:act(self.activated)
  end
end

  