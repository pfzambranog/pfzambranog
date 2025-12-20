Use SCMBD
Go


/*
Declare
   @PnEstatus               Integer      = 0,
   @PsMensaje               Varchar(250) = Null

Begin
   Execute dbo.Spp_validaBloqueos @PnEstatus = @PnEstatus     Output,
                                  @PsMensaje = @PsMensaje     Output;

   Select @PnEstatus, @PsMensaje

   Return

End
Go
*/

Create Or Alter Procedure dbo.Spp_validaBloqueos
  (@PnEstatus               Integer      = 0    Output,
   @PsMensaje               Varchar(250) = Null Output)
As

Declare
   @w_error                 Integer,
   @w_desc_error            Varchar(  250),
   @w_indice                Varchar(  100),
   @w_server                Varchar(  100),
   @w_usuario               Varchar(  Max),
   @w_idMotivoCorreo        Smallint,
   @w_idAplicacion          Smallint,
   @w_idTipoNotificacion    Tinyint,
   @w_tiempo                Integer,
   @w_idUsuarioAct          Integer,
   @w_segundos              Integer,
   @w_registros             Integer,
   @w_idObjeto              Integer,
   @w_fechaProc             Datetime,
   @w_ruta                  Varchar(  150),
   @w_log                   Varchar(  150),
   @w_Archivo               Varchar(  150),
   @w_ArchivoSalida         Varchar(  150),
   @w_url                   Varchar(  250),
   @w_parametroURL          Varchar(  250),
   @w_grupoCorreo           Varchar(   20),
   @w_ambiente              Varchar(  250),
   @w_incidencia            Varchar(  850),
   @w_parametros            Varchar(  Max),
   @w_mensaje               Varchar(  Max),
   @w_proceso               Varchar(  100),
   @w_ip                    Varchar(   30),
   @w_query                 Varchar( 1000),
   @w_periodicidad          Varchar(   60),
   @w_sql                   NVarchar(4000),
   @w_param                 NVarchar( 750),
   @w_servidor              Sysname,
   @w_tabla                 Sysname,
   @w_dbname                Sysname,
   @w_instancia             Sysname,
   @w_base                  Sysname,
   @w_objeto                Sysname,
   @w_fechaAct              Datetime,
   @w_idProceso             Integer,
   @w_secuencia             Integer,
   @w_minutosEspera         Integer,
   @w_linea                 Integer,
   @w_idEstatus             Tinyint;

