Page = {}

function Page.new(name, class, trackName)
	local page = {}
	page.name = name
	page.class = class
	page.trackName = trackName
	page.commands = { 'init' }	
	return page
end

--urls is table, keys: test, prepare, release
function Page.newH5Host(name, urls, trackName)
	local page = {}
	page.name = name
	page.class = 'TRIPWebViewHostController'
	page.trackName = trackName
	page.commands = { 'init' }	
	page.urls = urls
	return page
end

--page support commands
function Page.addCommand(page, command)
	table.insert(page.commands, command)
	return page
end

return Page