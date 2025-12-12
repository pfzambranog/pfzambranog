Use SCMBD
Go

If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'logAnalisisJobsTbl')
   Begin
      Drop Table dbo.logAnalisisJobsTbl
   End
Go

Create Table dbo.logAnalisisJobsTbl
(idProceso         Integer         Not Null   Identity(1, 1),
 servidor          Sysname         Not Null,
 Job               Sysname         Not Null,
 idPaso            Integer         Not Null,
 nombrePaso        Sysname         Not Null, 
 fechaInicio       DateTime        Not Null Default GetDate(),
 fechaTermino      Datetime            Null,
 informado         Tinyint         Not Null   Default 0,
 error             Integer         Not Null   Default 0,
 mensajeError      Nvarchar(4000)  Not Null   Default '',
Constraint logAnalisisJobsPk
Primary Key (idProceso))
Go


Create Index logAnalisisJobsIdex01 On logAnalisisJobsTbl (fechaTermino, informado)
Go


Create Unique Index logAnalisisJobsIdex02 On logAnalisisJobsTbl (servidor, Job, idPaso, fechaInicio)
Go

--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Log de Análisis de Jobs con Errores en su Ejecución.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisJobsTbl'

Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador Correlativo del Proceso de Análisis.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisJobsTbl', 
                                @level2type = 'Column',
                                @level2name = 'idProceso'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Servidor donde se realizó Proceso de Análisis.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisJobsTbl', 
                                @level2type = 'Column',
                                @level2name = 'servidor'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Job que presento Problemas.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisJobsTbl', 
                                @level2type = 'Column',
                                @level2name = 'Job'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Paso del Job que presento Problemas.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisJobsTbl', 
                                @level2type = 'Column',
                                @level2name = 'idPaso'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Nombre del Paso del Job que presento Problemas.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisJobsTbl', 
                                @level2type = 'Column',
                                @level2name = 'nombrePaso'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Fecha de Ejecución del Job que presento Problemas' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisJobsTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaInicio'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Fecha de Ejecución de la Consulta a la Actividad de los Jobs' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisJobsTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaTermino'
Go


Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Error encontrado durante la Ejecución del Job', 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisJobsTbl', 
                                @level2type = 'Column',
                                @level2name = 'error'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Descripción del Error encontrado durante la Ejecución del Job' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'logAnalisisJobsTbl', 
                                @level2type = 'Column',
                                @level2name = 'mensajeError'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Estatus del Proceso de Información del Error Enconstrado' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logAnalisisJobsTbl', 
                                @level2type = 'Column',
                                @level2name = 'informado'
Go