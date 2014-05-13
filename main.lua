map=require "libs/LOVEly-tiles-master/map"
--mapdata=require "libs/LOVEly-tiles-master/mapdata"
grid=require "libs/LOVEly-tiles-master/grid"
atlas=require "libs/LOVEly-tiles-master/atlas"
--drawlist=require "libs/LOVEly-tiles-master/drawlist"
generator=require "generator"
core=require "core"
carClass=require "car"
function love.load()
  red=255
  windowWidth=love.graphics.getWidth()/2
  text=""
  insert=0
  textEnterable=true
  highscore=false
	hit=10
	craters={}
	shooter={}
	shootTime={}
	font = love.graphics.newFont( 20 )
	menuFont = love.graphics.newFont( 12 )
	level="menu"
	tempVar=0
	love.window.setTitle("Rogue Racing")
	player=car(love.graphics.getWidth()/2,love.graphics.getHeight()-100,32,16,8,1,240,.5,100)
	splosion=love.graphics.newImage('splosion.png')
	turret=love.graphics.newImage('turret3.png')
  turrets={}
  for i=0,10 do
    turrets[i+1]=love.graphics.newImage("turret3"..tostring(i)..".png")
  end
	crater=love.graphics.newImage('crater.png')
	resetTimer=0
	totalTimer=0
	mapX=0
	preMap=0
	love.graphics.setBackgroundColor( 127, 106, 0 )
	car=love.graphics.newImage('car.png')
	local sheet = love.graphics.newImage('atlas.png')
	local sheetatlas = atlas.new(64,64,32,32)
	valleyMap=map(sheet,sheetatlas)
	valleyMap:setViewRange(1,1,31,22)
	offset=0
	width=5
end
function love.draw()
	if level=="game" then
		--love.graphics.setBackgroundColor( 127, 106, 0 )
		if hit<10 then
			hit=hit+1
			love.graphics.setColor(255,0,0)
			--love.graphics.setBackgroundColor(255,0,0)
		end
		valleyMap:draw(0,love.graphics.getHeight()+math.floor(mapX),0,1,-1)
		local image = car
		if player:getAlive()==false then
			image=splosion
		end
		love.graphics.setColor(0,0,0)
		love.graphics.setFont(font)
		love.graphics.print("Speed: "..math.floor(player:getSpeed()*15),1000,love.graphics.getHeight()/2-50)
		love.graphics.print("Health: "..player:getHealth(),1000,love.graphics.getHeight()/2)
		love.graphics.print("Score: "..score,1000,love.graphics.getHeight()/2+50)
		love.graphics.setColor(255,255,255)
		for i=1,table.getn(shooter)/2 do
			love.graphics.draw(turrets[turretTime(i)],32*(shooter[2*i-1]+15)+16,love.graphics.getHeight()-32*shooter[2*i]+mapX+16,math.atan2(-shooter[2*i]*32+100,32*(shooter[2*i-1]+15)-player:getX())+math.pi,1,1,16,16)
		end
		for i=1,table.getn(craters)/2 do
			love.graphics.draw(crater,craters[2*i-1],craters[2*i]+mapX)
		end
		player:draw(image)
	elseif level=="menu" then
		love.graphics.setFont(font)
		if score~=nil then
			love.graphics.print(score,love.graphics.getWidth()/2-font:getWidth(score)/2-20,love.graphics.getHeight()/2-100)
		end
		love.graphics.print("Press space to start!",love.graphics.getWidth()/2-font:getWidth("Press space to start!")/2-20,love.graphics.getHeight()/2)
  elseif level == "end" then
    love.graphics.print("GAME OVER",windowWidth-60,200)
		love.graphics.print(score,windowWidth-20,170)
    for i, v in ipairs(csv) do 
      if (i % 2 == 0) then
        x=windowWidth+30
        if v==4 then
          if red == 255 then
            love.graphics.setColor( 255, 0, 0)
          else
            love.graphics.setColor( 255, 255, 255)
          end
          v=text
          if text=='' then
            love.graphics.setColor( 255, 0, 0)
            v="Enter name:"
          end
        end
      else
        x=love.graphics.getWidth()/2-30-tostring(v):len()*13
      end
      love.graphics.print(v,x,math.ceil(i/2)*20+250)
      love.graphics.setColor( 255, 255, 255)
		end
	end
end
function turretTime(n)
  local x = totalTimer-shootTime[n] or 0
  if x < 1 then
    return math.floor(x*9+2)
  else
    return 1
  end
