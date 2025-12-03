Use SCMBD
Go

/*
Declare
   @w_idProceso           Integer      = 0,
   @PnEstatus             Integer      = 0,
   @PsMensaje             Varchar(250) = Null;

Begin
   Select @w_idProceso = Max(idProceso)
   From   dbo.logMantenimientoDepTablaTbl

   Execute Spp_MantenimientoDepuraTablas @PnEstatus = @PnEstatus Output,
                                         @PsMensaje = @PsMensaje Output

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

   Select *
   From   dbo.logMantenimientoDepTablaTbl
   Where  idProceso > Isnull(@w_idProceso, 0)

   Return

End
Go

*/

Create Or Alter Procedure dbo.Spp_MantenimientoDepuraTablas
  (@PnEstatus              Integer      = 0     Output,
   @PsMensaje              Varchar(250) = Null  Output)
As

Declare
   @w_error                Integer,
   @w_desc_error           Varchar(  250),
   @w_ambiente             Varchar(  250),
   @w_incidencia           Varchar(  850),
   @w_proceso              Varchar(  100),
   @w_ip                   Varchar(   30),
   @w_grupoCorreo          Varchar(   20),
   @w_usuario              Varchar(  Max),
   @w_parametros           Varchar(  Max),
   @w_dbname               Sysname,
   @w_baseDatos            Sysname,
   @w_tabla                Sysname,
   @w_tablalOG             Sysname,
   @w_campo                Sysname,
   @w_procedimiento        Sysname,
   @w_servidor             Sysname,
   @w_instancia            Sysname,
   @w_query                Nvarchar( Max),
   @w_sql                  NVarchar(1500),
   @w_param                NVarchar( 750),
   @w_comilla              Char(1),
   @w_fechaInicio          Datetime,
   @w_fechaAct             Datetime,
   @w_fechaComp            Date,
   @w_fechaProc            Date,
   @w_idTipoNotificacion   Tinyint,
   @w_idEstatus            Tinyint,
   @w_secuencia            Integer,
   @w_idAplicacion         Integer,
   @w_idMotivoCorreo       Integer,
   @w_dias                 Integer,
   @w_registros            Integer,
   @w_idProceso            Integer,
   @w_idProcesoLog         Integer,
   @w_idUsuarioAct         Integer;

Declare
   C_DepPaso1 Cursor For
   Select idProceso, baseDatos, tabla, campo, dias
   From   dbo.catMantenimentoTablasTbl a
   Where  servidor  = @@ServerName
   And    idTipoDep = 1
   And    idEstatus = 1
   And    Exists    ( Select Top 1 1
                      From   sys.databases
                      Where  state_desc = 'ONLINE'
                      And    name       = a.baseDatos);

Declare
   C_DepPaso2 Cursor For
   Select idProceso, baseDatos, tabla, Concat(a.baseDatos, '.dbo.', a.procedimiento), dias
   From   dbo.catMantenimentoTablasTbl a
   Where  servidor  = @@ServerName
   And    idTipoDep = 2
   And    idEstatus = 1
   And    Exists    ( Select Top 1 1
                      From   sys.databases
                      Where  state_desc = 'ONLINE'
                      And    name       = a.baseDatos);

Begin
/*

Objetivo:    Procedimiento de Depuración de datos en tablas incluidas en la entidad catMantenimentoTablasTbl.
Programador: Pedro Felipe Zambrano
Fecha:       06/05/2025

*/

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

