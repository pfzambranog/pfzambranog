Use SCMBD
Go


/*

Declare
   @PnIdProceso             Integer      = 3518128,
   @PnIdUsuarioAct          Integer      = 18,
   @PnEstatus               Integer      = 0,
   @PsMensaje               Varchar(250);

Begin
   Execute dbo.Spp_notificaAnalisisLinkedServers @PnIdProceso    = @PnIdProceso,
                                                 @PnIdUsuarioAct = @PnIdUsuarioAct,
                                                 @PnEstatus      = @PnEstatus Output,
                                                 @PsMensaje      = @PsMensaje Output;

   If @PnEstatus != 0
      Begin
         Select @PnEstatus As Estatus, @PsMensaje As Mensaje
     End

   Return

End
Go
*/

Create Or Alter Procedure dbo.Spp_notificaAnalisisLinkedServers
  (@PnIdProceso             Integer,
   @PnIdUsuarioAct          Integer,
   @PnEstatus               Integer      = 0    Output,
   @PsMensaje               Varchar(250) = Null Output)
As

Declare
   @w_error                    Integer,
   @w_desc_error               Varchar(  250),
   @w_registros                Integer,
   @w_secuencia                Integer,
   @w_sql                      NVarchar( 1500),
   @w_param                    NVarchar(  750),
   @w_comilla                  Char(1),
   @w_basedatos                Sysname,
   @w_tablaLog                 Sysname,
--
   @w_idSession                Varchar(  64),
   @w_idEstatus                Tinyint,
   @w_idGrupo                  Integer,
   @w_idMotivoCorreo           Integer,
   @w_parametros               Varchar( Max),
   @w_account_name             Sysname,
   @w_grupoCorreo              Varchar(  20),
   @w_idAplicacion             Integer,
   @w_fechaInicial             Date,
   @w_fechaTermino             Date,
--
   @w_comando                  Varchar(8000),
   @w_salida                   Varchar(8000),
   @w_consultaTexto            NVarchar(2048),
   @w_consultaEncriptada       NVarchar(4000),
   @w_html                     Nvarchar(MAX),
   @w_idObject                 Integer,
   @w_archivoXML               Xml,
   @w_cadenaEncriptada         Varchar(4000),
   @w_URL                      Varchar( 750),
   @w_incidencia               Varchar( 250),
--
   @w_procedimiento            Sysname,
   @w_ultimaEjecucion          Datetime,
   @w_cantidadEjecuciones      Integer,
   @w_tiempoMinimoEjecucion    Decimal(18, 2),
   @w_tiempoMaximoEjecucion    Decimal(18, 2),
--
   @w_idReceptor               Integer,
   @w_aplicacion               Varchar(100),
   @w_cuerpo                   Varchar(Max),
   @w_body                     Varchar(Max),
   @w_saludo                   Varchar(100),
   @w_nombre                   Varchar(100),
   @w_correo                   Varchar(100),
   @w_asunto                   Varchar(250),
   @w_ipOrigen                 Varchar( 20),
   @w_server                   Sysname,
   @w_instancia                Sysname,
   @w_ambiente                 Sysname,
   @w_linea                    Integer,
   @w_idCorreo                 Integer,
   @w_registrosUser            Integer,
   @w_idProceso                Integer;

Declare
   @w_UsuarioReceptorCorreo Table
   (secuencia    Integer       Not Null Identity(1, 1) Primary Key,
    idReceptor   Integer       Not Null);

Declare
   @w_GrupoReceptorCorreoDet Table
   (secuencia    Integer       Not Null Identity(1, 1) Primary Key,
    idReceptor   Integer       Not Null,
    correo       Varchar(250)      Null,
    nombre       Varchar(100)      Null);

Begin

-- Objetivo:    Genera Notificación de Problemas de conexión de los Linked Server.
-- Programador: Pedro Felipe Zambrano
-- Fecha:       31/10/2025
-- Versión:     1
--

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

