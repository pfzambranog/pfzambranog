Use SCMBD
Go


If Not Exists ( Select top 1 1
                From   dbo.conMotivosCorreoTbl
                Where  idMotivo = 106)
   Begin
      Insert Into dbo.conMotivosCorreoTbl
      (idMotivo,      descripcion,  titulo,   cuerpo,
       URL,           idUsuarioAct, fechaAct, ipAct,
       macAddressAct, permiteCompartir)
      Select 106, 'Incidencias BD', 'Incidencias BD',
      '&saludo& &Nombre& Por medio del presente se te informa que &incidencia& en el servidor &servidor& ',
      '',             18,           Getdate(), dbo.Fn_BuscaDireccionIP(),
      dbo.Fn_Busca_DireccionMAC(), 0
    End
Go

If Not Exists ( Select top 1 1
                From   conMotivosCorreoTbl
                Where  idMotivo = 110)
   Begin
      Insert Into dbo.conMotivosCorreoTbl
      (idMotivo,      descripcion,  titulo,   cuerpo,
       URL,           idUsuarioAct, fechaAct, ipAct,
       macAddressAct, permiteCompartir)
      Select 110, 'Incidencias BD', 'Tiempos Altos de Ejecución',
      '<!DOCTYPE html>
    <html lang="es">
        <tbody>
                <p>&saludos&, &Nombre&
                <p style="margin:0 0 12px 0;font-size:16px;line-height:24px;font-family:Arial,sans-serif;color:#153643">
                    Por medio del presente te informamos que existen procesos con alto consumo de tiempo de proceso en el servidor &Servidor&

                <p>Presiona el Link para ver mas detalles 
                <p>&URL&

        </tbody>
    </html>',
      '',             18,     Getdate(), dbo.Fn_BuscaDireccionIP(),
      dbo.Fn_Busca_DireccionMAC(), 0
    End
Go