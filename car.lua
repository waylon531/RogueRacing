car={}
car.__index = car
setmetatable(car, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})
function car.new(positionX,positionY,length,width,topSpeed,acceleration,turnRate,friction,health)
  local self = setmetatable({}, car)
  self.startHealth=health
  self.health=health
  self.length=length
  self.width=width
  self.position={positionX,positionY}
  self.startPosition=self.position[1]
  self.collisionPoints = init
  self.speed=0
  self.angle=0
  self.prevAngle=0
  self.turnRate=turnRate
  self.acceleration=acceleration+friction
  self.topSpeed=topSpeed+.01
  return self
end
function car:collisionDetect(map,mapX,preMap)
	local mapx=mapX
	local collision=false
	for x=-self.width/2,self.width/2,2 do
		for y=-self.length/2,self.length/2,4 do
			local ang=math.deg(math.atan2(y,x))
			local angle=ang+self.angle
			local c=math.sqrt(y*y+x*x)
			local newX=c*math.cos(math.rad(angle))+self.position[1]
			local newY=c*math.sin(math.rad(angle))+self.position[2]
			local tileY=math.ceil((love.graphics.getHeight()+mapX-newY)/32)
			local tileX=math.ceil(newX/32)
			if map:getTile(tileX,tileY)~=1 then
				if collision==false then
					if self.speed>1 then
						self.health=math.ceil(self.health-3^(self.speed-1)+1)
					end
					if self.speed~=0 then
						if y<1 then
							self.position[1]=self.position[1]-math.sin(math.rad(self.angle))
							mapx=mapx-math.cos(math.rad(self.angle))
						else
							self.position[1]=self.position[1]+math.sin(math.rad(self.angle))
							mapx=mapx+math.cos(math.rad(self.angle))
						end
						self.speed=0
					end
					self.angle=self.prevAngle
					collision=true
				end
			end
		end
	end
	return mapx,collision
end
function car:turn(direction,dt)
	local x=2
	local v=1
	if direction=="right" then
		v=-1
	end
	if self.speed<0 then
		x=-2
		v=-v
	end
	self.prevAngle=self.angle
	self.angle=self.angle-v*self.turnRate*dt*2/(self.speed+x)
end
function car:accelerate(acceleration,dt)
	self.speed=self.speed+acceleration*self.acceleration*dt
	if self.speed>self.topSpeed then
		self.speed=self.topSpeed
	end
end
function car:getSpeed()
  if self.speed>7.98 then
    return 8
  else
    return self.speed
  end
end
function car:getAngle()
	return self.angle
end
function car:damage(damage)
	self.health=self.health-damage
end

function car:getX()
	return self.position[1]
end
function car:reset()
	self.health=self.startHealth
	self.position[1]=self.startPosition
	self.speed=0
	self.angle=0
end
function car:getY()
	return self.position[2]
end
function car:draw(image)
	love.graphics.draw(image,self.position[1],self.position[2],self.angle*math.pi/180,1,1,self.width/2,self.length/2)
end
function car:getAlive()
	if self.health>0 then
		return true
	else
		return false
	end
end
function car:getHealth()
	local health=self.health
	if health<0 then
		health=0
	end
	return health
end
function car:update(friction,dt)
	self.position[1]=self.position[1]+math.sin(math.rad(self.angle))*self.speed
	if self.speed < 0 then
		friction=friction*(-1)
	end
	if self.speed==0 then
		friction=0
	end
	if math.abs(self.speed)-friction*dt<(self.acceleration-friction)*dt/2 then
		self.speed=0
		friction=0
	end
	self.speed=self.speed-friction*dt
end
