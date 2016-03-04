--test_scheduler.lua
-- modified to let the first task run an arbitrary number of times
-- before yielding.
package.path = package.path..";../?.lua"

local Kernel = require("schedlua.kernel")()
local Functor = require("schedlua.functor")
local cutoff = 25; --arbitrary number for testing

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
		print(num)
		local eventName = name..tostring(num);
		signalOne(eventName)
		if num > (cutoff - 1) then
			signalOne(eventName)
			yield();
		end
	end
	signalAll(name..'-finished')

end

function waitCutoff()
	local signalName = "yieldCounter"
	signalName = "yieldCounter" .. (cutoff + 10)
	print("LAMDA"); 
	waitForSignal(signalName) 
	print("ALERT: reached ", (cutoff + 10)) 
end

local function main()
	local t1 = spawn(yieldCounter, "yieldCounter", 50)
	local t2 = spawn(waitingOnCount, "yieldCounter", 40)
	local t3 = spawn(waitCutoff)

	local t13 = onSignal(Functor(onCountFinished, "yieldCounter-1"), "yieldCounter-finished")
	local t14 = onSignal(Functor(onCountFinished, "yieldCounter-2"), "yieldCounter-finished")
	local t15 = onSignal(Functor(onCountFinished, "yieldCounter-3"), "yieldCounter-finished")
end

run(main)
