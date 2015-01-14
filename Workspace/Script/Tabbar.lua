Tabbar = {}

function Tabbar.new(name, class)
	local tabbar = {}
	tabbar.name = name
	tabbar.class = class
	tabbar.items = {}
	return tabbar
end

function Tabbar.addItem(tabbar, item)
	table.insert(tabbar.items, item)
	return tabbar
end

return Tabbar