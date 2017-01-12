--[[git do not forget
git add file
git commit -m "stuff"
git push
]]--

function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

dofile("tableSave.lua")
math.randomseed(os.time())
function ls(dir)
  local results = {}
  for entry in io.popen('ls -1 ' .. dir):lines() do
    table.insert(results, entry)
  end
  return results
end

enemyExists = false
levelEnemies = {}
local enemyNums = {}

function main()
  -- read all the levels
  print("LOADING CONTENT")
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
		print("   Enemies:")
		for _,enemy in ipairs(levelEnemies[level]) do
			print("     " .. enemy)
		end
		print("   Items:")
		for _,item in ipairs(levelItems[level]) do
			print("     " .. item)
		end
	end
end

function loadPlayer()
	player = {}
	stats = {}
	inv = {}
	temp = io.open("player.lua","r")
	if temp:read("*all") ~= nil then
		player = table.load("player.lua")
		stats = table.load("playerStats.lua")
		inv = table.load("inventory.lua")
	end
	temp:close()
end

function createPlayer()
	loadPlayer()
	io.write("\ncreate a new character? (leave blank to load last character)\n")
	input = io.read("*line")
	if input =="y" or input == "yes" or player["name"]==nil or player["hp"] == 0 then
		if player["name"] == nil then
			print("You have no game to load")
		end 
		stats = {
		kills = 0,
		itemUses = 0,
		levelsVisted = 0,
		hpGained = 0,
		hpLost = 0
		}
		
		player = {
		hp=15,
		defs=5,
		defb=5,
		defm=5,
		xp=0,
		lvl=1
		}
		::redoName::
		io.write("\nWhat is your name?\n")
		input = io.read("*line")
		input = trim(input)
		if input == "" or input == " " then
			goto redoName
		end
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
end

main()
::restart::
createPlayer()
--[[
playerHP = 15
playerDEFS --sharp
playerDEFB --blunt
playerDEFM --magic
playerDEX
playerSTR
playerINT
]]--

function commands(input)
	local input = trim(input)
	if string.lower(input) == "inv" or string.lower(input) == "inventory" then
		displayInv()
	end
	if string.lower(input) =="stats" then
		displayStats()
	end
	if string.lower(input) == "run" then
		if run() then
			runWin = true
		else
			runLoss = true
		end
		enemyAttack()
	end
	if string.lower(input)=="use" then
		useItem()
	end
	if string.lower(input)=="xp" then
		print("you have "..player["xp"].."XP")
	end
	if string.lower(input)=="hp" or string.lower(input)=="health" then
		print("you have "..player["hp"].."HP")
	end
	if string.lower(input)=="player" then
		displayPlayer()
	end
	if string.lower(input)=="help" then
		help()
	end
	if string.lower(input)=="give" then
		findItem()
	end
end

function nextLevel()
	paces = 0
	if levelCount == nil or levelCount == 0 then
		print("ERR: 0 levels found")
	else
		currentLevel = levels[math.random(1,levelCount)]
		print("You have fallen and ended up in the "..currentLevel.."...\n")
		level = currentLevel
	end
	foundExit = false
	stats["levelsVisted"] = stats["levelsVisted"]+1
	save()
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
	print("")
	print("You have found a "..keyItem.."!")
	if inv[keyItem] == nil then
		inv[keyItem] = {p1,p2,p3}
	else
		if inv[keyItem][3] == nil then
			inv[keyItem][3] = 1
		else
			inv[keyItem][3] = inv[keyItem][3]+1
			print("You now have "..inv[keyItem][3].." "..keyItem.."s!")
		end
	end
	print("")
end

function displayInv()
	print("inventory")
	local count = 0
	for k,v in pairs(inv) do
	count = count+1
	io.write(count)
		if v[3] ~= nil then
			io.write("   "..tostring(k))
			io.write(" x "..tostring(v[3]).."\n")
		else
			print("   "..tostring(k))
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
  def = ({
    S = player["defs"],
    B = player["defb"],
    M = player["defm"]
  })[enemy["atkType"]:upper()]

  if def ~= nil then
    local dmg = enemy["atk"] + tempRand - def
    if dmg > 0 then
      player["hp"] = player["hp"] - dmg
      print(enemy.name .. " did " .. dmg .. " damage to you")
      stats["hpLost"] = stats["hpLost"] + dmg
    else
      print(enemy.name .. " is too weak and did no damage")
      stats["hpLost"] = stats["hpLost"] - 1
    end
  end
	print("you have "..player["hp"].." health left")
	if runWin then
		enemyFound = false
		print("You ran away!")
		runWin = false
	end
	if runLoss then
		print("You tried and failed to escape!")
		runLoss = false
	end
end

