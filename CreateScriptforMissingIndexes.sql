--Generates create scripts for all missing indexes in a Database.



select 'create nonclustered index ncx_'+object_name(object_id)+'_'
+replace(replace(replace(equality_columns+ISNULL('_'+inequality_Columns,''),', ','_'),'[',''),']','')+' on '
+replace(statement,'['+db_name()+'].','')+'('+equality_columns+ISNULL(','+inequality_columns,'')+')'
+isnull(' include ('+included_columns+')','') CreateScript
,statement, equality_columns,inequality_columns,included_columns,avg_user_impact,last_user_seek,last_user_scan,
avg_total_user_cost,user_seeks,user_scans,unique_compiles
from sys.dm_db_missing_index_group_stats gs
join sys.dm_db_missing_index_groups g on gs.group_handle=g.index_group_handle
join sys.dm_db_missing_index_details id on id.index_handle=g.index_handle
where database_id=DB_ID() and equality_columns is not null
order by cast(last_user_seek as DATE) desc,user_seeks desc,avg_user_impact desc
