Use SCMBD
Go

If Exists ( Select Top 1 1
            From   Sysobjects
            Where  Uid  = 1
            And    Type = 'U'
            And    Name = 'logHistorialEjecucionProcTbl')
   Begin
      Drop Table dbo.logHistorialEjecucionProcTbl
   End
Go

Create Table dbo.logHistorialEjecucionProcTbl
  (idProceso        Integer         Not Null,
   secuencia        Integer         Not Null,
   baseDatos        Sysname         Not Null,
   procedimiento    Sysname         Not Null,
   ultimaEjecucion  Datetime        Not Null,
   fechaProcesoAnt  Datetime        Not Null,
   fechaProcesoAct  Datetime        Not Null Default Getdate(),
   dias             Integer         Not Null Default 0,
   cantidad         Integer         Not Null Default 0,
   tiempoMinimo     Decimal (18, 2) Not Null Default 0,
   tiempoMaximo     Decimal (18, 2) Not Null Default 0,
   informado        Tinyint         Not Null Default 0,
Constraint logHistorialEjecucionProcPk
Primary Key Clustered (idProceso, secuencia)
On [Primary],
Index logHistorialEjecucionProcIdx01  Unique (baseDatos, procedimiento, fechaProcesoAct))
On [Primary]
Go

--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Historial de Ejecuciones de Procedimientos.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logHistorialEjecucionProcTbl'

Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Proceso de Análisis.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logHistorialEjecucionProcTbl', 
                                @level2type = 'Column',
                                @level2name = 'idProceso'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador Correlativo del Proceso de Análisis.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logHistorialEjecucionProcTbl', 
                                @level2type = 'Column',
                                @level2name = 'secuencia'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Base de datos donde se ejecuta el Proceso de Análisis.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logHistorialEjecucionProcTbl', 
                                @level2type = 'Column',
                                @level2name = 'baseDatos'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Nombre del Procedimiento Ejecutado.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logHistorialEjecucionProcTbl', 
                                @level2type = 'Column',
                                @level2name = 'procedimiento'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Última Fecha de Ejecución del Procedimiento.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logHistorialEjecucionProcTbl', 
                                @level2type = 'Column',
                                @level2name = 'ultimaEjecucion'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Fecha Anterior de Consulta de Ejecución.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logHistorialEjecucionProcTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaProcesoAnt'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Fecha Actual de Consulta de Ejecución.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logHistorialEjecucionProcTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaProcesoAct'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Días de Análisis del Proceso.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logHistorialEjecucionProcTbl', 
                                @level2type = 'Column',
                                @level2name = 'dias'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Cantidad de ejecuciones del procedimiento durante el período analizado.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logHistorialEjecucionProcTbl', 
                                @level2type = 'Column',
                                @level2name = 'cantidad'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Tiempo Mínimo de ejecución del procedimiento en el período analizado', 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logHistorialEjecucionProcTbl', 
                                @level2type = 'Column',
                                @level2name = 'tiempoMinimo'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Tiempo Máximo de ejecución del procedimiento en el período analizado', 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logHistorialEjecucionProcTbl', 
                                @level2type = 'Column',
                                @level2name = 'tiempoMaximo'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Estatus del envío del resulatado de la consulta del Proceso' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'logHistorialEjecucionProcTbl', 
                                @level2type = 'Column',
                                @level2name = 'informado'
Go

