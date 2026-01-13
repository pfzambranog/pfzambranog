USE [SCMBD]
GO

/****** Object:  Table [dbo].[catMensajesErroresTbl]    Script Date: 06/01/2026 11:29:55 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[catMensajesErroresTbl](
	[idError] [int] NOT NULL,
	[mensaje] [varchar](250) NULL,
	[idUsuarioAct] [int] NOT NULL,
	[fechaAct] [datetime] NULL,
	[ipAct] [varchar](30) NULL,
	[macAddressAct] [varchar](30) NULL,
 CONSTRAINT [catMensajesErroresPk] PRIMARY KEY CLUSTERED 
(
	[idError] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[catMensajesErroresTbl] ADD  CONSTRAINT [catMensajesErroresDf01]  DEFAULT (getdate()) FOR [fechaAct]
GO

ALTER TABLE [dbo].[catMensajesErroresTbl]  WITH CHECK ADD  CONSTRAINT [catMensajesErroresFk01] FOREIGN KEY([idUsuarioAct])
REFERENCES [dbo].[segUsuariosTbl] ([idUsuario])
GO

ALTER TABLE [dbo].[catMensajesErroresTbl] CHECK CONSTRAINT [catMensajesErroresFk01]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del Código de Error' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'catMensajesErroresTbl', @level2type=N'COLUMN',@level2name=N'idError'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descipción del Error' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'catMensajesErroresTbl', @level2type=N'COLUMN',@level2name=N'mensaje'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del Usuario que Actualizó el Registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'catMensajesErroresTbl', @level2type=N'COLUMN',@level2name=N'idUsuarioAct'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Última Fecha de  Actualización del Registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'catMensajesErroresTbl', @level2type=N'COLUMN',@level2name=N'fechaAct'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Dirección IP desde donde se Actualizó el Registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'catMensajesErroresTbl', @level2type=N'COLUMN',@level2name=N'ipAct'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Dirección Mac desde donde se Actualizó el Registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'catMensajesErroresTbl', @level2type=N'COLUMN',@level2name=N'macAddressAct'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CátaloGo Generales' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'catMensajesErroresTbl'
GO


