Use SCMBD
Go

/*

Declare
   @PsBaseDatos                Sysname      = 'SCMBD',
   @PbSolicictaNotificacion    Bit          = 0,
   @PnEstatus                  Integer      = 0,
   @PsMensaje                  Varchar(250);

Begin
   Execute dbo.Spp_analizaEjecucionProcedimientos @PsBaseDatos             = @PsBaseDatos,
                                                  @PbSolicictaNotificacion = @PbSolicictaNotificacion,
                                                  @PnEstatus               = @PnEstatus Output,
                                                  @PsMensaje               = @PsMensaje Output;

   If @PnEstatus != 0
      Begin
         Select @PnEstatus As Estatus, @PsMensaje As Mensaje
     End

   Return

End
Go
*/

Create or Alter Procedure dbo.Spp_analizaEjecucionProcedimientos
  (@PsBaseDatos                Sysname      = Null,
   @PbSolicictaNotificacion    Bit          = 0,
   @PnEstatus                  Integer      = 0    Output,
   @PsMensaje                  Varchar(250) = Null Output)
As

Declare
   @w_error                 Integer,
   @w_desc_error            Varchar(  250),
   @w_usuario               Varchar(  250),
   @w_codigoGrupoCorreo     Varchar(   20),
   @w_grupoCorreo           Varchar(   20),
   @w_ip                    Varchar(   30),
   @w_proceso               Varchar(  100),
   @w_incidencia            Varchar(  100),
   @w_parametros            Varchar(  Max),
   @w_object                Sysname,
   @w_baseDatos             Sysname,
   @w_servidor              Sysname,
   @w_instancia             Sysname,
   @w_ambiente              Sysname,
   @w_tablaLog              Sysname,
   @w_idAplicacion          Integer,
   @w_registros             Integer,
   @w_idUsuarioAct          Integer,
   @w_secuencia             Integer,
   @w_dias                  Integer,
   @w_idProceso             Integer,
   @w_linea                 Integer,
   @w_idMotivoCorreo        Smallint,
   @w_idTipoNotificacion    Tinyint,
   @w_idEstatus             Tinyint,
   @w_fechaProc             Date,
   @w_fechaAct              Datetime,
   @w_fechaProcesoAnt       Datetime,
   @w_sql                   NVarchar( 1500),
   @w_param                 NVarchar(  750),
   @w_estado                NVarchar(  120),
   @w_comilla               Char(1);

Declare
   @w_tempObjetos  Table
   (secuencia        Integer        Not Null Identity (1, 1) Primary Key,
    baseDatos        Sysname        Not Null,
    procedimiento    Sysname        Not Null,
    ultimaEjecucion  Datetime       Not Null,
    cantidad         Integer        Not Null,
    tiempoMinimo     Decimal(18, 2) Not Null Default 0.00,
    tiempoMaximo     Decimal(18, 2) Not Null Default 0.00)

Begin

/*

Objetivo:    Análisis de Ejecuciones de Procedimientos Compilados en Base de Datos.
Programador: Pedro Felipe Zambrano
Fecha:       28/09/2025
Versión:     1

*/

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off


