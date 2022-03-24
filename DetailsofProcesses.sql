--Provides detailed overview of all running processes in a SQL Server.

-------Detailed_ver4
select c.session_id as spid,case when r.session_id is null then 'IA' else 'A' end as "?",
coalesce(object_name(t.objectid,sp.dbid) ,object_name(l.objectid,sp.dbid),l.text) sp,
SUBSTRING ( t.text,COALESCE (NULLIF(r.statement_start_offset/2, 0), 1),CASE r.statement_end_offset 
WHEN -1 THEN DATALENGTH(t.text)ELSE (r.statement_end_offset/2 - r.statement_start_offset/2)END)as exact_stmt,
coalesce(convert(varchar(12),getdate()-r.start_time,114),convert(varchar(12),last_request_end_time-last_request_start_time,114))  elapsedtime,
s.login_name,s.host_name,c.client_net_address as ip,s.program_name,coalesce(start_time,s.last_request_start_time) as start_time
,coalesce(r.status,s.status) as status,command,db_name(coalesce(t.dbid,sp.dbid)) dbname,coalesce(blocking_session_id,blocked) as "blk?",
wait_type,wait_time,last_wait_type,wait_resource,open_transaction_count as trcnt,r.cpu_time,
r.reads,r.writes,r.logical_reads as logrds,p.query_plan,r.percent_complete as "%",
dateadd(ms,r.estimated_completion_time,getdate())estimated_completion_time
--,cast((select db_name(resource_database_id)as dbname,resource_type,case resource_type when 'object' then 
--OBJECT_NAME(resource_associated_entity_id,resource_database_id)
--else cast(resource_associated_entity_id as varchar(max))+' '+cast(resource_description as varchar(max)) end as resourcename,
--request_mode,request_status from sys.dm_tran_locks
--where resource_type<>'database' and request_session_id=r.session_id
--for xml path('lock'),root('locks'))as xml) as locks
from (select distinct spid,dbid,blocked from sys.sysprocesses)sp join
sys.dm_exec_connections c on sp.spid=c.session_id join sys.dm_exec_sessions s on c.session_id=s.session_id
left outer join sys.dm_exec_requests r on s.session_id=r.session_id outer apply sys.dm_exec_sql_text(r.sql_handle) t 
outer apply sys.dm_exec_sql_text(c.most_recent_sql_handle) l
outer apply sys.dm_exec_query_plan(r.plan_handle) p where c.session_id>50 and c.session_id<>@@spid
and r.session_id is not null
order by 2,1