--
-- Inicializamos Variables
--

   Select @PnEstatus            = 0,
          @PsMensaje            = '',
          @w_comilla            = Char(39),
          @w_secuencia          = 0,
          @w_saludo             = dbo.Fn_calculaSaludo(),
          @w_server             = @@Servername;

--
-- Creación de Tablas Temporales.
--

   Create Table   #tempLinkServer
   (secuencia                 Integer        Not Null,
    servidor                  Sysname        Not Null,
    linkServer                Sysname        Not Null,
    actividad                 Varchar(Max)   Not Null,
    fechaInicio               Datetime       Not Null,
    fechaTermino              Datetime           Null,
    error                     Integer        Not Null,
    mensajeError              Varchar(250)   Not Null)

--
-- Búsqueda de Parámetros.
--

   Select @w_idSession          = idSession,
          @w_idMotivoCorreo     = idMotivoCorreo,
          @w_parametros         = parametros,
          @w_idEstatus          = idEstatus
   From   dbo.conProcesosTbl
   Where  idProceso = @PnIdProceso
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 3000,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort Off
         Return
      End

   If @w_idEstatus != 1
      Begin
         Select @PnEstatus = Case When @w_idEstatus = 2
                                  Then 2999
                                  Else 3004
                             End,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus);

         Set Xact_Abort Off
         Return
      End

   Select  @w_account_name = perfilCorreo,
           @w_cuerpo       = html,
           @w_asunto       = descripcion,
           @w_URL          = URL
   From    dbo.conMotivosCorreoTbl
   Where   idMotivo   = @w_idMotivoCorreo
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 6200,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)

         Goto Salida
      End


--
-- Inicio de Proceso
--

   Update dbo.conProcesosTbl
   Set    idEstatus           = 2,
          registrosProcesados = 0,
          fechaInicio         = Getdate(),
          fechaTermino        = Null,
          mensajeProc         = 'En Proceso',
          tiempoProceso       = 0
   Where  idProceso           = @PnIdProceso;

   Begin Try
      Select @w_grupoCorreo     = dbo.Fn_splitStringColumna(@w_parametros, '|',  1),
             @w_server          = dbo.Fn_splitStringColumna(@w_parametros, '|',  2),
             @w_ipOrigen        = dbo.Fn_splitStringColumna(@w_parametros, '|',  3),
             @w_instancia       = dbo.Fn_splitStringColumna(@w_parametros, '|',  4),
             @w_ambiente        = dbo.Fn_splitStringColumna(@w_parametros, '|',  5),
             @w_basedatos       = dbo.Fn_splitStringColumna(@w_parametros, '|',  6),
             @w_idAplicacion    = dbo.Fn_splitStringColumna(@w_parametros, '|',  7),
             @w_incidencia      = dbo.Fn_splitStringColumna(@w_parametros, '|',  8),
             @w_idProceso       = dbo.Fn_splitStringColumna(@w_parametros, '|',  9),
             @w_tablaLog        = dbo.Fn_splitStringColumna(@w_parametros, '|', 10),
             @w_registros       = dbo.Fn_splitStringColumna(@w_parametros, '|', 11);

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

   If Isnull(@w_registros, 0) = 0
      Begin
         Select @PnEstatus = 98,
                @PsMensaje = Concat('Error en Linea ', @w_linea, ' ', ltrim(@w_Error), ' ', @w_desc_error);

         Goto Salida
      End

   Select @w_idGrupo   = idGrupo,
          @w_idEstatus = idEstatus
   From   dbo.conGrupoReceptorCorreoTbl
   Where  codigoGrupo = @w_grupoCorreo
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 554,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)

         Goto Salida
      End

   If @w_idEstatus != 1
      Begin
         Select @PnEstatus = 555,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)

         Goto Salida
      End

