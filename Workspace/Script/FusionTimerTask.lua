FusionTimerTask = {
}

function FusionTimerTask.newTask(class, interval, delay, count)
	local task = {}
	task.class = class
	task.interval = interval
	if delay == nil then 
		task.delay = 0 
	else
		task.delay = delay
	end
	if count == nil then
		task.count = 1
	else
		task.count = count
	end
	return task
end

function FusionTimerTask.newForeverTask(class, interval, delay)
	local task = {}
	task.class = class
	task.interval = interval
	if delay == nil then 
		task.delay = 0 
	else
		task.delay = delay
	end
	task.forever = true
	return task
end

return FusionTimerTask