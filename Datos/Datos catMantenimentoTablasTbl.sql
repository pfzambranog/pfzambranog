Use SCMBD
Go

Truncate table catMantenimentoTablasTbl;

Insert Into catMantenimentoTablasTbl
(baseDatos, tabla, campo, dias)
Select 'SCMBD', 'segRelUsuariosTokenTbl', 'fechaTermino', 30;

Insert Into catMantenimentoTablasTbl
(baseDatos, tabla, campo, dias)
Select 'SCMBD', 'movRechazosCorreoTbl', 'fechaAct', 30;

Insert Into catMantenimentoTablasTbl
(baseDatos, tabla, campo, dias)
Select 'SCMBD', 'movLogMonitoresPushTbl', 'fechaInicio', 30;

Insert Into catMantenimentoTablasTbl
(baseDatos, tabla, campo, dias)
Select 'SCMBD', 'movEntregaNotificacionesTbl', 'fechaNotificacion', 90;

Insert Into catMantenimentoTablasTbl
(baseDatos, tabla, campo, dias)
Select 'SCMBD', 'movEnvioCorreosTbl', 'fechaEnvio', 90;
