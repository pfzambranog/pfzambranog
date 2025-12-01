Use SCMBD
Go

If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'logMantenimientoBDTbl')
   Begin
      Drop Table logMantenimientoBDTbl
   End
Go

Create Table logMantenimientoBDTbl
(idProceso     Integer       Not Null Identity(1, 1),
 servidor      Sysname       Not Null,
 baseDatos     Sysname       Not Null,
 actividad     Varchar(Max)  Not Null, 
 fechaInicio   DateTime      Not Null   Default Getdate(),
 fechaTermino  Datetime          Null,
 error         Integer       Not Null   Default 0,
 mensajeError  Varchar(250)  Not Null   Default '',
Constraint logMantenimientoBDPk
Primary Key (idProceso))
Go

--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Log de Procesos de Mantenimiento de Base de Datos.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logMantenimientoBDTbl'

Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador Correlativo del Proceso de Mantenimiento' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logMantenimientoBDTbl', 
                                @level2type = 'Column',
                                @level2name = 'idProceso'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Servidor donde se realizó Proceso de Mantenimiento' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logMantenimientoBDTbl', 
                                @level2type = 'Column',
                                @level2name = 'servidor'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador de donde se realizó Proceso de Mantenimiento' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logMantenimientoBDTbl', 
                                @level2type = 'Column',
                                @level2name = 'baseDatos'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Descripción de la Actividad a Ejecutar' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logMantenimientoBDTbl', 
                                @level2type = 'Column',
                                @level2name = 'actividad'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Fecha de Inicio de la Actividad' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logMantenimientoBDTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaInicio'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Fecha Termino  de la Actividad' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logMantenimientoBDTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaTermino'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Error encontrado durante el proceso' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logMantenimientoBDTbl', 
                                @level2type = 'Column',
                                @level2name = 'error'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Descripción del Error encontrado durante el proceso' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logMantenimientoBDTbl', 
                                @level2type = 'Column',
                                @level2name = 'mensajeError'
Go