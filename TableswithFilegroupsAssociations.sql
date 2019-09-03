--Script to find the Tables and the FileGroups they are associated with.

select OBJECT_NAME(si.id)as name,si.name as indexname,mf.name as filename,mf.physical_name,ds.name as filegroupname,au.type_desc,si.rowcnt,au.total_pages*8/1024.00 as sizeMb from
sys.sysindexes si join sys.partitions p on si.id=p.object_id and si.indid=p.index_id join sys.allocation_units au on p.partition_id=au.container_id
join sys.data_spaces ds on au.data_space_id=ds.data_space_id join sys.master_files mf on ds.data_space_id=mf.data_space_id
where si.id in (select object_id from sys.tables where is_ms_shipped=0)
and mf.database_id=DB_ID()
order by name




------------------for all db

select replicate(' ',100) as dbname,OBJECT_NAME(si.id)as name,si.name as indexname,mf.name as filename,mf.physical_name,ds.name as filegroupname,au.type_desc,si.rowcnt,au.total_pages*8/1024.00 as sizeMb into #temp1 from
sys.sysindexes si join sys.partitions p on si.id=p.object_id and si.indid=p.index_id join sys.allocation_units au on p.partition_id=au.container_id
join sys.data_spaces ds on au.data_space_id=ds.data_space_id join sys.master_files mf on ds.data_space_id=mf.data_space_id
where 1=2

exec sp_msforeachdb 'use [?]
insert into #temp1
select ''?'',OBJECT_NAME(si.id)as name,si.name as indexname,mf.name as filename,mf.physical_name,ds.name as filegroupname,au.type_desc,si.rowcnt,au.total_pages*8/1024.00 as sizeMb from
sys.sysindexes si join sys.partitions p on si.id=p.object_id and si.indid=p.index_id join sys.allocation_units au on p.partition_id=au.container_id
join sys.data_spaces ds on au.data_space_id=ds.data_space_id join sys.master_files mf on ds.data_space_id=mf.data_space_id
where si.id in (select object_id from sys.tables where is_ms_shipped=0)
and mf.database_id=DB_ID() and db_id(''?'') <>2
order by name'

select * from #temp1

drop table #temp1
