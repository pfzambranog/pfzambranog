Use SCMBD
Go

Declare
   @w_idMotivo       Integer       = 103,
   @w_idUsuarioAct   Integer       = 1,
   @w_fechaAct       Datetime      = Getdate(),
   @w_ipAct          Varchar( 30)  = dbo.Fn_BuscaDireccionIP  (),
   @w_macAct         Varchar( 30)  = dbo.Fn_Busca_DireccionMac(),
   @w_perfil         Varchar( 30)  = 'Incidencias BD',
   @w_descripcion    Varchar(150)  = 'Comprobación de Integridad de BD',
   @w_titulo         Varchar(150)  = 'Mantenimiento Base de Datos',
   @w_html           Varchar(Max);

Set @w_html =
'<!DOCTYPE html>
<html lang="es">
	<head>
		<meta charset="UTF-8">  </head>
		<body style="font-family: Arial, sans-serif; color: #153643; font-size: 16px; line-height: 24px;">
			<!-- Encabezado -->
			<p>&saludo&, &Nombre&</p>
			<p>          Por medio del presente se te informa que se realizó el proceso de <b>&proceso&</b>.      </p>
			<!-- Datos del servidor en tabla -->
			<table cellpadding="0"
			       cellspacing="0"
			       style="font-family: Arial, sans-serif; font-size: 16px; color:#153643;">
				<tr>
					<td style="padding: 3px 12px 3px 0;">Servidor:</td>
					<td>
						<b>&server&</b>
					</td>
				</tr>
				<tr>
					<td style="padding: 3px 12px 3px 0;">IP:</td>
					<td>
						<b>&ip&</b>
					</td>
				</tr>
				<tr>
					<td style="padding: 3px 12px 3px 0;">Ambiente:</td>
					<td>
						<b>&ambiente&</b>
					</td>
				</tr>
				<tr>
					<td style="padding: 3px 12px 3px 0;">Fecha de Proceso:</td>
					<td>
						<b>&fechaproceso&</b>
					</td>
				</tr>				
			</table>

			<!-- Sección de Linked Servers -->
			<p style="margin-top: 20px;">
				<b>
					<u>Resumen del Proceso</u>
				</b>
			</p>
			<p>&tabla2&</p>
			<!-- Espacio -->
			<div style="height: 20px;"/>
			<!-- Información adicional -->
			<p>
				<b>              Para mayor información consulte la tabla &t_tabla& con el ID de proceso &idproceso&.          </b>
			</p>
			<p>
				<b>              NOTA: Este correo es de carácter informativo, favor de NO replicar y NO responder.          </b>
			</p>
		</body>
	</html>';

Begin
   If Exists ( Select top 1 1
               From   dbo.conMotivosCorreoTbl
               Where  idMotivo = @w_idMotivo)
      Begin
         Update dbo.conMotivosCorreoTbl
		 Set    descripcion   = @w_descripcion,
                titulo        = @w_titulo,
                html          = @w_html,
                fechaAct      = @w_fechaAct,
                ipAct         = @w_ipAct,
                macAddressAct =  @w_macAct
         Where  idMotivo = @w_idMotivo;
      End
   Else
      Begin
         Insert Into dbo.conMotivosCorreoTbl
         (idMotivo,      descripcion,      titulo,   cuerpo,
          URL,           idUsuarioAct,     fechaAct, ipAct,
          macAddressAct, permiteCompartir, html,     perfilCorreo)
         Select @w_idMotivo, @w_descripcion, @w_titulo, '',
                '', @w_idUsuarioAct, @w_fechaAct, @w_ipAct, @w_macAct,  0,
         	   @w_html, @w_perfil;

      End
   Return

End;

Go
