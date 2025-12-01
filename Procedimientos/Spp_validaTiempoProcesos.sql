Use SCMBD
Go

/*
Declare
   @PnEstatus               Integer      = 0,
   @PsMensaje               Varchar(250) = Null

Begin
   Execute dbo.Spp_validaTiempoProcesos @PnEstatus      = @PnEstatus     Output,
                                        @PsMensaje      = @PsMensaje     Output;

   Select @PnEstatus, @PsMensaje

   Return

End
Go
*/

Create or Alter Procedure dbo.Spp_validaTiempoProcesos
  (@PnEstatus               Integer      = 0    Output,
   @PsMensaje               Varchar(250) = Null Output)
As

Declare
   @w_error                 Integer,
   @w_desc_error            Varchar( 250),
   @w_indice                Varchar( 100),
   @w_ambiente              Varchar( 100),
   @w_usuario               Varchar(  Max),
   @w_idMotivoCorreo        Smallint,
   @w_idAplicacion          Smallint,
   @w_idTipoNotificacion    Tinyint,
   @w_tiempo                Integer,
   @w_idUsuarioAct          Integer,
   @w_segundos              Integer,
   @w_registros             Integer,
   @w_secuencia             Integer,
   @w_idObjeto              Integer,
   @w_sql                   NVarchar(1500),
   @w_param                 NVarchar( 750),
   @w_query                 Nvarchar( Max),
   @w_ruta                  Varchar(  150),
   @w_log                   Varchar(  250),
   @w_Archivo               Varchar(  250),
   @w_ArchivoSalida         Varchar(  250),
   @w_parametroURL          Varchar(  250),
   @w_url                   Varchar(  250),
   @w_grupoCorreo           Varchar(   20),
   @w_ip                    Varchar(   30),
   @w_incidencia            Varchar(  850),
   @w_parametros            Varchar(  Max),
   @w_proceso               Varchar(  100),
   @w_server                Varchar(  100),
   @w_servidor              Sysname,
   @w_tabla                 Sysname,
   @w_dbname                Sysname,
   @w_instancia             Sysname,
   @w_base                  Sysname,
   @w_objeto                Sysname,
   @w_fechaAct              Datetime,
   @w_fechaProc             Datetime,
   @w_idProceso             Integer;


Begin
/*

Objetivo:    Validación de Tiempos Excesivos de Proceso.
Programador: Pedro Felipe Zambrano
Fecha:       06/05/2025


*/
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

--
-- Inicializamos Variables
--

   Select @PnEstatus            = 0,
          @PsMensaje            = '',
          @w_server             = @@ServerName,
          @w_servidor           = @@ServerName,
          @w_instancia          = @@servicename,
          @w_idMotivoCorreo     = 110,
          @w_idAplicacion       = 27,
          @w_secuencia          = 0,
          @w_fechaAct           = Getdate(),
          @w_fechaProc          = @w_fechaAct,
          @w_dbname             = Db_name(),
          @w_ip                 = dbo.Fn_BuscaDireccionIP(),
          @w_indice             = Substring('IDX_' + Replace(Cast(newid()  As Varchar(100)), '-', ''), 1, 30);

   If @w_server like '%'+ Char(92) + '%'
      Begin
         Set @w_server = dbo.Fn_splitStringColumna(@w_server, Char(92), 1)
      End

--
-- Creación de Tablas
--

   Create Table #TiemposEjecucionTbl
   (secuencia                Integer        Not Null Identity (1, 1) Primary Key,
    sessionId                Integer        Not Null,
    servidor                 Sysname        Not Null,
    status                   Varchar (100)      Null,
    databaseName             Sysname        Not Null,
    individualQuery          Varchar (Max)      Null,
    parentQuery              Nvarchar(Max)      Null,
    programName              Sysname            Null,
    tiempoEjecucion          Integer        Not Null,
    fechaInicioProceso       Datetime       Not Null,
    idObjeto                 Integer        Not Null,
    objeto                   Sysname            Null);

   Set @w_sql = Concat('Create index ', @w_indice,  ' On #TiemposEjecucionTbl (servidor, sessionID)')
   Execute (@w_sql)

--
-- Búsqueda de Parámetros.
--

   Select @w_ambiente = Upper(parametroChar)
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 24
   If @@Rowcount = 0
      Begin
         Set @w_ambiente = ''
      End

   Select @w_usuario = parametroChar
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 8

   Select @w_sql   = 'Select @o_usuario = dbo.Fn_Desencripta_cadena(' + @w_usuario + ') ',
          @w_param = '@o_usuario Varchar(Max) Output '

   Execute Sp_ExecuteSQL @w_sql, @w_param, @o_usuario = @w_usuario Output

   Set @w_idUsuarioAct = Cast(@w_usuario As Smallint)

   Select @w_segundos = parametroNumber
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 11

   Set @w_segundos  = Isnull(@w_segundos, 0)

