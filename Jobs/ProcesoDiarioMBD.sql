USE [msdb]
GO

/****** Object:  Job [ProcesoDiarioMBD]    Script Date: 19/05/2022 10:11:15 a. m. ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 19/05/2022 10:11:15 a. m. ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ProcesoDiarioMBD', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Proceso Diario de Validación y Mantenimiento de BD', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Paso 1]    Script Date: 19/05/2022 10:11:16 a. m. ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Paso 1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Declare      
   @PnEstatus               Integer      = 0,
   @PsMensaje               Varchar(250) = Null

Begin
   Execute dbo.Spp_validaTiempoProcesos @PnEstatus      = @PnEstatus     Output,
                                        @PsMensaje      = @PsMensaje     Output;

   Select @PnEstatus, @PsMensaje
   
   Return

End
Go', 
		@database_name=N'SCMBD', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Paso 2]    Script Date: 19/05/2022 10:11:16 a. m. ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Paso 2', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Declare
   @PnEstatus      Integer      = Null,
   @PsMensaje      Varchar(250) = Null,
   @w_idProceso    Integer      = 0;

Begin
   Execute dbo.Spp_AnalisisLinkServer @PnEstatus = @PnEstatus Output,
                                      @PsMensaje = @PsMensaje Output;

   Return
End
Go', 
		@database_name=N'SCMBD', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Paso 3]    Script Date: 19/05/2022 10:11:16 a. m. ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Paso 3', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Declare
   @PnEstatus       Integer      = Null,
   @PsMensaje      Varchar(250) = Null,
   @w_idProceso    Integer      = 0;

Begin

   Execute dbo.Spp_AnalisisJobsNoEjecutados @PnEstatus = @PnEstatus Output,
                                            @PsMensaje = @PsMensaje Output;

   Return
End
Go', 
		@database_name=N'SCMBD', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Paso 4]    Script Date: 19/05/2022 10:11:16 a. m. ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Paso 4', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Declare
   @PnEstatus      Integer      = Null,
   @PsMensaje      Varchar(250) = Null

Begin

   Execute dbo.Spp_ValidaServicioProcesosRhin @PnEstatus = @PnEstatus Output,
                                              @PsMensaje = @PsMensaje Output;

   Return
End
Go', 
		@database_name=N'SCMBD', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Paso 5]    Script Date: 19/05/2022 10:11:16 a. m. ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Paso 5', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Declare
   @PsMensaje           Varchar(250) = Null,
   @w_idProceso         Integer      = 0,
   @PnEstatus             Integer      = 0

Begin

   Execute Spp_ValidaServicioCorreos @PnEstatus = @PnEstatus Output,
                                     @PsMensaje = @PsMensaje Output

   Return

End
Go', 
		@database_name=N'SCMBD', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Paso 6]    Script Date: 19/05/2022 10:11:16 a. m. ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Paso 6', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Declare
   @PnEstatus             Integer      = 0,  
   @PsMensaje             Varchar(250) = Null;

Begin

   Execute Spp_ValidaServicioNotPush @PnEstatus = @PnEstatus Output,
                                     @PsMensaje = @PsMensaje Output

   Return

End
Go ', 
		@database_name=N'SCMBD', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Paso 7]    Script Date: 19/05/2022 10:11:16 a. m. ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Paso 7', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Declare      
   @PnEstatus               Integer      = 0,
   @PsMensaje               Varchar(250) = Null

Begin
   Execute dbo.Spp_validaBloqueos @PnEstatus = @PnEstatus     Output,
                                  @PsMensaje = @PsMensaje     Output;

   Return

End', 
		@database_name=N'SCMBD', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Solicita Notificaciones]    Script Date: 19/05/2022 10:11:16 a. m. ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Solicita Notificaciones', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Declare
   @PdFechaProceso        Date         = Null,
   @PsIdProceso           Varchar(250) = ''3, 4, 14,  15, 16'',
   @PnEstatus             Integer      = 0,  
   @PsMensaje             Varchar(250) = Null;

Begin
   Execute Spp_SolicitaCorreoMasivoMantBD @PdFechaProceso = @PdFechaProceso,
                                          @PsIdProceso    = @PsIdProceso,
                                          @PnEstatus      = @PnEstatus Output,
                                          @PsMensaje      = @PsMensaje Output

   Select @PnEstatus, @PsMensaje

   Return

End
Go ', 
		@database_name=N'SCMBD', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Paso 1', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=4, 
		@freq_subday_interval=3, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20211001, 
		@active_end_date=99991231, 
		@active_start_time=80000, 
		@active_end_time=195959, 
		@schedule_uid=N'b8b79644-ce7f-4d9d-87b9-98524a7340e8'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

