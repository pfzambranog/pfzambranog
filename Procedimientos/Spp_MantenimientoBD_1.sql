Use SCMBD
Go


/*
Declare
   @PsDbName              Varchar(250) = 'SCMBD',
   @w_idProceso           Integer      = 0,
   @PnEstatus             Integer      = 0,
   @PsMensaje             Varchar(250) = Null;

Begin
   Select @w_idProceso = Max(idProceso)
   From   dbo.logMantenimientoBDTbl

   Execute Spp_MantenimientoBD_1 @PsDbName  = @PsDbName,
                                 @PnEstatus = @PnEstatus Output,
                                 @PsMensaje = @PsMensaje Output

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

   Select *
   From   dbo.logMantenimientoBDTbl
   Where  idProceso > @w_idProceso

   Return

End
Go

*/

Create Or Alter  Procedure dbo.Spp_MantenimientoBD_1
  (@PsDbName              Varchar(250) = Null,
   @PnEstatus             Integer      = 0     Output,
   @PsMensaje             Varchar(250) = Null  Output)
As

Declare
   @w_error               Integer,
   @w_desc_error          Varchar ( 250),
   @w_tipoRecovery        Varchar ( 100),
   @w_proceso             Varchar ( 100),
   @w_ip                  Varchar (  30),
   @w_grupoCorreo         Varchar (  20),
   @w_usuario             Varchar ( Max),
   @w_mensaje             Varchar ( Max),
   @w_incidencia          Varchar ( 150),
   @w_parametros          Varchar ( Max),
   @w_sql                 NVarchar(1500),
   @w_param               NVarchar( 750),
   @w_dbName              Sysname,
   @w_servidor            Sysname,
   @w_dbFile              Sysname,
   @w_ambiente            Sysname,
   @w_tablalOG            Sysname,
   @w_comilla             Char(1),
   @w_fechaInicio         Datetime,
   @w_fechaAct            Datetime,
   @w_database_id         Integer,
   @w_idProceso           Integer,
   @w_idProcesoF          Integer,
   @w_linea               Integer,
   @w_idUsuarioAct        Integer,
   @w_secuencia           Smallint,
   @w_idAplicacion        Smallint,
   @w_idMotivoCorreo      Smallint,
   @w_idEstatus           Tinyint,
   @w_idTipoNotificacion  Tinyint,
   @w_Porc_Libre          Integer;

Begin

--
-- Objetivo:    Análiza, Valida y ejecuta Mantenimiento a la BD.
-- Programador: Pedro Felipe Zambrano
-- Fecha:       06/05/2025
--

   Set Nocount         On
   Set Xact_Abort      On
   Set Ansi_Nulls      Off
   Set Ansi_Warnings   Off

--
-- Incializamos Variables
--

   Select @PnEstatus            = 0,
          @PsMensaje            = Null,
          @w_comilla            = Char(39),
          @w_fechaAct           = Getdate(),
          @w_secuencia          = 0,
          @w_idAplicacion       = 27,
          @w_idMotivoCorreo     = 103,
          @w_ip                 = dbo.Fn_buscaDireccionIP(),
          @w_servidor           = @@ServerName;


   Select @w_ip = Replace(@w_ip, '(', ''),
          @w_ip = Replace(@w_ip, ')', '');

   If @w_servidor like '%'+ Char(92) + '%'
      Begin
         Set @w_servidor = dbo.Fn_splitStringColumna(@w_servidor, Char(92), 1)
      End

--
-- Inicio de Proceso.
--

--
-- Validaciones.
--

   If @PsDbName Is Not Null
      Begin
         Select @w_idEstatus = state
         From   sys.databases a
         Where  name       = @PsDbName;
         If @@Rowcount = 0
            Begin
               Select @PnEstatus = 8200,
                      @PsMensaje = dbo.Fn_Busca_MensajeError (@PnEstatus);
               Goto Salida;
            End

         If @w_idEstatus != 0
            Begin
               Select @PnEstatus = 8201,
                      @PsMensaje = dbo.Fn_Busca_MensajeError (@PnEstatus);
               Goto Salida;
            End

      End

