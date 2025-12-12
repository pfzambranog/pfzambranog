Use SCMBD
Go

If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'logAnalisisLSTbl')
   Begin
      Drop Table dbo.logAnalisisLSTbl
   End
Go

Create Table dbo.logAnalisisLSTbl
(idProceso     Integer       Not Null,
 Secuencia     Integer       Not Null,
 servidor      Sysname       Not Null,
 linkServer    Sysname       Not Null,
 actividad     Varchar(Max)  Not Null, 
 fechaInicio   DateTime      Not Null   Default Getdate(),
 fechaTermino  Datetime          Null,
 error         Integer       Not Null   Default 0,
 mensajeError  Varchar(250)  Not Null   Default '',
 informado     Tinyint       Not Null   Default 0,
Constraint logAnalisisLSPk
Primary Key (idProceso, Secuencia))
Go

--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Log de Procesos de Análisis de Link Sever.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisLSTbl'

Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador Correlativo del Proceso de Análisis' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisLSTbl', 
                                @level2type = 'Column',
                                @level2name = 'idProceso'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador de la Secuencia del Proceso de Análisis' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisLSTbl', 
                                @level2type = 'Column',
                                @level2name = 'secuencia'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Servidor donde se realizó Proceso de Análisis LS' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisLSTbl', 
                                @level2type = 'Column',
                                @level2name = 'servidor'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador de donde se realizó Proceso de Análisis' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisLSTbl', 
                                @level2type = 'Column',
                                @level2name = 'linkServer'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Descripción de la Actividad a Ejecutar' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisLSTbl', 
                                @level2type = 'Column',
                                @level2name = 'actividad'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Fecha de Inicio de la Actividad' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisLSTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaInicio'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Fecha Termino  de la Actividad' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisLSTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaTermino'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Error encontrado durante el proceso' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisLSTbl', 
                                @level2type = 'Column',
                                @level2name = 'error'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Descripción del Error encontrado durante el proceso de Análisis' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisLSTbl', 
                                @level2type = 'Column',
                                @level2name = 'mensajeError'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Estatus del Proceso de Información del Error Enconstrado' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisLSTbl', 
                                @level2type = 'Column',
                                @level2name = 'informado'
Go
