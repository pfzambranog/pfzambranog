Use SCMBD
Go

If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'movLogMonitoresPushTbl')
   Begin
      Drop Table dbo.movLogMonitoresPushTbl
   End
Go

Create Table dbo.movLogMonitoresPushTbl
  (idMovimiento   Bigint       Not Null IDENTITY(1,1) ,
   idMonitor      Smallint     Not Null,
   idOrigen       Smallint     Not Null,
   fechaInicio    Datetime     Not Null,
   registros      Integer      Not Null,
   error          Integer      Not Null,
   comentarios    Varchar(250) Not Null,
 CONSTRAINT movLogMonitoresPushPk
 PRIMARY KEY CLUSTERED(idMovimiento))
GO

ALTER TABLE dbo.movLogMonitoresPushTbl ADD  DEFAULT (getdate()) FOR fechaInicio
GO

ALTER TABLE dbo.movLogMonitoresPushTbl ADD  DEFAULT ((0)) FOR registros
GO

ALTER TABLE dbo.movLogMonitoresPushTbl ADD  DEFAULT ((0)) FOR error
GO

ALTER TABLE dbo.movLogMonitoresPushTbl ADD  DEFAULT (char((32))) FOR comentarios
GO


--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Tabla de movimientos de los Monitores Push' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'movLogMonitoresPushTbl'

Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Identificador de movimientos de los Monitores Push.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'movLogMonitoresPushTbl',
                                @level2type = 'Column',
                                @level2name = 'idMovimiento'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Identificador del Monitor Push.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'movLogMonitoresPushTbl',
                                @level2type = 'Column',
                                @level2name = 'idMonitor'
Go
