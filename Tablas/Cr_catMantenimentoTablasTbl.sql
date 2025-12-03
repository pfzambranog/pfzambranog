Use SCMBD
Go

If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'catMantenimentoTablasTbl')
   Begin
      Drop Table dbo.catMantenimentoTablasTbl
   End
Go

Create Table dbo.catMantenimentoTablasTbl
(idProceso         Integer       Not Null    Identity(1, 1),
 servidor          Sysname       Not Null    Default @@ServerName,
 baseDatos         Sysname       Not Null    Default db_name(),
 tabla             Sysname       Not Null,
 idTipoDep         Tinyint       Not Null    Default 1,
 campo             Sysname           Null,
 dias              Smallint      Not Null    Default 0,
 procedimiento     Sysname           Null,
 ultFechaProceso   Datetime          Null,
 fechaAlta         Datetime      Not Null    Default Getdate(),
 fechaAct          Datetime      Not Null    Default Getdate(),
 idEstatus         Bit           Not Null    Default 1,
Constraint catMantenimentoTablasPk
Primary Key (idProceso))
Go

--
-- Comentarios
--

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Catálogo de Tablas a ser depuradas.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catMantenimentoTablasTbl'

Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador Correlativo del Proceso de Mantenimiento' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catMantenimentoTablasTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'idProceso'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador del Servidor donde se realizó Proceso de Mantenimiento' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catMantenimentoTablasTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'servidor'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador de BD donde se realizará el Proceso de Mantenimiento' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catMantenimentoTablasTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'baseDatos'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador de la entidad donde se realizará el Proceso de Mantenimiento' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catMantenimentoTablasTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'tabla'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador del Tipo de Depuración Aplicacble a la Tabla.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catMantenimentoTablasTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'idTipoDep'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Columna de Comparación para el Proceso de Mantenimiento de la Tabla por Fecha.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catMantenimentoTablasTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'campo'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Cantidad de Dias Mínimo para la Depuración de Datos de la Tabla.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catMantenimentoTablasTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'dias'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Procedimiento a Ejecutar para la Depuración de la Tabla.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catMantenimentoTablasTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'procedimiento'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Última Fecha de Depuración realizada.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catMantenimentoTablasTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'ultFechaProceso'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Fecha de Alta del Registro.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catMantenimentoTablasTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'fechaAlta'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Última Fecha de Actualización del Registro.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catMantenimentoTablasTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'fechaAct'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador del Estatus del Registro.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catMantenimentoTablasTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'idEstatus'
Go