--
-- Definición de CURSOR C_Base
--

   If Cursor_status('global', 'C_Base') >= -1
      Begin
         Close      C_Base
         Deallocate C_Base
      End

   Declare
      C_base Cursor For
      Select database_id, name, recovery_model_desc
      From   sys.databases a
      Where  name         = Isnull(@PsDbName, a.name)
      And    name    Not In ('master', 'tempdb', 'model', 'msdb')
      And    state        = 0
      Order  by 1;

--
-- Búsqueda de Parámetros.
--

   Select @w_Porc_Libre = Cast(parametroNumber As Integer)
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 26;
   If @@Rowcount = 0
      Begin
         Set @w_Porc_Libre = 0;
      End

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
   Where  idProceso = 1;
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
   From   dbo.logMantenimientoBDTbl;

   Set @w_idProceso = Isnull(@w_idProceso, 0) + 1;

   Open  C_Base
   While @@Fetch_status < 1
   Begin
      Fetch C_Base Into @w_database_id, @w_dbName, @w_tipoRecovery
      If @@Fetch_status != 0
         Begin
            Break
         End

      Select @w_fechaInicio = Getdate(),
             @w_secuencia   = @w_secuencia + 1;

      Begin Try
         Insert Into dbo.logMantenimientoBDTbl
         (idProceso, secuencia, servidor, baseDatos,
          actividad)
         Select @w_idProceso, @w_secuencia, @w_servidor, @w_dbName,
               'Comprobación de la integridad lógica y física de la base de datos';
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 230),
                 @w_linea      = error_line();
      End   Catch

      If Isnull(@w_Error, 0)  <> 0
         Begin
            Select @PnEstatus  = @w_Error,
                   @PsMensaje  = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' En línea ', @w_linea);

            Update  dbo.logMantenimientoBDTbl
            Set     fechaTermino = Getdate(),
                    Error        = @PnEstatus,
                    mensajeError = @PsMensaje
            Where   idProceso = @w_idProceso
            And     secuencia = @w_secuencia;

            Goto Siguiente

         End

      If @w_tipoRecovery != 'SIMPLE'
         Begin
            Set @w_sql = 'Alter Database ' + @w_dbName + ' Set Recovery Simple';

            Begin Try
               Execute (@w_sql)
            End   Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_desc_error = Substring (Error_Message(), 1, 230),
                       @w_linea      = error_line();
            End   Catch

            If Isnull(@w_Error, 0)  <> 0
               Begin
                  Select @PnEstatus  = @w_Error,
                         @PsMensaje  = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' En línea ', @w_linea);

                  Update  dbo.logMantenimientoBDTbl
                  Set     fechaTermino = Getdate(),
                          Error        = @PnEstatus,
                          mensajeError = @PsMensaje
                  Where   idProceso = @w_idProceso
                  And     secuencia = @w_secuencia;

                  Goto Siguiente

               End
         End

      Set @w_sql = Concat('Use ', @w_dbName, ';', 'Dbcc Checkdb (', @w_dbName, ', noindex) With No_infomsgs')

      Begin Try
         Execute (@w_sql)
      End   Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 220),
                 @w_linea      = error_line();
      End   Catch

      If Isnull(@w_Error, 0)  <> 0
         Begin
            Select @PnEstatus  = @w_Error,
                   @PsMensaje  = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' En línea ', @w_linea);

            Update  dbo.logMantenimientoBDTbl
            Set     fechaTermino = Getdate(),
                    Error        = @PnEstatus,
                    mensajeError = @PsMensaje
            Where   idProceso    = @w_idProceso

            Goto Siguiente

         End

      Begin Try
         Update  dbo.logMantenimientoBDTbl
         Set     fechaTermino = Getdate()
         Where   idProceso = @w_idProceso
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 230),
                 @w_linea      = error_line()
      End   Catch

      If Isnull(@w_Error, 0)  <> 0
         Begin
            Select @PnEstatus  = @w_Error,
                   @PsMensaje  = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' En línea ', @w_linea);

            Update  dbo.logMantenimientoBDTbl
            Set     fechaTermino = Getdate(),
                    Error        = @PnEstatus,
                    mensajeError = @PsMensaje
            Where   idProceso = @w_idProceso
            And     secuencia = @w_secuencia;

            Goto Siguiente
         End

