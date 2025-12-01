Use SCMBD
Go

If Not Exists ( Select top 1 1
                From   dbo.conMotivosCorreoTbl
                Where  idMotivo = 110)
   Begin
      Insert Into dbo.conMotivosCorreoTbl
      (idMotivo,      descripcion,  titulo,   cuerpo,
       URL,           idUsuarioAct, fechaAct, ipAct,
       macAddressAct, permiteCompartir, Html)
      Select 110, 'Incidencias BD', 'Tiempos Altos de Ejecución',
      '&saludos&, &Nombre&
      
      Por medio del presente te informamos que se encontró la siguiente incidencia:

      Incidencia: &incidencia%
      Tabla Log:  &tabla&
      Id Proceso: &idProceso%
		
      Servidor:  &server&
      Instancia: &instancia&
      Ambiente:  &ambiente&
      ip:        &ip&
		
      
      Query:      &query%
      Objeto:     &objeto%',
      '',             18,     Getdate(), dbo.Fn_BuscaDireccionIP(),
      dbo.Fn_Busca_DireccionMAC(), 0,
            '<!DOCTYPE html>
    <html lang="es">
        <tbody>
                <p>&saludos&, &Nombre&
                <p style="margin:0 0 12px 0;font-size:16px;line-height:24px;font-family:Arial,sans-serif;color:#153643">
                    Por medio del presente te informamos que se encontró la siguiente incidencia:

                <p> Incidencia: &incidencia%
                <p> Tabla Log:  &tabla&
                <p> Id Proceso: &idProceso%
				<p> 
                <p> Servidor:  &server&
                <p> Instancia: &instancia&
                <p> Ambiente:  &ambiente&
                <p> ip:        &ip&
				<p> 

                <p> Query:      &query%
                <p> Objeto:     &objeto%

        </tbody>
    </html>'
    End
Else
   Begin
      Update dbo.conMotivosCorreoTbl
      Set    descripcion      = 'Incidencias BD',
             titulo           = 'Incidencias BD',
             cuerpo           = '&saludos&, &Nombre&
      
      Por medio del presente te informamos que se encontró la siguiente incidencia:

      Incidencia: &incidencia%
      Tabla Log:  &tabla&
      Id Proceso: &idProceso%
		
      Servidor:  &server&
      Instancia: &instancia&
      Ambiente:  &ambiente&
      ip:        &ip&
		
      
      Query:      &query%
      Objeto:     &objeto%',
             URL              = '',
             idUsuarioAct     = 18, 
             fechaAct         = Getdate(),
             ipAct            = dbo.Fn_BuscaDireccionIP(),
             macAddressAct    = dbo.Fn_Busca_DireccionMAC(),
             permiteCompartir = 0,
             html             =
   '<!DOCTYPE html>
    <html lang="es">
        <tbody>
                <p>&saludos&, &Nombre&
                <p style="margin:0 0 12px 0;font-size:16px;line-height:24px;font-family:Arial,sans-serif;color:#153643">
                    Por medio del presente te informamos que se encontró la siguiente incidencia:

                <p> Incidencia: &incidencia%
                <p> Tabla Log:  &tabla&
                <p> Id Proceso: &idProceso%
				<p> 
                <p> Servidor:  &server&
                <p> Instancia: &instancia&
                <p> Ambiente:  &ambiente&
                <p> ip:        &ip&
				<p> 

                <p> Query:      &query%
                <p> Objeto:     &objeto%

        </tbody>
    </html>'
      Where  idMotivo    = 110
   End
Go
Go