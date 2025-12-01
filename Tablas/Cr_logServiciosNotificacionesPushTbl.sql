Use SMBDTI
Go

If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'logServiciosNotificacionesPushTbl')
   Begin
      Drop Table logServiciosNotificacionesPushTbl
   End
Go

Create Table logServiciosNotificacionesPushTbl
(idProceso     Integer       Not Null   Identity(1, 1),
 servidor      Sysname       Not Null,
 idMonitor     Integer       Not Null,
 actividad     Varchar(Max)  Not Null, 
 fechaInicio   DateTime      Not Null   Default Getdate(),
 fechaTermino  Datetime          Null   Default Getdate(),
 informado     Bit           Not Null   Default 0,
 error         Integer       Not Null   Default 0,
 mensajeError  Varchar(250)  Not Null   Default '',
Constraint logServiciosNotificacionesPushPk
Primary Key (idProceso))
Go

--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Log de Análisis de Servicios Notificaciones Push.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificacionesPushTbl'

Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador Correlativo del Proceso de Análisis' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificacionesPushTbl', 
                                @level2type = 'Column',
                                @level2name = 'idProceso'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Servidor donde se realizó Proceso de Análisis' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificacionesPushTbl', 
                                @level2type = 'Column',
                                @level2name = 'servidor'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Monitor con Problemas' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificacionesPushTbl', 
                                @level2type = 'Column',
                                @level2name = 'idMonitor'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Descripción de la Actividad Ejecutada.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificacionesPushTbl', 
                                @level2type = 'Column',
                                @level2name = 'actividad'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Fecha de Inicio de la Actividad' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificacionesPushTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaInicio'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Fecha Termino  de la Actividad' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificacionesPushTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaTermino'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identifica si el Análisis ya fue Informado.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificacionesPushTbl', 
                                @level2type = 'Column',
                                @level2name = 'informado'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Error encontrado durante el proceso' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificacionesPushTbl', 
                                @level2type = 'Column',
                                @level2name = 'error'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Descripción del Error encontrado durante el proceso de Análisis' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logServiciosNotificacionesPushTbl', 
                                @level2type = 'Column',
                                @level2name = 'mensajeError'
Go