end
function love.keypressed(key)
  if key == " " and level =="end" then
    if level =="end" and highscore==true then
      csv[insert]=text
      love.filesystem.write("highscores.csv",core.toCSV(csv))
      highscore=false
    end
  end
	local successful=true
  if level=="end" then
		if key =="backspace" then
			text=string.sub(text, 1, string.len(text)-1)
		end
	end
	if key == 'return' then
    --print(textEnterable)
		if textEnterable == false then
			textEnterable=true
			red=255
		else
			textEnterable=false
			red=0
		end
	end
	if key==" " and (level=="menu" or level=="end") then
		mapX=0
		local inc=0
		offset=0
		width=5
    score=0
		while successful==true and inc<=15 do
			offset=0
			width=5
			inc=inc+1
			for row=1,23 do 
				width,offset,newLine=generate(width,offset,offset,newLine,0)
				for x=-15,15 do
					if newLine[x]==4 or newLine[x]==5 then
						table.insert(shooter, x)
						table.insert(shooter, row)
						table.insert(shootTime,0)
						newLine[x]=newLine[x]-2
					end
					valleyMap:setTile(x+16,row,newLine[x]+1)
				end
			end
			tempVar,successful=player:collisionDetect(valleyMap,mapX,preMap)
			--if inc>10 then successful=false end
		end
		inc=0
		craters={}
		shooter={}
		shootTime={}
		level="game"
		totalTimer=0
		player:reset()
	end
	if key=="return" then
		player:damage(100)
	end
end
function love.update(dt)
  if level ~= "end" and level~="menu" then
    if dt>.5 then dt=.1 end
    if player:getAlive()==true then
      resetTimer=resetTimer+dt
      if resetTimer<5 then
        totalTimer=totalTimer+dt
      end
      if love.keyboard.isDown("up") then
        resetTimer=0
        player:accelerate(1,dt)
      elseif love.keyboard.isDown("down") then
        resetTimer=0
        if player:getSpeed()>0 then
          player:accelerate(-5,dt)
        else
          player:accelerate(-.5,dt)
        end
      end
      if love.keyboard.isDown("left") then
        resetTimer=0
        player:turn("left",dt)
      elseif love.keyboard.isDown("right") then
        player:turn("right",dt)
        resetTimer=0
      end
      preMap=mapX
      mapX=mapX+math.cos(math.rad(-player:getAngle()))*player:getSpeed()*dt*60
      if mapX>31 then 
        mapX=mapX-32 
        for i=1,table.getn(craters)/2 do
          craters[2*i]=craters[2*i]+32
        end
        for i,v in ipairs(shooter) do
          if i%2==0 then
            shooter[i]=shooter[i]-1
            if shooter[i]<1 then
              table.remove(shooter,i)
              table.remove(shooter,i-1)
              table.remove(shootTime,i/2)
              if shooter[i]~=nil then
                shooter[i]=shooter[i]-1
              end
            end
          end
        end
        width,offset,newLine=generate(width, offset,math.sin(totalTimer*math.pi/14)+offset,newLine,totalTimer)
        --score=score+math.ceil(100/math.ceil(width))
        score=score+10
        --print(width)
        for i=-15,15 do
          if newLine[i]==4 or newLine[i]==5 then
            --score=score+200
            table.insert(shooter, i)
            table.insert(shooter, 23)
            table.insert(shootTime,totalTimer-2)
            newLine[i]=newLine[i]-2
          end
        end
        valleyMap=updateMap(valleyMap,newLine)
      end
      player:update(.5,dt)
      mapX=player:collisionDetect(valleyMap,mapX,preMap)
      for i,v in ipairs(shootTime) do
        if totalTimer-v>3 then
          shootTime[i]=totalTimer
          local anglo=math.rad(love.math.random(1,360))
          local range=math.sqrt((-shooter[2*i]*32+100)^2+(32*(shooter[2*i-1]+15)-player:getX())^2)
          local roll=love.math.random(1,100)
          local toHit=100-10*math.sqrt(range/100)-(player:getSpeed()+1)^2
          if roll<=toHit then
            player:damage(10)
            hit=0
          else
            table.insert(craters,player:getX()-math.cos(anglo)*(8+roll-toHit))
            table.insert(craters,player:getY()-math.sin(anglo)*(16+roll-toHit))
          end
        end
      end
      if craters[2]~=nil then
        if craters[2]>love.graphics.getHeight() then
          table.remove(craters,2)
          table.remove(craters,1)
        end
      end
    else 
      --print("end")
      level="end"
      contents= love.filesystem.read("highscores.csv")
      csv = core.ParseCSVLine(contents)
      for i, v in ipairs(csv) do 
        if (i % 2 == 0) then
        else
          if tonumber(score) > tonumber(v) and highscore==false then
            highscore=true
            insert=i+1
            table.insert(csv,i,core.round(score,6))
            table.insert(csv,i+1,4)
            table.remove(csv)
            table.remove(csv)
            score=v
            if csv[10]==nil then
              csv[10]="waylon"
            end
          end
        end
      end
      --score=totalTimer
      text=""
      textEnterable=true
      red=255
      hit=10
      resetTimer=0
      love.filesystem.write("highscores.csv",core.toCSV(csv))
    end
  elseif level == "end" then
    --print("Things") 
  end
end
function love.quit()
	if level=='end' and highscore==true then
		csv[insert]=text
		love.filesystem.write("highscores.csv",core.toCSV(csv))
		highscore=false
	end
end
function love.textinput(t)
	if textEnterable==true then
		text = text .. t
    --print(text)
	end
end
