local quad  = love.graphics.newQuad
local drawq = love.graphics.drawq
local ceil  = math.ceil
local path  = (...):match('^.+[%.\\/]') or ''
local grid  = require (path..'grid')

-- ##########################
-- 0.9.0 COMPATIBILITY

if not drawq  then
	drawq = love.graphics.draw
end

-- ##########################

local indexToCoord = function(atlas,index)
	if type(index) == 'table' then 
		return index[1],index[2]
	end
	local c  = atlas.columns
	local gy = ceil(index/c)
	local gx = index-(gy-1)*c
	return gx,gy
end

local getq = function(self,index)
	local cell = grid.get(self,indexToCoord(self,index))
	if cell then return cell.quad
	else
		local gx,gy = indexToCoord(self,index)
		index       = (gy - 1) * self:getColumns() + gx
		error('Atlas index is out of range: '..string.format('%s (%s,%s)',index,gx,gy))
	end
end

-------------------
-- MODULE
-------------------

local atlas  = setmetatable({},{__call = function(self,...) return self.new(...) end})
atlas.__index= atlas

atlas.__call = function(self,index)
	return atlas.getqViewport(self,index)
end

function atlas.new(imageWidth,imageHeight,  quadWidth,quadHeight,  atlasWidth,atlasHeight,  ox,oy,  xspacing,yspacing)
	local iw,ih,qw,qh,aw,ah,xs,ys = imageWidth,imageHeight,quadWidth,quadHeight,atlasWidth,atlasHeight,xspacing,yspacing
	
	local self  = grid.new()
	qh          = qh or qw
	ox,oy       = ox or 0,oy or 0
	xs,ys       = xs or 0,ys or 0
	aw          = aw or iw
	ah          = ah or ih
	local tw,th = qw+xs,qh+ys
	local dx,dy = (aw+xs)/tw,(ah+ys)/th
	assert(dx % 1 == 0 and dy % 1 == 0,'Dimensions of atlas must be multiples of dimensions of quads + spacings!')
	self.rows      = dy
	self.columns   = dx
	self.qWidth    = qw
	self.qHeight   = qh
	self.aWidth    = aw
	self.aHeight   = ah
	self.ox,self.oy= ox,oy
	self.xs,self.ys= xs,ys
	self.iWidth    = imageWidth
	self.iHeight   = imageHeight
	self.atlasname = nil
	
	self.tileoffset= {}
	self.properties= {}
	
	for gx = 1,dx do 
		for gy = 1,dy do
			local tile = {
				quad     = quad((gx-1)*tw+ox,(gy-1)*th+oy,qw,qh,iw,ih),
				property = nil,
			}
			grid.set(self,gx,gy,tile)
		end
	end
	return setmetatable(self,atlas)
end

function atlas:getRows()
	return self.rows
end

function atlas:getColumns()
	return self.columns
end

function atlas:getImageSize()
	return self.iWidth,self.iHeight
end

function atlas:getViewport()
	return self.ox,self.oy,self.aWidth,self.aHeight
end

function atlas:getSpacings()
	return self.xs,self.ys
end

function atlas:getqSize()
	return self.qWidth,self.qHeight
end

function atlas:getqViewport(index)
	local quad = getq(self,index)
	local x,y  = quad:getViewport()
	return x,y,atlas.getqSize(self)
end

function atlas:setqProperty(index,value)
	grid.get(self,indexToCoord(self,index)).property = value
end

function atlas:getqProperty(index)
	return grid.get(self,indexToCoord(self,index)).property
end

function atlas:setName(atlasname)
	self.atlasname = atlasname
end

function atlas:getName()
	return self.atlasname
end

function atlas:draw(image,index,...)
	drawq(image,getq(self,index),...)
end

-- ####################################
-- TMX RELATED FUNCTIONS
-- ####################################

function atlas:getTileOffsets()
	local to = self.tileoffset
	return to.x,to.y
end

function atlas:setTileOffsets(x,y)
	local to = self.tileoffset
	to.x,to.y= x or 0,y or 0
end

function atlas:getLayerProperties()
	return self.properties
end

return atlas