--
-- Inicializamos Variables
--

   Select @PnEstatus            = 0,
          @PsMensaje            = '',
          @w_secuencia          = 0,
          @w_idMotivoCorreo     = 107,
          @w_comilla            = Char(39),
          @w_baseDatos          = Db_name(),
          @PsBaseDatos          = Isnull(@PsBaseDatos, @w_baseDatos),
          @w_fechaAct           = Getdate(),
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
-- Validación.
--

   Select @w_estado = state_desc
   From   sys.databases
   Where  name       = @PsBaseDatos
   If @@Rowcount = 0
      Begin
         Select @PnEstatus  = 8000,
                @PsMensaje  = dbo.Fn_Busca_MensajeError(@PnEstatus)

         Goto Salida
      End

   If @w_estado != 'ONLINE'
      Begin
         Select @PnEstatus  = 8002,
                @PsMensaje  = dbo.Fn_Busca_MensajeError(@PnEstatus)

         Goto Salida
      End

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
          @w_idTipoNotificacion = idTipoNotificacion,
          @w_tablalOG           = tablaLog,
          @w_proceso            = descripcion,
          @w_idEstatus          = idEstatus
   From   dbo.catControlProcesosTbl
   Where  idProceso = 6
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
   From   dbo.logHistorialEjecucionProcTbl;

   Set @w_idProceso = Isnull(@w_idProceso, 0) + 1;

   Set @w_sql = Concat('Select a.name, ',
                              'object_name(object_id, d.database_id), ',
                              'd.last_execution_time, d.execution_count, ',
                              'Round(min_worker_time / 1000000.00, 2), ',
                              'Round(max_worker_time / 1000000.00, 2) ',
                       'From   sys.dm_exec_procedure_stats  d ',
                       'Join   sys.databases a ',
                       'On     a.database_id = d.database_id ',
                       'Where  name          = ', @w_comilla, @PsBaseDatos, @w_comilla, ' ',
                       'And    type          = ', @w_comilla, 'P',          @w_comilla, ' ',
                       'Order by 5 desc');

    Begin Try
       Insert Into @w_tempObjetos
      (baseDatos,    procedimiento, ultimaEjecucion, cantidad,
       tiempoMinimo, tiempoMaximo)
       Execute (@w_sql);
       Set @w_registros = @@Rowcount
    End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230),
              @w_linea      = error_line()
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error en Linea ', @w_linea, ' ', ltrim(@w_Error), ' ', @w_desc_error);

         Goto Salida
      End

    If @w_registros = 0
       Begin
          Select @w_registros
          Goto Salida
       End

    While @w_secuencia < @w_registros
    Begin
       Set @w_secuencia = @w_secuencia + 1

       Select @w_object = procedimiento
       From   @w_tempObjetos
       Where  secuencia = @w_secuencia
       If @@Rowcount = 0
          Begin
             Break
          End

       Select @w_fechaProcesoAnt = Max(fechaProcesoAct)
       From   dbo.logHistorialEjecucionProcTbl
       Where  baseDatos = @PsBaseDatos
       And    procedimiento = @w_object

       If @w_fechaProcesoAnt Is Null
          Begin
             Set @w_fechaProcesoAnt = @w_fechaAct
          End

       Set @w_dias = Datediff(dd, @w_fechaProcesoAnt, @w_fechaAct) + 1;

       Insert Into dbo.logHistorialEjecucionProcTbl
       (idProceso,          secuencia,       baseDatos,       procedimiento,
        ultimaEjecucion,    fechaProcesoAnt, fechaProcesoAct, dias,
        cantidad,           tiempoMinimo,    tiempoMaximo)
       Select @w_idProceso,    @w_secuencia,        baseDatos,       procedimiento,
              ultimaEjecucion, @w_fechaProcesoAnt,  @w_fechaAct,     @w_dias,
              cantidad,        tiempoMinimo,        tiempoMaximo
       From   @w_tempObjetos a
       Where  secuencia = @w_secuencia
       And    Not Exists ( Select Top 1 1
                           From   dbo.logHistorialEjecucionProcTbl
                           Where  baseDatos                     = a.baseDatos
                           And    procedimiento                 = a.procedimiento
                           And    Cast(fechaProcesoAct As Date) = Cast(@w_fechaAct As Date))



       Set @w_sql = 'Use ' +  @PsBaseDatos + '; Execute sp_recompile ' + @w_object

       Begin Try
          Execute (@w_sql)
       End Try

       Begin Catch
          Select  @w_Error      = @@Error,
                  @w_desc_error = Substring (Error_Message(), 1, 230)

       End   Catch

       If IsNull(@w_Error, 0) <> 0
          Begin
             Select @PnEstatus = @w_Error,
                    @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error
          End

    End


Salto:

    If @PbSolicictaNotificacion = 0
       Begin
          Goto Salida
       End

    Select  @w_codigoGrupoCorreo = codigoGrupoCorreo,
            @w_idEstatus         = idEstatus
    From    dbo.relBaseDatosGrupoCorreoTbl
    Where   baseDatos = @PsBaseDatos
    If @@Rowcount = 0
       Begin
          Select @PnEstatus = 557,
                 @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)
          Goto Salida
       End

    If @w_idEstatus = 0
       Begin
          Select @PnEstatus = 555,
                 @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)
          Goto Salida
       End

      Set @w_incidencia = 'Análisis y Validación de Ejecuciones de Procedimientos'

      Set @w_parametros = Concat(@w_grupoCorreo,  '|', @w_servidor,     '|',
                                 @w_ip,           '|', @w_instancia,    '|',
                                 @w_ambiente,     '|', @w_baseDatos,    '|',
                                 @w_idAplicacion, '|', @w_incidencia,   '|',
                                 @w_tablaLog,     '|', @w_idProceso);

      Execute dbo.Spa_conProcesosTbl @PnIdMotivo           = @w_idMotivoCorreo,
                                     @PnIdTipoNotificacion = @w_idTipoNotificacion,
                                     @PsParametros         = @w_parametros,
                                     @PdFechaProgramada    = @w_fechaAct,
                                     @PnIdUsuarioAct       = @w_idUsuarioAct,
                                     @PnEstatus            = @PnEstatus  Output,
                                     @PsMensaje            = @PsMensaje  Output

      Update dbo.logHistorialEjecucionProcTbl
      Set    informado    = 1
      Where  idProceso = @w_idProceso

      Update dbo.catControlProcesosTbl
      Set    ultFechaEjecucion = Getdate()
      Where  idProceso = 6

Salida:

    Set Xact_Abort    Off
    Return

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Anális de Ejecuciones de Procedimientos Compilados en Base de Datos Seleccionada.',
   @w_procedimiento  NVarchar(250) = 'Spp_analizaEjecucionProcedimientos';

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

