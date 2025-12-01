Use SCMBD
Go


/*
Declare
   @PnEstatus      Integer      = Null,
   @PsMensaje      Varchar(250) = Null,
   @w_idProceso    Integer      = 0;

Begin
   Select @w_idProceso = Max(idProceso)
   From   SMBDTI.dbo.logAnalisisJobsTbl

   Execute dbo.Spp_AnalisisJobsNoEjecutados @PnEstatus = @PnEstatus Output,
                                            @PsMensaje = @PsMensaje Output;

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

   Select *
   From   SMBDTI.dbo.logAnalisisJobsTbl
   Where  idProceso > Isnull(@w_idProceso, 0);

   Return
End
Go


*/

Create  Or Alter Procedure dbo.Spp_AnalisisJobsNoEjecutados
  (@PdFechaProceso Date         = Null,
   @PnEstatus      Integer      = Null Output,
   @PsMensaje      Varchar(250) = Null Output)
As

Declare
   @w_error             Integer,
   @w_desc_error        Varchar(  250),
   @w_fechaAct          Datetime,
   @w_fecha             Integer,
   @w_sql               Varchar(Max),
   @w_comilla           Char(1),
   @w_registros         Integer,
   @w_linea             Integer;

Begin
/*

Objetivo:    Procedimiento de Validación de Jobs No Ejecutados.
Programador: Pedro Felipe Zambrano
Fecha:       06/05/2022

*/

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    On

   Select @PnEstatus        = 0,
          @PsMensaje        = Null,
          @w_fechaAct       = Getdate(),
          @w_comilla        = Char(39),
          @PdFechaProceso   = Isnull(@PdFechaProceso, @w_fechaAct),
          @w_fecha          = Cast(Convert(Char(10), @PdFechaProceso, 112) As Integer);

  Create Table #TempJobs
  ( instance_id        Integer          Null,
    job_id             Uniqueidentifier Null,
    job_name           Sysname          Null,
    step_id            Integer          Null,
    step_name          Sysname          Null,
    sql_message_id     Integer          Null,
    sql_severity       Integer          Null,
    message            Nvarchar(4000)   Null,
    run_status         Integer          Null,
    run_date           Integer          Null,
    run_time           Integer          Null,
    run_duration       Integer          Null,
    operator_emailed   Sysname          Null,
    operator_netsent   Sysname          Null,
    operator_paged     Sysname          Null,
    retries_attempted  Integer          Null,
    server             Sysname          Null);

   Begin Try
      Update catControlProcesosTbl
      Set    ultFechaEjecucion = Getdate()
      Where  idProceso         = 12;
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)

   End   Catch

   If IsNull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

         Set Xact_Abort    Off
         Return
      End

    Set @w_sql = Concat('msdb.dbo.sp_help_jobhistory @start_run_date = ', @w_comilla, @w_fecha, @w_comilla, ', ',
                                                    '@mode           = ', @w_comilla, 'FULL',        @w_comilla,  ', ',
                                                    '@run_status     = 0')

    Begin Try
      Insert into #TempJobs
      Execute ( @w_sql);
      Set @w_registros = @@Rowcount
    End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230),
              @w_linea      = error_line()

   End   Catch

   If IsNull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' En Línea ', @w_linea);

      End
      
    If @w_registros = 0
       Begin
          Set Xact_Abort    Off
          Return
       End

    Select server         server,
           sql_message_id idError,
           message        mensajeError,
           job_name       Job,
           step_id        paso,
           step_name      nombrePaso,
           Case run_date When 0
                Then ''
                Else
                   Convert(Datetime,
                     stuff(stuff(cast(run_date as Nchar(8)), 7, 0, '-'), 5, 0, '-') + N' ' +
                     stuff(stuff(substring(cast(1000000 + run_time as nchar(7)), 2, 6), 5, 0, ':'), 3, 0, ':'),
                           120)
           End horaFechaEjecucion
    Into  #TempJobsSal
    From  #TempJobs
    Where sql_message_id != 0
    If @@Rowcount = 0
       Begin
          Set Xact_Abort    Off
          Return
       End

   Insert into dbo.logAnalisisJobsTbl
    (servidor, Job, idPaso, nombrePaso,    fechaInicio,
     error,    mensajeError)
    Select server,  Job, paso, nombrePaso, horaFechaEjecucion,
           idError, mensajeError
    From   #TempJobsSal a
    Where  idError != 0
    And    Not Exists ( Select Top 1 1
                        From   dbo.logAnalisisJobsTbl
                        Where  servidor                    = a.server
                        And    Job                         = a.Job
                        And    idPaso                      = a.paso
                        And    Cast(fechaInicio As date)   = Cast(a.horaFechaEjecucion As Date))

   Set Xact_Abort    Off
   Return

End
Go

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Validación de Jobs No Ejecutados.',
   @w_procedimiento  NVarchar(250) = 'Spp_AnalisisJobsNoEjecutados';

If Not Exists (Select Top 1 1
               From   sys.extended_properties a
               Join   sysobjects  b
               On     b.xtype   = 'P'
               And    b.name    = @w_procedimiento
               And    b.id      = a.major_id)
   Begin
      Execute  sp_addextendedproperty @name       = N'MS_Description',
                                      @value      = @w_valor,
                                      @level0type = 'Schema',
                                      @level0name = N'dbo',
                                      @level1type = 'Procedure',
                                      @level1name = @w_procedimiento

   End
Else
   Begin
      Execute sp_updateextendedproperty @name       = 'MS_Description',
                                        @value      = @w_valor,
                                        @level0type = 'Schema',
                                        @level0name = N'dbo',
                                        @level1type = 'Procedure',
                                        @level1name = @w_procedimiento
   End
Go
