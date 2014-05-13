function generate(width,offset,offsetMean,oldLine,timePassed)
	if timePassed==nil then
		timePassed=0
	end
	permaW=width
	permaO=offset
	permaM=offsetMean
	local edge = true
	local line = {}
	success=false
	local inc = 0
	while success == false do
		newOffset = love.math.randomNormal( 1, offsetMean )
		if newOffset >0 then 
			newOffset = math.ceil(newOffset)
		else
			newOffset=math.floor(newOffset)
		end
		width = love.math.randomNormal( .5, width )
		while width>5 or width<.5 do
			width = love.math.randomNormal( .5, width )
		end
		while math.abs(newOffset)>10 do
			newOffset = love.math.randomNormal( 1, offsetMean )
			if newOffset >0 then 
				newOffset = math.ceil(newOffset)
			else
				newOffset=math.floor(newOffset)
			end
		end
		local offset=newOffset
		for x=-15,15 do
			if x ~= offset then
				line[x]=math.floor(math.log((math.abs(x-offset))/width))
				if line[x]>1 then 
					line[x]=1
				elseif line[x]<0 then
					line[x]=0
				end
				--Check if tile is at the edge of floor tiles
				if (math.floor(math.log(math.abs((x+1-offset)/width)))==0 or math.log(math.abs((x+1-offset)/width))<0) and edge==true then
					line[x]=2
					if love.math.random(1, 100)<=math.ceil(10/(1+math.exp(-timePassed/100))-5) then
						line[x]=4
					end
					edge=false
				elseif (math.floor(math.log((math.abs(x+1-offset))/width))==1 or math.floor(math.log((math.abs(x+1-offset))/width))>1) and edge==false then
					line[x]=3
					if love.math.random(1, 100)<=math.ceil(10/(1+math.exp(-timePassed/100))-5) then
						line[x]=5
					end
					edge=true
				elseif line[x]<0 then 
					line[x]=0
				end
			else
				line[x]=0
			end
		end
		if line[15] == 0 then
			line[15]=3
			if love.math.random(1, 100)<=math.ceil(10/(1+math.exp(-timePassed/100))-5) then
				line[15]=5
			end
		elseif line[-15]==0 then
			line[-15]=2
			if love.math.random(1, 100)<=math.ceil(10/(1+math.exp(-timePassed/100))-5) then
				line[15]=4
			end
		end
		if oldLine~=nil then
			for i=-15,15 do
				if oldLine[i]==0 and line[i]==0 then 
					success=true
				end
			end
		else
			success=true
		end
		if success==false then
			inc=inc+1
			width=permaW
			offset=permaO
			offsetMean=permaM
		end
		if inc>3 then
			success=true
		end
	end
	return width, newOffset, line
end
function updateMap(map,line)
	local v=0
	for row=1,22 do 
		for x=-15,15 do
			v=map:getTile(x+16,row+1)
			map:setTile(x+16,row,v)
		end
	end
	for x=-15,15 do
		map:setTile(x+16,23,line[x]+1)
	end
	return map
end