--

      Set @w_secuencia = @w_secuencia + 1;

      Begin Try
         Insert Into dbo.logMantenimientoBDTbl
         (idProceso, secuencia, servidor, baseDatos,
          actividad)
         Select @w_idProceso, @w_secuencia, @w_servidor, @w_dbName,
               'Compactación Base de Datos';

      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 220),
                 @w_linea      = error_line();
      End   Catch

      If Isnull(@w_Error, 0)  <> 0
         Begin
            Select @PnEstatus  = @w_Error,
                   @PsMensaje  = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' En línea ', @w_linea);

            Goto Siguiente
         End

      Set @w_sql = Concat('use ', @w_dbName, '; Dbcc Shrinkdatabase (', @w_comilla, @w_dbName, @w_comilla, ', ', @w_Porc_Libre, ', NOTRUNCATE) With No_infomsgs')

      Begin Try
         Execute (@w_sql)
      End   Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 220),
                 @w_linea      = error_line();
      End   Catch

      If Isnull(@w_Error, 0)  <> 0
         Begin
            Select @PnEstatus  = @w_Error,
                   @PsMensaje  = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' En línea ', @w_linea);

            Update  dbo.logMantenimientoBDTbl
            Set     fechaTermino = Getdate(),
                    Error        = @PnEstatus,
                    mensajeError = @PsMensaje
            Where   idProceso = @w_idProceso
            And     secuencia = @w_secuencia;

            Goto Siguiente

         End

      Begin Try
         Update  dbo.logMantenimientoBDTbl
         Set     fechaTermino = Getdate()
         Where   idProceso = @w_idProceso
         And     secuencia = @w_secuencia;
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 230),
                 @w_linea      = error_line();
      End   Catch

      If Isnull(@w_Error, 0)  <> 0
         Begin
            Select @PnEstatus  = @w_Error,
                   @PsMensaje  = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' En línea ', @w_linea);

            Update  dbo.logMantenimientoBDTbl
            Set     fechaTermino = Getdate(),
                    Error        = @PnEstatus,
                    mensajeError = @PsMensaje
            Where   idProceso = @w_idProceso
            And     secuencia = @w_secuencia;

            Goto Siguiente
         End

      If Cursor_status('global', 'C_Files') >= -1
         Begin
            Close      C_Files
            Deallocate C_Files
         End

      Declare
         C_Files Cursor For
         Select a.name
         From   sys.master_files a
         Join   sys.databases b
         On     b.database_id = a.database_id
         Where  b.database_id = @w_database_id
         And    b.name        = @w_dbName
         And    a.type        = 1
         And    a.state_desc  = 'ONLINE';

      Open  C_Files
      While @@Fetch_status < 1
      Begin
         Fetch C_Files Into @w_dbFile
         If @@Fetch_status != 0
            Begin
               Break
            End

         Set @w_secuencia = @w_secuencia + 1;

         Begin Try
            Insert Into dbo.logMantenimientoBDTbl
            (idProceso, secuencia, servidor, baseDatos,
             actividad)
            Select @w_idProceso, @w_secuencia, @w_servidor, @w_dbName,
                   Concat('Compactación Archivo Log.: ', @w_dbFile);

         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230),
                    @w_linea      = error_line();
         End   Catch

         If Isnull(@w_Error, 0)  <> 0
            Begin
               Select @PnEstatus  = @w_Error,
                      @PsMensaje  = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' En línea ', @w_linea);

               Update  dbo.logMantenimientoBDTbl
               Set     fechaTermino = Getdate(),
                       Error        = @PnEstatus,
                       mensajeError = @PsMensaje
               Where   idProceso = @w_idProceso
               And     secuencia = @w_secuencia;

               Goto Next_File

            End

         Set @w_sql = Concat('Use ', @w_dbName, '; Dbcc Shrinkfile (', @w_comilla, @w_dbFile, @w_comilla ,
                              ', Truncateonly) With No_infomsgs');

         Begin Try
            Execute (@w_sql)
         End   Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230),
                    @w_linea      = error_line();
         End   Catch

         If Isnull(@w_Error, 0)  <> 0
            Begin
               Select @PnEstatus  = @w_Error,
                      @PsMensaje  = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' En línea ', @w_linea);

               Update  dbo.logMantenimientoBDTbl
               Set     fechaTermino = Getdate(),
                       Error        = @PnEstatus,
                       mensajeError = @PsMensaje
               Where   idProceso = @w_idProceso
               And     secuencia = @w_secuencia;

               Goto Next_File
            End

         Begin Try
            Update  dbo.logMantenimientoBDTbl
            Set     fechaTermino = Getdate()
            Where   idProceso = @w_idProceso
            And     secuencia = @w_secuencia;
         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230),
                    @w_linea      = error_line();
         End   Catch

         If Isnull(@w_Error, 0)  <> 0
            Begin
               Select @PnEstatus  = @w_Error,
                      @PsMensaje  = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' En línea ', @w_linea);

               Goto Next_File
            End

