--[[
%% properties
%% events
%% globals
--]]
     
-- ID des mobiles,tablettes pour notification
local portable = { 892 }
local backup_symbol = '!' -- for auto delete only backups with this symbol on irst postion in description
local backup_stay = '060' -- numbers of days to store autobackups (from 001 to 999 with loading zeros)
print('Current parameters:')
print('delete after: '..backup_stay..' day(s), only backups with description start by ['..backup_symbol..']')
fibaro:sleep(10*1000)

function sendPush(message)
    if #portable > 0 then
        for _,v in ipairs(portable) do
            fibaro:call(v,'sendPush', message)
        end
    end
end

-- Message Descriptif du Backup
local descriptif = backup_symbol..'['..backup_stay..'] Autobackup - '..os.date("%d/%m/%y - %HH%M")

-- Password admin encodé en base64
local password = 'cGR1cmJhamxvQGl0LXNlY'

local url = 'http://127.0.0.1/api/service/backups'
local datas = '{"action":"create","params":{"name":"'..descriptif..'"}}'


local httpClient = net.HTTPClient()
httpClient:request(url , {
		success = function(response)
					if tonumber(response.status) == 201 or tonumber(response.status) == 202 then
						print("Backup Created at " .. os.date())
        				sendPush(descriptif .. ' effectué')				
                    else
						print("Error " .. response.status)
         				sendPush('Erreur lors de la création du Backup - '.. response.status)
                    end
                end,
        error = function(err)
					print('error = ' .. err)
                end,
        options = {
				method = 'POST',
                headers = { 
						["content-type"] = 'application/json',
						["Authorization"] = 'Basic '..password
                          },
                data = datas
			}
});