--
-- Consulta de los Usuarios Receptores de Correos.
--

   Insert Into  @w_UsuarioReceptorCorreo
   (idReceptor)
   Select b.idReceptor
   From   dbo.conGrupoReceptorCorreoDetTbl b
   Where  b.idEstatus  = 1
   And    b.idGrupo    = @w_idGrupo
   Set @w_registros = @@Identity;

   If @w_registros = 0
      Begin
               Select @PnEstatus  = 99,
                      @PsMensaje  = dbo.Fn_Busca_MensajeError(@PnEstatus)

          Goto Salida
      End

--

   Set @w_sql = 'Select idUsuario, correo, nombre ' +
                'From   dbo.segUsuariosTbl '        +
                'Where  idUsuario In ('

   While @w_secuencia < @w_registros
   Begin
      Set @w_secuencia = @w_secuencia + 1
      Select @w_idReceptor = idReceptor
      From   @w_UsuarioReceptorCorreo
      Where  secuencia = @w_secuencia;
      If @@Rowcount = 0
         Begin
            Break
         End

      If @w_secuencia != 1
         Begin
            Set @w_sql = @w_sql + ', '
         End

      Set @w_sql = Concat(@w_sql,  @w_idReceptor)

   End

   Set @w_sql = @w_sql + ')'

--

   Begin Try
      Insert Into @w_GrupoReceptorCorreoDet
     (idReceptor, correo, nombre)
      Execute(@w_sql)
      Set @w_registrosUser = @@Identity
   End Try

   Begin Catch
      Select  @w_Error       = @@Error,
              @w_desc_error  = Substring (Error_Message(), 1, 230)
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

         Update dbo.conProcesosTbl
         Set    idEstatus           = 4,
                mensajeProc         = @PsMensaje ,
                registrosProcesados = 1,
                fechaTermino        = Getdate(),
                tiempoProceso       = Datediff(SS, fechaInicio, Getdate()),
                idUsuarioAct        = @PnIdUsuarioAct
         Where  idProceso = @PnIdProceso

         Set Xact_Abort Off
         Return
      End

--

   Insert Into #tempLinkServer
   (secuencia,   servidor,     linkServer, actividad,
    fechaInicio, fechaTermino, error,      mensajeError)
   Select secuencia,   servidor,     linkServer, actividad,
          fechaInicio, fechaTermino, error,      mensajeError
   From   dbo.logAnalisisLSTbl a
   Where  informado   = 1
   And    idProceso   = @w_idProceso;

   Select @w_secuencia = 0,
          @w_registros = @@Rowcount;


   Select  @w_fechaInicial = Min(fechaInicio), @w_fechaTermino = Max(fechaTermino)
   From    #tempLinkServer;

--
-- Construcción del correo
--

   Select @w_cuerpo = Replace(@w_cuerpo, '&saludos&',       Trim(@w_saludo)),
          @w_cuerpo = Replace(@w_cuerpo, '&incidencia%',    @w_asunto),
          @w_cuerpo = Replace(@w_cuerpo, '&server&',        @w_server),
          @w_cuerpo = Replace(@w_cuerpo, '&ip&',            @w_ipOrigen),
          @w_cuerpo = Replace(@w_cuerpo, '&instancia&',     @w_instancia),
          @w_cuerpo = Replace(@w_cuerpo, '&BaseDatos&',     @w_basedatos),
          @w_cuerpo = Replace(@w_cuerpo, '&ambiente&',      @w_ambiente),
          @w_cuerpo = Replace(@w_cuerpo, '&t_tabla&',       @w_tablalOG),
          @w_cuerpo = Replace(@w_cuerpo, '&proceso&',       @w_incidencia),
          @w_cuerpo = Replace(@w_cuerpo, '&idproceso&',     @w_idProceso);


   Set @w_sql = Concat('Select Top 10 servidor "Servidor Destino", linkServer "Linked Server", ',
                              'fechaTermino "Fecha Proceso", error "Código Error",   mensajeError "Mensaje Error" ',
                       'From   #tempLinkServer ',
                       'Order by secuencia ')

   Execute dbo.Spp_ProcesaConsultaHtmlTable @PsConsulta   = @w_sql,
                                            @PsOrdenPres  = ' ',
                                            @PsHTML       = @w_html    Output,
                                            @PnEstatus    = @PnEstatus Output,
                                            @PsMensaje    = @PsMensaje Output;

   If @PnEstatus != 0
      Begin
         Goto Salida
      End

   Set @w_cuerpo = Replace(@w_cuerpo, '&tabla2&',     @w_html)