Next_File:

      End
      Close      C_Files
      Deallocate C_Files

      If @w_tipoRecovery != 'SIMPLE'
         Begin
            Set @w_sql = 'Alter Database ' + @w_dbName + ' Set Recovery ' + @w_tipoRecovery;

            Begin Try
               Execute (@w_sql)
            End   Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_desc_error = Substring (Error_Message(), 1, 230),
                       @w_linea      = error_line();
            End   Catch

            If Isnull(@w_Error, 0)  <> 0
               Begin
                  Select @PnEstatus  = @w_Error,
                         @PsMensaje  = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' En línea ', @w_linea);

               Update  dbo.logMantenimientoBDTbl
               Set     fechaTermino = Getdate(),
                       Error        = @PnEstatus,
                       mensajeError = @PsMensaje
               Where   idProceso = @w_idProceso
               And     secuencia = @w_secuencia;

               Goto Siguiente

            End

         End

   End

Siguiente:

   Close      C_Base
   Deallocate C_Base


--
-- Generación de Solicitud de Notificación.
--

   Set @w_incidencia = Substring(@w_proceso, 1, 150)

   Set @w_parametros = Concat(@w_grupoCorreo,  '|', @w_servidor,     '|',
                              @w_ip,           '|', @w_ambiente,     '|',
                              @w_tablalOG,     '|', @w_idAplicacion, '|',
                              @w_incidencia,   '|', @w_idProceso);

   Execute dbo.Spa_conProcesosTbl @PnIdMotivo           = @w_idMotivoCorreo,
                                  @PnIdTipoNotificacion = @w_idTipoNotificacion,
                                  @PsParametros         = @w_parametros,
                                  @PdFechaProgramada    = @w_fechaAct,
                                  @PnIdUsuarioAct       = @w_idUsuarioAct,
                                  @PnEstatus            = @PnEstatus  Output,
                                  @PsMensaje            = @PsMensaje  Output;

   If @PnEstatus = 0
      Begin
         Begin Try
            Update dbo.logMantenimientoBDTbl
            Set    informado = 1
            From   dbo.logMantenimientoBDTbl a
            Where  idProceso = @w_idProceso;

            Update dbo.catControlProcesosTbl
            Set    ultFechaEjecucion = Getdate()
            Where  idProceso = 1;
         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230),
                    @w_linea      = error_line()

         End   Catch

         If IsNull(@w_Error, 0) <> 0
            Begin
               Select @PnEstatus = @w_Error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' En Linea ', @w_linea);

            End
     End

Salida:

   Set Xact_Abort Off
   Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Análiza, Valida y ejecuta Mantenimiento a la BD.',
   @w_procedimiento  Varchar( 100) = 'Spp_MantenimientoBD_1'


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
                                      @level0name = N'Dbo',
                                      @level1type = 'Procedure',
                                      @level1name = @w_procedimiento;

   End
Else
   Begin
      Execute sp_updateextendedproperty @name       = 'MS_Description',
                                        @value      = @w_valor,
                                        @level0type = 'Schema',
                                        @level0name = N'Dbo',
                                        @level1type = 'Procedure',
                                        @level1name = @w_procedimiento
   End
Go

