DROP TABLE IF EXISTS ##Tiempos_ejecucion;

	CREATE TABLE ##Tiempos_ejecucion (session_id varchar (100) NULL,
    host varchar (100) Null,
    loginame varchar (100) Null,
    status varchar (100) Null,
    blk_by varchar (100) Null,
    DatabaseName varchar (100) Null,
    Individual_Query text Null,
    Parent_Query text Null,
    Program_Name varchar (100) Null,
    Tiempo_Ejecucion_Minutos varchar(100) Null);


 insert into ##Tiempos_ejecucion   
 Select es.session_id, es.host_name, es.login_name, er.status, er.blocking_session_id [blk_by]   ,
    DB_NAME(es.database_id) AS DatabaseName, Substring (qt.text,(er.statement_start_offset/2) + 1,    
    ((Case When er.statement_end_offset = -1 Then Len(Convert(Nvarchar(Max), qt.text)) * 2  Else er.statement_end_offset  End - er.statement_start_offset)/2) + 1) As Individual_Query,
    qt.text AS Parent_Query, es.program_name, DATEDIFF(MINUTE,er.start_time,(SYSDATETIME())) as Tiempo_ejecucion_minutos
From        sys.dm_exec_requests er   
left join   sys.dm_exec_sessions es 
On          es.session_id = er.session_id  
Cross Apply sys.dm_exec_sql_text  (er.sql_handle)  qt   
Cross Apply sys.dm_exec_query_plan(er.plan_handle) qp  
Where /es.is_user_process = 0  AND/ es.session_Id Not In (@@SPID) and login_name not like ('%rhinmonitor%') and program_name  not like ('%DatabaseMail%') and DATEDIFF(MINUTE,er.start_time,(SYSDATETIME())) > 3
Order By Tiempo_ejecucion_minutos

EXEC xp_cmdshell 'bcp "select * from ##Tiempos_ejecucion" queryout "C:\sysadmin\dba\monitor_rendimiento\log_tiempos_ejecucion.txt" -d tempdb -T -c -t,'

if exists (select * from ##Tiempos_ejecucion)
     Begin
     EXEC msdb.dbo.sp_send_dbmail
          @profile_name = 'Alerts_Altas_Masivas',
          @recipients = 'francisco.genel@3ti.mx;carlos.ramo@3ti.mx',
          @subject = 'Correo Tiempos de ejecucion server 27',
          @body = N'Si recibes este mail, revisar de inmediato',
          @file_attachments = 'C:\sysadmin\dba\monitor_rendimiento\log_tiempos_ejecucion.txt'
     END