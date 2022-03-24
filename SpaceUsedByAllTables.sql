--Script to find space used by all the tables in all the databases in sql server.


-------------------for a single database
select OBJECT_NAME(object_id)as name,sum(reserved_page_count*8192.00/1073741824) as "size(gb)",
sum(case when (index_id > 1) then 0 else row_count end)as rows
from sys.dm_db_partition_stats where object_id in (select object_id from sys.objects where type='u' and is_ms_shipped=0) 
--and reserved_page_count>1000
group by object_name(object_id)
order by "size(gb)" desc

------------------------for all database
select db_name() as dbname,OBJECT_NAME(object_id)as name,sum(reserved_page_count*8192/1048576) as "size(gb)",
sum(case when (index_id > 1) then 0 else row_count end)as rows,
convert(varchar(100),GETDATE(),100) as sampledatetime 
into #tabledtls
from sys.dm_db_partition_stats where  1=2
group by OBJECT_NAME(object_id)

exec sp_msforeachdb 'use [?]
insert into #tabledtls
select db_name() as dbname,OBJECT_NAME(object_id)as name,sum(reserved_page_count*8192/1048576) as "size(gb)",sum(case when (index_id > 1) then 0 else row_count end)as rows,
convert(varchar(100),GETDATE(),100) as sampledatetime 
from sys.dm_db_partition_stats where object_id in (select object_id from sys.objects where type=''u'' and is_ms_shipped=0) 
and db_name() not in (''tempdb'',''model'',''ReportServer'',''ReportServerTempDB'',''ASPState'',''EventNotifications'',''dba_admin'',''master'',''msdb'')
group by OBJECT_NAME(object_id)'

select * from #tabledtls 
--where [size(gb)]>1000
order by "size(gb)" desc
drop table #tabledtls

  
