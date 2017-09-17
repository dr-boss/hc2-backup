# hc2-backup
automotive backup, restore configuration of Fibaro HC2
I need my modification  because of many (biggest or smallest)  problem each  time when I upgrade HC2 with new firmware. And the problem not happen direct after upgrade, but  hours or days after (like my last problem with corrupt z-wave databases or 503 error after restart) .

For restore backup when I have 503 error without chance to login I use REST client for POST http://HC2IP/api/service/backups/ with payload {"action":"restore","params":{"id":928}}. "id" I take form GET http://HC2IP/api/service/backups

 

Functions:

1. Autodelete only autobackup (created by backup_store.lua scene)

2. Autodelete no oldest backup but delete backups by days from today.

Note: Scenes not use any variables stored in HC2, they parse data by backup destricption

 

In backup-create.lua you have this parameters:

backup_symbol = '!' -- this symbol is added on beginning of description on backup time. Scenes use this for identify autobackup and for not delete manual or upgrade time backups without this symbol (in example on attached printscreen I use ‘p’ on place of '!')

 

backup_stay = '025' -- days for store backup from 001 to 999 days (obligatory with loading zeros). When for ex. you change this parameters for 1 backup from 030 to 025 and after this return to 030, only this one have different store time from another backups.

 

In backup-delete.lua

backup_symbol = '!' -- most important to be same to backup_symbol defined in backup_store.lua

 

default_stay = 'no' -- use individual backup store time from description. Set 'yes' if you decide to ignore individual time to store backup defined in backup__store.lua and registered in backup description

 

backup_stay = '030' -- if you decide to set default_stay to 'yes' backup_delete.lua use this for check number of day after witch the backup will be delete. The backup_delete.lua use this parameter too for backup with description who start by '!' but without [NNN] for number of store day (ex. for temporary backup created manually, they be delete after this number of day)

 

Structure of backup description used by scenes:

![025] any character/any text

! - first symbol identify backup created and used by scenes, obligatory for treatment by this two scenes

[025] - number of days for store backup, not obligatory, if not exist the backup_stay defined in backup_delete.lua are used.


After confirmation from Fibaro Support that "httpClient:request(url..." blocks handle until the scene is over not to end of called http work and /api/service/backups/'..id  can only be launched once at the same time. Therefore, to delete more than one file, you must call the external scene who delete backups

In this case I updated code of backup-delete.lua and added backup-batch. All necessary parameters are passed automatically to backup-batch.lua, You only need edit parameters in backup-create.lua and backup-delete.lua.

I added for batch process NotificationService with popups on web page like in situation with to many scenes run at same time 
