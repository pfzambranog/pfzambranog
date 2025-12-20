Use SCMBD
Go

/*
Declare
   @w_idProceso    Integer,
   @PnEstatus      Integer      = Null,
   @PsMensaje      Varchar(250) = Null;

Begin
   Select @w_idProceso = Max(idProceso)
   From   SCMBD.dbo.logAnalisisJobsTbl

   Execute dbo.Spp_AnalisisJobsNoEjecutados @PnEstatus = @PnEstatus Output,
                                            @PsMensaje = @PsMensaje Output;

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

   Select *
   From   SCMBD.dbo.logAnalisisJobsTbl
   Where  idProceso > Isnull(@w_idProceso, 0);

   Return
End
Go


*/

Create Or Alter Procedure dbo.Spp_AnalisisJobsNoEjecutados
  (@PnEstatus                  Integer      = Null Output,
   @PsMensaje                  Varchar(250) = Null Output)
As

Declare
   @w_error                    Integer,
   @w_fecha                    Integer,
   @w_registros                Integer,
   @w_linea                    Integer,
   @w_secuencia                Integer,
   @w_idGrupo                  Integer,
   @w_idMotivoCorreo           Integer,
   @w_idUsuarioAct             Integer,
   @w_idAplicacion             Integer,
   @w_idEstatus                Tinyint,
   @w_idTipoNotificacion       Tinyint,
   @w_idProceso                Integer,
   @w_fechaAct                 Datetime,
   @w_desc_error               Varchar( 220),
   @w_parametros               Varchar( Max),
   @w_usuario                  Varchar( Max),
   @w_mensaje                  Varchar( Max),
   @w_idSession                Varchar(  64),
   @w_proceso                  Varchar(  100),
   @w_ip                       Varchar(  30),
   @w_grupoCorreo              Varchar(  20),
   @w_sql                      NVarchar(1500),
   @w_param                    NVarchar( 750),
   @w_comilla                  Char(1),
   @w_account_name             Sysname,
   @w_basedatos                Sysname,
   @w_tablaLog                 Sysname,
   @w_servidor                 Sysname,
   @w_instancia                Sysname,
   @w_ambiente                 Sysname;

Begin

-- Objetivo:    Procedimiento de Validación de Jobs No Ejecutados.
-- Programador: Pedro Felipe Zambrano
-- Fecha:       06/05/2025

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    On

--
-- Inicializamos Variables
--

   Select @PnEstatus            = 0,
          @PsMensaje            = '',
          @w_secuencia          = 0,
          @w_idMotivoCorreo     = 105,
          @w_comilla            = Char(39),
          @w_baseDatos          = Db_name(),
          @w_fechaAct           = Getdate(),
          @w_fecha              = Cast(Convert(Char(10), @w_fechaAct, 112) As Integer),
          @w_servidor           = @@ServerName,
          @w_instancia          = @@servicename,
          @w_idAplicacion       = 27,
          @w_ip                 = dbo.Fn_buscaDireccionIP();

   Select @w_ip = Replace(@w_ip, '(', ''),
          @w_ip = Replace(@w_ip, ')', '');

   If @w_servidor like '%'+ Char(92) + '%'
      Begin
         Set @w_servidor = dbo.Fn_splitStringColumna(@w_servidor, Char(92), 1)
      End

--
-- Creación de Tablas Temporales.
--

  Create Table #TempJobs
  ( secuencia          Integer          Not Null Identity(1, 1) Primary Key,
    instance_id        Integer              Null,
    job_id             Uniqueidentifier     Null,
    job_name           Sysname              Null,
    step_id            Integer              Null,
    step_name          Sysname              Null,
    sql_message_id     Integer              Null,
    sql_severity       Integer              Null,
    message            Nvarchar(4000)       Null,
    run_status         Integer              Null,
    run_date           Integer              Null,
    run_time           Integer              Null,
    run_duration       Integer              Null,
    operator_emailed   Sysname              Null,
    operator_netsent   Sysname              Null,
    operator_paged     Sysname              Null,
    retries_attempted  Integer              Null,
    server             Sysname              Null);

  Create Table #TempJobsSal
  (secuencia           Integer          Not Null Identity(1, 1) Primary Key,
   server              Sysname,
   idError             Integer,
   mensajeError        Nvarchar(Max),
   Job                 Sysname,
   paso                Integer,
   nombrePaso          Sysname,
   horaFechaEjecucion  Datetime)

