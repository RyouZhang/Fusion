FusionActor = {
}

function FusionActor.new(name, class)
	local actor = {}
	actor.name = name
	if class == nil then
		actor.class = 'FusionActor'
	else
		actor.class = class
	end
	return actor
end

function FusionActor.newLuaActor(name, scriptName, enterName)
	local actor = {}
	actor.name = name
	actor.class = 'FusionLuaActor'
	actor.script = scriptName
	actor.enter = enterName
	return actor
end

function FusionActor.addFilter(actor, filter)	
	actor.filter = filter
	return actor
end

return FusionActor