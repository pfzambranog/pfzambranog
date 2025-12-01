Use SCMBD
Go

/*

Declare
   @PsBaseDatos             Sysname      = 'SCMBD',
   @PbGeneraNotificacion    Bit          = 0,
   @PnEstatus               Integer      = 0,
   @PsMensaje               Varchar(250);

Begin
   Execute dbo.Spp_analizaEjecucionProcedimientos @PsBaseDatos          = @PsBaseDatos,
                                                  @PbGeneraNotificacion = @PbGeneraNotificacion,
                                                  @PnEstatus            = @PnEstatus Output,
                                                  @PsMensaje            = @PsMensaje Output;

   If @PnEstatus != 0
      Begin
         Select @PnEstatus As Estatus, @PsMensaje As Mensaje
     End

   Return

End
Go
*/

Create or Alter Procedure dbo.Spp_analizaEjecucionProcedimientos
  (@PsBaseDatos             Sysname,
   @PbGeneraNotificacion    Bit          = 0,
   @PnEstatus               Integer      = 0    Output,
   @PsMensaje               Varchar(250) = Null Output)
As

Declare
   @w_error                 Integer,
   @w_desc_error            Varchar(  250),
   @w_usuario               Varchar(  250),
   @w_codigoGrupoCorreo     Varchar(   20),
   @w_parametros            Varchar(  Max),
   @w_object                Sysname,
   @w_baseDatos             Sysname,
   @w_registros             Integer,
   @w_idUsuarioAct          Integer,
   @w_secuencia             Integer,
   @w_dias                  Integer,
   @w_idMotivoCorreo        Smallint,
   @w_idEstatus             Tinyint,
   @w_fechaProc             Date,
   @w_fechaAct              Datetime,
   @w_fechaProcesoAnt       Datetime,
   @w_sql                   NVarchar( 1500),
   @w_param                 NVarchar(  750),
   @w_estado                NVarchar(  120);

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
          @w_idMotivoCorreo     = 111,
          @w_baseDatos          = Db_name(),
          @w_fechaAct           = Getdate();

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

   Select @w_usuario = parametroChar
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 17

   Select @w_sql   = 'Select @o_usuario = dbo.Fn_Desencripta_cadena(' + @w_usuario + ') ',
          @w_param = '@o_usuario Varchar(Max) Output '

   Execute Sp_ExecuteSQL @w_sql, @w_param, @o_usuario = @w_usuario Output

   Set @w_idUsuarioAct = Cast(@w_usuario As Smallint)

    Insert Into @w_tempObjetos
   (baseDatos,    procedimiento, ultimaEjecucion, cantidad,
    tiempoMinimo, tiempoMaximo)
    Select a.name,
           object_name(object_id, d.database_id),
           d.last_execution_time, d.execution_count,
           Round(min_worker_time / 1000000.00, 2),
           Round(max_worker_time / 1000000.00, 2)
    From   sys.dm_exec_procedure_stats  d
    Join   sys.databases a
    On     a.database_id = d.database_id
    Where  name = @PsBaseDatos
    And    type = 'P'
    Order by 5 desc

    Set @w_registros = @@Identity

    If @w_registros = 0
       Begin
          Goto Salida
       End

Goto Salto

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
       Where  procedimiento = @w_object

       If @w_fechaProcesoAnt Is Null
          Begin
             Set @w_fechaProcesoAnt = @w_fechaAct
          End

       Set @w_dias = Datediff(dd, @w_fechaProcesoAnt, @w_fechaAct) + 1;

       Insert Into dbo.logHistorialEjecucionProcTbl
       (baseDatos,       procedimiento, ultimaEjecucion, fechaProcesoAnt,
        fechaProcesoAct, dias,          cantidad,        tiempoMinimo,
        tiempoMaximo)
       Select baseDatos,    procedimiento,  ultimaEjecucion, @w_fechaProcesoAnt,
              @w_fechaAct,  @w_dias,        cantidad,        tiempoMinimo,
              tiempoMaximo
       From   @w_tempObjetos
       Where  secuencia = @w_secuencia

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

    If Exists (Select Top 1 1
               From   sys.databases
               Where  name       = @PsBaseDatos
               And    state_desc = 'ONLINE')
       Begin
          Insert Into dbo.logHistorialEjecucionProcTbl
          (baseDatos,       procedimiento, ultimaEjecucion, fechaProcesoAnt,
           fechaProcesoAct, dias,          cantidad,        tiempoMinimo,
           tiempoMaximo)
          Select baseDatos,       procedimiento, ultimaEjecucion, fechaProcesoAnt,
                 fechaProcesoAct, dias,          cantidad,        tiempoMinimo,
                 tiempoMaximo
          From   dbo.logHistorialEjecucionProcTbl a
          Where  baseDatos  = @PsBaseDatos
          And    Not Exists ( Select Top 1 1
                              From   dbo.logHistorialEjecucionProcTbl
                              Where  baseDatos       = a.baseDatos
                              And    procedimiento   = a.procedimiento
                              And    fechaProcesoAct = a.fechaProcesoAct)
       End

Salto:

    If @PbGeneraNotificacion = 0
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


    Select @w_fechaProc  = @w_fechaAct,
           @w_parametros =  Concat(@PsBaseDatos, '|', @w_codigoGrupoCorreo, '|', '27', '|', @w_fechaProc);

    Select @w_parametros 

Salida:

    Set Xact_Abort    Off
    Return

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Análisa las Ejecuciones de Procedimientos Compilados en Base de Datos Seleccionada.',
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

