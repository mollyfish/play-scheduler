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

local function counter(name, nCount)
	for num in numbers(nCount) do
		print(num)
		--local eventName = name..tostring(num);
		local eventName = name..tostring(num);
		--print(eventName)
		signalOne(eventName);

		yield();
	end

	signalAll(name..'-finished')
end

function wait15() 
	print("LAMDA"); 
	waitForSignal("counter15") 
	print("reached 15!!") 
end

local function main()
	local t1 = spawn(counter, 1, "counter", 50)
	local t3 = spawn(waitingOnCount, 1, "counter", 25)
	local t4 = spawn(wait15, 0)

--	counter15
	-- test signalAll().  All three of these should trigger when
	-- counter finishes
	local t13 = onSignal(Functor(onCountFinished, "counter-1"), "counter-finished")
	local t14 = onSignal(Functor(onCountFinished, "counter-2"), "counter-finished")
	local t15 = onSignal(Functor(onCountFinished, "counter-3"), "counter-finished")
--
end

run(main)


--print("After kernel run...")
