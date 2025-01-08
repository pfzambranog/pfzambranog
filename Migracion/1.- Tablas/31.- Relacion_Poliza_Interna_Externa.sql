--
-- Script de Generaci�n de tabla de Relaci�n de importaci�n de p�lizas contables.
--

If Exists (Select Top 1 1
           From   sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'Relacion_Poliza_Interna_Externa')
   Begin
      Drop table dbo.Relacion_Poliza_Interna_Externa
   End
Go
-- Creating table 'Relacion_Poliza_Interna_Externa'

Create Table dbo.Relacion_Poliza_Interna_Externa
   (Referencia          Varchar(20)  Not Null,
    Fecha_Mov           datetime     Not Null,
    Fuentedatos         Varchar(50)  Not Null,
    Referencia_contable Varchar(20)      Null,
    Fecha_Cap           Datetime     Not Null Default Getdate(),
    Usuario             Varchar(10)      Null
Constraint Relacion_Poliza_Interna_ExternaPk
Primary Key Clustered(Referencia, Fecha_Mov, Fuentedatos));
Go

--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Tabla Relaci�n de importaci�n de p�lizas contables' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'Relacion_Poliza_Interna_Externa'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Referencia �nica de la P�liza Origen' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'Relacion_Poliza_Interna_Externa',
                                @level2type = 'Column',
                                @level2name = 'Referencia'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Fecha de la P�liza Origen' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'Relacion_Poliza_Interna_Externa',
                                @level2type = 'Column',
                                @level2name = 'Fecha_Mov'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Descripci�n del Origen de la P�liza.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'Relacion_Poliza_Interna_Externa',
                                @level2type = 'Column',
                                @level2name = 'Fuentedatos'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Referencia �nica de la P�liza Destino.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'Relacion_Poliza_Interna_Externa',
                                @level2type = 'Column',
                                @level2name = 'Referencia_contable'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'Fecha de la Migraci�n de la P�liza Contable.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'Relacion_Poliza_Interna_Externa',
                                @level2type = 'Column',
                                @level2name = 'Fecha_Cap'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description',
                                @value      = 'C�digo de Usuario que realiza la Migraci�n de la P�liza Contable.' ,
                                @level0type = 'Schema',
                                @level0name = 'dbo',
                                @level1type = 'Table',
                                @level1name = 'Relacion_Poliza_Interna_Externa',
                                @level2type = 'Column',
                                @level2name = 'Usuario'
Go