--
-- Búsqueda de Parámetros.
--

   Select @w_ambiente = Upper(parametroChar)
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 24;
   If @@Rowcount = 0
      Begin
         Set @w_ambiente = ''
      End

   Select @w_usuario = parametroChar
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 8;

   Select @w_sql   = 'Select @o_usuario = dbo.Fn_Desencripta_cadena(' + @w_usuario + ') ',
          @w_param = '@o_usuario Varchar(Max) Output '

   Execute Sp_ExecuteSQL @w_sql, @w_param, @o_usuario = @w_usuario Output

   Set @w_idUsuarioAct = Cast(@w_usuario As Integer)

   Select @w_grupoCorreo        = codigoGrupoCorreo,
          @w_tablalOG           = tablaLog,
          @w_idTipoNotificacion = idTipoNotificacion,
          @w_proceso            = descripcion,
          @w_mensaje            = mensaje,
          @w_idEstatus          = idEstatus
   From   dbo.catControlProcesosTbl
   Where  idProceso = 12
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 3000,
                @PsMensaje = Dbo.Fn_Busca_MensajeError(@PnEstatus)

         Goto Salida
      End

   If @w_idEstatus != 1
      Begin
         Select @PnEstatus = 3006,
                @PsMensaje = Dbo.Fn_Busca_MensajeError(@PnEstatus)

         Goto Salida
      End

--
-- Inicio de Proceso
--

   Select @w_idProceso = Max(idProceso)
   From   dbo.logAnalisisJobsTbl;

   Set @w_idProceso = Isnull(@w_idProceso, 0) + 1;

    Set @w_sql = Concat('msdb.dbo.sp_help_jobhistory @start_run_date = ', @w_comilla, @w_fecha, @w_comilla, ', ',
                                                    '@mode           = ', @w_comilla, 'FULL',        @w_comilla,  ', ',
                                                    '@run_status     = 1')

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

         Goto Salida
      End

   If @w_registros = 0
      Begin
         Set Xact_Abort    Off
         Return
      End

   Begin Try
      Insert Into #TempJobsSal
      (server, idError,     mensajeError, Job,
       paso,   nombrePaso,  horaFechaEjecucion)
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
      From   #TempJobs
      -- Where  sql_message_id != 0;

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

         Goto Salida

      End

   Begin Try
      Insert into dbo.logAnalisisJobsTbl
       (idProceso, secuencia,     servidor,      Job,
        idPaso,    nombrePaso,    fechaInicio,   error,
        mensajeError)
       Select @w_idProceso, secuencia,  server,              Job,
              paso,         nombrePaso, horaFechaEjecucion,  idError,
              mensajeError
       From   #TempJobsSal a
       Where  Not Exists ( Select Top 1 1
                           From   dbo.logAnalisisJobsTbl
                           Where  servidor                    = a.server
                           And    Job                         = a.Job
                           And    idPaso                      = a.paso
                           And    Cast(fechaInicio As date)   = Cast(a.horaFechaEjecucion As Date))
       Order By 4, 5;
      Set @w_registros = @@Rowcount;

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

         Goto Salida

      End

   Begin Try
      Update catControlProcesosTbl
      Set    ultFechaEjecucion = Getdate()
      Where  idProceso         = 12;
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230),
              @w_linea      = error_line()

   End   Catch

   If IsNull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = 9999,
                @PsMensaje = @w_mensaje;

         Goto Salida
      End

   If @w_registros = 0
      Begin
         Goto Salida
      End

--
-- Solicitud de Notificación.
--

   Set @w_parametros = Concat(@w_grupoCorreo,  '|', @w_servidor,     '|',
                              @w_ip,           '|', @w_instancia,    '|',
                              @w_ambiente,     '|', @w_baseDatos,    '|',
                              @w_idAplicacion, '|', @w_proceso,   '|',
                              @w_tablaLog,     '|', @w_idProceso);

   Execute dbo.Spa_conProcesosTbl @PnIdMotivo           = @w_idMotivoCorreo,
                                  @PnIdTipoNotificacion = @w_idTipoNotificacion,
                                  @PsParametros         = @w_parametros,
                                  @PdFechaProgramada    = @w_fechaAct,
                                  @PnIdUsuarioAct       = @w_idUsuarioAct,
                                  @PnEstatus            = @PnEstatus  Output,
                                  @PsMensaje            = @PsMensaje  Output

   Update dbo.logAnalisisJobsTbl
   Set    informado    = 1,
          fechaTermino = Getdate()
   Where  idProceso = @w_idProceso;

   Update dbo.catControlProcesosTbl
   Set    ultFechaEjecucion = Getdate()
   Where  idProceso = 12;


Salida:


   Set Xact_Abort    Off
   Return

End
Go

--
-- Comentarios.
--

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
