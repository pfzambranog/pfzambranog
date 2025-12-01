Use SCMBD
Go

If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'logMantenIndicesDetTbl')
   Begin
      Drop Table dbo.logMantenIndicesDetTbl
   End
Go

Create Table dbo.logMantenIndicesDetTbl
(idProcesoDet      Integer         Not Null   Identity(1, 1),
 idProceso         Integer         Not Null,
 actividad         Varchar(100)    Not Null,
 fechaInicio       DateTime        Not Null   Default GetDate(),
 fechaTermino      Datetime            Null,
 error             Integer         Not Null   Default 0,
 mensajeError      Nvarchar(4000)  Not Null   Default '',
Constraint logMantenIndicesDetPk
Primary Key (idProcesoDet),
Constraint logMantenIndicesDetFk01
Foreign Key (idProceso)
References logMantenIndicesTbl (idProceso) On Delete Cascade)
Go

Create Index logMantenIndicesDetIdx01 on logMantenIndicesDetTbl (idProceso)
Go

--
-- Comentarios
--

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Log Detallado de Proceso Mantenimiento de Índices.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logMantenIndicesDetTbl'

Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador Correlativo del Detalle de Proceso de Mantenimiento.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logMantenIndicesDetTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'idProcesoDet'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador Correlativo del Proceso Padre de Mantenimiento.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logMantenIndicesDetTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'idProceso'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Descripción de la actividad.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logMantenIndicesDetTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'actividad'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Fecha de Inicio del Proceso de Mantenimiento' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logMantenIndicesDetTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'fechaInicio'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Fecha Termino del Proceso de Mantenimiento' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logMantenIndicesDetTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'fechaTermino'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador del Error encontrado durante el Proceso de Mantenimiento.', 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logMantenIndicesDetTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'error'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Descripción del Error encontrado durante el Proceso de Mantenimiento.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo',
                                   @level1type = 'Table',
                                   @level1name = 'logMantenIndicesDetTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'mensajeError'
Go