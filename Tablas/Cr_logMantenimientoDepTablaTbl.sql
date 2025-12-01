Use SCMBD
Go

If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'logMantenimientoDepTablaTbl')
   Begin
      Drop Table logMantenimientoDepTablaTbl
   End
Go

Create Table logMantenimientoDepTablaTbl
(idProceso     Integer       Not Null   Identity(1, 1),
 servidor      Sysname       Not Null   Default @@ServerName,
 baseDatos     Sysname       Not Null,
 tabla         Sysname       Not Null,
 registros     Integer       Not Null   Default 0,
 fechaInicio   DateTime      Not Null   Default Getdate(),
 fechaTermino  Datetime          Null,
 error         Integer       Not Null   Default 0,
 mensajeError  Varchar(250)  Not Null   Default '',
 informado     Tinyint       Not Null   Default 0,
Constraint logMantenimientoDepTablaPk
Primary Key (idProceso))
Go

--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Log de Procesos de Depuración de Información de tablas.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logMantenimientoDepTablaTbl'

Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador Correlativo del Proceso de Depuración' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logMantenimientoDepTablaTbl', 
                                @level2type = 'Column',
                                @level2name = 'idProceso'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Servidor donde se realizó Proceso de Depuración' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logMantenimientoDepTablaTbl', 
                                @level2type = 'Column',
                                @level2name = 'servidor'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador de la Tabla donde se realizó Proceso de Depuración' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logMantenimientoDepTablaTbl', 
                                @level2type = 'Column',
                                @level2name = 'tabla'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Número de Registros Depurados en la Tabla.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logMantenimientoDepTablaTbl', 
                                @level2type = 'Column',
                                @level2name = 'registros'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Fecha de Inicio de la Actividad' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logMantenimientoDepTablaTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaInicio'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Fecha Termino  de la Actividad' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logMantenimientoDepTablaTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaTermino'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Error encontrado durante el proceso' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logMantenimientoDepTablaTbl', 
                                @level2type = 'Column',
                                @level2name = 'error'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Descripción del Error encontrado durante el proceso de Depuración' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logMantenimientoDepTablaTbl', 
                                @level2type = 'Column',
                                @level2name = 'mensajeError'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Estatus que indica si fue notificado el evento de error.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logMantenimientoDepTablaTbl', 
                                @level2type = 'Column',
                                @level2name = 'informado'
Go