function levelUp()
	print("\nYou have leveled up!!!\n")
	print("Increase what stat?")
	displayPlayer()
	local tempRand = math.random(3,5)
	::retryLvl::
	io.write("increase:")
	local input = io.read("*line")
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
	save()
end

function displayPlayer()
	print("")
	print(player["name"])
	print("   Sharp Defense="..player["defs"])
	print("   Blunt Defense="..player["defb"])
	print("   Magic Defense="..player["defm"])
	print("   Dexterity="..player["dex"])
	print("   Intelligence="..player["int"])
	print("   Strength="..player["str"])
	print("")
end

function displayStats()
	print("")
	print(player["name"])
	print("   Item Uses="..stats["itemUses"])
	print("   Levels Visted="..stats["levelsVisted"])
	print("   Hp Lost="..stats["hpLost"])
	print("   Hp Gained="..stats["hpGained"])
	print("   Kills="..stats["kills"])
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
	print("   player: display skills and player bits and bobs")
	print("   save: save your stats (can't be done during a fight)")
	print("   run: gives you a chance to escape!")
	print("   help: display this again")
	print("")
end

function save()
	player["level"] = level
	player["paces"] = paces
	assert( table.save( player, "player.lua" ) == nil )
	assert( table.save( inv, "inventory.lua" ) == nil )
	assert( table.save( stats, "playerStats.lua" ) == nil )
end

function run()
	if math.random(1,10) >7 then
		return true
	else
		return false
	end
end

function travel()
	local north = false
	local south = false
	local east = false
	local west = false
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
	commands(input)
	if string.lower(input)=="save" then
		print("Game Saved!")
		save()
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
	paces = paces+1
	if paces > 5*player["lvl"] and math.random(1,20) == 3  then
		foundExit = true
	end
	if math.random(1,5) == 3 and not foundExit then
		enemyFound = true
	end
end

function useItem()
	io.write("use: ")
	input=io.read("*line")
	input = trim(input)
	has = false
	local count = -1
	if enemy ~= nil then
		for k,v in pairs(inv) do
			if string.lower(k)==string.lower(input) or tonumber(input) == count then
				has = true
				if tonumber(input) == count then
					input = k
					print("you used your "..input)
				end
			end
			count = count+1
		end
	end
	if has == false and enemy ~= nil then
		print("You don't have a "..input)
	else
		stats["itemUses"] = stats["itemUses"]+1
		selItem = string.lower(input)
		if string.upper(inv[selItem][2])=="H" then
			tempRand = math.random(1,4)-2
			stats["hpGained"] = stats["hpGained"]+(inv[selItem][1]+tempRand)
			player["hp"]=player["hp"]+(inv[selItem][1]+tempRand)
			if player["hp"]>15 then
				player["hp"] = 15
			end
			print("you have gained "..(inv[selItem][1]+tempRand).."HP, you now have "..player["hp"].."HP")
			if inv[selItem][3] == nil then
				inv[selItem][3] = 1
			end
			inv[selItem][3] = inv[selItem][3]-1
			if inv[selItem][3] < 1 then
				inv[selItem] = nil
			end
		else
			if enemy ~= nil then
				attack()
				enemyAttack()
			else
				print("nothing to use "..input.." on")
			end
		end
	end
end

help()
if player["level"] == nil then
	nextLevel()
else
	print("\nyou are now in the "..player["level"].."\n")
	level = player["level"]
end
if player["paces"] == nil then
	paces = 0
else
	paces = player["paces"]
end
enemyFound = false
foundExit = false

while player["hp"] > 0 do  --ACTUAL CODE LOOP
	if enemyFound and not foundExit then
		encounter()
	end
	if enemyFound and not foundExit then
		while enemy["hp"]>0 and player["hp"]>0 and enemyFound do
			io.write("\nwhat will you do!\n")
			local input = io.read("*line")
			commands(input)
		end
		if not runWin then
			if enemy["hp"] <1 then
				print("")
				print("You killed "..enemy["name"])
				stats["kills"] = stats["kills"]+1
				randXp = math.random(1,5)*10
				print("you gain "..randXp.."XP")
				player["xp"] = player["xp"]+randXp
				print("")
				if enemy["dropChance"] == nil then
					enemy["dropChance"] = 3
				end
				if math.random(1,enemy["dropChance"]) == 1 then
					findItem()
				end
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
		travel()
		if foundExit then
			nextLevel()
		end
	end
	if foundExit then
		nextLevel()
	end
end
print("you died!")
io.write("\nretry?\n")
input = io.read("*line")
if input == "y" or input == "yes" then
	player["hp"] = 0
	assert( table.save( player, "player.lua" ) == nil )
	goto restart
else
	player["hp"] = 0
	assert( table.save( player, "player.lua" ) == nil )
end
