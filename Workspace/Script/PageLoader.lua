if requireEx == nil then
	requireEx = require
end

requireEx('Page')
requireEx('Tabbar')

page_array = {}
tabbar_array = {}

_G['register_page'] = function(page)
	page_array[page.name] = page
end

_G['register_tabbar'] = function(tabbar)
	tabbar_array[tabbar.name] = tabbar
end

Page_Index = requireEx('Page_Index')
for _,page in ipairs(Page_Index) do
	requireEx(page)
end

function queryTabbarByName(name)
	if tabbar_array[name] ~= nil then
		return	tabbar_array[name]
	end
	return nil
end

function queryPageByName(name)
	if page_array[name] ~= nil then
		return	page_array[name]
	end
	return nil
end

function checkPageNameValid(name)
	if page_array[name] ~= nil then
		return true
	end
	return false
end

-- Rewrite Page Url
rewrite_rule_array = {}
_G['register_rewrite_rule'] = function(page, command, func)
	if rewrite_rule_array[page] == nil then
		rewrite_rule_array[page] = {}
	end
	if command == nil then
		rewrite_rule_array[page]['default'] = func
	else
		rewrite_rule_array[page][command] = func
	end
end

Rewrite_Index = requireEx('Rewrite_Index')
for _,rewrite in ipairs(Rewrite_Index) do
	requireEx(rewrite)
end

function rewritePageMessage(page, command, params, callback)
	if rewrite_rule_array[page] == nil then		
		return nil
	end
	local result = {}
	if rewrite_rule_array[page][command] ~= nil then
		result.page, result.command, result.params, result.callback = rewrite_rule_array[page][command](page, command, params, callback)
	else
		result.page, result.command, result.params, result.callback = rewrite_rule_array[page]['default'](page, command, params, callback)
	end
	return result
end

-- White_List
-- requireEx('WhiteList')

function checkWhitelistValid(host, whitelist)
	for _,v in ipairs(whitelist) do
		if type(v) == 'string' then
			result = string.gmatch(host, v)()
			if result then return true end
		end
	end
	return false
end