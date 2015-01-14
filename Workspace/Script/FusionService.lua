FusionService = {
}

function FusionService.new(name, class)
	local service = {}
	service.name = name
	if class == nil then	
		service.class = 'FusionService'
	else
		service.class = class
	end
	service.actors = {}
	return service
end

function FusionService.addFilter(service, filter)
	service.filter = filter
	return service
end

function FusionService.addActor(service, actor)
	service.actors[actor.name] = actor
	return service
end

return FusionService