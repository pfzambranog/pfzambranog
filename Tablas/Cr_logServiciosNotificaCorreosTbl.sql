Use SCMBD
Go

If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'logServiciosNotificaCorreosTbl')
   Begin
      Drop Table logServiciosNotificaCorreosTbl
   End
Go

Create Table logServiciosNotificaCorreosTbl
(idProceso          Integer        Not Null   Identity(1, 1),
 servidor           Sysname        Not Null,
 idPerfilCorreo     Integer        Not Null,
 descripcion        NVarchar(510)  Not Null, 
 fechaInicio        DateTime       Not Null   Default Getdate(),
 fechaTermino       Datetime           Null   Default Getdate(),
 informado          Tinyint        Not Null   Default 0,
 error              Integer        Not Null   Default 0,
 mensajeError       Varchar(250)   Not Null   Default '',
Constraint logServiciosNotificaCorreosPk
Primary Key (idProceso))
Go

--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Log de Análisis de Servicios Notificaciones de Correos' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificaCorreosTbl'

Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador Correlativo del Proceso de Análisis' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificaCorreosTbl', 
                                @level2type = 'Column',
                                @level2name = 'idProceso'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Servidor donde se realizó Proceso de Análisis' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificaCorreosTbl', 
                                @level2type = 'Column',
                                @level2name = 'servidor'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Perfil de Correos con Problemas' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificaCorreosTbl', 
                                @level2type = 'Column',
                                @level2name = 'idPerfilCorreo'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Perfil de Correo no Procesado' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificaCorreosTbl', 
                                @level2type = 'Column',
                                @level2name = 'descripcion'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Fecha de Inicio de la Actividad' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificaCorreosTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaInicio'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Fecha Termino  de la Actividad' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificaCorreosTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaTermino'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identifica si el Análisis ya fue Informado.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificaCorreosTbl', 
                                @level2type = 'Column',
                                @level2name = 'informado'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Error encontrado durante el proceso' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificaCorreosTbl', 
                                @level2type = 'Column',
                                @level2name = 'error'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Descripción del Error encontrado durante el proceso de Análisis' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificaCorreosTbl', 
                                @level2type = 'Column',
                                @level2name = 'mensajeError'
Go