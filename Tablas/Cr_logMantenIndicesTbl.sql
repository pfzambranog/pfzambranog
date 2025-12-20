Use SCMBD
Go

If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'logMantenIndicesTbl')
   Begin
      Drop Table dbo.logMantenIndicesTbl
   End
Go

Create Table dbo.logMantenIndicesTbl
(idProceso         Integer         Not Null,
 secuencia         Smallint        Not Null,
 servidor          Sysname         Not Null,
 basedatos         Sysname         Not Null,
 fechaProceso      DateTime        Not Null   Default GetDate(),
 informado         Tinyint         Not Null   Default 0,
 error             Integer         Not Null   Default 0,
 mensajeError      Nvarchar(4000)  Not Null   Default '',
Constraint logMantenIndicesPk
Primary Key (idProceso, secuencia))
Go


--
-- Comentarios
--

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Log de Proceso Mantenimiento de Índices.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logMantenIndicesTbl'

Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador Correlativo del Proceso de Mantenimiento.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logMantenIndicesTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'idProceso'
Go


Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Secuencia del Identificador del Proceso de Mantenimiento.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logMantenIndicesTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'secuencia'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador del Servidor donde se realizó Proceso de Mantenimiento.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logMantenIndicesTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'servidor'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Nombre de la Base de Datos donde se realizó Proceso de Mantenimiento.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logMantenIndicesTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'basedatos'
Go


Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Fecha de Proceso de Mantenimiento' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logMantenIndicesTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'fechaProceso'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Estatus que indica si fue notificado el Proceso de Mantenimiento.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logMantenIndicesTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'informado'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador del Error encontrado durante el Proceso de Mantenimiento.', 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logMantenIndicesTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'error'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Descripción del Error encontrado durante el Proceso de Mantenimiento.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo',
                                   @level1type = 'Table',
                                   @level1name = 'logMantenIndicesTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'mensajeError'
Go