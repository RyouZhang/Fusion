if requireEx == nil then
	requireEx = require
end

requireEx('FusionService')
requireEx('FusionActor')
requireEx('FusionFilter')
requireEx('FusionTimerTask')

core_service_array = {}
logic_service_array = {}
timer_task_array = {}

_G['register_core_service'] = function(fusion_service)
	table.insert(core_service_array, fusion_service)
end

_G['register_logic_service'] = function(fusion_service)
	logic_service_array[fusion_service.name] = fusion_service
end

_G['register_timer_task'] = function(task)
	table.insert(timer_task_array, task)
end

requireEx('Service_Index')
for _,service in ipairs(Service_Index) do
	requireEx(service)
end

function queryLogicServiceByName(name)
	if logic_service_array[name] ~= nil then
		return	logic_service_array[name]
	end
	return nil
end

function getCoreServices()
	return core_service_array
end

function getTimerTasks()
	return timer_task_array
end