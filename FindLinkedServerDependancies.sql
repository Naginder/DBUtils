Script to find linked servers dependancies in sql server wide or database wide, their usage in a job or SP.

--Server Level
--finds all linked servers
select server_id as srvid,name as depobjname into #linkedservers from sys.servers where server_id<>0 and name<>'repl_distributor'

--create table to hold the parent modules
create table #dependantmodules (dmid int identity,dbid smallint,dbname nvarchar(128),objname nvarchar(128),id int,proctext nvarchar(max),depobjname nvarchar(128),)

exec sp_MSforeachdb 'use [?]
--gets all parents dependant on linked servers
--insert into #dependantmodules
--select db_id() as dbid,db_name() as dbname,object_name(id) as objname,id,OBJECT_DEFINITION(id) as proctext,depobjname
--	from sys.syscomments c cross join #linkedservers l where id>0 and colid=1 and CHARINDEX(l.depobjname collate database_default,c.text,0)>0
--gets all childs dependant on parents for n recursions
;with parents as
(
--select dbid,dbname,objname,id,proctext,depobjname,null as depobjid from #dependantmodules where dbid=db_id()
select db_id() as dbid,db_name() as dbname,object_name(id) as objname,id,OBJECT_DEFINITION(id) as proctext,depobjname collate database_default as depobjname,null as depobjid
	from sys.syscomments c cross join #linkedservers l where id>0 and colid=1 and 
	(CHARINDEX(('' ''+l.depobjname collate database_default)+''.'',c.text,0)>0 or CHARINDEX((''[''+l.depobjname collate database_default)+'']'',c.text,0)>0)
union all
select db_id() as dbid,db_name() as dbname,object_name(referencing_id) objname,referencing_id as object_id,OBJECT_DEFINITION(referencing_id) as text,
OBJECT_NAME(referenced_id) as depobjname,referenced_id from sys.sql_expression_dependencies s inner join parents p on referenced_id=id and dbid=db_id()
) 
insert into #dependantmodules
select dbid,dbname,objname,id,proctext,depobjname from parents
option(MAXRECURSION 365)'

--get list of jobs having code based linked server access
insert into #dependantmodules
select db_id() as dbid,db_name() as dbname,(select 'job '+name from msdb..sysjobs where job_id=j.job_id)+' '+j.step_name,null as id,command,l.depobjname from msdb..sysjobsteps j 
cross join #linkedservers l where charindex((' '+l.depobjname collate database_default)+'.',command,0)>0 or charindex(('['+l.depobjname collate database_default)+']',command,0)>0

--displays dependancy
select dmid,dbname,objname,depobjname,proctext from #dependantmodules
	order by depobjname

--shows unused linkedservers
select distinct l.depobjname as linkedservers,case when d.depobjname is null then 'unused' else 'used' end as usage 
from #linkedservers l left outer join #dependantmodules d on l.depobjname=d.depobjname

--cleanup
drop table #dependantmodules
drop table #linkedservers


--DB Level
--finds all linked servers
select server_id as srvid,name as depobjname into #linkedservers from sys.servers where server_id<>0 and name<>'repl_distributor'

--create table to hold the parent modules
create table #dependantmodules (dmid int identity,dbid smallint,dbname nvarchar(128),objname nvarchar(128),id int,proctext nvarchar(max),depobjname nvarchar(128),)


--gets all parents dependant on linked servers
--insert into #dependantmodules
--select db_id() as dbid,db_name() as dbname,object_name(id) as objname,id,OBJECT_DEFINITION(id) as proctext,depobjname
--	from sys.syscomments c cross join #linkedservers l where id>0 and colid=1 and CHARINDEX(l.depobjname collate database_default,c.text,0)>0
--gets all childs dependant on parents for n recursions
;with parents as
(
--select dbid,dbname,objname,id,proctext,depobjname,null as depobjid from #dependantmodules where dbid=db_id()
select db_id() as dbid,db_name() as dbname,object_name(id) as objname,id,OBJECT_DEFINITION(id) as proctext,depobjname collate database_default as depobjname,null as depobjid
	from sys.syscomments c cross join #linkedservers l where id>0 and colid=1 and 
	(CHARINDEX((' '+l.depobjname collate database_default)+'.',c.text,0)>0 or CHARINDEX(('['+l.depobjname collate database_default)+']',c.text,0)>0)
union all
select db_id() as dbid,db_name() as dbname,object_name(referencing_id) objname,referencing_id as object_id,OBJECT_DEFINITION(referencing_id) as text,
OBJECT_NAME(referenced_id) as depobjname,referenced_id from sys.sql_expression_dependencies s inner join parents p on referenced_id=id and dbid=db_id()
) 
insert into #dependantmodules
select dbid,dbname,objname,id,proctext,depobjname from parents
option(MAXRECURSION 365)

--get list of jobs having code based linked server access
insert into #dependantmodules
select db_id() as dbid,db_name() as dbname,(select 'job '+name from msdb..sysjobs where job_id=j.job_id)+' '+j.step_name,null as id,command,l.depobjname from msdb..sysjobsteps j 
cross join #linkedservers l where charindex((' '+l.depobjname collate database_default)+'.',command,0)>0 or charindex(('['+l.depobjname collate database_default)+']',command,0)>0

--displays dependancy
select dmid,dbname,objname,depobjname,proctext from #dependantmodules
	order by dmid

--shows unused linkedservers
select l.depobjname as linkedservers,case when d.depobjname is null then 'unused' else 'used' end as usage 
from #linkedservers l left outer join #dependantmodules d on l.depobjname=d.depobjname

