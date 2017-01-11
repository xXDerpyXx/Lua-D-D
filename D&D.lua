--[[git do not forget
git add file
git commit -m "stuff"
git push
]]--


dofile("tableSave.lua")
math.randomseed(os.time())
function ls(dir)
  local results = {}
  for entry in io.popen('ls -1 ' .. dir):lines() do
    table.insert(results, entry)
  end
  return results
end

function tableLength(T)
	local count = 0
	for _ in pairs(T) do
		count = count + 1
	end
	return count
end

enemyExists = false
levelEnemies = {}
local enemyNums = {}

function main()
  -- read all the levels
  levels = ls("levels")
  levelEnemies = {}
  enemyNums = {}
  levelItems={}
  levelCount=0
  for _,level in ipairs(levels) do
	levelCount=levelCount+1
    levelEnemies[level] = {}
    levelItems[level] = {}
      -- for each level, read the enemies
      tempNum = 1
    for _,enemy in ipairs(ls("levels/" .. level .. "/enemies")) do
      table.insert(levelEnemies[level], enemy)
    end
    for _,item in ipairs(ls("levels/" .. level .. "/items")) do
      table.insert(levelItems[level], item)
    end
  end

  -- Print out what we loaded
  for _,level in ipairs(levels) do
    print(level..":")
    for _,enemy in ipairs(levelEnemies[level]) do
      print("  " .. enemy)
    end
  end
end

function loadPlayer()
	player = table.load("player.lua")
	inv = table.load("inventory.lua")
end

::restart::
loadPlayer()
io.write("\ncreate a new character?\n")
input = io.read("*line")
if input =="y" or input == "yes" then
	player = {
	hp=15,
	defs=5,
	defb=5,
	defm=5,
	xp=0,
	lvl=1
	}
	io.write("\nWhat is your name?\n")
	input = io.read("*line")
	player["name"] = input
	::redoClass::
	io.write("\nClass? Brute, Mage, or Knight\n")
	input = io.read("*line")
	if string.lower(input) == "brute" then
		player["dex"] = 3
		player["str"] = 7
		player["int"] = 3
		inv = {
			potion={5,"H",3},
			mace={5,"B"}
		}
	elseif string.lower(input) == "mage" then
		player["dex"] = 3
		player["str"] = 3
		player["int"] = 7
		inv = {
			potion={5,"H",3},
			zap={5,"M"}
		}
	elseif string.lower(input) == "knight" then
		player["dex"] = 7
		player["str"] = 3
		player["int"] = 3
		inv = {
			potion={5,"H",3},
			sword={5,"S"}
		}
	else
		goto redoClass
	end
	
	--[[dex=5,
	str=5,
	int=5,]]--
	
	assert( table.save( player, "player.lua" ) == nil )
	assert( table.save( inv, "inventory.lua" ) == nil )
else
	player=table.load("player.lua")
	print("player loaded, "..player["name"])
end
--[[
playerHP = 15
playerDEFS --sharp
playerDEFB --blunt
playerDEFM --magic
playerDEX
playerSTR
playerINT
]]--

main()

function nextLevel()
	paces = 0
	if levelCount == nil or levelCount == 0 then
		print("ERR: 0 levels found")
	else
		currentLevel = levels[math.random(1,levelCount)]
		print("You have fallen and ended up in the "..currentLevel.."...")
		level = currentLevel
	end
	foundExit = false
end

function encounter()
	--print(levelEnemies[level][1])
	enemyFile = nil
	enemy = nil
	while enemyFile == nil do
		tempNum = math.random(1,255)
		enemyFile = levelEnemies[level][tempNum]
	end
	enemyFile = string.gsub(enemyFile,"%.lua","")
	--print(enemyFile)
	--print("levels/"..level.."/enemies/"..enemyFile)
	enemy = dofile("levels/"..level.."/enemies/"..enemyFile..".lua")
	print("You have run into a "..enemy["name"].."!")
	enemyExists = true
end

function findItem()
	--print(levelEnemies[level][1])
	itemFile = nil
	item = nil
	while itemFile == nil do
		tempNum = math.random(1,255)
		itemFile = levelItems[level][tempNum]
	end
	itemFile = string.gsub(itemFile,"%.lua","")
	--print(enemyFile)
	--print("levels/"..level.."/enemies/"..enemyFile)
	item = dofile("levels/"..level.."/items/"..itemFile..".lua")
	for k,v in pairs(item) do
		keyItem = tostring(k)
		p1 = item[k][1]
		p2 = item[k][2]
		p3 = item[k][3]
	end
	print("You have found a "..keyItem.."!")
	if inv[keyItem] == nil then
		inv[keyItem] = {p1,p2,p3}
	else
		if p3 == nil then
			inv[keyItem][3] = 1
		else
			inv[keyItem][3] = inv[keyItem][3]+1
			print("You now have "..inv[keyItem][3].." "..keyItem.."s!")
		end
	end
	
	
end


