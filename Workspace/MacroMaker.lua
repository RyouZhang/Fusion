
require('Script/FusionService')
require('Script/FusionActor')
require('Script/FusionFilter')
require('Script/Page')
require('Script/Tabbar')
require('Script/FusionTimerTask')

print('Start executing MacroMaker')

os.execute('rm -rf Script.bundle')
os.execute('mkdir Script.bundle')

local scrip_array = {}
function check_same_script_name(script)
	for _,v in ipairs(scrip_array) do
		if v == script then return true end
	end
	return false
end

function get_all_lua_files(directory)
	local result = {}
	local exist = os.rename(directory,directory) and true or false
	if not exist then 
		return result 
	end

	local temp = io.popen('ls ' .. directory)
	for file in temp:lines() do
		local script = string.gmatch(file, '([^.]+.lua)')()
		if script then		
			table.insert(result, script)
		end
	end
	temp:close()
	return result
end


function scan_lua_script(directory, target)
	local files = get_all_lua_files(directory)
	for _,file in ipairs(files) do
		if check_same_script_name(file) then
			print('same script name:' .. directory .. '/' .. file)
			assert(true)
		end
		table.insert(scrip_array, file)
		if target then table.insert(target, directory .. '/' .. file) end
		os.execute('cp ' .. directory .. '/' .. file .. ' Script.bundle')
	end
end

-- 复制核心lua代码
scan_lua_script('Script', nil)

local directorys = {}
local file = io.popen('ls ../')
for v in file:lines() do
	if v ~= 'Workspace' and v ~= 'Ysera' then
		table.insert(directorys, '../' .. v .. '/Script')
	end
end
file:close()

local service_scripts = {}
local page_scripts = {}
local rewrite_scripts = {}

for _,directory in ipairs(directorys) do
	scan_lua_script(directory .. '/Service', service_scripts)
	scan_lua_script(directory .. '/Page', page_scripts)
	scan_lua_script(directory .. '/Rewrite', rewrite_scripts)
	scan_lua_script(directory .. '/Logic', nil)
end

function getFileName(filePath)  
    local fileName = string.match(filePath, ".+/([^/]*%.%w+)$")  
    local idx = fileName:match(".+()%.%w+$")  
    if(idx) then  
        return fileName:sub(1, idx-1)  
    else  
        return fileName  
    end  
end  

function generate_index_file(scripts, target)
	local file = io.open('Script.bundle/'..target ..'.lua', 'w')
	file:write(target .. ' = {\r\n')
	for i,v in ipairs(scripts) do
		if i ~= 1 then
			file:write(',\r\n')
		end
		file:write('\'' .. getFileName(v) .. '\'')
	end
	file:write('}\r\n')
	file:write('return '.. target)
	file:flush()	
end

local service_array = {}
_G['register_core_service'] = function(fusion_service)
	table.insert(service_array, fusion_service)
end

_G['register_logic_service'] = function(fusion_service)
	table.insert(service_array, fusion_service)
end

_G['register_tabbar'] = function(tabbar)
end

_G['register_timer_task'] = function(task)
end

function process_service_script()
	for _, service in ipairs(service_scripts) do
		local temp = io.open(service, 'r')
		local rawText = temp:read('*a')
		loadstring(rawText)()
		temp:close()
	end

	table.sort( service_array, function(a, b)
		if string.upper(a.name) > string.upper(b.name) then 
			return false 
		else 
			return true 
		end
	end )

	local file = io.open('TRIPServiceMacro.h', 'w')

	for _, service in ipairs(service_array) do
		file:write('/*==================================================*/\r\n')
		file:write('#define '.. string.upper(service.name .. '_service') .. '\t@"' .. service.name .. '"\r\n')	

		table.sort( service.actors, function(a, b)
			if string.upper(a.name) > string.upper(b.name) then 
				return false 
			else 
				return true 
			end
		end )
		for k,actor in pairs(service.actors) do		
			file:write('#define '.. string.upper(k) .. '_ACTOR\t@"' .. k .. '"\r\n')
		end	
		file:write('/*==================================================*/\r\n')
	end

	file:flush()
	file:close()

	generate_index_file(service_scripts, 'Service_Index')
end
process_service_script()

local page_array = {}

_G['register_page'] = function(page)
	table.insert(page_array, page)
end

function process_page_script()
	for _, page in ipairs(page_scripts) do
		local temp = io.open(page, 'r')
		local rawText = temp:read('*a')
		loadstring(rawText)()
		temp:close()
	end

	table.sort( page_array, function(a, b)
		if string.upper(a.name) > string.upper(b.name) then 
			return false 
		else 
			return true 
		end
	end )

	local file = io.open('TRIPPageMacro.h', 'w')
	for _, page in ipairs(page_array) do
		file:write('#define '.. string.upper(page.name .. '_PAGE') .. '\t@"' .. page.name .. '"\r\n')	
	end
	file:flush()
	file:close()

	generate_index_file(page_scripts, 'Page_Index')
end
process_page_script()

function process_rewrite_script()
	generate_index_file(rewrite_scripts, 'Rewrite_Index')
end
process_rewrite_script()

-- copy resource
function get_all_files(directory)
	local result = {}
	local exist = os.rename(directory .. '/Resource.bundle',directory .. '/Resource.bundle') and true or false
	if not exist then 
		return result 
	end

	local temp = io.popen('ls ' .. directory .. '/Resource.bundle')
	for file in temp:lines() do
		table.insert(result, file)	
	end
	temp:close()
	return result
end

function ls_directory(directory)
	local result = {}
	local temp = io.popen('ls ' .. directory)
	for file in temp:lines() do
		table.insert(result, file)	
	end
	temp:close()
	return result
end

os.execute('rm -rf Resource.bundle')
os.execute('mkdir Resource.bundle')

for _,directory in ipairs(directorys) do
	local files = get_all_files(directory)
	for _,file in ipairs(files) do
		os.execute('cp "' .. directory .. '/Resource.bundle/' .. file .. '" Resource.bundle')
	end
end

-- local exist = os.rename('./H5_Offline','./H5_Offline') and true or false
-- if exist then 
-- 	local files = ls_directory('./H5_Offline')
-- 	print(#files)
-- 	for _,file in ipairs(files) do
-- 		os.execute('cp "' .. './H5_Offline/' .. file .. '" Resource.bundle')
-- 		os.execute('rm -rd ' .. './H5_Offline/' .. file)
-- 	end
-- end

-- 生成发布用script.zip
local scripts = get_all_lua_files('Script.bundle')
os.execute('mkdir temp')
for _,script in ipairs(scripts) do
	os.execute('cp Script.bundle/' .. script ..' temp/')
end
os.execute('cd temp && zip -P 16ffcddaf14247ba931812977edd2d52 script.zip *.lua')
os.execute('mv temp/script.zip config.zip')
os.execute('rm -rf temp')
print('Executing MacroMaker finished')
