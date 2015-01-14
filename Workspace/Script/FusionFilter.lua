FusionFilter = {
}

function FusionFilter.new(class)
	local filter = {}
	if class == nil then
		filter.class = 'FusionFilter'
	else
		filter.class = class
	end
	return filter
end

function FusionFilter.andFilter(...)
	local filter = {}
	filter.class = 'FusionAndFilter'
	filter.filters = {...}
	return filter
end

function FusionFilter.orFilter(...)
	local filter = {}
	filter.class = 'FusionOrFilter'
	filter.filters = {...}
	return filter
end

function FusionFilter.notFilter(childFilter)
	local filter = {}
	filter.class = 'FusionNotFilter'
	filter.filter = childFilter
	return filter
end

function FusionFilter.luaFilter(scriptName, enterName)
	local filter = {}
	filter.class = 'FusionLuaFilter'
	filter.script = scriptName
	filter.enter = enterName
	return filter
end

return FusionFilter