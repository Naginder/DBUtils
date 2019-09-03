--Find the average run time of each SQL Agent Jobs.

select sj.name,sjh.message,sjh.run_status,sjh.run_date,sjh.run_time,sjh.run_duration,round(ajt.average_run_duration,2)avg_run_duration
from msdb..sysjobhistory sjh left join
(select job_id,avg(cast (run_duration as float))as average_run_duration from msdb..sysjobhistory 
where step_id=0
group by job_id
)ajt on sjh.job_id=ajt.job_id
join msdb..sysjobs sj on sj.job_id=sjh.job_id
where step_id=0 and instance_id in (select max(instance_id) from msdb..sysjobhistory
group by job_id)
--comment next line to see all jobs else only the jobs which have run yesterday
and sjh.run_date >CONVERT(varchar(8),GETDATE()-1,112)
order by name
