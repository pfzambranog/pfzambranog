Use SCMBD
Go

If Exists ( Select top 1 1
            From   dbo.conMotivosCorreoTbl
            Where  idMotivo = 112)
   Begin
      Delete dbo.conMotivosCorreoTbl
      Where  idMotivo = 112
   End
   
Insert Into  dbo.conMotivosCorreoTbl
(idMotivo,      descripcion,  titulo, cuerpo,
 URL,           idUsuarioAct, fechaAct, ipAct, 
 macAddressAct, permiteCompartir, perfilCorreo, html)
Select 112 idMotivo, 'Proceso de Depuración de Datos Históricos' descripcion,
       'Depuración de Datos Históricos' titulo, ' ' cuerpo, ' ' URL,
       1 idUsuarioAct, Getdate() fechaAct, '127.0.0.1' ipAct,
       dbo.Fn_Busca_DireccionMac() macAddressAct, 1 permiteCompartir,  'Incidencias BD',
       '<!DOCTYPE html> 
     <html lang="es">  
           <tbody> 
                <DIV Align="justify"> <style="margin:0 0 12px 0;font-size:16px;line-height:24px;font-family:Arial,sans-serif;color:#153643"></DIV>
                <p>&saludo&, &Nombre& </p>
                
                   Por medio del presente se te informa que se realizo el proceso de  <b>&incidencia&</b>
                
                <p></p>
                <p></p>

                <p> Servidor:   <b>&server&    </b> </p>
                <p> IP:         <b>&ip&        </b> </p>
                <p> Instancia:  <b>&instancia& </b></p>
                <p> Base Datos: <b>&BaseDatos& </b></p>
                <p> Ambiente:   <b>&ambiente&  </b></p>

                <p></p>

                <h3><u>Detalle de Objetos depurados </u></h3>
                <p> &detalle& </p>
                

               
                <b> Para Mayor Información Consulte la Tabla:  &t_tabla& </b>
                <p></p>
                
                
                <b> NOTA: Este correo es de caracter informativo, favor de NO Replicar y NO Responder  </b> </p> 
            </tbody>

       
   </html>'