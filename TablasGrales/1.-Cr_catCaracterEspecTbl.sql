If Exists(Select Top 1 1
          From   Sysobjects
          Where  Uid  = 1
          And    Type = 'U'
          And    Name = 'catCaracterEspecTbl')
   Begin
      Drop Table catCaracterEspecTbl
   End
GO

Create Table catCaracterEspecTbl
   (caracter  Char(1)  Not Null,
    chrAscii  Smallint Not Null,
Constraint catCaracterEspecPk
Primary Key (chrAscii))
Go 
    
--
-- Comentarios
--

EXEC sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Carácter Especial' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catCaracterEspecTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'caracter'
GO

EXEC sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Código Ascii del Carácter Especial' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catCaracterEspecTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'chrAscii'
GO

EXEC sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Catálogo de Caracteres especiales Permitidos.' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catCaracterEspecTbl'
GO