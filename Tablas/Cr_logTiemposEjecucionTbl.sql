Use SCMBD
Go

If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'logTiemposEjecucionTbl')
   Begin
      Drop Table dbo.logTiemposEjecucionTbl
   End
Go   

Create Table dbo.logTiemposEjecucionTbl
(idProceso                Bigint         Not Null Identity (1, 1),
 sessionId                Integer        Not Null,
 servidor                 Sysname        Not Null,
 status                   Varchar (100)      Null,
 databaseName             Sysname        Not Null,
 individualQuery          Varchar(Max)       Null,
 parentQuery              Varchar(Max)       Null,
 programName              Sysname            Null,
 fechaInicioProceso       Datetime       Not Null,
 tiempoEjecucion          Integer        Not Null,
 fechaConsulta            Date           Not Null Default Getdate(),
 fechaInicio              Date           Not Null Default Getdate(),
 fechaTermino             Datetime           Null,
 informado                Tinyint        Not Null Default 0,
 Constraint logTiemposEjecucionPk
 Primary Key (idProceso));
 
 Create Index idxLogTiemposEjecucion On logTiemposEjecucionTbl (servidor, sessionId)
 
--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Log de Análisis de Procesos de Tiempos de Ejecución.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logTiemposEjecucionTbl'

Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador Correlativo del Proceso de Análisis.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logTiemposEjecucionTbl', 
                                @level2type = 'Column',
                                @level2name = 'idProceso'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador de la Sessión con Problemas de Tiempos de Ejecución.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logTiemposEjecucionTbl', 
                                @level2type = 'Column',
                                @level2name = 'sessionId'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Servidor Problemas de Tiempos de Ejecución.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logTiemposEjecucionTbl', 
                                @level2type = 'Column',
                                @level2name = 'servidor'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Estatus del Proceso Reportado.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logTiemposEjecucionTbl', 
                                @level2type = 'Column',
                                @level2name = 'status'
Go
 
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador de la Base de Datos con Problemas de Tiempos de Ejecución.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logTiemposEjecucionTbl', 
                                @level2type = 'Column',
                                @level2name = 'databaseName'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Consulta con Problemas de Tiempos de Ejecución.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logTiemposEjecucionTbl', 
                                @level2type = 'Column',
                                @level2name = 'individualQuery'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Procedimiento / FUnción que ejecuta la Consulta con Problemas de Tiempos de Ejecución.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logTiemposEjecucionTbl', 
                                @level2type = 'Column',
                                @level2name = 'parentQuery'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Programa desde donde se ejecuta la Consulta con Problemas de Tiempos de Ejecución.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logTiemposEjecucionTbl', 
                                @level2type = 'Column',
                                @level2name = 'programName'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Fecha / Hora de inicio de la Consulta con Problemas de Tiempos de Ejecución.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logTiemposEjecucionTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaInicioProceso'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Tiempo de ejecución de la Consulta con Problemas de Tiempos de Ejecución.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logTiemposEjecucionTbl', 
                                @level2type = 'Column',
                                @level2name = 'tiempoEjecucion'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Fecha de la Consulta a los procesos.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logTiemposEjecucionTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaConsulta'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Fecha y Hora de Inicio de la Consulta a los procesos ' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logTiemposEjecucionTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaInicio'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Fecha y Hora de Termino de la Consulta a los procesos.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logTiemposEjecucionTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaTermino'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Indica si fue reportada la incidencia  de tiempos de ejecución.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logTiemposEjecucionTbl', 
                                @level2type = 'Column',
                                @level2name = 'informado'
Go
