Use SCMBD
Go


/*
Declare
   @PdFechaProceso        Date         = Null,
   @PsIdProceso           Varchar(250) = '3, 4',
   @PnEstatus             Integer      = 0,
   @PsMensaje             Varchar(250) = Null;

Begin
   Execute Spp_SolicitaCorreoMasivoMantBD @PdFechaProceso = @PdFechaProceso,
                                          @PsIdProceso    = @PsIdProceso,
                                          @PnEstatus      = @PnEstatus Output,
                                          @PsMensaje      = @PsMensaje Output

   Select @PnEstatus, @PsMensaje

   Return

End
Go

*/

Create Or Alter Procedure Spp_SolicitaCorreoMasivoMantBD
  (@PdFechaProceso        Date         = Null,
   @PsIdProceso           Varchar(250),
   @PnEstatus             Integer      = 0     Output,
   @PsMensaje             Varchar(250) = Null  Output)
As

Declare
   @w_error                 Integer,
   @w_desc_error            Varchar( 250),
   @w_parametros            Varchar( Max),
   @w_incidencia            Varchar( 250),
   @w_mensaje               Varchar( 250),
   @w_mensajeError          Varchar( 250),
   @w_servidor              Varchar( 100),
   @w_grupoCorreo           Varchar(  20),
   @w_correo                Varchar( 250),
   @w_descripcion           Varchar( 100),
   @w_link                  Varchar( 512),
   @w_ambiente              Varchar(  80),
   @w_fechaProceso          Date,
   @w_fechaAct              Datetime,
   @w_usuario               Varchar( Max),
   @w_sql                   NVarchar(1500),
   @w_param                 NVarchar( 750),
   @w_idAplicacion          Smallint,
   @w_idMotivoCorreo        Smallint,
   @w_idTipoNotificacion    Tinyint,
   @w_idUsuarioAct          Integer,
   @w_registros             Integer,
   @w_registros2            Integer,
   @w_secuencia             Integer,
   @w_tabla                 Sysname,
   @w_existe                Tinyint,
   @w_enviaNotificacion     Tinyint,
   @w_idFiltraError         Bit,
   @w_comilla               Char(1),
   @w_idProceso             Integer,
   @w_mensajeProc           Varchar(250);

Begin
/*

Objetivo:    Generación de Solicitud de Notificaciones por Incidencias.
Programador: Pedro Felipe Zambrano
Fecha:       06/05/2022

*/
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

--
-- Inicializamos Variables
--

   Select @PnEstatus            = 0,
          @PsMensaje            = Null,
          @w_fechaProceso       = Getdate(),
          @PdFechaProceso       = Isnull(@PdFechaProceso, @w_fechaProceso),
          @w_servidor           = @@ServerName,
          @w_idMotivoCorreo     = 106,
          @w_idTipoNotificacion = 1,
          @w_idAplicacion       = 27,
          @w_registros          = 0,
          @w_secuencia          = 0,
          @w_fechaAct           = Getdate(),
          @w_comilla            = Char(39);

--
-- Generación de Tabla Temporal
--

   Create Table #TempControlProcesos
   (secuencia              Integer        Not Null Identity(1, 1)  Primary key,
    idProceso              Integer        Not Null,
    descripcion            Varchar(100)   Not Null,
    tablaLog               Sysname            Null,
    mensaje                Varchar(Max)       Null,
    mensajeError           Varchar(Max)       Null,
    idTipoNotificacion     Tinyint            Null,
    enviaNotificacion      Tinyint            Null,
    idFiltraError          Bit            Not Null,
    link                   Varchar(512)       Null,
    codigoGrupoCorreo      Varchar( 30)       Null)

   Create Table #TempProcesos
   (secuencia    Integer       Not Null Identity(1, 1) Primary Key,
    idProceso    Integer       Not Null)

