Use SCMBD
Go


/*

Declare
   @PnIdProceso             Integer      = 0,
   @PnIdUsuarioAct          Integer      = 18,
   @PnEstatus               Integer      = 0,
   @PsMensaje               Varchar(250);

Begin
   Execute dbo.spp_notificaObjetosNoValidos @PnIdProceso    = @PnIdProceso,
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

Create Or Alter Procedure dbo.spp_notificaObjetosNoValidos
  (@PnIdProceso                Integer,
   @PnIdUsuarioAct             Integer,
   @PnEstatus                  Integer      = 0    Output,
   @PsMensaje                  Varchar(250) = Null Output)
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
   @w_tablaOrigen              Sysname,
   @w_idProceso                Bigint,
   @w_linea                    Integer,
--
   @w_idSession                Varchar(  64),
   @w_idEstatus                Tinyint,
   @w_idGrupo                  Integer,
   @w_idMotivoCorreo           Integer,
   @w_parametros               Varchar( Max),
   @w_account_name             Sysname,
   @w_grupoCorreo              Varchar(  20),
   @w_idAplicacion             Integer,
   @w_fechaProc                Date,
   @w_fechaInicial             Date,
   @w_ambiente                 Varchar(100),
   @w_instancia                Sysname,
--

   @w_html                     Nvarchar( Max),

--

   @w_idAplicacionBD           Integer,
   @w_idReceptor               Integer,
   @w_aplicacion               Varchar(100),
   @w_cuerpo                   Varchar(Max),
   @w_body                     Varchar(Max),
   @w_saludo                   Varchar(100),
   @w_nombre                   Varchar(100),
   @w_correo                   Varchar(100),
   @w_asunto                   Varchar(250),
   @w_ipOrigen                 Varchar( 30),
   @w_server                   Sysname,
   @w_servidorOrigen           Sysname,
   @w_idCorreo                 Integer,
   @w_registrosUser            Integer;


Begin

/*

Objetivo:    Genera Notificación de las Objetos de la Base de Datos no Válidos.
Programador: Pedro Felipe Zambrano
Fecha:       31/10/2025
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
          @w_comilla            = Char(39),
          @w_secuencia          = 0,
          @w_saludo             = '<p>' + dbo.Fn_calculaSaludo(),
          @w_server             = @@Servername;

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
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus);

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

--
-- Creación de Tablas Temporales.
--

   Create Table #tempObjetos
   (secuencia                 Integer       Not Null Identity(1, 1) Primary Key,
    server                    Sysname         Not Null,
    baseDatos                 Sysname         Not Null,
    correlativo               Integer         Not Null,
    tipo                      Varchar(  2)    Not Null,
    objeto                    Sysname         Not Null,
    mensajeError              Varchar(200)    Not Null)

   Create Table #UsuarioReceptorCorreo
   (secuencia    Integer       Not Null Identity(1, 1) Primary Key,
    idReceptor   Integer       Not Null);

   Create Table  #GrupoReceptorCorreoDet
   (secuencia    Integer       Not Null Identity(1, 1) Primary Key,
    idReceptor   Integer       Not Null,
    correo       Varchar(250)      Null,
    nombre       Varchar(100)      Null);

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

   Select  @w_account_name = Cast(descripcion as Sysname),
           @w_cuerpo       = html
   From    dbo.conMotivosCorreoTbl
   Where   idMotivo   = @w_idMotivoCorreo
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 6200,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)

         Goto Salida
      End

   Begin Try
      Select @w_grupoCorreo     = dbo.Fn_splitStringColumna(@w_parametros, '|',  1),
             @w_servidorOrigen  = dbo.Fn_splitStringColumna(@w_parametros, '|',  2),
             @w_basedatos       = dbo.Fn_splitStringColumna(@w_parametros, '|',  3),
             @w_instancia       = dbo.Fn_splitStringColumna(@w_parametros, '|',  4),
             @w_ambiente        = dbo.Fn_splitStringColumna(@w_parametros, '|',  5),
             @w_idAplicacion    = dbo.Fn_splitStringColumna(@w_parametros, '|',  6),
             @w_asunto          = dbo.Fn_splitStringColumna(@w_parametros, '|',  7),
             @w_idProceso       = dbo.Fn_splitStringColumna(@w_parametros, '|',  8),
             @w_tablaOrigen     = dbo.Fn_splitStringColumna(@w_parametros, '|',  9),
             @w_ipOrigen        = dbo.Fn_splitStringColumna(@w_parametros, '|', 10),
             @w_fechaProc       = Getdate(),
             @w_fechaInicial    = DateAdd(dd, -6, @w_fechaProc);
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

   Select @w_aplicacion = descripcion
   From   dbo.catAplicacionesTbl
   Where  idAplicacion = @w_idAplicacion
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 2046,
                @PsMensaje = dbo.Fn_Busca_MensajeError (@PnEstatus);

         Update dbo.conProcesosTbl
         Set    idEstatus           = 4,
                registrosProcesados = 0,
                fechaTermino        = Getdate(),
                mensajeProc         = @PsMensaje,
                tiempoProceso       = Datediff(ss, fechaInicio, Getdate())
         Where  idProceso           = @PnIdProceso;

         Set Xact_Abort Off
         Return

      End

   Select @w_idGrupo   = idGrupo,
          @w_idEstatus = idEstatus
   From   dbo.conGrupoReceptorCorreoTbl
   Where  codigoGrupo = @w_grupoCorreo
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 554,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)

      End

   If @w_idEstatus != 1
      Begin
         Select @PnEstatus = 555,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)

      End

   If @PnEstatus != 0
      Begin
         Update dbo.conProcesosTbl
         Set    idEstatus           = 4,
                mensajeProc         = @PsMensaje ,
                registrosProcesados = 0,
                fechaTermino        = Getdate(),
                tiempoProceso       = Datediff(SS, fechaInicio, Getdate()),
                idUsuarioAct        = @PnIdUsuarioAct
         Where  idProceso = @PnIdProceso

         Set Xact_Abort Off
         Return
      End

--
-- Consulta de los Usuarios Receptores de Correos.
--

   Insert Into  #UsuarioReceptorCorreo
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

         Update dbo.conProcesosTbl
         Set    idEstatus           = 4,
                mensajeProc         = @PsMensaje ,
                registrosProcesados = 0,
                fechaTermino        = Getdate(),
                tiempoProceso       = Datediff(SS, fechaInicio, Getdate()),
                idUsuarioAct        = @PnIdUsuarioAct
         Where  idProceso = @PnIdProceso

         Set Xact_Abort Off
         Return
      End


--

   Set @w_sql = 'Select idUsuario, correo, nombre ' +
                'From   dbo.segUsuariosTbl a '      +
                'Where  idUsuario In ('


   While @w_secuencia < @w_registros
   Begin
      Set @w_secuencia = @w_secuencia + 1

      Select @w_idReceptor = idReceptor
      From   #UsuarioReceptorCorreo
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

   Set @w_sql = @w_sql + ') ' +
                         'And Not Exists ( Select Top 1 1
                                           From   dbo.catCorreosNoValidosTbl
                                           Where  correo = a.correo)'

--

   Begin Try
      Insert Into #GrupoReceptorCorreoDet
     (idReceptor, correo, nombre)
      Execute(@w_sql)

      Set @w_registrosUser = @@Identity
   End Try

   Begin Catch
      Select  @w_Error       = @@Error,
              @w_desc_error  = Substring (Error_Message(), 1, 230),
              @w_linea       = error_line();
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error en Linea ', @w_linea, ' ', @w_Error, ' ', @w_desc_error);

         Update dbo.conProcesosTbl
         Set    idEstatus           = 4,
                mensajeProc         = @PsMensaje ,
                registrosProcesados = 0,
                fechaTermino        = Getdate(),
                tiempoProceso       = Datediff(SS, fechaInicio, Getdate()),
                idUsuarioAct        = @PnIdUsuarioAct
         Where  idProceso = @PnIdProceso

         Set Xact_Abort Off
         Return
      End

--

   Set @w_sql = Concat('Select servidor, databaseName, correlativo, ',
                              'tipo,     objectName,   ErrorMensaje ',
                       'From  ', @w_tablaOrigen, ' ',
                       'Where  idProceso =   ', @w_idProceso, ' ',
                       'And    informado = 1 ',
                       'Order  By correlativo');

   Begin Try
      Insert Into #tempObjetos
      (server, baseDatos, correlativo, tipo, objeto, mensajeError)
      Execute (@w_sql);

      Select @w_secuencia = 0,
             @w_registros = @@Rowcount;

   End Try

   Begin Catch
      Select  @w_Error       = @@Error,
              @w_desc_error  = Substring (Error_Message(), 1, 230),
              @w_linea       = error_line();
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error en Linea ', @w_linea, ' ', @w_Error, ' ', @w_desc_error);

         Update dbo.conProcesosTbl
         Set    idEstatus           = 4,
                mensajeProc         = @PsMensaje ,
                registrosProcesados = 0,
                fechaTermino        = Getdate(),
                tiempoProceso       = Datediff(SS, fechaInicio, Getdate()),
                idUsuarioAct        = @PnIdUsuarioAct
         Where  idProceso = @PnIdProceso

         Set Xact_Abort Off
         Return
      End


--
-- Consulta de la Aplicación Relacionada a la Base de datos.
--

   If Isnull(@w_registros, 0)  = 0
      Begin
         Select @PnEstatus = 99,
                @PsMensaje = dbo.Fn_Busca_MensajeError (@PnEstatus);

         Update dbo.conProcesosTbl
         Set    idEstatus           = 4,
                registrosProcesados = 0,
                fechaTermino        = Getdate(),
                mensajeProc         = @PsMensaje,
                tiempoProceso       = Datediff(ss, fechaInicio, Getdate())
         Where  idProceso           = @PnIdProceso;

         Set Xact_Abort Off
         Return

      End

   Select @w_ipOrigen = Replace(@w_ipOrigen, '<', ''),
          @w_ipOrigen = Replace(@w_ipOrigen, '>', '');

   Select @w_cuerpo = Replace(@w_cuerpo, '&saludos&',       Trim(@w_saludo)),
          @w_cuerpo = Replace(@w_cuerpo, '&incidencia%',    Concat('<b>','EXISTEN OBJETOS NO VÁLIDOS', '</b>')),
          @w_cuerpo = Replace(@w_cuerpo, '&server&',        Concat('<b>', @w_server,      '</b>')),
          @w_cuerpo = Replace(@w_cuerpo, '&ip&',            Concat('<b>', @w_ipOrigen,    '</b>')),
          @w_cuerpo = Replace(@w_cuerpo, '&instancia&',     Concat('<b>', @w_instancia,   '</b>')),
          @w_cuerpo = Replace(@w_cuerpo, '&BaseDatos&',     Concat('<b>', @w_basedatos,   '</b>')),
          @w_cuerpo = Replace(@w_cuerpo, '&ambiente&',      Concat('<b>', @w_ambiente,    '</b>')),
          @w_cuerpo = Replace(@w_cuerpo, '&tabla&',         Concat('<b>', @w_tablaOrigen, '</b>')),
          @w_cuerpo = Replace(@w_cuerpo, '&idProceso%',     Concat('<b>', @w_idProceso,   '</b>'));

--
-- Construcción del correo
--

   Set @w_sql = Concat('Select top 20 baseDatos "Base de Datos", tipo "Tipo Objeto", objeto "Objeto", ',
                        'mensajeError "Motivo de No Valides" ',
                'From   #tempObjetos
                 Order by 2, 3 ')

   Set @w_html = ''

   Execute dbo.Spp_ProcesaConsultaHtmlTable @PsConsulta   = @w_sql,
                                            @PsOrdenPres  = ' ',
                                            @PsHTML       = @w_html    Output,
                                            @PnEstatus    = @PnEstatus Output,
                                            @PsMensaje    = @PsMensaje Output;



   If @PnEstatus != 0
      Begin
         Goto Salida
      End
--

   Select  @w_cuerpo = @w_cuerpo + '<h3><u>LISTA DE OBJETOS NO VÁLIDOS</u></h3>'

   Select  @w_cuerpo = @w_cuerpo + @w_html,
           @w_cuerpo = @w_cuerpo + '</body></html>' + '<p>  <b> NOTA: Este correo es de caracter informativo, favor de NO Replicar y NO Responder </p>  </b>

       </tbody>
   </html>'

--

   Set @w_secuencia = 0

   While @w_secuencia < @w_registrosUser
   Begin
      Select @w_idCorreo  = 0,
             @w_secuencia = @w_secuencia + 1

      Select @w_nombre = nombre,
             @w_correo = correo
      From   #GrupoReceptorCorreoDet
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
                       @w_desc_error  = Substring (Error_Message(), 1, 230),
                       @w_linea       = error_line();
            End   Catch

            If Isnull(@w_Error, 0) <> 0
               Begin
                  Select @PnEstatus = @w_Error,
                         @PsMensaje = Concat('Error en Linea ', @w_linea, ' ', ltrim(@w_Error), ' ', @w_desc_error);

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

            Set @w_sql = Concat('Update dbo.', @w_tablaOrigen, ' ',
                                'Set    informado    = 2, ',
                                       'fechaTermino = ', @w_comilla, Getdate(), @w_comilla, ' ',
                                'Where  idProceso = ', @w_idProceso);

            Begin Try
               Execute (@w_sql)
            End Try

            Begin Catch
               Select  @w_Error       = @@Error,
                       @w_desc_error  = Substring (Error_Message(), 1, 230),
                       @w_linea       = error_line();
            End   Catch

            If Isnull(@w_Error, 0) <> 0
               Begin
                  Select @PnEstatus = @w_Error,
                         @PsMensaje = Concat('Error en Linea ', @w_linea, ' ', ltrim(@w_Error), ' ', @w_desc_error);

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

         Update dbo.catControlProcesosTbl
         Set    ultFechaNotifif    = Getdate()
         Where  idProceso = 5;

      End

--
   Return

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Genera Notificación de las Objetos de la Base de Datos no Válidos.',
   @w_procedimiento  NVarchar(250) = 'spp_notificaObjetosNoValidos';

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