--
-- Incializamos Variables
--

   Select @PnEstatus            = 0,
          @PsMensaje            = Null,
          @w_comilla            = Char(39),
          @w_servidor           = @@ServerName,
          @w_instancia          = @@servicename,
          @w_idMotivoCorreo     = 112,
          @w_idAplicacion       = 27,
          @w_secuencia          = 0,
          @w_fechaAct           = Getdate(),
          @w_fechaProc          = @w_fechaAct,
          @w_dbname             = Db_name(),
          @w_ip                 = dbo.Fn_buscaDireccionIP();

   Select @w_ip = Replace(@w_ip, '(', ''),
          @w_ip = Replace(@w_ip, ')', '');

   If @w_servidor like '%'+ Char(92) + '%'
      Begin
         Set @w_servidor = dbo.Fn_splitStringColumna(@w_servidor, Char(92), 1)
      End

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

   Set @w_idUsuarioAct = Cast(@w_usuario As Integer)

   Select @w_grupoCorreo        = codigoGrupoCorreo,
          @w_idTipoNotificacion = idTipoNotificacion,
          @w_tablalOG           = tablaLog,
          @w_proceso            = descripcion,
          @w_idEstatus          = idEstatus
   From   dbo.catControlProcesosTbl
   Where  idProceso = 13
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
   From   dbo.logMantenimientoDepTablaTbl;
   Set @w_idProceso = Isnull(@w_idProceso, 0) + 1;

   Open  C_DepPaso1
   While @@Fetch_status < 1
   Begin
      Fetch C_DepPaso1 Into @w_secuencia, @w_baseDatos, @w_tabla, @w_campo, @w_dias
      If @@Fetch_status != 0
         Begin
            Break
         End

      Select @w_fechaInicio = Getdate(),
             @PnEstatus     = 0,
             @PsMensaje     = '',
             @w_registros   = 0;

      Begin Try
         Insert Into dbo.logMantenimientoDepTablaTbl
         (idProceso, secuencia, servidor, baseDatos, tabla)
         Select @w_idProceso, @w_secuencia, @w_servidor, @w_baseDatos, @w_tabla

      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 230)
      End   Catch

      If Isnull(@w_Error, 0)  <> 0
         Begin
            Select @PnEstatus  = @w_Error,
                   @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

            Goto Siguiente
         End

      Select @w_dias      = @w_dias * -1,
             @w_fechaComp = DateAdd(dd, @w_dias, @w_fechaProc);

      Select @w_sql   = Concat('Select @o_salida = Count(1) ',
                               'From  ', @w_baseDatos, '.dbo.', @w_tabla, ' ',
                               'Where  Cast(', @w_campo , ' As Date) <= ', @w_comilla, @w_fechaComp, @w_comilla),
             @w_param = '@o_salida Integer Output';

      Execute Sp_ExecuteSQL @w_sql, @w_param, @o_salida = @w_registros Output;                        

      If @w_registros = 0
         Begin
            Select @PnEstatus = 98,
                   @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus);

            Update dbo.logMantenimientoDepTablaTbl
            Set    registros    = Isnull(@w_registros, 0),
                   fechaTermino = Getdate(),
                   error        = @PnEstatus,
                   mensajeError = @PsMensaje
            Where  idProceso = @w_idProceso
            And    secuencia = @w_secuencia;

            Goto Siguiente
         End
         
      Set @w_sql = Concat('Delete ', @w_baseDatos, '.dbo.', @w_tabla, ' ',
                          'Where  Cast(',  @w_campo, ' As Date) <= ', @w_comilla, @w_fechaComp, @w_comilla);

      Begin Try
         Execute(@w_sql)
      End   Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 230)
      End   Catch

      If Isnull(@w_Error, 0)  <> 0
         Begin
            Select @PnEstatus  = @w_Error,
                   @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error;
         End

      Set @w_query = @w_sql;

      Update dbo.logMantenimientoDepTablaTbl
      Set    registros    = Isnull(@w_registros, 0),
             fechaTermino = Getdate(),
             error        = @PnEstatus,
             mensajeError = @PsMensaje
      Where  idProceso = @w_idProceso
      And    secuencia = @w_secuencia;

      Update dbo.catMantenimentoTablasTbl
      Set    ultFechaProceso = Getdate()
      Where  idProceso = @w_secuencia

      Select @w_incidencia = 'Proceso de Baja de Registros '

      Set @w_parametros = Concat(@w_grupoCorreo,  '|', @w_servidor,     '|',
                                 @w_ip,           '|', @w_instancia,    '|',
                                 @w_ambiente,     '|', @w_baseDatos,    '|',
                                 @w_idAplicacion, '|', @w_incidencia,   '|',
                                 @w_idProceso,    '|', @w_tablaLog,     '|',
                                 @w_registros);

      Execute dbo.Spa_conProcesosTbl @PnIdMotivo           = @w_idMotivoCorreo,
                                     @PnIdTipoNotificacion = @w_idTipoNotificacion,
                                     @PsParametros         = @w_parametros,
                                     @PdFechaProgramada    = @w_fechaAct,
                                     @PnIdUsuarioAct       = @w_idUsuarioAct,
                                     @PnEstatus            = @PnEstatus  Output,
                                     @PsMensaje            = @PsMensaje  Output

      If @PnEstatus = 0
         Begin
            Update dbo.logMantenimientoDepTablaTbl
            Set    registros    = Isnull(@w_registros, 0),
                   fechaTermino = Getdate(),
                   error        = @PnEstatus,
                   mensajeError = @PsMensaje,
                   informado    = 1
            Where  idProceso = @w_idProceso

         End

Siguiente:

   End

   Close      C_DepPaso1
   Deallocate C_DepPaso1

   Open  C_DepPaso2
   While @@Fetch_status < 1
   Begin
      Fetch C_DepPaso2 Into @w_secuencia, @w_baseDatos, @w_tabla, @w_procedimiento, @w_dias
      If @@Fetch_status != 0
         Begin
            Break
         End

      Select @w_fechaInicio = Getdate(),
             @PnEstatus     = 0,
             @PsMensaje     = '',
             @w_registros   = 0;

        
      Begin Try
         Insert Into dbo.logMantenimientoDepTablaTbl
         (idProceso, secuencia, servidor, baseDatos, tabla)
         Select @w_idProceso, @w_secuencia, @w_servidor, @w_baseDatos, @w_tabla

      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 230)
      End   Catch

      If Isnull(@w_Error, 0)  <> 0
         Begin
            Select @PnEstatus  = @w_Error,
                   @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

            Goto SiguienteProc
         End

      Select @w_dias      = @w_dias * -1,
             @w_fechaComp = DateAdd(dd, @w_dias, Cast(@w_fechaProc As Date))

     Execute @w_procedimiento @PdFechaBase    = @w_fechaComp,
                              @PnIdUsuarioAct = @w_idUsuarioAct,
                              @PnEstatus      = @PnEstatus  Output,
                              @PsMensaje      = @PsMensaje  Output;

     If Isnumeric(@PsMensaje) = 1
        Begin
           Select @w_registros = Cast(@PsMensaje As Integer),
                  @PsMensaje   = ''

        End

      Update dbo.logMantenimientoDepTablaTbl
      Set    registros    = Isnull(@w_registros, 0),
             fechaTermino = Getdate(),
             error        = @PnEstatus,
             mensajeError = @PsMensaje,
             informado    = 1
      Where  idProceso = @w_idProcesoLog

      Update dbo.catMantenimentoTablasTbl
      Set    ultFechaProceso = Getdate()
      Where  idProceso = @w_idProceso

SiguienteProc:

   End

   Close      C_DepPaso2
   Deallocate C_DepPaso2

Salida:

   Set Xact_Abort Off
   Return

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Depuración de datos en tablas incluidas en la entidad catMantenimentoTablasTbl.',
   @w_procedimiento  NVarchar(250) = 'Spp_MantenimientoDepuraTablas';

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
