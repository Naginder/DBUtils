Finds Duplicate Indexes (Exact or Partial) for a single database or server wide.

-- exact duplicates
with indexcols as
(
select id as id, indid as indid, name,
(select case keyno when 0 then NULL else colid end as [data()]
from sys.sysindexkeys as k
where k.id = i.id
and k.indid = i.indid
order by keyno, colid
for xml path('')) as cols,
(select case keyno when 0 then colid else NULL end as [data()]
from sys.sysindexkeys as k
where k.id = i.id
and k.indid = i.indid
order by colid
for xml path('')) as inc,reserved
from sys.sysindexes as i
)
select
object_schema_name(c1.id) + '.' + object_name(c1.id) as 'table',
c1.name as 'index',
c2.name as 'exactduplicate',c2.reserved*8/1024.00 as sizeMB
from indexcols as c1
join indexcols as c2
on c1.id = c2.id
and c1.indid < c2.indid
and c1.cols = c2.cols
and c1.inc = c2.inc
compute sum(c2.reserved*8/1024.00);

--Partial Duplicates
with indexcols as
(
select id as id, indid as indid, name,
(select case keyno when 0 then NULL else colid end as [data()]
from sys.sysindexkeys as k
where k.id = i.id
and k.indid = i.indid
order by keyno, colid
for xml path('')) as cols,reserved
from sys.sysindexes as i
)
select
object_schema_name(c1.id) + '.' + object_name(c1.id) as 'table',
c1.name as 'index',
c2.name as 'partialduplicate',c2.reserved*8/1024.00 as sizeMB
from indexcols as c1
join indexcols as c2
on c1.id = c2.id
and c1.indid < c2.indid
and (c1.cols like c2.cols + '%' 
or c2.cols like c1.cols + '%') ;



--server wide

create table #dupindex (dbname varchar(100),tblname varchar(200),indexname varchar(200),indid int,exactduplicate varchar(200),dupindid int,sizeMB float)

-- exact duplicates
exec sp_msforeachdb 'use [?];
with indexcols as
(
select id, indid, name,
(select case keyno when 0 then NULL else colid end as [data()]
from sys.sysindexkeys as k
where k.id = i.id
and k.indid = i.indid
order by keyno, colid
for xml path('''')) as cols,
(select case keyno when 0 then colid else NULL end as [data()]
from sys.sysindexkeys as k
where k.id = i.id
and k.indid = i.indid
order by colid
for xml path('''')) as inc,reserved
from sys.sysindexes as i where db_id()<>2
)
insert into #dupindex
select db_name() as dbname,
object_schema_name(c1.id) + ''.'' + object_name(c1.id) as ''table'',
c1.name as ''index'',c1.indid,
c2.name as ''exactduplicate'',c2.indid,case when c2.reserved<>0 then c2.reserved*8.00/1024 else c2.reserved end as sizeMB
from indexcols as c1
join indexcols as c2
on c1.id = c2.id
and c1.indid < c2.indid
and c1.cols = c2.cols
and c1.inc = c2.inc;'

select * from #dupindex
compute sum(sizeMB)

drop table #dupindex



-- Partial indexes

create table #dupindex (dbname varchar(100),tblname varchar(200),indexname varchar(200),partialduplicate varchar(200),sizeMB float)

exec sp_msforeachdb 'use [?];
with indexcols as
(
select id, indid, name,
(select case keyno when 0 then NULL else colid end as [data()]
from sys.sysindexkeys as k
where k.id = i.id
and k.indid = i.indid
order by keyno, colid
for xml path('''')) as cols,reserved
from sys.sysindexes as i
)
insert into #dupindex
select db_name() as dbname,
object_schema_name(c1.id) + ''.'' + object_name(c1.id) as ''table'',
c1.name as ''index'',
c2.name as ''partialduplicate'',case when c2.reserved<>0 then c2.reserved*8.00/1024 else c2.reserved end as sizeMB
from indexcols as c1
join indexcols as c2
on c1.id = c2.id
and c1.indid < c2.indid
and (c1.cols like c2.cols + ''%'' 
or c2.cols like c1.cols + ''%'') ;'

select * from #dupindex

drop table #dupindex
