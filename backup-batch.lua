--[[
%% properties
%% events
%% globals
--]]
-- scene called by backup-create
-------=================
local params = fibaro:args()
local del_id = '0'
local typ = false
local password = ''


function doNotify(info, level)
local scene = api.get("/scenes/" .. __fibaroSceneId)
print( scene.name )
HomeCenter.NotificationService.publish({
    type = "GenericSystemNotification", --"GenericDeviceNotification",
    priority = level,
    canBeDeleted = "true",
    data =
    {
        subType = "DeviceNotConfigured",
      	name = "Backup System",
        text =  info,
        url = "/scenes/edit.html?id="..__fibaroSceneId.."#bookmark-advanced",
        urlText = "Edycja sceny"
    }
})  
  
end


if (params) then
  for k, v in ipairs(params) do
    if (v.del_id) then del_id = v.del_id end
    if (v.typ) then typ = v.typ end
    if (v.pass) then password = v.pass end
  end
end

local function deleteMethod(requestUrl, successCallback, errorCallback)
local http = net.HTTPClient()
http:request(requestUrl, {
options = {
method = 'DELETE',
headers = {
['Authorization']= 'Basic '..password
},
},
success = successCallback,
error = errorCallback
})
end

local IP = api.get('/settings/network')['ip']
local url = 'http://'..IP..'/api/service/backups/'..del_id
    
deleteMethod(url, function(resp)
    print('Status2: ' .. resp.status)
    print("Backup "..del_id.." deleted at " .. os.date())
    local data = json.decode(resp.data)
    if tonumber(resp.status) == 200 then
    doNotify('Backup '..del_id..' deleted at'.. os.date(), "info" )
    else
    doNotify('Backup '..del_id..' error '..resp.status..' at '..os.date(), "alert" )      
    end

  end, 
    
  function(err)
    print(del_id..' error2 ' .. err)
    doNotify('Backup '..del_id..' error '..err, "alert" )
  end
)
------==================
--   fibaro:sleep(45*1000)
  