Use SCMBD
Go

If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'logAnalisisObjetosNoValidosTbl')
   Begin
      Drop Table dbo.logAnalisisObjetosNoValidosTbl
   End
Go

Create Table dbo.logAnalisisObjetosNoValidosTbl
   (idProceso        Bigint         Not Null,
    correlativo      Integer        Not Null,
	servidor         Sysname        Not Null,
	databaseName     Sysname        Not Null,
    tipo             Char(2)        Not Null,
	objectName       Sysname        Not Null,
	ErrorMensaje     Varchar(Max)   Not Null, 
	fechaConsulta    Date           Not Null  Default Getdate(),
	fechaInicio      Date           Not Null  Default Getdate(),
	fechaTermino     Datetime           Null,
	informado        Tinyint        Not Null  Default 0,
Constraint logAnalisisObjetosNoValidosPk
Primary Key Clustered (idProceso, correlativo),
Index logAnalisisObjetosNoValidosIdx01 (Tipo, objectName))
Go

--
-- Comentarios
--

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Catálogo de Tablas de Objetos No Validos.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logAnalisisObjetosNoValidosTbl'

Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador Correlativo del Proceso de Consulta de Objetos No Validos' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logAnalisisObjetosNoValidosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'idProceso'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Secuencia del Proceso de Consulta de Objetos No Validos' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logAnalisisObjetosNoValidosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'correlativo'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador del Servidor con  Problemas de Objetos No Validos' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logAnalisisObjetosNoValidosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'servidor'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Base de Datos con Problemas de Objetos No Validos' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logAnalisisObjetosNoValidosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'databaseName'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Tipo de Objeto No Valido' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logAnalisisObjetosNoValidosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'tipo'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador del Objeto No Valido' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logAnalisisObjetosNoValidosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'ObjectName'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Mensaje del Error en el Objeto No Valido' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logAnalisisObjetosNoValidosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'ErrorMensaje'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Fecha de la Consulta de Objeto No Valido' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logAnalisisObjetosNoValidosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'fechaConsulta'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Fecha de Inicio del Proceso de Consulta de Objeto No Valido' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logAnalisisObjetosNoValidosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'fechaInicio'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Fecha de Inicio del Proceso de Consulta de Objeto No Valido' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logAnalisisObjetosNoValidosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'fechaTermino'
Go
   
Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Indica si fue reportada la incidencia de Objetos No Validos' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logAnalisisObjetosNoValidosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'informado'
Go
 
 