function attack()
	tempRand = math.random(1,4)-2
	if string.upper(inv[selItem][2]) == "S" then
		if (((inv[selItem][1]+(player["dex"]-5))+tempRand)-enemy["defs"]) > 0 then
			enemy["hp"] = enemy["hp"]-(((inv[selItem][1]+(player["dex"]-5))+tempRand)-enemy["defs"])
			print("you did "..(((inv[selItem][1]+(player["dex"]-5))+tempRand)-enemy["defs"]).." damage to "..enemy["name"])
		else
			enemy["hp"] = enemy["hp"]-1
			print(enemy["name"].."'s armor is too strong, you did only 1 damage")
		end
	elseif string.upper(inv[selItem][2]) == "B" then
		if (((inv[selItem][1]+(player["str"]-5))+tempRand)-enemy["defb"]) > 0 then
			enemy["hp"] = enemy["hp"]-(((inv[selItem][1]+(player["str"]-5))+tempRand)-enemy["defb"])
			print("you did "..(((inv[selItem][1]+(player["str"]-5))+tempRand)-enemy["defb"]).." damage to "..enemy["name"])
		else
			enemy["hp"] = enemy["hp"]-1
			print(enemy["name"].."'s armor is too strong, you did only 1 damage")
		end
	elseif string.upper(inv[selItem][2]) == "M" then
		if (((inv[selItem][1]+(player["int"]-5))+tempRand)-enemy["defm"]) > 0 then
			enemy["hp"] = enemy["hp"]-(((inv[selItem][1]+(player["int"]-5))+tempRand)-enemy["defm"])
			print("you did "..(((inv[selItem][1]+(player["int"]-5))+tempRand)-enemy["defm"]).." damage to "..enemy["name"])
		else
			enemy["hp"] = enemy["hp"]-1
			print(enemy["name"].."'s armor is too strong, you did only 1 damage")
		end
	end
	print(enemy["name"].." has "..enemy["hp"].." health left")
end

function enemyAttack()
	tempRand = math.random(1,4)-2
	if string.upper(enemy["atkType"]) == "S" then
		if (enemy["atk"]+tempRand-player["defs"])>0 then
			player["hp"] = player["hp"]-(enemy["atk"]+tempRand-player["defs"])
			print(enemy["name"].." did "..(enemy["atk"]+tempRand-player["defs"]).." damage to you")
		else
			print(enemy["name"].." is too weak and did no damage")
		end
	elseif string.upper(enemy["atkType"]) == "B" then
		if (enemy["atk"]+tempRand-player["defb"])>0 then
			player["hp"] = player["hp"]-(enemy["atk"]+tempRand-player["defb"])
			print(enemy["name"].." did "..(enemy["atk"]+tempRand-player["defb"]).." damage to you")
		else
			print(enemy["name"].." is too weak and did no damage")
		end
	elseif string.upper(enemy["atkType"]) == "M" then
		if (enemy["atk"]+tempRand-player["defm"])>0 then
			player["hp"] = player["hp"]-(enemy["atk"]+tempRand-player["defm"])
			print(enemy["name"].." did "..(enemy["atk"]+tempRand-player["defm"]).." damage to you")
		else
			print(enemy["name"].." is too weak and did no damage")
		end
	end
	print("you have "..player["hp"].." health left")
end

function levelUp()
	print("\nYou have leveled up!!!\n")
	print("Increase what stat?")
	displayStats()
	tempRand = math.random(1,5)
	::retryLvl::
	io.write("increase:")
	input = io.read("*line")
	if string.lower(input) == "sharp" or string.lower(input) == "sharp defense" then
		print("Sharp Defense increased by "..tempRand)
		player["defs"] = player["defs"]+tempRand
	elseif string.lower(input) == "blunt" or string.lower(input) == "blunt defense" then
		print("Blunt Defense increased by "..tempRand)
		player["defb"] = player["defb"]+tempRand
	elseif string.lower(input) == "magic" or string.lower(input) == "magic defense" then
		print("Magic Defense increased by "..tempRand)
		player["defm"] = player["defm"]+tempRand
	elseif string.lower(input) == "strength" then
		print("Strength increased by "..tempRand)
		player["str"] = player["str"]+tempRand
	elseif string.lower(input) == "dexterity" then
		print("Dexterity increased by "..tempRand)
		player["dex"] = player["dex"]+tempRand
	elseif string.lower(input) == "intelligence" then
		print("Intelligence increased by "..tempRand)
		player["defs"] = player["defs"]+tempRand
	else
		goto retryLvl
	end
end
function displayStats()
	print("")
	print("Sharp Defense="..player["defs"])
	print("Blunt Defense="..player["defb"])
	print("Magic Defense="..player["defm"])
	print("Dexterity="..player["dex"])
	print("Intelligence="..player["int"])
	print("Strength="..player["str"])
	print("")
end

function help()
	print("")
	print("basic commands:")
	print("   use: select and use a weapon/item")
	print("   inv: look in your inventory")
	print("   xp: check xp")
	print("   hp: check hp")
	print("   stats: display stats")
	print("   save: save your stats (can't be done during a fight)")
	print("   help: display this again")
	print("")