Begin
/*

Objetivo:    Validación de Consultas Bloquedas en la Base de Datos.
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
          @w_idMotivoCorreo     = 109,
          @w_idAplicacion       = 27,
          @w_secuencia          = 0,
          @w_fechaAct           = Getdate(),
          @w_dbname             = Db_name(),
          @w_ip                 = dbo.Fn_BuscaDireccionIP(),
          @w_indice             = Substring('IDX_' + Replace(Cast(newid() As Varchar(100)), '-', ''), 1, 30);

   Select @w_ip = Replace(@w_ip, '(', ''),
          @w_ip = Replace(@w_ip, ')', '');

   If @w_servidor like '%'+ Char(92) + '%'
      Begin
         Set @w_servidor = dbo.Fn_splitStringColumna(@w_servidor, Char(92), 1)
      End

--
-- Creación de Tablas
--

   Create Table #TempBloqueosBD
   (secuencia              Integer         Not Null  Identity(1, 1) Primary Key,
    servidor               Sysname                   Collate SQL_Latin1_General_CP1_CI_AS,
    baseDatos              Sysname                   Collate SQL_Latin1_General_CP1_CI_AS,
    sessionID              Integer         Not Null,
    esource_type           Nvarchar(120)   Not Null,
    objectName             Sysname                   Collate SQL_Latin1_General_CP1_CI_AS,
    resource_description   Nvarchar(512)       Null,
    request_session_id     Varchar (100)       Null,
    request_mode           Nvarchar(120)       Null,
    request_status         Nvarchar(120)       Null,
    Query                  Varchar(Max)        Null,
    fechaInicio            Datetime            Null,
    tiempo_bloqueo         Integer         Not Null,
    idObjeto               Integer             Null,
    idEstatus              Bit             Not Null Default 1,
    Index #TempBloqueosBDIdx01 (servidor, sessionID));


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

   Select @w_segundos = parametroNumber
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 11;

   Set @w_segundos  = Isnull(@w_segundos, 0)

   Select @w_minutosEspera = ParametroNumber
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 15;

   Set @w_minutosEspera = Isnull(@w_minutosEspera, 60);

   Select @w_grupoCorreo        = codigoGrupoCorreo,
          @w_idTipoNotificacion = idTipoNotificacion,
          @w_tabla              = tablaLog,
          @w_proceso            = descripcion,
          @w_idEstatus          = idEstatus,
          @w_mensaje            = mensaje,
          @w_periodicidad       = dbo.Fn_splitStringColumna (Trim(periodicidad), Char(32), 1)
   From   dbo.catControlProcesosTbl
   Where  idProceso = 4
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


   If Isnumeric(@w_periodicidad) = 1
      Begin
         Set @w_minutosEspera = Isnull(@w_periodicidad, @w_minutosEspera);
      End

--

   Insert Into #TempBloqueosBD
   (servidor,       baseDatos,            sessionID,          esource_type,
    ObjectName,     resource_description, request_session_id, request_mode,
    request_status, Query,                fechaInicio,        Tiempo_bloqueo,
    idObjeto)
   Select @w_servidor, c.name, a.session_id, b.resource_type,
          Case When b.resource_type = 'OBJECT'
               Then Object_name(b.resource_associated_entity_id, b.resource_database_id)
               When b.resource_type = 'DATABASE'
               Then 'DB'
               Else Case When b.resource_database_id = c.database_id
                         Then (Select Object_name(object_id, b.resource_database_id)
                               From   sys.partitions
                               Where  hobt_id = b.resource_associated_entity_id)
                         Else  '(Run under DB context)'
                    End
          End, b.resource_description, b.request_session_id, b.request_mode,
          b.request_status, (Select Substring(S.Text, (ER.statement_start_offset / 2) + 1,
                                      ((Case When  ER.statement_end_offset = -1
                                             Then  Datalength(S.text)
                                             Else ER.statement_end_offset
                                        End - ER.statement_start_offset) / 2) + 1)
                             From   sys.dm_exec_requests ER
                             Cross  apply sys.dm_exec_sql_text(ER.sql_handle) S
                             Where  b.request_session_id = ER.session_id),
          a.start_time,
          Datediff(ss, a.start_time, Getdate()),
         (Select objectid
          From   sys.dm_exec_requests ER
          Cross  apply sys.dm_exec_sql_text(ER.sql_handle) S
          Where  b.request_session_id = ER.session_id)
   From   sys.dm_exec_requests  a
   Join   sys.dm_tran_locks b
   On     b.request_session_id  = a.session_id
   Join   sys.databases c
   On     c.database_id         = a.database_id
   Where  blocking_session_id <> 0
   Order  By 2, 3;

   Set @w_registros = @@Rowcount

   If @w_registros = 0
      Begin
         Select @PnEstatus = 98,
                @PsMensaje = Substring(@w_mensaje, 1, 250);

         Goto Salida
      End

   Select @w_idProceso = Max(idProceso)
   From   dbo.logProcesosBloqueadosTbl;

   Set @w_idProceso = Isnull(@w_idProceso, 0) + 1;

   Begin Try
      Insert Into dbo.logProcesosBloqueadosTbl
      (idProceso, secuencia,     servidor,       databaseName,
       sessionId, esource_type,  ObjectName,     resource_description,
       request_session_id,       request_mode,   request_status, Query,
       fechaInicioProceso,       Tiempo_bloqueo)
      Select @w_idProceso,       secuencia,     servidor,                 baseDatos,
             sessionID,          esource_type,  Isnull(ObjectName, ''),   Isnull(resource_description,''),
             request_session_id, request_mode,  request_status,           Query,
             fechaInicio,        tiempo_bloqueo
      From   #TempBloqueosBD a
      Where  Not Exists (Select Top 1 1
                         From   dbo.logProcesosBloqueadosTbl
                         Where  servidor     = a.servidor
                         And    databaseName = a.baseDatos
                         And    sessionId    = a.sessionId
                         And    Datediff(mi, fechaTermino, @w_fechaAct) < @w_minutosEspera);

      Set @w_registros = @@Rowcount
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230),
              @w_linea      = error_line();

   End   Catch

   If IsNull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error.: ', @w_Error, '. ', @w_desc_error, ' En Línea: ', @w_linea);

          Goto Salida
      End

   If @w_registros = 0
      Begin
         Select @PnEstatus = 99,
                @PsMensaje = Dbo.Fn_Busca_MensajeError(@PnEstatus)

         Goto Salida
      End

   Set @w_incidencia = Substring(@w_proceso, 1, 150)

   Set @w_parametros = Concat(@w_grupoCorreo,  '|', @w_servidor,     '|',
                              @w_ip,           '|', @w_instancia,    '|',
                              @w_ambiente,     '|', @w_dbname,       '|',
                              @w_tabla,        '|', @w_idAplicacion, '|',
                              @w_incidencia,   '|', @w_idProceso);

   Execute dbo.Spa_conProcesosTbl @PnIdMotivo           = @w_idMotivoCorreo,
                                  @PnIdTipoNotificacion = @w_idTipoNotificacion,
                                  @PsParametros         = @w_parametros,
                                  @PsURL                = @w_url,
                                  @PdFechaProgramada    = @w_fechaAct,
                                  @PnIdUsuarioAct       = @w_idUsuarioAct,
                                  @PnEstatus            = @PnEstatus  Output,
                                  @PsMensaje            = @PsMensaje  Output;

   If @PnEstatus = 0
      Begin
         Update dbo.logProcesosBloqueadosTbl
         Set    fechaConsulta  = Getdate(),
                fechaTermino   = Getdate(),
                tiempo_bloqueo = b.tiempo_bloqueo,
                informado      = 1
         From   dbo.logProcesosBloqueadosTbl a
         Join   #TempBloqueosBD              b
         On     b.servidor     = a.servidor
         And    b.baseDatos    = a.databaseName
         And    b.sessionId    = a.sessionId
         Where  a.idProceso    = @w_idProceso;

         Update dbo.catControlProcesosTbl
         Set    ultFechaEjecucion = Getdate()
         Where  idProceso = 4
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
   @w_valor          Nvarchar(250) = 'Procedimiento de Validación de Procesos Bloqueados.',
   @w_procedimiento  NVarchar(250) = 'Spp_validaBloqueos';

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