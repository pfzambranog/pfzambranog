Use SCMBD
Go

/*
Declare
   @PsDbName              Sysname      = 'SCMBD',
   @PnImprimeResultado    Bit          = 0,
   @PnEstatus             Integer      = 0,
   @PsMensaje             Varchar(250) = Null

Begin
   Execute dbo.Spp_AnalisisObjetosNoValidos @PsDbName           = @PsDbName,
                                            @PnImprimeResultado = @PnImprimeResultado,
                                            @PnEstatus          = @PnEstatus Output,
                                            @PsMensaje          = @PsMensaje Output


   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

   Return

End
Go
*/

Create Or Alter Procedure dbo.Spp_AnalisisObjetosNoValidos
   @PsDbName              Sysname      = Null,
   @PnImprimeResultado    Bit          = 0,
   @PnEstatus             Integer      = 0    Output,
   @PsMensaje             Varchar(250) = Null Output
As

Declare
   @w_dbName                Sysname,
   @w_servidor              Sysname,
   @w_tabla                 Sysname,
   @w_instancia             Sysname,
   @w_comilla               Char(1),
   @w_sql                   NVarchar(1500),
   @w_param                 NVarchar( 750),
   @w_state_desc            Nvarchar( 120),
   @w_desc_error            Varchar ( 250),
   @w_ambiente              Varchar ( 250),
   @w_actividad             Varchar (  80),
   @w_grupoCorreo           Varchar (  20),
   @w_ipAct                 Varchar (  30),
   @w_proceso               Varchar ( 200),
   @w_parametros            Varchar (2000),
   @w_usuario               Varchar ( Max),
   @w_existe                Tinyint,
   @w_idMotivoCorreo        Integer,
   @w_idAplicacion          Integer,
   @w_error                 Integer,
   @w_linea                 Integer,
   @w_registros             Integer,
   @w_idTipoNotificacion    Integer,
   @w_idUsuarioAct          Integer,
   @w_idProceso             BigInt,
   @w_fechaAct              Datetime;

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

--
-- Incializamos Variables
--

   Select @PnEstatus            = 0,
          @PsMensaje            = Null,
          @w_servidor           = @@ServerName,
          @w_instancia          = @@servicename,
          @w_idMotivoCorreo     = 111,
          @w_idAplicacion       = 27,
          @w_comilla            = Char(39),
          @w_ipAct              = dbo.Fn_BuscaDireccionIP();

   Select @w_dbName     = name,
          @w_state_desc = state_desc
   From   sys.databases a
   Where  name       = @PsDbName;
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 8200,
                @PsMensaje = 'Error.: ' + dbo.Fn_Busca_MensajeError(@PnEstatus);

         Set Xact_Abort Off
         Return

      End

   If @w_state_desc != 'ONLINE'
      Begin
         Select @PnEstatus = 8201,
                @PsMensaje = 'Error.: ' + dbo.Fn_Busca_MensajeError(@PnEstatus);

         Set Xact_Abort Off
         Return

      End

   Select top 1 @w_usuario = parametroChar
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 8;

   Select @w_sql   = 'Select @o_usuario = dbo.Fn_Desencripta_cadena(' + @w_usuario + ') ',
          @w_param = '@o_usuario Varchar(Max) Output '

   Execute Sp_ExecuteSQL @w_sql, @w_param, @o_usuario = @w_usuario Output

   Set @w_idUsuarioAct = Cast(@w_usuario As Smallint)

   Select top 1 @w_ambiente = parametroChar
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 24;


