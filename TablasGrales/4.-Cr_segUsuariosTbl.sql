Use SCMBD
Go

If Exists (Select Top 1 1 
           From   Sysobjects 
           Where  Uid = 1
           And    Type = 'U'
           And    Name = 'segUsuariosTbl')
   Begin 
     Drop Table segUsuariosTbl
   End    
Go    

Create Table segUsuariosTbl
   (idUsuario       Integer       Not Null,
    idEstatus       Bit           Not Null Default(1),
    idUsuarioAct    Integer       Null,
    fechaAct        Datetime      Null,
    ipAct           Varchar(30)   Null,
    macAddressAct   Varchar(30)   Null,
Constraint SegUsuariosFk
Primary Key (idUsuario))

--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'CódiGo de Usuario en la Aplicación' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'segUsuariosTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'idUsuario'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = '0 = Desactivado, 1 = Activo' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'segUsuariosTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'idEstatus'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'CódiGo de Usuario que realizó la Actualización del Registro' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'segUsuariosTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'idUsuarioAct'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Última Fecha de Actualización del Registro' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'segUsuariosTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'fechaAct'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Última Dirección IP desde donde se efectuó la Actualización del Registro' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'segUsuariosTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'ipAct'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Última Dirección Mac desde donde se efectuó la Actualización del Registro' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'segUsuariosTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'macAddressAct'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'CatáloGo de Usuarios' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'segUsuariosTbl'
Go