--
-- Inicio de Proceso.
--

   Select @w_grupoCorreo        = codigoGrupoCorreo,
          @w_idTipoNotificacion = idTipoNotificacion,
          @w_tabla              = tablaLog,
          @w_proceso            = descripcion
   From   dbo.catControlProcesosTbl
   Where  idProceso = 3
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 3000,
                @PsMensaje = Dbo.Fn_Busca_MensajeError(@PnEstatus)

         Goto Salida
      End

   Update dbo.catControlProcesosTbl
   Set    ultFechaEjecucion = Getdate()
   Where  idProceso = 3

   Insert into #TiemposEjecucionTbl
  (sessionId,          servidor,    status,      databaseName,
   individualQuery,    parentQuery, programName, tiempoEjecucion,
   fechaInicioProceso, idObjeto)
   Select es.session_id, @w_servidor, er.status, Db_name(es.database_id),
          Substring (qt.text,(er.statement_start_offset / 2) + 1,
                    ((Case When er.statement_end_offset = -1
                           Then Len(Convert(Nvarchar(Max), qt.text)) * 2
                           Else er.statement_end_offset
                      End - er.statement_start_offset) / 2) + 1) Individual_Query,
          qt.text Parent_Query, es.program_name,
          Datediff(ss, er.start_time, @w_fechaProc) Tiempo_ejecucion_minutos,
          er.start_time, qt.objectid
   From   sys.dm_exec_requests er
   Join   sys.dm_exec_sessions es
   On     es.session_id         = er.session_id
   Join   sys.databases c
   On     c.database_id         = es.database_id
   Cross  Apply sys.dm_exec_sql_text  (er.sql_handle)  qt
   Where  es.session_Id        != @@SPID
   And    Datediff(ss,er.start_time, @w_fechaProc) > @w_segundos
   And    c.name               != 'msdb'
   And    wait_type            != 'TRACEWRITE'
   Order  By Tiempo_ejecucion_minutos
   Set @w_registros = @@Rowcount

   If @w_registros = 0
      Begin
         Select @PnEstatus = 99,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus);

         Goto Salida
      End

   While @w_secuencia < @w_registros
   Begin
      Set @w_secuencia = @w_secuencia + 1
      Select @w_base     = databaseName,
             @w_idObjeto = idObjeto,
             @w_query    = individualQuery
      From   #TiemposEjecucionTbl
      Where  secuencia = @w_secuencia
      If @@Rowcount = 0
         Begin
            Goto Siguiente
         End

      Set @w_base = Concat(@w_base, '.', 'sys.sysobjects');

      Select @w_sql   = 'Select @o_objeto = name From ' + @w_base + ' Where id = ' + Cast(@w_idObjeto As Varchar),
             @w_param = '@o_objeto   Sysname Output'

      Execute Sp_ExecuteSQL @w_sql, @w_param, @o_objeto = @w_objeto Output

      Insert Into dbo.logTiemposEjecucionTbl
      (sessionId,          servidor,    status,      databaseName,
       individualQuery,    parentQuery, programName, tiempoEjecucion,
       fechaInicioProceso)
      Select sessionId,       servidor,    status,      databaseName,
             individualQuery, parentQuery, programName, tiempoEjecucion,
             fechaInicioProceso
      From   #TiemposEjecucionTbl a
      Where  secuencia = @w_secuencia
      And    Not Exists (Select Top 1 1
                         From   dbo.logTiemposEjecucionTbl
                         Where  servidor  = a.servidor
                         And    sessionId = a.sessionId);
      If @@Rowcount = 0
         Begin
            Goto Siguiente
         End

      Set @w_idProceso = @@Identity

      Select @w_incidencia = 'Tiempos de Ejecución de Procesos Altos',
             @w_ip         = Replace(@w_ip, '(', ''),
             @w_ip         = Replace(@w_ip, ')', '');

      Set @w_parametros = Concat(@w_grupoCorreo, '|', @w_servidor,    '|',
                                 @w_ip,          '|', @w_instancia,   '|',
                                 @w_ambiente,    '|', @w_idAplicacion,'|',
                                 @w_incidencia,  '|', @w_idProceso,   '|',
                                 @w_tabla,       '|', @w_objeto,      '|',
                                 @w_query);

      Execute dbo.Spa_conProcesosTbl @PnIdMotivo           = @w_idMotivoCorreo,
                                     @PnIdTipoNotificacion = @w_idTipoNotificacion,
                                     @PsParametros         = @w_parametros,
                                     @PsURL                = @w_url,
                                     @PdFechaProgramada    = @w_fechaAct,
                                     @PnIdUsuarioAct       = @w_idUsuarioAct,
                                     @PnEstatus            = @PnEstatus  Output,
                                     @PsMensaje            = @PsMensaje  Output

      If @PnEstatus = 0
         Begin
            Update dbo.logTiemposEjecucionTbl
            Set    fechaConsulta = Getdate(),
                   fechaTermino  = Getdate(),
                   informado     = 1
            From   dbo.logTiemposEjecucionTbl a
            Where  idProceso = @w_idProceso;

         End
Siguiente:

   End

Salida:

   Set Xact_Abort    Off
   Return

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Validación de Tiempos Excesivos de Proceso.',
   @w_procedimiento  NVarchar(250) = 'Spp_validaTiempoProcesos';

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
