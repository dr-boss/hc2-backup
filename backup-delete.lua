--[[
%% properties
%% events
%% globals
--]]


-- Flag dryrun; for bapass delete function
local dryrun = false

--[[ 
modification to delete only backup file created by autobackup scene
(selected by '!' in descrption on first positon) and oldes more that 90 days 
Backups created manualy (without '!') are not deleted by this scene
--]]
local backup_batch = '147' -- batch scene for delete backup (isn't posible to delete more that one backup in one run of scene. The httpClient:request command block handler of /backup until scene not finiched  
local backup_stay = 0 -- time in day for store autobackup file if not use time in description ore no time in description
local default_stay = 'no' -- if 'yes' use [backup_stay] for all autobackup file, if 'no' use number of days stored in desciption of backup
local backup_symbol = '!' -- only delete after day stored in [backup_time] backup with this symbol on first postion in decription text. Need the same as in auto backup scene

-- Password admin encodé en base64
local password = 'cGR1cmJhamxvQGl0LXNlY'
local IP = api.get('/settings/network')['ip']
print('Current parameters:')
print('only backups with description start by ['..backup_symbol..'] are processed')
print('and deleted after: '..backup_stay..' day(s) if not dedicated information in description')
if  default_stay == 'yes' then print('Number of days for store backup is overwriten by '.. tostring(backup_stay) ..' day(s)') end

function sortBackup(data)
	local backups = json.decode(data)
	-- Vérification de présence Backup
	if (backups and type(backups == 'table') and #backups > 0) then
		if #backups > 1 then print(#backups .. ' backups exist') else print('1 backup') end
	
		for i in ipairs(backups) do
        delta=os.time() - tonumber(backups[i]['timestamp'])
      	todelete=string.sub(backups[i]['description'],1,1) -- =='!'
				if default_stay == 'no' and string.sub(backups[i]['description'],2,2) == '[' then -- obsłużyć gdy nie trafi na []
      			
        		backup_stay_tmp=tonumber(string.sub(backups[i]['description'],3,5))
        		else
        		backup_stay_tmp=backup_stay
        end
    		if delta <= backup_stay_tmp*60*60*24 and (string.sub(backups[i]['description'],1,1)) == backup_symbol then
          fibaro:debug('<font color="orange">ID: '..backups[i]['id']..' | TIME: '..os.date("%Y/%m/%d %H:%M:%S", backups[i]['timestamp'])..' | DESC: '..backups[i]['description'])
        	fibaro:debug("^^^ To delete in ".. backup_stay_tmp-tostring(math.floor(delta/60/60/24)).." day from today ^^^")
        elseif delta > backup_stay_tmp*60*60*24 and (string.sub(backups[i]['description'],1,1)) == backup_symbol then
          fibaro:debug('<font color="red">ID: '..backups[i]['id']..' | TIME: '..os.date("%Y/%m/%d %H:%M:%S", backups[i]['timestamp'])..' | DESC: '..backups[i]['description'])
        	print("^^^ Deleted this time ^^^")



------------------------------------------------
if (not dryrun) then
fibaro:startScene(backup_batch, {{del_id = backups[i]['id']}, {typ = dryrun},{pass = password} })
fibaro:sleep(60*1000)
end
------------------------------------------------          
        	else
        	fibaro:debug('<font color="green">ID: '..backups[i]['id']..' | TIME: '..os.date("%Y/%m/%d %H:%M:%S", backups[i]['timestamp'])..' | DESC: '..backups[i]['description'])
      		end
    	end
	else
		print('No backup or error')
		fibaro:abort()
	end
	
--[[
  -- ==================== DO TESTU =====================
  
	local timestamp = {} -- do nagłówka
  
  --table.insert(timestamp, backups[i]['timestamp']) -- w miejsce obecnej funckji kasowania
  table.insert(idstamp, backups[i]['id']) -- w miejsce obecnej funckji kasowania, zapisuje do nowej tabeli ID backup'ow do skasowania
  
  --nowe kasowanie przez zewnętrzną fukcję (scenę) już po wyświetleniu całej listy na podstawie nowej listy
	--for i in ipairs(timestamp) do
  for i in ipairs(idstamp) do
     deleteBackup(idstamp[i]['id'])
     fibaro:sleep(45*1000)
  end
	
  -- ===================================================
--]]

end


-- orginal function not used in case of neccesery delete more than one backup

function deleteBackup(id)
	-- Requete via API pour effacer le backup le plus ancien
	if (not dryrun) and (id) then
		print('Deleting backup '..id..' in progress. Wait 60s')
		local url = 'http://'..IP..'/api/service/backups/'..id
		local httpClient = net.HTTPClient()
		httpClient:request(url , {
			success = function(response)
						if tonumber(response.status) == 200 then
							print("Backup "..id.." deleted at " .. os.date())
						else
							print(id.." Error " .. response.status)						
						end
					end,
			error = function(err)
						print(id..' error = ' .. err)
					end,
			options = {
					method = 'DELETE',
					headers = {
						["content-type"] = 'application/x-www-form-urlencoded;',
						["authorization"] = 'Basic '..password
            },
          timeout = 60000,
					data = 'id='..id
				}
		})
    --fibaro:sleep(69*1000)
  	end
end

-- Check list of backup and call criteria check
local GETClient = net.HTTPClient()
if dryrun then print('Mode DryRun -> Bypass delete, only check backup for delete') end

GETClient:request('http://'..IP..'/api/service/backups', {
	success = function(response)
				if tonumber(response.status) == 200 then
					sortBackup(response.data)
				else
					print("Error " .. response.status)						
                   end
                end,
	error = function(err)
				print('error = ' .. err)
            end,
	headers = {
				["content-type"] = 'application/x-www-form-urlencoded;',
				["authorization"] = 'Basic '..password
				}				      	
	});
	


