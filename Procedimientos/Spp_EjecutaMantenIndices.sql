Use SCMBD
Go

/*
Declare
   @PsDbName              Sysname      = 'SCMBD',
   @PnEstatus             Integer      = 0,
   @PsMensaje             Varchar(250) = Null

Begin
   Execute dbo.Spp_EjecutaMantenIndices @PsDbName  = @PsDbName,
                                        @PnEstatus = @PnEstatus Output,
                                        @PsMensaje = @PsMensaje Output

   Select @PnEstatus, @PsMensaje

   Return

End
Go

*/

Create Or Alter Procedure dbo.Spp_EjecutaMantenIndices
  (@PsDbName              Sysname      = Null,
   @PnEstatus             Integer      = 0     Output,
   @PsMensaje             Varchar(250) = Null  Output)
As

Declare
   @w_error               Integer,
   @w_registros           Integer,
   @w_registro2           Integer,
   @w_secuencia           Integer,
   @w_secuencia2          Integer,
   @w_secuencia3          Integer,
   @w_idProceso           Integer,
   @w_idProceso2          Integer,
   @w_object_id           Integer,
   @w_linea               Integer,
   @w_idUsuarioAct        Integer,
   @w_idAplicacion        Smallint,
   @w_fragmentacion       Decimal(10, 3),
   @w_porcFragm           Decimal(10, 2),
   @w_desc_error          Varchar ( 250),
   @w_proceso             Varchar ( 100),
   @w_actividad           Varchar (  80),
   @w_ip                  Varchar (  30),
   @w_grupoCorreo         Varchar (  20),
   @w_incidencia          Varchar ( 150),
   @w_parametros          Varchar ( Max),
   @w_usuario             Varchar ( Max),
   @w_mensaje             Varchar ( Max),
   @w_sql                 NVarchar(1500),
   @w_param               NVarchar( 750),
   @w_existe              Tinyint,
   @w_existeError         Tinyint,
   @w_idEstatus           Tinyint,
   @w_idMotivoCorreo      Smallint,
   @w_idTipoNotificacion  Smallint,
   @w_comilla             Char(1),
   @w_fechaAct            Datetime,
   @w_dbName              Sysname,
   @w_servidor            Sysname,
   @w_esquema             Sysname,
   @w_tabla               Sysname,
   @w_tablalOG            Sysname,
   @w_indice              Sysname,
   @w_ambiente            Sysname;

Begin

-- Objetivo:    Realiza el mantenimiento de índices de la Base de Datos Seleccionada.
-- Programador: Pedro Felipe Zambrano
-- Fecha:       06/05/2025


   Set Nocount         On
   Set Xact_Abort      On
   Set Ansi_Nulls      Off
   Set Ansi_Warnings   Off

--
-- Incializamos Variables
--

   Select @PnEstatus            = 0,
          @PsMensaje            = Char(32),
          @w_comilla            = Char(39),
          @w_fechaAct           = Getdate(),
          @w_servidor           = @@ServerName,
          @w_secuencia          = 0,
          @w_idAplicacion       = 27,
          @w_idMotivoCorreo     = 104,
          @w_ip                 = dbo.Fn_buscaDireccionIP();

   Select @w_ip = Replace(@w_ip, '(', ''),
          @w_ip = Replace(@w_ip, ')', '');

   If @w_servidor like '%'+ Char(92) + '%'
      Begin
         Set @w_servidor = dbo.Fn_splitStringColumna(@w_servidor, Char(92), 1)
      End

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

   If Cursor_status('global', 'C_BaseD') >= -1
      Begin
         Close      C_BaseD
         Deallocate C_BaseD
      End

--
-- Definición de CURSOR
--
   Declare
      C_BaseD Cursor For
      Select name
      From   sys.databases a
      Where  state_desc = 'ONLINE'
      And    name  Not In ('master', 'tempdb', 'model', 'msdb')
      And    name       = Isnull(@PsDbName, a.name)
      Order  By 1;

