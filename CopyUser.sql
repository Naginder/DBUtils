--Creates a script which can be used to copy a single user specified, along with permissions and access granted from one sql server
set nocount on
declare @username varchar(100)
Set @username='crystaluser'
if exists(select 1 from sys.database_principals where name=@username)
begin
select'--create user script for '+@username
select 'create user ['+u.name+'] for login ['+l.name+case when default_schema_name is not null then '] with default_schema=['+default_schema_name+']' else ']'end collate database_default
from sys.database_principals u ,sys.server_principals l
where u.sid=l.sid and u.name =@username

select'--permissions script for '+@username

select'--database permissions'
select case state when 'w' then 'grant' else state_desc end +' '+permission_name+' to ['+user_name(grantee_principal_id)+']'+case state when 'w' then ' With Grant Option' else '' end from sys.database_permissions
where grantee_principal_id in
(
select principal_id from sys.database_principals
where name =@username)
and class = 0

select'--rolemembership'
select 'exec sp_addrolemember @rolename='''+u.name+''',@membername='''+user_name(member_principal_id)+''''
from sys.database_role_members,sys.sysusers u
where role_principal_id=u.uid
and member_principal_id=user_id(@username)

select '--schema permissions'
select case state when 'w' then 'grant' else state_desc end +' '+permission_name+' on schema::'+schema_name(major_id)+' to ['+user_name(grantee_principal_id)+']'+case state when 'w' then ' With Grant Option' else '' end
from sys.database_permissions
where grantee_principal_id in
(
select principal_id from sys.database_principals
where name = @username)
and class = 3

select'--object level permissions'
select case state when 'w' then 'GRANT' else state_desc end+' '+permission_name +' on ['+schema_name(objectproperty(major_id,'schemaid'))+'].['+object_name(major_id)+'] to ['+user_name(grantee_principal_id)+']'+case state when 'w' then ' With Grant Option' else '' end
from sys.database_permissions
where grantee_principal_id in
(
select principal_id from sys.database_principals
where name = @username)
and class = 1
and minor_id =0

select'--column level permissions'
select case state when 'w' then 'GRANT' else state_desc end +' '+permission_name+' on ['+schema_name(objectproperty(major_id,'schemaid'))+'].['+object_name(major_id)+'](['+col_name(major_id,minor_id)+']) to ['+
user_name(grantee_principal_id)+']'+case state when 'w' then ' With Grant Option' else '' end
from sys.database_permissions
where grantee_principal_id in
(
select principal_id from sys.database_principals
where name = @username)
and class = 1
and minor_id !=0


set nocount off

end
else
begin
print 'no such user found '+@username
end