end

help()

nextLevel()
enemyFount = false


while player["hp"] > 0 do
	if enemyFound and not foundExit then
		encounter()
	end
	if enemyFound and not foundExit then
		while enemy["hp"]>0 and player["hp"]>0 do
			io.write("\nwhat will you do!\n")
			input = io.read("*line")
			if string.lower(input) == "inv" or string.lower(input) == "inventory" then
				print("inventory")
				for k,v in pairs(inv) do
					if v[3] ~= nil then
						io.write("   "..tostring(k))
						io.write(" x "..tostring(v[3]).."\n")
						
					else
						print("   "..tostring(k))
					end
				end
			end
			if string.lower(input)=="use" then
				io.write("use: ")
				input=io.read("*line")
				has = false
				for k,v in pairs(inv) do
					if string.lower(k)==string.lower(input) then
					has = true
					end
				end
				if has == false then
					print("You don't have a "..input)
				else
					selItem = string.lower(input)
					if string.upper(inv[selItem][2])=="H" then
						tempRand = math.random(1,4)-2
						player["hp"]=player["hp"]+(inv[selItem][1]+tempRand)
						if player["hp"]>15 then
							player["hp"] = 15
						end
						print("you have gained "..(inv[selItem][1]+tempRand).."HP, you now have "..player["hp"].."HP")
						inv[selItem][3] = inv[selItem][3]-1
						if inv[selItem][3] < 1 then
							inv[selItem] = nil
						end
					else
						attack()
						enemyAttack()
					end
				end
			end
			if string.lower(input)=="xp" then
				print("you have "..player["xp"].."XP")
			end
			if string.lower(input)=="hp" or string.lower(input)=="health" then
				print("you have "..player["hp"].."HP")
			end
			if string.lower(input)=="stats" or string.lower(input)=="health" then
				displayStats()
			end
			if string.lower(input)=="help" then
				help()
			end
			if string.lower(input)=="give" then
				findItem()
			end
		end
		if enemy["hp"] <1 then
			print("")
			print("You killed "..enemy["name"])
			randXp = math.random(1,5)*10
			print("you gain "..randXp.."XP")
			player["xp"] = player["xp"]+randXp
			print("")
			if math.random(1,10) == 5 then
				findItem()
			end
		end
		if player["xp"]>player["lvl"]*100 then
			player["xp"] = 0
			player["lvl"] = player["lvl"]+1
			levelUp()
		end
	end
	enemy = nil
	enemyExists = false
	enemyFound = false
	while not enemyFound and not foundExit and player["hp"]>0 do
		local north = false
		local south = false
		local east = false
		local west = false
		local foundExit = false
		if math.random(1,2) == 2 then
			north = true
			print("there is a path north")
		end
		if math.random(1,2) == 2 then
			south = true
			print("there is a path south")
		end
		if math.random(1,2) == 2 then
			east = true
			print("there is a path east")
		end
		if math.random(1,2) == 2 then
			west = true
			print("there is a path west")
		end
		if not north and not east and not south and not west then
			north = true
			print("there is a path north")
		end
		::redoPath::
		io.write("\nwhich way shall you travel?\n")
		input = io.read("*line")
		if string.lower(input)=="xp" then
			print("you have "..player["xp"].."XP")
			goto redoPath
		end
		if string.lower(input)=="hp" or string.lower(input)=="health" then
			print("you have "..player["hp"].."HP")
			goto redoPath
		end
		if string.lower(input) == "inv" or string.lower(input) == "inventory" then
				print("inventory")
				for k,v in pairs(inv) do
					if v[3] ~= nil then
						io.write("   "..tostring(k))
						io.write(" x "..tostring(v[3]).."\n")
						
					else
						print("   "..tostring(k))
					end
				end
				goto redoPath
			end
		if string.lower(input)=="save" then
			print("Game Saved!")
			assert( table.save( player, "player.lua" ) == nil )
			assert( table.save( inv, "inventory.lua" ) == nil )
			goto redoPath
		end
		
		if string.lower(input)=="stats" or string.lower(input)=="health" then
			displayStats()
			goto redoPath
		end
		if string.lower(input)=="north" then
			if north then
				print("you head north!")
			else
				print("north is blocked")
				goto redoPath
			end
		end
		if string.lower(input)=="south" then
			if south then
				print("you head south!")
			else
				print("south is blocked")
				goto redoPath
			end
		end
		if string.lower(input)=="east" then
			if east then
				print("you head east!")
			else
				print("east is blocked")
				goto redoPath
			end
		end
		if string.lower(input)=="west" then
			if west then
				print("you head west!")
			else
				print("west is blocked")
				goto redoPath
			end
		end
		print("")
		if paces > 5 then
			foundExit = true
			break
		elseif math.random(1,5) == 3 and not foundExit then
			enemyFound = true
		end
	end
	if foundExit then
		nextLevel()
	end
end
print("you died!")
io.write("\nretry?\n")
input = io.read("*line")
if input == "y" or "yes" then
	goto restart
end
