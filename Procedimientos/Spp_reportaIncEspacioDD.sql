Use SCMBD
Go

/*

Declare
   @PnIdProceso                   Integer       = 1,
   @PnEstatus                     Integer       = 0,
   @PsMensaje                     Varchar( 250) = '';

Begin
   Execute dbo.Spp_reportaIncEspacioDD @PnIdProceso = @PnIdProceso,
                                         @PnEstatus   = @PnEstatus Output,
                                         @PsMensaje   = @PsMensaje Output;

   Select @PnEstatus, @PsMensaje

   Return

End
Go

*/

Create Or Alter Procedure dbo.Spp_reportaIncEspacioDD
  (@PnIdProceso                   Integer       = 0,
   @PnIdUsuarioAct                Integer       = Null,
   @PnEstatus                     Integer       = 0  Output,
   @PsMensaje                     Varchar( 250) = '' Output)

As

Declare
   @w_Error                 Integer,
   @w_desc_error            Varchar( 250),
   @w_parametros            Varchar( Max),
   @w_titulo                Varchar( 200),
   @w_cuerpo                Varchar(1000),
   @w_body                  Varchar(1000),
   @w_body2                 Varchar(1000),
   @w_body3                 Varchar(1000),
   @w_html                  Varchar(8000),
   @w_html2                 Varchar(8000),
   @w_incidencia            Varchar( 250),
   @w_servidor              Varchar( 100),
   @w_grupoCorreo           Varchar(  20),
   @w_ip                    Varchar(  30),
   @w_correo                Varchar( 250),
   @w_fechaProceso          Varchar(  10),
   @w_saludo                Varchar( 100),
   @w_nombre                Varchar( 100),
   @w_idSession             Varchar(  30),
   @w_url                   Varchar( 250),
   @w_url2                  Varchar( 250),
   @w_nota                  Varchar( 100),
   @w_observacion1          Varchar( 250),
   @w_observacion2          Varchar( 250),
   @w_usuario               Varchar( Max),
   @w_query                 Varchar(1000),
   @w_ambiente              Varchar(  80),
   @w_instancia             Varchar(  80),
   @w_sql                   NVarchar(1500),
   @w_param                 NVarchar( 750),
   @w_idUsuario             Integer,
   @w_idGrupo               Integer,
   @w_registros             Integer,
   @w_secuencia             Integer,
   @w_mailitem_id           Integer,
   @w_idProceso             Integer,
   @w_idEstatus             Tinyint,
   @w_idUsuarioAct          Integer,
   @w_idTipoNotificacion    Smallint,
   @w_idMotivoCorreo        Smallint,
   @w_idAplicacion          Smallint,
   @w_fechaAct              Datetime,
   @w_account_name          Sysname,
   @w_tabla                 Sysname,
   @w_objeto                Sysname,
   @w_totaldisponible       Varchar(80),
   @w_porcentajeLibre       Varchar(80);

Begin
/*

Objetivo:    Generación de Notificaciones por Incidencias en Tiempos de Proceso.
Programador: Pedro Felipe Zambrano
Fecha:       05/05/2025


*/

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    On
   Set Ansi_Warnings On
   Set Ansi_Padding  On

   Select @PnEstatus   = 0,
          @PsMensaje   = '',
          @w_registros = 0,
          @w_secuencia = 0,
          @w_saludo    = dbo.Fn_calculaSaludo();

   If @PnIdUsuarioAct Is Null
      Begin
         Select @w_usuario = parametroChar
         From   dbo.conParametrosGralesTbl
         Where  idParametroGral = 8

         Select @w_sql   = 'Select @o_usuario = dbo.Fn_Desencripta_cadena(' + @w_usuario + ') ',
                @w_param = '@o_usuario Varchar(Max) Output '

         Execute Sp_ExecuteSQL @w_sql, @w_param, @o_usuario = @w_usuario Output

         Set @w_idUsuarioAct = Cast(@w_usuario As Smallint)
      End
   Else
      Begin
         Set @w_idUsuarioAct = @PnIdUsuarioAct
      End

--
-- Generación de Tabla Temporal
--

   Create Table #TempGrupoReceptorCorreoDet
   (secuencia    Integer       Not Null Identity(1, 1) Primary Key,
    idReceptor   Integer       Not Null)

