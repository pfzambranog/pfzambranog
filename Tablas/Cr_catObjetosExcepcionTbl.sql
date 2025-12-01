Use SCMBD
Go

If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'catObjetosExcepcionTbl')
   Begin
      Drop Table dbo.catObjetosExcepcionTbl
   End
Go

Create Table dbo.catObjetosExcepcionTbl
(idProceso         Integer         Not Null   Identity(1, 1),
 baseDatos         Sysname         Not Null,
 tipo              Varchar(2)      Not Null,
 objeto            Sysname         Not Null,
 fechaAlta       DateTime        Not Null   Default GetDate(),
Constraint catObjetosExcepcionPk
Primary Key (idProceso),
Index catObjetosExcepcionIdx01 Unique (baseDatos, objeto))
Go

--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Catálogo de Objetos Exceptuados de Análisis' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'catObjetosExcepcionTbl'

Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Identificador Correlativo del  Objeto Exceptuado.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'catObjetosExcepcionTbl',
                                @level2type = 'Column',
                                @level2name = 'idProceso'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Identificador de la base de datos que contiene el Objeto Exceptuado.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'catObjetosExcepcionTbl',
                                @level2type = 'Column',
                                @level2name = 'baseDatos'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Identificador del tipo de Objeto Exceptuado.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'catObjetosExcepcionTbl',
                                @level2type = 'Column',
                                @level2name = 'tipo'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Nombre del Objeto Exceptuado.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'catObjetosExcepcionTbl',
                                @level2type = 'Column',
                                @level2name = 'objeto'
Go


Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Fecha de alta del registro' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'catObjetosExcepcionTbl',
                                @level2type = 'Column',
                                @level2name = 'fechaAlta'
Go