--
-- Creación de Tablas Temporales.
--

   Create Table #tempObj1
   (secuencia       Integer Identity (1, 1) Not Null Primary Key,
    baseDatos       Sysname                 Not Null,
    fragmentacion   Decimal(10, 3)              Null,
    object_id       Integer                 Not Null);

   Create Table #tempObj2
   (secuencia       Integer Identity (1, 1) Not Null Primary Key,
    esquema         Sysname                 Not Null,
    tabla           Sysname                 Not Null,
    indice          Sysname                     Null);

--
-- Búsqueda de Parámetros.
--

   Select @w_porcFragm = parametroNumber
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 25;
   If @@Rowcount = 0
      Begin
         Set @w_porcFragm = 0;
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
   Where  idProceso = 2;
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
   From   dbo.logMantenIndicesTbl;

   Set @w_idProceso = Isnull(@w_idProceso, 0) + 1;

   Open  C_BaseD
   While @@Fetch_status < 1
   Begin
      Fetch C_BaseD Into @w_dbName
      If @@Fetch_status != 0
         Begin
            Break
         End

      Select @w_registro2   = 0,
             @PnEstatus     = 0,
             @PsMensaje     = '',
             @w_secuencia   = @w_secuencia + 1,
             @w_secuencia2  = 0,
             @w_Error       = 0;

      Insert Into dbo.logMantenIndicesTbl
      (idProceso, secuencia,servidor, baseDatos)
      Select @w_idProceso, @w_secuencia, @w_servidor, @w_dbName

      Truncate Table #tempObj1

      Set @w_sql = 'Select ' + @w_comilla  + @w_dbName + @w_comilla + ', avg_fragmentation_in_percent , object_id
                    From  sys.dm_db_index_physical_stats
                    (DB_ID(N'+ @w_comilla  + @w_dbName + @w_comilla +'), Null, NULL, NULL , Null)
                    Where  avg_fragmentation_in_percent >= ' + Cast(@w_porcFragm As Varchar) + '
                    And    index_type_desc != ' + @w_comilla + 'HEAP' + @w_comilla;

      Insert Into #tempObj1
      (baseDatos, fragmentacion, object_id )
      Execute (@w_sql)
      Set @w_registros = @@Rowcount

      If @w_registros = 0
         Begin
            Goto NextBd
         End

      While  @w_secuencia2 < @w_registros
      Begin
         Select @w_secuencia2 = @w_secuencia2 + 1,
                @PnEstatus   = 0,
                @PsMensaje   = '',
                @w_Error     = 0;

         Select @w_object_id      = object_id,
                @w_fragmentacion  = fragmentacion
         From   #tempObj1
         Where  secuencia = @w_secuencia2;
         If @@Rowcount = 0
            Begin
               Break
            End

         Truncate Table #tempObj2

         Set @w_sql = 'Select c.name,  b.name, a.name
                       From   ' + @w_dbName + '.sys.indexes a
                       Join   ' + @w_dbName + '.sys.tables  b
                       On     b.object_id = a.object_id
                       Join   ' + @w_dbName + '.sys.schemas c
                       On     b.schema_id = c.schema_id
                       Where  b.object_id = ' + Cast(@w_object_id As Varchar) + '
                       Order  By 2, 3'

         Insert Into #tempObj2
         (esquema, tabla, indice)
         Execute (@w_sql)

         Select @w_registro2  = @@Rowcount,
                @w_secuencia3 = 0

         While  @w_secuencia3 < @w_registro2
         Begin
            Select @w_secuencia3 = @w_secuencia3 + 1,
                   @w_actividad  = '',
                   @PnEstatus    = 0,
                   @PsMensaje    = '',
                   @w_Error      = 0;

            Select @w_tabla   = tabla,
                   @w_indice  = indice,
                   @w_esquema = esquema
            From   #tempObj2
            Where  secuencia = @w_secuencia3
            If @@Rowcount = 0
               Begin
                  Break
               End

            If @w_indice Is Not Null
               Begin
                  Set @w_actividad = ''

                  Select @w_actividad = 'Reorganiza Índice ' + @w_tabla + '.' + @w_indice,
                         @w_sql       = 'Alter Index "' + @w_indice + '" On ' + @w_dbName + '.' + @w_esquema + '.' + @w_tabla + ' Reorganize'

                  Insert Into dbo.logMantenIndicesDetTbl
                  (idProceso, secuencia, actividad)
                  Select @w_idProceso, @w_secuencia, @w_actividad

                  Set @w_idProceso2 = @@Identity

                  Begin Try
                     Execute(@w_sql)
                  End   Try

                  Begin Catch
                     Select  @w_Error      = @@Error,
                             @w_desc_error = Substring (Error_Message(), 1, 230),
                             @w_linea      = error_line();

                  End   Catch

                  If IsNull(@w_Error, 0) <> 0
                     Begin
                        Select @PnEstatus = @w_Error,
                               @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' En Linea ', @w_linea);

                        Update dbo.logMantenIndicesDetTbl
                        Set    error        = @PnEstatus,
                               mensajeError = @PsMensaje,
                               fechaTermino = Getdate()
                        Where  idProcesoDet = @w_idProceso2
                        Goto Siguiente

                     End

