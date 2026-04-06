select 
* from msdb.dbo.sysmail_allitems
order by mailitem_id desc

--delete from msdb.dbo.sysmail_allitems where recipients like '%correa%'