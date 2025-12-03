Use SCMBD
Go

If Not Exists ( Select top 1 1
                From   dbo.conMotivosCorreoTbl
                Where  idMotivo = 106)
   Begin
      Insert Into dbo.conMotivosCorreoTbl
      (idMotivo,      descripcion,  titulo,   cuerpo,
       URL,           idUsuarioAct, fechaAct, ipAct,
       macAddressAct, permiteCompartir,       perfilCorreo, Html)
      Select 106, 'Incidencias BD', 'Incidencias BD',
      '&saludo&, &Nombre& Por medio del presente se te informa que el proceso de &incidencia&, EN EL SERVIDOR &servidor& ',
      '',             18,           Getdate(), dbo.Fn_BuscaDireccionIP(),
      dbo.Fn_Busca_DireccionMAC(), 0, 'Incidencias BD',
            '<!DOCTYPE html>
    <html lang="es">
        <tbody>
                <p>&saludo&, &Nombre&
                <p style="margin:0 0 12px 0;font-size:16px;line-height:24px;font-family:Arial,sans-serif;color:#153643">

                    Por medio del presente se te informa que el proceso de &incidencia&, EN EL SERVIDOR &servidor& 

        </tbody>
    </html>'
      
   End
Else
   Begin
      Update dbo.conMotivosCorreoTbl
      Set    descripcion      = 'Incidencias BD',
             titulo           = 'Incidencias BD',
             cuerpo           = '&saludo&, &Nombre&

                                 Por medio del presente se te informa que el proceso de &incidencia&, EN EL SERVIDOR &servidor& ',
             URL              = '', 
             idUsuarioAct     = 18, 
             fechaAct         = Getdate(),
             ipAct            = dbo.Fn_BuscaDireccionIP(),
             macAddressAct    = dbo.Fn_Busca_DireccionMAC(),
             permiteCompartir = 0,
             perfilCorreo     = 'Incidencias BD',
             Html             = '<!DOCTYPE html>
     <html lang="es">
        <tbody>
                <p>&saludo&, &Nombre&
                <p style="margin:0 0 12px 0;font-size:16px;line-height:24px;font-family:Arial,sans-serif;color:#153643">

                    Por medio del presente se te informa que el proceso de &incidencia&. EN EL SERVIDOR &servidor& 

        </tbody>
     </html>'
      Where  idMotivo    = 106
   End
Go

If Not Exists ( Select top 1 1
                From   dbo.conMotivosCorreoTbl
                Where  idMotivo = 110)
   Begin
      Insert Into dbo.conMotivosCorreoTbl
      (idMotivo,      descripcion,  titulo,   cuerpo,
       URL,           idUsuarioAct, fechaAct, ipAct,
       macAddressAct, permiteCompartir, perfilCorreo Html)
      Select 110, 'Incidencias BD', 'Tiempos Altos de Ejecución',
      '&saludos&, &Nombre&
      
       Por medio del presente te informamos que existen procesos con alto consumo de tiempo de proceso en el servidor &Servidor&

       Presiona el Link para ver mas detalles 
       &URL&',
      '',             18,     Getdate(), dbo.Fn_BuscaDireccionIP(),
      dbo.Fn_Busca_DireccionMAC(), 0, 'Incidencias BD',
            '<!DOCTYPE html>
    <html lang="es">
        <tbody>
                <p>&saludos&, &Nombre&
                <p style="margin:0 0 12px 0;font-size:16px;line-height:24px;font-family:Arial,sans-serif;color:#153643">
                
                    Por medio del presente te informamos que existen procesos con alto consumo de tiempo de proceso en el servidor &Servidor&

                <p>Presiona el Link para ver mas detalles 
                <p>&URL&

        </tbody>
    </html>'
    End
Else
   Begin
      Update dbo.conMotivosCorreoTbl
      Set    descripcion      = 'Incidencias BD',
             titulo           = 'Incidencias BD',
             cuerpo           = '&saludos&, &Nombre&
      
       Por medio del presente te informamos que existen procesos con alto consumo de tiempo de proceso EN EL SERVIDOR &Servidor&

       Presiona el Link para ver mas detalles 
       &URL&',
             URL              = '',
             idUsuarioAct     = 18, 
             fechaAct         = Getdate(),
             ipAct            = dbo.Fn_BuscaDireccionIP(),
             macAddressAct    = dbo.Fn_Busca_DireccionMAC(),
             permiteCompartir = 0,
             html             = '<!DOCTYPE html>
    <html lang="es">
        <tbody>
                <p>&saludos&, &Nombre&
                <p style="margin:0 0 12px 0;font-size:16px;line-height:24px;font-family:Arial,sans-serif;color:#153643">
                    Por medio del presente te informamos que existen procesos con alto consumo de tiempo de proceso EN EL SERVIDOR &Servidor&

                <p>Presiona el Link para ver mas detalles 
                <p>&URL&

        </tbody>
    </html>'
      Where  idMotivo    = 110
   End
Go
Go