--cleanup
drop table #dependantmodules
drop table #linkedservers

--SQL 2005
--finds all linked servers
select server_id as srvid,name as depobjname into #linkedservers from sys.servers where server_id<>0 and name<>'repl_distributor'

--create table to hold the parent modules
create table #dependantmodules (dmid int identity,dbid smallint,dbname nvarchar(128),objname nvarchar(128),id int,proctext nvarchar(max),depobjname nvarchar(128),)

exec sp_MSforeachdb 'use [?]
--gets all parents dependant on linked servers
--insert into #dependantmodules
--select db_id() as dbid,db_name() as dbname,object_name(id) as objname,id,OBJECT_DEFINITION(id) as proctext,depobjname
--	from sys.syscomments c cross join #linkedservers l where id>0 and colid=1 and CHARINDEX(l.depobjname collate database_default,c.text,0)>0
--gets all childs dependant on parents for n recursions
;with parents as
(
--select dbid,dbname,objname,id,proctext,depobjname,null as depobjid from #dependantmodules where dbid=db_id()
select db_id() as dbid,db_name() as dbname,object_name(id) as objname,id,OBJECT_DEFINITION(id) as proctext,depobjname collate database_default as depobjname,null as depobjid
	from sys.syscomments c cross join #linkedservers l where id>0 and colid=1 and 
	(CHARINDEX(('' ''+l.depobjname collate database_default)+''.'',c.text,0)>0 or CHARINDEX((''[''+l.depobjname collate database_default)+'']'',c.text,0)>0)
union all
select db_id() as dbid,db_name() as dbname,object_name(s.object_id) objname,s.object_id,OBJECT_DEFINITION(s.object_id) as text,
OBJECT_NAME(referenced_major_id) as depobjname,referenced_major_id from sys.sql_dependencies s inner join parents p on referenced_major_id=id and dbid=db_id()
) 
insert into #dependantmodules
select dbid,dbname,objname,id,proctext,depobjname from parents
option(MAXRECURSION 365)'

--get list of jobs having code based linked server access
insert into #dependantmodules
select db_id() as dbid,db_name() as dbname,(select 'job '+name from msdb..sysjobs where job_id=j.job_id)+' '+j.step_name,null as id,command,l.depobjname from msdb..sysjobsteps j 
cross join #linkedservers l where charindex((' '+l.depobjname collate database_default)+'.',command,0)>0 or charindex(('['+l.depobjname collate database_default)+']',command,0)>0

--displays dependancy
select dmid,dbname,objname,depobjname,proctext from #dependantmodules
	order by dmid

--shows unused linkedservers
select l.depobjname as linkedservers,case when d.depobjname is null then 'unused' else 'used' end as usage 
from #linkedservers l left outer join #dependantmodules d on l.depobjname=d.depobjname

--cleanup
drop table #dependantmodules
drop table #linkedservers

--sql2005 db level
--finds all linked servers
select server_id as srvid,name as depobjname into #linkedservers from sys.servers where server_id<>0 and name<>'repl_distributor'

--create table to hold the parent modules
create table #dependantmodules (dmid int identity,dbid smallint,dbname nvarchar(128),objname nvarchar(128),id int,proctext nvarchar(max),depobjname nvarchar(128),)


--gets all parents dependant on linked servers
--insert into #dependantmodules
--select db_id() as dbid,db_name() as dbname,object_name(id) as objname,id,OBJECT_DEFINITION(id) as proctext,depobjname
--	from sys.syscomments c cross join #linkedservers l where id>0 and colid=1 and CHARINDEX(l.depobjname collate database_default,c.text,0)>0
--gets all childs dependant on parents for n recursions
;with parents as
(
--select dbid,dbname,objname,id,proctext,depobjname,null as depobjid from #dependantmodules where dbid=db_id()
select db_id() as dbid,db_name() as dbname,object_name(id) as objname,id,OBJECT_DEFINITION(id) as proctext,depobjname collate database_default as depobjname,null as depobjid
	from sys.syscomments c cross join #linkedservers l where id>0 and colid=1 and 
	(CHARINDEX((' '+l.depobjname collate database_default)+'.',c.text,0)>0 or CHARINDEX(('['+l.depobjname collate database_default)+']',c.text,0)>0)
union all
select db_id() as dbid,db_name() as dbname,object_name(s.object_id) objname,s.object_id,OBJECT_DEFINITION(s.object_id) as text,
OBJECT_NAME(referenced_major_id) as depobjname,referenced_major_id from sys.sql_dependencies s inner join parents p on referenced_major_id=id and dbid=db_id()
) 
insert into #dependantmodules
select dbid,dbname,objname,id,proctext,depobjname from parents
option(MAXRECURSION 365)

--get list of jobs having code based linked server access
insert into #dependantmodules
select db_id() as dbid,db_name() as dbname,(select 'job '+name from msdb..sysjobs where job_id=j.job_id)+' '+j.step_name,null as id,command,l.depobjname from msdb..sysjobsteps j 
cross join #linkedservers l where charindex((' '+l.depobjname collate database_default)+'.',command,0)>0 or charindex(('['+l.depobjname collate database_default)+']',command,0)>0

--displays dependancy
select dmid,dbname,objname,depobjname,proctext from #dependantmodules
	order by dmid

--shows unused linkedservers
select l.depobjname as linkedservers,case when d.depobjname is null then 'unused' else 'used' end as usage 
from #linkedservers l left outer join #dependantmodules d on l.depobjname=d.depobjname

--cleanup
drop table #dependantmodules
drop table #linkedservers