--
-- Búsqueda de Parametros
--

   Select @w_idSession          = idSession,
          @w_idMotivoCorreo     = idMotivoCorreo,
          @w_parametros         = parametros,
          @w_idTipoNotificacion = idTipoNotificacion,
          @w_url                = urlArchivoSalida,
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

   If @w_idTipoNotificacion Not Between 0 And 2
      Begin
         Select @PnEstatus = 6202,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)

         Goto Salida
      End

   Select  @w_account_name =  Cast(descripcion as Sysname),
           @w_titulo       =  titulo,
           @w_cuerpo       =  cuerpo,
           @w_html         =  html
   From    dbo.conMotivosCorreoTbl
   Where   idMotivo   = @w_idMotivoCorreo
   If @@Rowcount = 0
   Begin
      Select @PnEstatus = 6200,
             @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)

      Goto Salida
   End

   Select @w_grupoCorreo     = dbo.Fn_splitStringColumna(@w_parametros, '|', 1),
          @w_servidor        = dbo.Fn_splitStringColumna(@w_parametros, '|', 2),
          @w_ip              = dbo.Fn_splitStringColumna(@w_parametros, '|', 3),
          @w_instancia       = dbo.Fn_splitStringColumna(@w_parametros, '|', 4),
          @w_ambiente        = dbo.Fn_splitStringColumna(@w_parametros, '|', 5),
          @w_idAplicacion    = dbo.Fn_splitStringColumna(@w_parametros, '|', 6),
          @w_incidencia      = dbo.Fn_splitStringColumna(@w_parametros, '|', 7),
          @w_idProceso       = dbo.Fn_splitStringColumna(@w_parametros, '|', 8),
          @w_tabla           = dbo.Fn_splitStringColumna(@w_parametros, '|', 9),
          @w_totaldisponible = dbo.Fn_splitStringColumna(@w_parametros, '|', 10),
          @w_porcentajeLibre = dbo.Fn_splitStringColumna(@w_parametros, '|', 11),
          @w_titulo          = @w_incidencia;

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

   Select @w_observacion1 = '<b> Para Mayor Información Consulte la Tabla: ' + @w_tabla + '</b> ',
          @w_observacion2 = '<b> NOTA: Este correo es de caracter informativo, favor de NO Replicar y NO Responder </b>';

   Select @w_ip = Replace(@w_ip, '<', ''),
          @w_ip = Replace(@w_ip, '>', '');

   Select @w_html = Replace(@w_html,     '&saludos&',       @w_saludo),
          @w_html = Replace(@w_html,     '&incidencia%',    @w_incidencia),
          @w_html = Replace(@w_html,     '&tabla&',         @w_tabla),
          @w_html = Replace(@w_html,     '&idProceso%',     @w_idProceso),
          @w_html = Replace(@w_html,     '&server&',        @w_servidor),
          @w_html = Replace(@w_html,     '&instancia&',     @w_instancia),
          @w_html = Replace(@w_html,     '&ambiente&',      @w_ambiente),
          @w_html = Replace(@w_html,     '&ip&',            @w_ip),
          @w_html = Replace(@w_html,     '&query%',         @w_totaldisponible),
          @w_html = Replace(@w_html,     'Query:',          'Espacio Disponible:    '),
          @w_html = Replace(@w_html,     '&objeto%',        @w_porcentajeLibre),
          @w_html = Replace(@w_html,     'objeto:',         'Porcentaje Disponible: '),
          @w_html = Replace(@w_html,     '&Observacion1&',  @w_observacion1),
          @w_html = Replace(@w_html,     '&Observacion2&',  @w_observacion2)

   Set @w_html = '<Notificacion><html><body><DIV Align="justify"> ' + @w_html

   Insert Into #TempGrupoReceptorCorreoDet
   (idReceptor)
   Select idReceptor
   From   dbo.conGrupoReceptorCorreoDetTbl
   Where  idGrupo   = @w_idGrupo
   And    idEstatus = 1;
   Set @w_registros = @@Identity


   While @w_secuencia < @w_registros
   Begin
      Set @w_secuencia = @w_secuencia + 1
      Select @w_idUsuario = idReceptor
      From   #TempGrupoReceptorCorreoDet
      Where  secuencia = @w_secuencia
      If @@Rowcount = 0
         Begin
            Break
         End

      Select @w_correo = correo,
             @w_nombre = nombre
      From   dbo.segUsuariosTbl
      Where  idUsuario = @w_idUsuario
      And    idEstatus = 1;
      If @@Rowcount = 0
         Begin
            Goto Siguiente
         End

      If @w_idTipoNotificacion In (0, 2)
         Begin
            Select @w_body2 = Replace(@w_body,  '&Nombre&', @w_nombre),
                   @w_body3 = Replace(@w_body2, '&URL&',    Concat(Char(126), @w_url, Char(126)));

            Insert Into dbo.conEmisionNotificacionesTbl
            (idSession,          idAplicacion,            idPrioridad,        idMotivoCorreo,
             idTipoNotificacion, tokenGoogleDestinatario, correoDestinatario, asunto,
             body,               urlArchivos,             adjuntos,           fechaEnvioNotificacion,
             idEstatus,          idOrigen)
             Select Distinct @w_idSession,         @w_idAplicacion,    1 idPrioridad, @w_idMotivoCorreo,
                             0 idTipoNotificacion, b.tokenGoogle,      @w_correo,     @w_titulo,
                             @w_body3,             Isnull(@w_url,''),  '' adjuntos,   Null,
                             1 idEstatus,          b.idOrigen
             From   dbo.segRelUsuariosTokenTbl b
             Where  b.idUsuario    = @w_idUsuario
             And    b.idAplicacion = 6
             And    b.idEstatus    = 1
             And    b.tokenGoogle Is Not Null
             And    Exists        ( Select Top 1 1
                                    From   dbo.segRelAplicacionUsuarioTbl
                                    Where  idUsuario    = b.idUsuario
                                    And    idAplicacion = @w_idAplicacion
                                    And    idEstatus    = 1)

             Set @w_registros = @w_registros + 1


         End

         If @w_idTipoNotificacion In (1, 2)
            Begin
               If Exists (Select Top 1 1
                          From   dbo.catCorreosNoValidosTbl
                          Where  correo = @w_correo)
                  Begin
                     Goto Siguiente
                  End

               Set @w_html2 = Replace(@w_html,  '&Nombre&', @w_nombre);

               Execute msdb.dbo.sp_send_dbmail @profile_name            = @w_account_name,
                                               @recipients              = @w_correo,
                                               @Subject                 = @w_titulo,
                                               @Body                    = @w_html2,
                                               @importance              = 'High',
                                               @body_format             = 'HTML',
                                               @mailitem_id             = @w_mailitem_id Output;

               If Isnull(@w_mailitem_id, 0) != 0
                  Begin
                     Select @w_fechaAct  = Getdate(),
                            @w_idEstatus = Isnull(@w_registros, 0) + 1

                     Insert Into dbo.movEnvioCorreosTbl
                     (mailitem_id,    fechaEnvio, idProceso, idAplicacion,
                      idMotivoCorreo, correo,     subject,   idEstatus,
                      servidor)
                      Select @w_mailitem_id,    @w_fechaAct, @PnIdProceso, @w_idAplicacion,
                             @w_idMotivoCorreo, @w_correo,   @w_titulo,    1,
                             @@Servername

                      Update dbo.logProcesosEspacioDDTbl
                      Set    fechaTermino  = Getdate(),
                             informado     = 2
                      From   dbo.logProcesosEspacioDDTbl a
                      Where  idProceso = @w_idProceso;
                      
                      Update dbo.catControlProcesosTbl
                      Set    ultFechaNotifif    = Getdate()
                      Where  idProceso = 17   

                  End
            End