--
   Set @w_secuencia = 0

   While @w_secuencia < @w_registrosUser
   Begin
      Set @w_secuencia = @w_secuencia + 1

      Select @w_nombre = nombre,
             @w_correo = correo
      From   @w_GrupoReceptorCorreoDet
      Where  secuencia = @w_secuencia;
      If @@Rowcount = 0
         Begin
            Break
         End

      Set @w_body = Replace(@w_cuerpo, '&Nombre&', @w_nombre);

      Execute msdb.dbo.sp_send_dbmail @profile_name          = @w_account_name,
                                      @recipients            = @w_correo,
                                      @Subject               = @w_asunto,
                                      @Body                  = @w_body,
                                      @importance            = 'High',
                                      @body_format           = 'HTML',
                                      @mailitem_id           = @w_idCorreo Output

      If @w_idCorreo != 0
         Begin
            Begin Try
               Insert Into dbo.movEnvioCorreosTbl
               (mailitem_id,    fechaEnvio, idProceso, idAplicacion,
                idMotivoCorreo, correo,     subject,   idEstatus,
                servidor)
                Select @w_idCorreo,         Getdate(),         @PnIdProceso,     @w_idAplicacion,
                       @w_idMotivoCorreo,   @w_correo,         @w_asunto,        1,
                       @@ServerName         servidor
            End Try

            Begin Catch
               Select  @w_Error       = @@Error,
                       @w_desc_error  = Substring (Error_Message(), 1, 230)
            End   Catch

            If Isnull(@w_Error, 0) <> 0
               Begin
                  Select @PnEstatus = @w_Error,
                         @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar)))

                  Update conProcesosTbl
                  Set    idEstatus           = 4,
                         mensajeProc         = @PsMensaje ,
                         registrosProcesados = 1,
                         fechaTermino        = Getdate(),
                         tiempoProceso       = Datediff(SS, fechaInicio, Getdate()),
                         idUsuarioAct        = @PnIdUsuarioAct
                  Where  idProceso = @PnIdProceso

                  Set Xact_Abort Off
                  Return
               End

         End

   End

Salida:

   If @PnEstatus != 0
      Begin
         Update dbo.conProcesosTbl
         Set    idEstatus           = 4,
                registrosProcesados = 0,
                fechaTermino        = Getdate(),
                mensajeProc         = @PsMensaje,
                tiempoProceso       = Datediff(ss, fechaInicio, Getdate())
         Where  idProceso           = @PnIdProceso;
      End
   Else
      Begin
         Update dbo.conProcesosTbl
         Set    idEstatus           = 3,
                registrosProcesados = @w_secuencia,
                fechaTermino        = Getdate(),
                mensajeProc         = 'Correos Enviados OK',
                tiempoProceso       = Datediff(ss, fechaInicio, Getdate())
         Where  idProceso           = @PnIdProceso;

        Update dbo.logAnalisisLSTbl
        Set    informado       = 2,
               fechaTermino = Getdate()
        From   dbo.logAnalisisLSTbl a
        Where  informado   = 1
        And    idProceso   = @w_idProceso;

        Update dbo.catControlProcesosTbl
        Set    ultFechaNotifif = Getdate()
        Where  idProceso = 11
      End

--
   Return

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Genera Notificación de Problemas de conexión de los Linked Server.',
   @w_procedimiento  NVarchar(250) = 'Spp_notificaAnalisisLinkedServers';

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
