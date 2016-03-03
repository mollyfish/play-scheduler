--test_scheduler.lua
package.path = package.path..";../?.lua"

local Kernel = require("schedlua.kernel")()
local Functor = require("schedlua.functor")

local function numbers(ending)
	local idx = 0;
	local function closure()
		idx = idx + 1;
		if idx > ending then
			return nil;
		end
		return idx;
	end
	
	return closure;
end

local function waitingOnCount(name, ending)
	local eventName = name..tostring(ending)
	waitForSignal(eventName)

	print("REACHED COUNT: ", ending)
end

local function onCountFinished(name)
	print("Counter Finished: ", name)
end

local function yieldCounter(name, nCount)
	for num in numbers(nCount) do
		print("num:  ", num)
		local eventName = name..tostring(num);
		signalOne(eventName)
		if num > (nCount/2 - 2) then
			print("eventName: ", eventName)
			signalOne(eventName)
			yield();
		end
	end
	signalAll(name..'-finished')

end

-- local function counter(name, nCount)
-- 	for num in numbers(nCount) do
-- 		print("num:  ", num)
-- 		local eventName = name..tostring(num);
-- 		signalOne(eventName)
-- 		yield();
-- 	end
-- 	signalAll(name..'-finished')
-- end

function wait35() 
	print("LAMDA"); 
	waitForSignal("yieldCounter35") 
	print("reached 35!!") 
end

local function main()
	local t1 = spawn(yieldCounter, "yieldCounter", 50)
	local t2 = spawn(waitingOnCount, "waitingCounter", 40)
	local t3 = spawn(wait15)

--	counter15
	-- test signalAll().  All three of these should trigger when
	-- counter finishes
	local t13 = onSignal(Functor(onCountFinished, "yieldCounter-1"), "yieldCounter-finished")
	local t14 = onSignal(Functor(onCountFinished, "yieldCounter-2"), "yieldCounter-finished")
	local t15 = onSignal(Functor(onCountFinished, "yieldCounter-3"), "yieldCounter-finished")
--
end

run(main)


--print("After kernel run...")
