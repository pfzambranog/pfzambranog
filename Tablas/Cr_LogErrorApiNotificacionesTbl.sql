USE SCMBD
GO

If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'LogErrorApiNotificacionesTbl')
   Begin
      Drop Table dbo.LogErrorApiNotificacionesTbl
   End
Go   

Create Table dbo.LogErrorApiNotificacionesTbl(
	idMovimiento    Bigint       NOT NULL IDENTITY(1,1),
	fechaMovimiento Datetime     NOT NULL Default Getdate(),
	cadena          Varchar(250) NOT NULL,
	acccion         Varchar(100) NOT NULL,
	idError         Integer      NOT NULL,
	mensajeError    Varchar(250) NOT NULL,
	informado       Tinyint      NOT NULL,
 CONSTRAINT LogErrorApiNotificacionesPk PRIMARY KEY CLUSTERED 
(
	idMovimiento ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
GO


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador Correlativo en Movimientos con Error.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogErrorApiNotificacionesTbl', @level2type=N'COLUMN',@level2name=N'idMovimiento'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha del Movimiento con Error.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogErrorApiNotificacionesTbl', @level2type=N'COLUMN',@level2name=N'fechaMovimiento'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cadena de Ejecución que Causo el Error.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogErrorApiNotificacionesTbl', @level2type=N'COLUMN',@level2name=N'cadena'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Acción Sobre la Ejecución de la API que presentó el Error.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogErrorApiNotificacionesTbl', @level2type=N'COLUMN',@level2name=N'acccion'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código del Error de la Ejecución de la API.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogErrorApiNotificacionesTbl', @level2type=N'COLUMN',@level2name=N'idError'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código del Error de la Ejecución de la API.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogErrorApiNotificacionesTbl', @level2type=N'COLUMN',@level2name=N'mensajeError'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si el Error fue informado.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogErrorApiNotificacionesTbl', @level2type=N'COLUMN',@level2name=N'informado'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla de Movimientos de Error en llamados y ejecución de la API de emisión de notificaciones' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogErrorApiNotificacionesTbl'
GO


