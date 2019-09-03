--This Script provides list of all Databases and the size of the database files with the space used within each.

--database list
create table #dblist(servername varchar(100),dbname varchar(100))
insert into #dblist
exec sp_msforeachdb 'select @@servername,''[?]'''
--delete from #dblist where dbname in('model')
--select * from #dblist
--db file list
create table #dbfilelist(dbname varchar(100),name varchar(100),filename varchar(1000),Maxsize float)
insert into #dbfilelist
exec sp_msforeachdb 'select ''[?]'',name,filename,maxsize from sys.sysaltfiles where dbid=db_id(''?'')' --and name not in (''model'')'
--select * from #dbfilelist
--join the two & show result
create table #serverdbdtls(servername varchar(100),dbname varchar(100),name varchar(100),filename varchar(1000),Maxsize float)
insert into #serverdbdtls
select d.servername,d.dbname,f.name,f.filename,f.maxsize from #dblist d join #dbfilelist f on d.dbname=f.dbname 
--db file stats for mdf files
create table #dbfilestats(fileid int,filegroup int,totalextents float,usedextents float,name varchar(100),filename varchar(1000))
insert into #dbfilestats
exec sp_msforeachdb 'use [?] dbcc showfilestats'
alter table #serverdbdtls add [filesize(mb)] float,[spaceleft(mb)] float
update #serverdbdtls set [filesize(mb)] =(dfs.totalextents*64)/1024 ,
[spaceleft(mb)] =((dfs.totalextents-dfs.usedextents)*64)/1024
from #dbfilestats dfs where #serverdbdtls.filename=dfs.filename
--logspace for ldf files
create table #dblogspace(dbname varchar(100),logsize float,logspaceused float,status int)
insert into #dblogspace exec('dbcc sqlperf(logspace)')
--select * from #dblogspace
update #serverdbdtls set [filesize(mb)]=(dls.logsize),[spaceleft(mb)]=((100-dls.logspaceused)*dls.logsize)/100
from #dblogspace dls where replace(replace(#serverdbdtls.dbname,'[',''),']','')=dls.dbname and
#serverdbdtls.filename like'%.ldf%'
--select replace(replace(#serverdbdtls.dbname,'[',''),']','') from #serverdbdtls
--show the final data
select servername,replace(replace(#serverdbdtls.dbname,'[',''),']','') as database_name,name,filename,
round([filesize(mb)],2)Filesize_in_Mb,round([spaceleft(mb)],2) as spaceleft_in_Mb,"%spaceleft"=round(([spaceleft(mb)]/[filesize(mb)])*100,2),case maxsize when -1 then -1 when 0 then 0 else maxsize*8/1024 end as maxsize_in_mb from #serverdbdtls
--drop temp tables
drop table #dblist
drop table #dbfilelist
drop table #dbfilestats
drop table #dblogspace
drop table #serverdbdtls