--
-- Busqueda de Parámetros
--

   Select @w_ambiente = Upper(parametroChar)
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 16
   If @@Rowcount = 0
      Begin
         Set @w_ambiente = ''
      End

   Set @w_servidor = Concat(@w_servidor, '-', 'AMBIENTE.: ', @w_ambiente)

   Select @w_usuario = parametroChar
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 9

   Select @w_sql      = 'Select @o_cadena = idUsuarioAct
                         From Openquery(Scsti, ''Select scsti.dbo.Fn_Desencripta_cadena(' + @w_usuario + ') idUsuarioAct '')',
          @w_param    = '@o_cadena Varchar(Max) Output '

   Execute Sp_ExecuteSQL @w_sql, @w_param, @o_cadena = @w_usuario Output

   Set @w_idUsuarioAct = Cast(@w_usuario As Integer)

   Set @w_sql = 'Select idProceso,          descripcion,        tablaLog,       mensaje,
                        mensajeError,       idTipoNotificacion, idFiltraError,  enviaNotificacion,
                        link,               codigoGrupoCorreo
                 From   dbo.catControlProcesosTbl
                 Where  idEstatus  = 1
                 And    idProceso In (' + @PsIdProceso + ')'

   Begin Try
      Insert Into #TempControlProcesos
     (idProceso,    descripcion,        tablaLog,          mensaje,
      mensajeError, idTipoNotificacion, idFiltraError,     enviaNotificacion,
      link,         codigoGrupoCorreo)
      Execute(@w_sql)
      Set @w_registros = @@Identity
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch

   If Isnull(@w_Error, 0)  <> 0
      Begin
         Select @PnEstatus  = @w_Error,
                @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

         Set Xact_Abort    Off
         Return
      End

   While @w_secuencia < @w_registros
   Begin
      Set @w_secuencia = @w_secuencia + 1;
      Select @w_idProceso          = idProceso,
             @w_descripcion        = descripcion,
             @w_tabla              = tablaLog,
             @w_mensaje            = mensaje,
             @w_mensajeError       = mensajeError,
             @w_idTipoNotificacion = idTipoNotificacion,
             @w_enviaNotificacion  = enviaNotificacion,
             @w_idFiltraError      = idFiltraError,
             @w_link               = link,
             @w_grupoCorreo        = codigoGrupoCorreo
      From   #TempControlProcesos
      Where  secuencia = @w_secuencia;
      If @@Rowcount = 0
      Begin
         Break
      End

      Select @w_registros2  = 0,
             @w_existe      = 0,
             @PnEstatus     = 0,
             @PsMensaje     = '',
             @w_incidencia  = Null;

      If Not Exists ( Select Top 1 1
                      From   dbo.conGrupoReceptorCorreoTbl
                      Where  codigoGrupo = @w_grupoCorreo)
         Begin
            Goto Siguiente
         End

      Select @w_sql   = 'Select @o_registros = Count(1)
                         From   dbo.' + @w_tabla  + '
                         Where  Cast(fechaInicio as Date) = ' + @w_comilla + Cast(@PdFechaProceso As Varchar) + @w_comilla + '
                         And    informado                 = 0',
             @w_param = '@o_registros    Integer Output'

      Execute Sp_ExecuteSQL @w_sql, @w_param, @o_registros = @w_registros2 Output

      If Isnull(@w_registros2, 0) = 0
         Begin
            Goto Siguiente
         End

      If @w_enviaNotificacion  = 0 Or
         @w_registros          = 0
         Begin
            Goto Siguiente
         End

      Set @w_incidencia = Concat(@w_descripcion, ' IdProceso.:', @w_idProceso)

      Set @w_parametros = Concat(@w_grupoCorreo, '|', @w_incidencia, '|', @w_servidor, '|',
                                 Convert(Char(10), @PdFechaProceso, 103), '|', @w_idAplicacion)

      Execute dbo.Spa_conProcesosTbl @PnIdMotivo           = @w_idMotivoCorreo,
                                               @PnIdTipoNotificacion = @w_idTipoNotificacion,
                                               @PsParametros         = @w_parametros,
                                               @PsURL                = @w_link,
                                               @PdFechaProgramada    = @w_fechaAct,
                                               @PnIdUsuarioAct       = @w_idUsuarioAct,
                                               @PnEstatus            = @PnEstatus  Output,
                                               @PsMensaje            = @PsMensaje  Output

      If @PnEstatus = 0
         Begin
         Set @w_sql   = 'Update dbo.' + @w_tabla  + '
                         Set    Informado    = 1,
                                fechaTermino = ' +  @w_comilla + Cast(Getdate() As Varchar) + @w_comilla + '
                         Where  idProceso = ' + Cast(@w_idProceso As Varchar);

            Begin Try
               Execute (@w_sql)
            End   Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_desc_error = Substring (Error_Message(), 1, 230)
            End   Catch

            If Isnull(@w_Error, 0)  <> 0
               Begin
                  Select @PnEstatus  = @w_Error,
                         @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

                  Break
               End
         End

Siguiente:

   End

   If Isnull(@PsMensaje, '') = ''
      Begin
         Set @PsMensaje = @w_mensajeProc
      End

   Set Xact_Abort    Off
   Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Solicitud de Notificaciones por Proceso Mantenimiento de Base de Datos.',
   @w_procedimiento  NVarchar(250) = 'Spp_SolicitaCorreoMasivoMantBD';

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