Siguiente:

                  Update dbo.logMantenIndicesDetTbl
                  Set    fechaTermino = Getdate()
                  Where  idProcesoDet = @w_idProceso2

               End
         End

         Set @w_actividad = 'Actualizando Estadísticas Entidad ' + @w_esquema + '.' + @w_tabla

         Insert Into dbo.logMantenIndicesDetTbl
         (idProceso, secuencia, actividad)
         Select @w_idProceso, @w_secuencia, @w_actividad
         Set @w_idProceso2 = @@Identity

         Set @w_sql = 'Update Statistics  ' + @w_dbName + '.' + @w_esquema + '.' +  @w_tabla + ' With Fullscan '

         Begin Try
            Execute(@w_sql)
         End   Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230),
                    @w_linea      = error_line()

         End   Catch

         If IsNull(@w_Error, 0) <> 0
            Begin
               Select @PnEstatus = @w_Error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' En Linea ', @w_linea);

               Update dbo.logMantenIndicesDetTbl
               Set    error        = @PnEstatus,
                      mensajeError = @PsMensaje,
                      fechaTermino = Getdate()
               Where  idProcesoDet = @w_idProceso2
            End
         Else
            Begin
               Update dbo.logMantenIndicesDetTbl
               Set    fechaTermino = Getdate()
               Where  idProcesoDet = @w_idProceso2
            End

Proximo:

      End


      If Exists (Select Top 1 1
                 From   logMantenIndicesDetTbl
                 Where  idProceso = @w_idProceso
                 And    secuencia = @w_secuencia
                 And    error    != 0)
         Begin
            Set @w_existeError = 1
         End
      Else
         Begin
            Set @w_existeError = 0
         End

NextBd:

      Update dbo.logMantenIndicesTbl
      Set    fechaProceso = Getdate(),
             error        = @w_existeError,
             mensajeError = Case When @w_existeError != 0
                                 Then 'Hay errores en el proceso de Mantenimiento. ' + a.mensajeError
                                 Else @w_mensaje
                            End
      From   dbo.logMantenIndicesTbl a
      Where  idProceso = @w_idProceso
      And    secuencia = @w_secuencia;

   End

   Close      C_BaseD
   Deallocate C_BaseD

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
            Update dbo.logMantenIndicesTbl
            Set    informado = 1
            From   dbo.logMantenIndicesTbl a
            Where  idProceso = @w_idProceso;
         
            Update dbo.catControlProcesosTbl
            Set    ultFechaEjecucion = Getdate()
            Where  idProceso = 2;
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

   Set Xact_Abort    Off
   Return

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Mantenimiento de Índices.',
   @w_procedimiento  NVarchar(250) = 'Spp_EjecutaMantenIndices';

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
