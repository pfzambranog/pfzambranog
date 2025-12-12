Use SCMBD
Go

If Exists ( Select top 1 1
            From   dbo.conMotivosCorreoTbl
            Where  idMotivo = 107)
   Begin
      Delete dbo.conMotivosCorreoTbl
      Where  idMotivo = 107
   End
   
Insert Into dbo.conMotivosCorreoTbl
Select 107, 'Ejecuciones de Procedimientos de Base de Datos', 'Ejecuciones de Procedimientos', '',
       '', 1, Getdate(), dbo.Fn_BuscaDireccionIP(), dbo.Fn_Busca_DireccionMac(), 0,
	    '<!DOCTYPE html> 
     <html lang="es">  
           <tbody> 
                <DIV Align="justify" style="margin:0 0 12px 0;font-size:16px;line-height:24px;font-family:Arial,sans-serif;color:#153643"></DIV>
                <p>&saludo&, &Nombre& </p>
                
                <p>Por medio del presente se te informa que se realizo el proceso de <b>&proceso&</b></p>
                
                <p></p>
                <p></p>

                <p>Servidor:                 <b>&server&</b></p>
                <p>IP:                       <b>&ip&</b></p>
                <p>Instancia:                <b>&instancia&</b></p>
                <p>Base Datos:               <b>&BaseDatos&</b></p>
                <p>Ambiente:                 <b>&ambiente&</b></p>
                <p></p>            
                <p>Fecha Inicial de Proceso: <b>&fechaInicial&</b></p>
                <p>Fecha Final de Proceso:   <b>&fechaFinal&</b></p>
                <p></p>

                <t1>
                    <b><u>Procedimientos Ejecutados ordenados por Cantidad de Ejecuciones</u> </p>
           
                    <p>&tabla1&</p>
                </t1>

                <p></p>
                <p></p>
                
                <t2>
                    <b><u>Procedimientos Ejecutados ordenados por Mayor Tiempo de Ejecución</u> </p>
           
                    <p>&tabla2&</p>
                </t2>

                <p></p>
                <p></p>
                
                <t3>
                    <b><u>Procedimientos Ejecutados ordenados por Mayor Tiempo Mínimo de Ejecución</u> </p>
           
                    <p>&tabla3&</p>
                </t3>

                <p></p>
                <p></p>
                <p></p>
                <p></p>

                <p><b>Se presentan el Top 10 en cada tabla</b></p>
                <p></p>

                <p><b>Para Mayor Información Consulte la Tabla: &t_tabla&</b></p>
                <p></p>

                <p><b>NOTA: Este correo es de caracter informativo, favor de NO Replicar y NO Responder</b></p>
            </tbody>
       </html>,
', 'Incidencias BD'
Go

If Exists ( Select top 1 1
            From   dbo.conMotivosCorreoTbl
            Where  idMotivo = 108)
   Begin
      Delete dbo.conMotivosCorreoTbl
      Where  idMotivo = 108
   End
   
Insert Into dbo.conMotivosCorreoTbl
Select 108, 'Validación de Conectividad de Linked Servers', 'Validación de Linked Servers', '',
       '', 1, Getdate(), dbo.Fn_BuscaDireccionIP(), dbo.Fn_Busca_DireccionMac(), 0,
'<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
</head>

<body style="font-family: Arial, sans-serif; color: #153643; font-size: 16px; line-height: 24px;">

    <!-- Encabezado -->
    <p>&saludo&, &Nombre&</p>

    <p>
        Por medio del presente se te informa que se realizó el proceso de 
        <b>&proceso&</b>.
    </p>

    <!-- Datos del servidor en tabla -->
    <table cellpadding="0" cellspacing="0" style="font-family: Arial, sans-serif; font-size: 16px; color:#153643;">
        <tr>
            <td style="padding: 3px 12px 3px 0;">Servidor:</td>
            <td><b>&server&</b></td>
        </tr>
        <tr>
            <td style="padding: 3px 12px 3px 0;">IP:</td>
            <td><b>&ip&</b></td>
        </tr>
        <tr>
            <td style="padding: 3px 12px 3px 0;">Instancia:</td>
            <td><b>&instancia&</b></td>
        </tr>
        <tr>
            <td style="padding: 3px 12px 3px 0;">Base de Datos:</td>
            <td><b>&BaseDatos&</b></td>
        </tr>
        <tr>
            <td style="padding: 3px 12px 3px 0;">Ambiente:</td>
            <td><b>&ambiente&</b></td>
        </tr>
    </table>

    <!-- Sección de Linked Servers -->
    <p style="margin-top: 20px;"><b><u>Linked Servers con Problemas de Conexión</u></b></p>

    <p>&tabla2&</p>

    <!-- Espacio -->
    <div style="height: 20px;"></div>

    <!-- Información adicional -->
    <p>
        <b>
            Para mayor información consulte la tabla &t_tabla& con el ID de proceso &idproceso&.
        </b>
    </p>

    <p>
        <b>
            NOTA: Este correo es de carácter informativo, favor de NO replicar y NO responder.
        </b>
    </p>

</body>
</html>', 'Incidencias BD'
Go