Siguiente:

   End

   If @w_registros = 0
   Begin
      Select @PnEstatus = 556,
             @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)
   End

Salida:

   If @PnEstatus != 0
      Begin
         Set @w_idEstatus = 4
      End
   Else
      Begin
         Select @w_idEstatus = Case When @w_idTipoNotificacion = 2
                                    Then 6
                                    Else 3
                               End,
                @PsMensaje   = Case When @w_idTipoNotificacion = 0
                                    Then 'Notificaciones Enviadas OK'
                                    When @w_idTipoNotificacion = 1
                                    Then 'Solicitud Envio de Correos OK'
                                    Else 'Proceso Terminado Ok'
                               End;
      End

   Set @w_fechaAct  = Getdate()

   Update dbo.conProcesosTbl
   Set    idEstatus           = @w_idEstatus,
          mensajeProc         = @PsMensaje,
          registrosProcesados = @w_registros,
          fechaTermino        = @w_fechaAct,
          tiempoProceso       = Isnull(Datediff(SS, fechaInicio, @w_fechaAct), 0),
          idUsuarioAct        = @w_idUsuarioAct
   Where  idProceso = @PnIdProceso

  Set Xact_Abort Off
  Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Generación de Notificaciones por Incidencias de Disponibilidad de Espacio libre en DD.',
   @w_procedimiento  Varchar( 100) = 'Spp_reportaIncEspacioDD'


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
