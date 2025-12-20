Use SCMBD
Go

If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'logProcesosBloqueadosTbl')
   Begin
      Drop Table dbo.logProcesosBloqueadosTbl
   End
Go   

Create Table dbo.logProcesosBloqueadosTbl
(idProceso                Bigint         Not Null,
 secuencia                Smallint       Not Null,
 servidor                 Sysname        Not Null,
 databaseName             Sysname        Not Null,
 sessionId                Integer        Not Null,
 esource_type             Nvarchar(120)  Not Null,
 ObjectName               Sysname        Not Null,
 resource_description     Nvarchar(512)  Not Null,
 request_session_id       Varchar (100)      Null,
 request_mode             Nvarchar(120)  Not Null,
 request_status           Nvarchar(120)  Not Null,
 Query                    Varchar(Max)       Null,
 fechaInicioProceso       Datetime       Not Null,
 Tiempo_bloqueo           Integer        Not Null,
 fechaConsulta            Date           Not Null Default Getdate(),
 fechaInicio              Date           Not Null Default Getdate(),
 fechaTermino             Datetime           Null,
 informado                Tinyint        Not Null Default 0,
 Constraint logProcesosBloqueadosPk
 Primary Key (idProceso, secuencia));
 
Create Index idxlogProcesosBloqueados On logProcesosBloqueadosTbl (servidor, databaseName, sessionId)
 
 --
-- Comentarios
--

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                  @value      = 'Log de Análisis de Procesos de Procesos y Consultas Bloqueadas' , 
                                  @level0type = 'Schema',
                                  @level0name = 'dbo', 
                                  @level1type = 'Table',
                                  @level1name = 'logProcesosBloqueadosTbl'

Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador Correlativo del Proceso de Análisis.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logProcesosBloqueadosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'idProceso'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador del Servidor Problemas de Consultas Bloqueadas.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logProcesosBloqueadosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'servidor'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador de la Base de Datos con Problemas de Consultas Bloqueadas.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logProcesosBloqueadosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'databaseName'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador de la Sessión con Problemas de Consultas Bloqueadas.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logProcesosBloqueadosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'sessionId'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador del Objeto Bloqueado por la Consulta.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logProcesosBloqueadosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'ObjectName'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Descripción del Recurso donde se genera el Bloqueo.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logProcesosBloqueadosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'resource_description'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Id de la Sesión donde se genera el Bloqueo.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logProcesosBloqueadosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'request_session_id'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Modos de bloqueo. (Ver catCriteriosTbl)' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logProcesosBloqueadosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'request_mode'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Estado actual de la Consulta. Valores posibles GRANTED, CONVERT, WAIT, LOW_PRIORITY_CONVERT, LOW_PRIORITY_WAIT o ABORT_BLOCKERS' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logProcesosBloqueadosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'request_status'
Go


Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Consulta que Provoca el Bloqueo.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logProcesosBloqueadosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'Query'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Fecha / Hora de inicio de la Consulta con Problemas de Bloqueo.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logProcesosBloqueadosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'fechaInicioProceso'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Tiempo de Bloqueo de la Consulta con Problemas.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logProcesosBloqueadosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'Tiempo_bloqueo'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Fecha de la Consulta a los procesos.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logProcesosBloqueadosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'fechaConsulta'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Fecha y Hora de Inicio de la Consulta a los procesos ' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logProcesosBloqueadosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'fechaInicio'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Fecha y Hora de Termino de la Consulta a los procesos.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logProcesosBloqueadosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'fechaTermino'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Indica si fue reportada la incidencia de Procesos Bloqueados.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'logProcesosBloqueadosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'informado'
Go