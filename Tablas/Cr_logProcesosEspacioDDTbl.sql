USE SCMBD
GO

/****** Object:  Table dbo.logProcesosEspacioDDTbl    Script Date: 01/12/2025 12:24:49 p. m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.logProcesosEspacioDDTbl') AND type in (N'U'))
DROP TABLE dbo.logProcesosEspacioDDTbl
GO

/****** Object:  Table dbo.logProcesosEspacioDDTbl    Script Date: 01/12/2025 12:24:49 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE dbo.logProcesosEspacioDDTbl(
    idProceso int IDENTITY(1,1) NOT NULL,
    servidor sysname NOT NULL,
    fechaInicio datetime NOT NULL,
    fechaTermino datetime NULL,
    totalEspacio decimal(18, 2) NOT NULL,
    totaldisponible decimal(18, 2) NOT NULL,
    porcentajeDisponible decimal(18, 2) NOT NULL,
    informado Tinyint NOT NULL,
    error int NOT NULL,
    mensajeError nvarchar(4000) NOT NULL,
 CONSTRAINT logProcesosEspacioDDPk PRIMARY KEY CLUSTERED
(
    idProceso ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE dbo.logProcesosEspacioDDTbl ADD  DEFAULT (@@servername) FOR servidor
GO

ALTER TABLE dbo.logProcesosEspacioDDTbl ADD  DEFAULT (getdate()) FOR fechaInicio
GO

ALTER TABLE dbo.logProcesosEspacioDDTbl ADD  DEFAULT ((0)) FOR totalEspacio
GO

ALTER TABLE dbo.logProcesosEspacioDDTbl ADD  DEFAULT ((0)) FOR totaldisponible
GO

ALTER TABLE dbo.logProcesosEspacioDDTbl ADD  DEFAULT ((0)) FOR porcentajeDisponible
GO

ALTER TABLE dbo.logProcesosEspacioDDTbl ADD  DEFAULT ((0)) FOR informado
GO

ALTER TABLE dbo.logProcesosEspacioDDTbl ADD  DEFAULT ((0)) FOR error
GO

ALTER TABLE dbo.logProcesosEspacioDDTbl ADD  DEFAULT ('') FOR mensajeError
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador Correlativo del Proceso de Análisis.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'logProcesosEspacioDDTbl', @level2type=N'COLUMN',@level2name=N'idProceso'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del Servidor donde se realizó Proceso de Análisis.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'logProcesosEspacioDDTbl', @level2type=N'COLUMN',@level2name=N'servidor'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha Inicio de Ejecución del Análisis' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'logProcesosEspacioDDTbl', @level2type=N'COLUMN',@level2name=N'fechaInicio'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha Termino de Ejecución del Análisis' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'logProcesosEspacioDDTbl', @level2type=N'COLUMN',@level2name=N'fechaTermino'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Espacio Total del Disco Duro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'logProcesosEspacioDDTbl', @level2type=N'COLUMN',@level2name=N'totalEspacio'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Espacio Disponible en Total del Disco Duro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'logProcesosEspacioDDTbl', @level2type=N'COLUMN',@level2name=N'totaldisponible'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Porcentaje de Espacio Disponible en Total del Disco Duro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'logProcesosEspacioDDTbl', @level2type=N'COLUMN',@level2name=N'porcentajeDisponible'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estatus que indica si fue notificado el resultado del análisis' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'logProcesosEspacioDDTbl', @level2type=N'COLUMN',@level2name=N'informado'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del Error encontrado durante el análisis' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'logProcesosEspacioDDTbl', @level2type=N'COLUMN',@level2name=N'error'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción del Error encontrado durante la análisis' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'logProcesosEspacioDDTbl', @level2type=N'COLUMN',@level2name=N'mensajeError'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Log de Análisis de Análisis de Espacio Disponible en DD.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'logProcesosEspacioDDTbl'
GO


