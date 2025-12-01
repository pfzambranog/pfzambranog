Use SCMBD
Go

If Exists (Select Top 1 1
           From   sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'catAplicacionesTbl')
   Begin 
      Drop Table dbo.catAplicacionesTbl
   End
Go

Create Table dbo.catAplicacionesTbl
   (idAplicacion    Smallint       Not Null,
    descripcion     Varchar(100)   Not Null,
    idEstatus       Bit            Not Null Default(1),
    idUsuarioAct    Smallint       Not Null,
    fechaAct        Datetime       Not Null Default Getdate(),
    ipAct           Varchar( 30)       Null,
    macAddressAct   Varchar( 30)       Null,
Constraint catAplicacionesPk
Primary Key (idAplicacion))
Go

--
-- Comentarios
--

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Catálogo de Aplicaciones',
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catAplicacionesTbl'

Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador Único de Aplicación.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catAplicacionesTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'idAplicacion'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Nombre de la aplicación.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catAplicacionesTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'descripcion'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = '0 = Desactivado, 1 = Activo' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'catAplicacionesTbl', 
                                @level2type = 'Column',
                                @level2name = 'idEstatus'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'CódiGo de Usuario que realizó la Actualización del Registro' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'catAplicacionesTbl', 
                                @level2type = 'Column',
                                @level2name = 'idUsuarioAct'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Última Fecha de Actualización del Registro' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'catAplicacionesTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaAct'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Última Dirección IP desde donde se efectuó la Actualización del Registro' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'catAplicacionesTbl', 
                                @level2type = 'Column',
                                @level2name = 'ipAct'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Última Dirección Mac desde donde se efectuó la Actualización del Registro' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'catAplicacionesTbl', 
                                @level2type = 'Column',
                                @level2name = 'macAddressAct'
Go
