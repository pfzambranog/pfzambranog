  
/*  
  
Declare  
   @PnIdProceso             Integer      = 3507095,  
   @PnIdUsuarioAct          Integer      = 18,  
   @PnEstatus               Integer      = 0,  
   @PsMensaje               Varchar(250);  
  
Begin  
   Execute Spp_notificaAnalisisEjecucionProc @PnIdProceso    = @PnIdProceso,  
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
  
Alter   Procedure Spp_notificaAnalisisEjecucionProc  
  (@PnIdProceso             Integer      = Null,  
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
--  
   @w_comando                  Varchar(8000),  
   @w_salida                   Varchar(8000),  
   @w_consultaTexto            NVarchar(2048),  
   @w_consultaEncriptada       NVarchar(4000),  
   @w_idObject                 Integer,  
   @w_archivoXML               Xml,  
   @w_cadenaEncriptada         Varchar(4000),  
   @w_URL                      Varchar( 750),  
--  
   @w_procedimiento            Sysname,  
   @w_ultimaEjecucion          Datetime,  
   @w_CantidadEjecuciones      Integer,  
   @w_tiempoMinimoEjecucion    Decimal(18, 2),  
   @w_tiempoMaximoEjecucion    Decimal(18, 2),  
--          
   @w_cuerpo                   Varchar(Max),  
   @w_body                     Varchar(Max);  
  
Declare  
   @w_TempXml Table  
   (archivo    Xml Null)  
  
Declare  
   @w_tempObjetos  Table  
   (secuencia                 Integer        Not Null Identity (1, 1) Primary Key,  
    baseDatos                 Sysname        Not Null,  
    procedimiento             Sysname        Not Null,  
    ultimaEjecucion           Datetime       Not Null,  
    CantidadEjecuciones       Integer        Not Null,  
    tiempoMinimoEjecucion     Decimal(18, 2) Not Null Default 0.00,  
    tiempoMaximoEjecucion     Decimal(18, 2) Not Null Default 0.00)  
  
Declare  
   @w_GrupoReceptorCorreoDet Table  
   (secuencia    Integer       Not Null Identity(1, 1) Primary Key,  
    idReceptor   Integer       Not Null)  
  
Begin  
  
/*  
  
Objetivo:    Genera Notificación de las Estadisticas de Ejecuciones de Procedimientos Compilados en Base de Datos en un Período.  
Programador: Pedro Felipe Zambrano  
Fecha:       31/10/2022  
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
          @w_secuencia          = 0;  
--  
-- Búsqueda de Parámetros.  
--  
  
   Select @w_idSession          = idSession,  
          @w_idMotivoCorreo     = idMotivoCorreo,  
          @w_parametros         = parametros  
   From   dbo.conProcesosTbl  
   Where  idProceso = @PnIdProceso  
   If @@Rowcount = 0  
      Begin  
         Select @PnEstatus = 3000,  
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)  
  
         Set Xact_Abort Off  
         Return  
  End  
  
   Select  @w_account_name =  Cast(descripcion as Sysname)  
   From    dbo.conMotivosCorreoTbl  
   Where   idMotivo   = @w_idMotivoCorreo  
   If @@Rowcount = 0  
   Begin  
      Select @PnEstatus = 6200,  
             @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)  
  
      Goto Salida  
   End  
  
   Select @w_grupoCorreo     = dbo.Fn_splitStringColumna(@w_parametros, '|', 1),  
          @w_idAplicacion    = dbo.Fn_splitStringColumna(@w_parametros, '|', 2),  
          @w_fechaProc       = dbo.Fn_splitStringColumna(@w_parametros, '|', 3),  
          @w_basedatos       = dbo.Fn_splitStringColumna(@w_parametros, '|', 4);  
  
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
         Select @PnEstatus = 554,  
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)  
  
         Goto Salida  
      End  
  
--  
--  
--  
  
   Select @w_cadenaEncriptada = parametroChar  
   From   dbo.conParametrosGralesTbl  
   Where  idParametroGral = 31;  
   If @@Rowcount           = 0 Or  
      @w_cadenaEncriptada Is Null  
      Begin  
         Select @PnEstatus = 9999,  
                @PsMensaje = 'Error. La URL de la API LS no esta identificada.'  
  
         Set Xact_Abort    Off  
         Return  
      End  
  
   Set @w_URL = dbo.fn_DesEncrypta64 (@w_cadenaEncriptada);
   
   Set @w_URL = trim(@w_URL)  
  
--  
  
   Set @w_sql = Concat('Declare ',  
                          '@PnEstatus Integer      = 0, ',  
                          '@PsMensaje Varchar(250) = Char(32); ',  
                       'Begin',  
                         ' Execute Spc_analizaEjecucionProcedimientos @PsBaseDatos    = ', @w_comilla, @w_basedatos, @w_comilla, ', ',  
                                                                    ' @PdFechaProceso = ', @w_comilla, @w_fechaProc, @w_comilla, ', ',  
                                                                    ' @PnOrden        = 2, ',  
                                                                    ' @PnEstatus      = @PnEstatus Output, ',  
                                                                    ' @PsMensaje      = @PsMensaje Output;',   
                          'Select @PnEstatus Estatus, @PsMensaje Mensaje ',  
                       'End');  
  
   Set @w_consultaTexto = Concat('{"idAplicacionDestino": ', @w_idAplicacion, ',"idAplicacionOrigen": 6,"consulta": "' +  
                          @w_sql + '","idUsuarioAct":', @PnIdUsuarioAct, ',"idTipoRespuesta": 2}')  
  
   If IsJson(@w_consultaTexto) = 0  
      Begin  
         Select @PnEstatus  = 9999,  
                @PsMensaje  = 'Error.: Cadena a Encriptar no es tipo Json'  
  
         Set Xact_Abort Off  
         Return  
  
      End  
  
   Set @w_consultaEncriptada = dbo.fn_Encrypta64(@w_consultaTexto);
   
   Set @w_comando = '{"data": "' + trim(@w_consultaEncriptada) + '"}'  
  
   If IsJson(@w_comando) = 0  
      Begin  
         Select @PnEstatus  = 9999,  
                @PsMensaje  = 'Error.: Cadena no es tipo Json'  
  
         Set Xact_Abort Off  
         Return  
  
      End  
  
   Execute sp_OACreate 'MSXML2.XMLHTTP', @w_idObject Output;  
  
   Execute sp_OAMethod @w_idObject, 'open', Null, 'post', @w_URL, 'false'  
  
   Execute sp_OAMethod @w_idObject, 'setRequestHeader', Null, 'Content-Type', 'application/json'  
  
   Execute @PnEstatus = sp_OAMethod @w_idObject, 'send', Null, @w_comando  
  
   Insert Into @w_TempXml  
   Execute @PnEstatus  = sp_OAMethod @w_idObject, 'responseText'  
  
   Execute sp_OADestroy @w_idObject  
  
   Select @w_archivoXML = archivo  
   From   @w_TempXml  
  
   Execute sp_xml_preparedocument @w_idObject Output, @w_archivoXML;  
     
   Insert Into @w_tempObjetos  
   (baseDatos,    procedimiento, ultimaEjecucion, CantidadEjecuciones,  
    tiempoMinimoEjecucion, tiempoMaximoEjecucion)  
   Select baseDatos,             procedimiento, ultimaEjecucion, CantidadEjecuciones,  
          tiempoMinimoEjecucion, tiempoMaximoEjecucion  
   From Openxml (@w_idObject, 'Result/Table', 3)  
   With (baseDatos                     Sysname,  
         procedimiento                 Sysname,  
         ultimaEjecucion               Datetime,  
         CantidadEjecuciones           Integer,  
         tiempoMinimoEjecucion         Decimal(18, 2),  
         tiempoMaximoEjecucion         Decimal(18, 2));  
  
   Set @w_registros = @@Identity  
  
   Execute sp_xml_removedocument @w_idObject  
  
   Delete  @w_TempXml;  
  
Select *  
from @w_tempObjetos  
Return  
  
--  
  
   Set    @w_cuerpo = '<!DOCTYPE html>  
                      <html>  
                      <body> '  
  
   Set @w_body = N'<table width="830" BORDER CELLPADDING=10 CELLSPACING=0"> '  
  
   Set @w_body = @w_body + N'<tr bgcolor="#ccd5e3"> ' +  
                           N'<th width="200">Base de Datos</th> '       + Char(13) +  
                           N'<th width="200">Procedimiento</th>'        + Char(13) +  
                           N'<th width="230">Última Ejecución</th>'     + Char(13) +  
                           N'<th width="100">Cantidad</th>'             + Char(13) +  
                           N'<th width="100">Tiempo Mínimo</th>'        + Char(13) +  
                           N'<th width="100">Tiempo Máximo</th></tr>'   + Char(13)  
  
--  
  
   While @w_secuencia < @w_registros  
   Begin  
      Set @w_secuencia = @w_secuencia + 1  
      Select @w_basedatos               = baseDatos,  
             @w_procedimiento           = procedimiento,   
             @w_ultimaEjecucion         = ultimaEjecucion,   
             @w_CantidadEjecuciones     = CantidadEjecuciones,  
             @w_tiempoMinimoEjecucion   = tiempoMinimoEjecucion,   
             @w_tiempoMaximoEjecucion   = tiempoMaximoEjecucion  
      From   @w_tempObjetos  
      Where  secuencia = @w_secuencia;  
      If @@Rowcount = 0  
         Begin  
            Break  
         End  
  
      If @w_secuencia = 1    
         Begin    
             Select @w_body = @w_body + '<tr>' +  '<td rowspan="' + 'basedatos' + '">' + @w_basedatos  + '</td>' + Char(13)     
         End    
                  
  
   End  
     
   Set @w_body = @w_body + N'</TABLE> ' + Char(13) +  
                                  N'<TAB>'     + Char(13)  
  
--  
    Set  @w_cuerpo = @w_cuerpo + @w_body  
    Set  @w_cuerpo = @w_cuerpo + '</body></html>'  
  
Select @w_cuerpo  
  
Salida:  
  
--  
   Return  
  
End  