Use SCMBD
Go

If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'conMotivosCorreoTbl')
   Begin
      Drop Table dbo.conMotivosCorreoTbl
   End
Go


Create TABLE dbo.conMotivosCorreoTbl(
	idMotivo         smallint      NOT Null,
	descripcion      varchar( 100)     Null,
	titulo           varchar(1000) Not Null,
	cuerpo           varchar(8000) Not Null,
	URL              varchar(1000)     Null,
	idUsuarioAct     Integer       Not Null,
	fechaAct         datetime      Not Null,
	ipAct            varchar(30)       Null,
	macAddressAct    varchar(30)       Null,
	permiteCompartir bit           Not Null Default ((0)),
	html             varchar(8000)     Null,
    perfilCorreo     Varchar(1000)     Null,   
 CONSTRAINT conMotivosCorreoPk PRIMARY KEY CLUSTERED 
(
	idMotivo ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
 ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE dbo.conMotivosCorreoTbl ADD  CONSTRAINT conMotivosCorreoDef01  DEFAULT (getdate()) FOR fechaAct
GO



EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de Motivo de Emisión de Correo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'conMotivosCorreoTbl', @level2type=N'COLUMN',@level2name=N'idMotivo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Decripción Motivo de Emisión de Correo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'conMotivosCorreoTbl', @level2type=N'COLUMN',@level2name=N'descripcion'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Titulo del Correo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'conMotivosCorreoTbl', @level2type=N'COLUMN',@level2name=N'titulo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Texto del Correo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'conMotivosCorreoTbl', @level2type=N'COLUMN',@level2name=N'cuerpo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Dirección URL de Apoyo para Envío de Notificaciones' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'conMotivosCorreoTbl', @level2type=N'COLUMN',@level2name=N'URL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del Último Usuario que Actualizó el Registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'conMotivosCorreoTbl', @level2type=N'COLUMN',@level2name=N'idUsuarioAct'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ultima fecha de actualiazción del Registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'conMotivosCorreoTbl', @level2type=N'COLUMN',@level2name=N'fechaAct'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Última Dirección IP desde Donde se Actualizo el Registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'conMotivosCorreoTbl', @level2type=N'COLUMN',@level2name=N'ipAct'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Última Dirección MAC desde Donde se Actualizo el Registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'conMotivosCorreoTbl', @level2type=N'COLUMN',@level2name=N'macAddressAct'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Bandera que Indica si el Motivo de Correo puede ser Compartido' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'conMotivosCorreoTbl', @level2type=N'COLUMN',@level2name=N'permiteCompartir'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Texto del Correo  en Formato HTML' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'conMotivosCorreoTbl', @level2type=N'COLUMN',@level2name=N'html'
GO

EXEC sys.sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Perfil de Correo Relacionado al Motivo de Correo',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'TABLE',
                                @level1name = N'conMotivosCorreoTbl',
                                @level2type = N'COLUMN',
                                @level2name = N'perfilCorreo'
GO


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Catálogo de Configuración de Motivos de Emisión de Correos.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'conMotivosCorreoTbl'
GO



