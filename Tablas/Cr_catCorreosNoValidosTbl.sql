Use SCMBD
Go

If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'logAnalisisJobsTbl')
   Begin
      Drop Table logAnalisisJobsTbl
   End
Go

Create Table dbo.catCorreosNoValidosTbl
(Correo          Varchar( 260) Not Null,
 Motivo          Varchar(1000)     Null,
 fechaAlta       Datetime      Not Null Default Getdate(),
Constraint catCorreosNoValidosPk
Primary Key(correo))
--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Catalogo de correos no Válidos.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'catCorreosNoValidosTbl'

Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Dirección de correo no Válido.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'catCorreosNoValidosTbl', 
                                @level2type = 'Column',
                                @level2name = 'correo'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Motivo de correo no Válido.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'catCorreosNoValidosTbl', 
                                @level2type = 'Column',
                                @level2name = 'Motivo'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'F correo no Válido.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'catCorreosNoValidosTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaAlta'
Go