--
-- Inicio de Proceso.
--

   Select @w_grupoCorreo        = codigoGrupoCorreo,
          @w_idTipoNotificacion = idTipoNotificacion,
          @w_tabla              = tablaLog,
          @w_proceso            = descripcion
   From   dbo.catControlProcesosTbl
   Where  idProceso = 5
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 3000,
                @PsMensaje = Dbo.Fn_Busca_MensajeError(@PnEstatus)

         Goto Salida
      End

   Begin Try
      Update dbo.catControlProcesosTbl
      Set    ultFechaEjecucion = Getdate()
      Where  idProceso         = 5;
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)

   End   Catch

   If IsNull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

         Goto Salida
      End

   Create Table #invalid_db_objects (
   secuencia            Integer        Not Null Identity (1, 1) Primary Key,
   invalid_object_id    Integer        Not Null,
   invalid_obj_name     Sysname,
   MensajeError         Nvarchar(3000) Not Null,
   invalid_obj_type     Char(2)        Not Null,
   Index invalid_db_objectsPk (invalid_object_id));

   Set @w_sql = 'Select Distinct cte.referencing_id, ' +
                       'Schema_name(c.schema_id) + ' + @w_comilla + '.' +  @w_comilla + ' + c.name obj_name, ' +
                        @w_comilla + 'Invalid object name ' +  @w_comilla +
	 				   ' +  cte.obj_name, ' +
                        'c.type
                 From ( Select sed.referencing_id,
                               obj_name = Coalesce(sed.referenced_schema_name + ' + @w_comilla + '.' + @w_comilla +
                                           ', Char(32)) + sed.referenced_entity_name ' +
                       'From    ' + @w_dbName + '.sys.sql_expression_dependencies sed ' +
                       'Where   sed.is_ambiguous   = 0 ' +
                       'And     sed.referenced_id Is Null) cte ' +
                'Join  ' + @w_dbName + + '.sys.objects c ' +
                'On    c.object_id = cte.referencing_id'

   Begin Try
      Insert Into #invalid_db_objects
      (invalid_object_id, invalid_obj_name, MensajeError, invalid_obj_type)
      Execute (@w_sql)
      Set @w_registros = @@Rowcount;
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230),
              @w_linea      = Error_line();
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus  = @w_Error,
                @PsMensaje  = Concat('Error: ',  @w_Error, ' ', ' en linea ',  @w_linea, ', ', @w_desc_error)

         Goto Salida
      End

   If @PnImprimeResultado = 1
      Begin
         Select invalid_obj_type [Tipo Objeto], invalid_obj_name "Invalid OBJECT NAME" , MensajeError "Message Error"
         From   #invalid_db_objects
         Order  By 1, 2;

        Goto Salida
      End

   If @w_registros = 0
      Begin
         Select @PnEstatus  = 0,
                @PsMensaje  = 'No hay objetos invalidos';

         Set Xact_Abort Off
         Return
      End

   Select @w_idProceso = Max(idProceso)
   From   dbo.logAnalisisObjetosNoValidosTbl;

   Set @w_idProceso = Isnull(@w_idProceso, 0) + 1;

   Begin Try
      Insert Into dbo.logAnalisisObjetosNoValidosTbl
     (idProceso, correlativo, servidor, databaseName, tipo, ObjectName, ErrorMensaje)
      Select @w_idProceso, secuencia, @w_servidor, @w_dbName, invalid_obj_type, invalid_obj_name, MensajeError
      From   #invalid_db_objects;

   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230),
              @w_linea      = Error_line();
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus  = @w_Error,
                @PsMensaje  = Concat('Error: ',  @w_Error, ' ', ' en linea ',  @w_linea, ', ', @w_desc_error)

         Goto Salida
      End

      Set @w_parametros = Concat(@w_grupoCorreo, '|', @w_servidor,    '|', @PsDbName,   '|', @w_instancia, '|',
                                 @w_ambiente,    '|', @w_idAplicacion,'|', @w_proceso,  '|', @w_idProceso, '|',
                                 @w_tabla,       '|', @w_ipAct);


      Execute dbo.Spa_conProcesosTbl @PnIdMotivo           = @w_idMotivoCorreo,
                                     @PnIdTipoNotificacion = @w_idTipoNotificacion,
                                     @PsParametros         = @w_parametros,
                                     @PdFechaProgramada    = @w_fechaAct,
                                     @PnIdUsuarioAct       = @w_idUsuarioAct,
                                     @PnEstatus            = @PnEstatus  Output,
                                     @PsMensaje            = @PsMensaje  Output;
      If @PnEstatus = 0
         Begin
            Update dbo.logAnalisisObjetosNoValidosTbl
            Set    fechaTermino = Getdate(),
                   informado    = 1
            Where  idProceso    = @w_idProceso;
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
   @w_valor          Varchar(1500) = 'Consulta y Reporta los Objetos no válidos de la BD Seleecionada.',
   @w_procedimiento  Varchar( 100) = 'Spp_AnalisisObjetosNoValidos'


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

