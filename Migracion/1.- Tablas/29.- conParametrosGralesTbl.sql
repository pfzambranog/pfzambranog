If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid = 1
           And    Type = 'U'
           And    Name = 'conParametrosGralesTbl')
   Begin
     Drop Table conParametrosGralesTbl
   End
Go

Create Table conParametrosGralesTbl(
    idParametroGral Smallint       Not Null,
    descripcion     Varchar(100)   Null,
    parametroChar   Varchar(150)   Null,
    parametroNumber Numeric(24, 6) Null,
    parametroFecha  Datetime       Null,
    idUsuarioAct    Smallint       Not Null,
    fechaAct        Datetime       Not Null,
    ipAct           Varchar(30)    Null,
    macAddressAct   Varchar(30)    Null,
 Constraint conParametrosGralesPk
 Primary Key (idParametroGral))

--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'C�diGo de Par�metro General de Configuraci�n' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl',
                                @level2type = 'Column',
                                @level2name = 'idParametroGral'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Descripci�n de Par�metro General de Configuraci�n' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl',
                                @level2type = 'Column',
                                @level2name = 'descripcion'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Par�metro Tipo Char.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl',
                                @level2type = 'Column',
                                @level2name = 'parametroChar'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Par�metro Tipo Numerico.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl',
                                @level2type = 'Column',
                                @level2name = 'parametroNumber'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Par�metro Tipo Fecha.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl',
                                @level2type = 'Column',
                                @level2name = 'parametroFecha'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'C�diGo de Usuario que realiz� �ltima actualizacion' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl',
                                @level2type = 'Column',
                                @level2name = 'idUsuarioAct'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Fecha de Aactualizaci�n del Registro' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl',
                                @level2type = 'Column',
                                @level2name = 'fechaAct'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = '�ltima Direcci�n IP desde donde se efectu� la Actualizaci�n del Registro' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl',
                                @level2type = 'Column',
                                @level2name = 'ipAct'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = '�ltima Direcci�n Mac desde donde se efectu� la Actualizaci�n del Registro' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl',
                                @level2type = 'Column',
                                @level2name = 'macAddressAct'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Cat�loGo de Par�metros de Generales de Configuraci�n' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'conParametrosGralesTbl'
Go
