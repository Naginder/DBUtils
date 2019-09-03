--Creates a script for user creation with permissions and bindings
--execute in text mode.

set nocount on
select 'use '+db_name()
select'--create user script'
select 'create user ['+u.name+']'+case when l.name is not null then 
 'for login ['+l.name+']' else ' without login ' end + case when default_schema_name is not null then  
'with default_schema=['+default_schema_name+']' else ''end collate database_default
from sys.database_principals u left outer join sys.server_principals l
on u.sid=l.sid --collate database_default
where u.name not in ('dbo','public','guest','information_schema','sys')
and u.type !='R'

select'--User Binding with Logins'
select 'exec sp_change_users_login ''update_one'','''+u.name+''','''+l.name+'''' collate database_default
from sys.database_principals u ,sys.server_principals l
where u.sid=l.sid
and u.name !='dbo'

select'--create roles script'
select 'Create role ['+name+'] Authorization ['+user_name(owning_principal_id)+']' from sys.database_principals where type='r' and principal_id!=0 and is_fixed_role=0

select'--database permissions for roles'
select case state when 'w' then 'Grant' else state_desc end +' '+permission_name+' to ['+user_name(grantee_principal_id)+']'+case state when 'w' then ' With Grant Option' else '' end from sys.database_permissions
where grantee_principal_id in
(select principal_id from sys.database_principals where type='r' and principal_id!=0 and is_fixed_role=0)
and class = 0

select '--schema permissions for roles'
select case state when 'w' then 'Grant' else state_desc end +' '+permission_name+' on schema::'+schema_name(major_id)+' to ['+user_name(grantee_principal_id)+']'+case state when 'w' then ' With Grant Option' else '' end
from sys.database_permissions
where grantee_principal_id in
(select principal_id from sys.database_principals where type='r' and principal_id!=0 and is_fixed_role=0)
and class = 3

select'--object level permissions for roles'
select case state when 'w' then 'GRANT' else state_desc end+' '+permission_name +' on ['+schema_name(objectproperty(major_id,'schemaid'))+'].['+object_name(major_id)+'] to ['+user_name(grantee_principal_id)+']'+case state when 'w' then ' With Grant Option' else '' end
from sys.database_permissions
where grantee_principal_id in
(select principal_id from sys.database_principals where type='r' and principal_id!=0 and is_fixed_role=0)
and class = 1
and minor_id =0

select'--column level permissions for roles'
select case state when 'w' then 'GRANT' else state_desc end +' '+permission_name+' on ['+schema_name(objectproperty(major_id,'schemaid'))+'].['+object_name(major_id)+'](['+col_name(major_id,minor_id)+']) to ['+
user_name(grantee_principal_id)+']'+case state when 'w' then ' With Grant Option' else '' end
from sys.database_permissions
where grantee_principal_id in
(select principal_id from sys.database_principals where type='r' and principal_id!=0 and is_fixed_role=0)
and class = 1
and minor_id !=0


select'--permissions script for users'

select'--database permissions'
select case state when 'w' then 'grant' else state_desc end+' '+permission_name+' to ['+user_name(grantee_principal_id)+']' +case state when 'w' then ' With Grant Option' else '' end from sys.database_permissions
where grantee_principal_id in
(
select principal_id from sys.database_principals
where name not in ('dbo','public','information_schema','sys','guest')
and type !='r')
and class = 0

select'--rolemembership'
select 'exec sp_addrolemember @rolename='''+u.name+''',@membername='''+user_name(member_principal_id)+''''
from sys.database_role_members,sys.sysusers u
where role_principal_id=u.uid
and member_principal_id!=user_id('dbo')

select '--schema permissions'
select case state when 'w' then 'grant' else state_desc end +' '+permission_name+' on schema::'+schema_name(major_id)+' to ['+user_name(grantee_principal_id)+']'+case state when 'w' then ' With Grant Option' else '' end
from sys.database_permissions
where grantee_principal_id in
(
select principal_id from sys.database_principals
where name not in ('dbo','public','information_schema','sys','guest')
and type !='r')
and class = 3

select'--object level permissions'
select case state when 'w' then 'GRANT' else state_desc end+' '+permission_name +' on ['+schema_name(objectproperty(major_id,'schemaid'))+'].['+object_name(major_id)+'] to ['+user_name(grantee_principal_id)+']'+case state when 'w' then ' With Grant Option' else '' end
from sys.database_permissions
where grantee_principal_id in
(
select principal_id from sys.database_principals
where name not in ('dbo','public','information_schema','sys','guest')
and type !='r')
and class = 1
and minor_id =0

select'--column level permissions'
select case state when 'w' then 'GRANT' else state_desc end +' '+permission_name+' on ['+schema_name(objectproperty(major_id,'schemaid'))+'].['+object_name(major_id)+'](['+col_name(major_id,minor_id)+']) to ['+
user_name(grantee_principal_id)+']'+case state when 'w' then ' With Grant Option' else '' end
from sys.database_permissions
where grantee_principal_id in
(
select principal_id from sys.database_principals
where name not in ('dbo','public','information_schema','sys','guest')
and type !='r')
and class = 1
and minor_id !=0


set nocount off

