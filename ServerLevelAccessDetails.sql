--Find details of users and their access across the server - SQL Server


--all the logins
select sp.name,sp.create_date,sp.modify_date,sp.type_desc,case sp.is_disabled when 0 then 'enabled' else 'disabled' end status,
sl.is_policy_checked,is_expiration_checked
from sys.server_principals sp left outer join sys.sql_logins sl on sp.principal_id=sl.principal_id 
where sp.type in ('s','g','u') and sp.name not like '##%'

--server level role memberships
exec sp_helpsrvrolemember

--all logins access to databases
exec sp_helplogins

--database role memberships
exec sp_msforeachdb 'use [?]
select ''?'' as dbname,USER_NAME(role_principal_id) rolename,USER_NAME(member_principal_id) username from sys.database_role_members where member_principal_id !=1'

--access on object level to users
exec sp_msforeachdb 'use [?]
select ''?'',OBJECT_NAME(major_id)objectname,USER_NAME(grantee_principal_id)username,permission_name,state_desc from sys.database_permissions
where class in (1,3) and major_id>0'
