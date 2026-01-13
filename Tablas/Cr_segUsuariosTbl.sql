-- Use SCMBD
-- Go

If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'segUsuariosTbl')
   Begin
      Drop Table dbo.segUsuariosTbl
   End
Go

Create Table dbo.segUsuariosTbl
  (idUsuario           Integer        Not Null,
   claveUsuario        Varchar(260)   Not Null,
   nombre              Varchar(400)   Not Null,
   idTipoUsuario       Tinyint        Not Null Default 0,
   primerApellido      Varchar(80)        Null,
   segundoApellido     Varchar(80)        Null,
   nombres             Varchar(160)       Null,
   correo              Varchar(260)       Null,
   idEstatus           Tinyint        Not Null Default 1,
   idUsuarioAct        Integer        Not Null,
   fechaAct            Datetime       Not Null Default Getdate(),
   ipAct               Varchar(30)        Null,
   macAddressAct       Varchar(30)        Null,
Constraint SegUsuariosFk Primary Key Clustered
(idUsuario)
On [MgrPostgreIndices])
On [Primary]
Go

--
-- Comentarios
--

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'CatáloGo de Usuarios',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'segUsuariosTbl';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Identificador Único de Seguridad de Usuario',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'segUsuariosTbl',
                                   @level2type = N'Column',
                                   @level2name = N'idUsuario';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Código de Usuario en la Aplicación',
                                   @level0type = N'Schema',@level0name=N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'segUsuariosTbl',
                                   @level2type = N'Column',
                                   @level2name = N'claveUsuario';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Nombre completo del Usuario',
                                   @level0type = N'Schema',@level0name=N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'segUsuariosTbl',
                                   @level2type = N'Column',
                                   @level2name = N'nombre';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Identificador del Tipo de Usuario. 0 = Fucional, 1 = Administrativo',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'segUsuariosTbl',
                                   @level2type = N'Column',
                                   @level2name = N'idTipoUsuario';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Primer Apellido del Usuario',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'segUsuariosTbl',
                                   @level2type = N'Column',
                                   @level2name = N'primerApellido';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Segundo Apellido del Usuario',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'segUsuariosTbl',
                                   @level2type = N'Column',
                                   @level2name = N'segundoApellido';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Nombres del Usuario',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'segUsuariosTbl',
                                   @level2type = N'Column',
                                   @level2name = N'nombres';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Correo del Usuario',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'segUsuariosTbl',
                                   @level2type = N'Column',
                                   @level2name = N'correo';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Identificador del Estatus Usuario',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'segUsuariosTbl',
                                   @level2type = N'Column',
                                   @level2name = N'idEstatus';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Identificador del Último Usuario que Actualizó el Registro',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'segUsuariosTbl',
                                   @level2type = N'Column',
                                   @level2name = N'idUsuarioAct';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Última Fecha de Actualización el Registro',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'segUsuariosTbl',
                                   @level2type = N'Column',
                                   @level2name = N'fechaAct';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Última Dirección IP desde donde se Actualizó el Registro',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'segUsuariosTbl',
                                   @level2type = N'Column',
                                   @level2name = N'ipAct';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Última Dirección MAC desde donde se Actualizó el Registro',
                                   @level0type = N'Schema',@level0name=N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'segUsuariosTbl',
                                   @level2type = N'Column',
                                   @level2name = N'macAddressAct';
Go


