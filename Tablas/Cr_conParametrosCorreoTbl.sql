Use SCMBD
Go

If Exists (Select Top 1 1
           From   sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'conParametrosCorreoTbl')
   Begin
      Drop Table dbo.conParametrosCorreoTbl
   End
Go

Create Table dbo.conParametrosCorreoTbl
   (idParametro      Integer      Not Null,
    descripcion      Varchar(100) Not Null,
    idAplicacion     Smallint         Null,
    valorNumerico    Integer          Null,
    valorAlfa        Varchar(250)     Null,
    valorTexto       Varchar(Max)     Null,
    valorFecha       Datetime         Null,
    idEstatus        Bit          Not Null Default 1,
    idUsuarioAct     Integer      Not Null,
    fechaAct         Datetime     Not Null  Default Getdate(),
    ipAct            Varchar(30)      Null,
    macAddressAct    Varchar(30)      Null,
Constraint conParametrosCorreoPk
Primary Key Clustered (idParametro)
On [PRIMARY],
Constraint conParametrosCorreoFk01
Foreign Key(idUsuarioAct)
References dbo.segUsuariosTbl (idUsuario) On delete Cascade,
Constraint conParametrosCorreoFk02
Foreign Key(idAplicacion)
References dbo.catAplicacionesTbl (idAplicacion) On delete Cascade)
Textimage_On [Primary];

--
-- Comentarios
--


Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Catálogo de los Parámetros de Correo por Aplicación',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conParametrosCorreoTbl';
Go



Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Identificador Único del Parámetro de Correo',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conParametrosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'idParametro';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Descripción del Parámetro de Correo',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conParametrosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'descripcion';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Código de Aplicación',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conParametrosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'idAplicacion';
Go


Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Valor Numérico del Parámetro',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conParametrosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'valorNumerico';
Go

Execute sys.sp_addextendedproperty @name=N'MS_Description',
                                   @value=N'Valor Alfanumérico del Parámetro',
                                   @level0type=N'Schema',
                                   @level0name=N'dbo', 
                                   @level1type=N'Table',
                                   @level1name=N'conParametrosCorreoTbl',
                                   @level2type=N'Column',
                                   @level2name=N'valorAlfa';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Valor Texto del Parámetro',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conParametrosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'valorTexto'
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Valor Fecha del Parámetro',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conParametrosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'valorFecha'
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Identificador del Estatus del Registro',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conParametrosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'idEstatus';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Código de Usuario que Actualizó el Registro',
                                   @level0type = N'Schema',@level0name=N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conParametrosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'idUsuarioAct';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Última Fecha de Actualización del Registro',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conParametrosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'fechaAct';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Dirección IP desde donde se Actualizó el Registro',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conParametrosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'ipAct';
Go

Execute sys.sp_addextendedproperty @name       = N'MS_Description',
                                   @value      = N'Dirección MAC desde donde se Actualizó el Registro',
                                   @level0type = N'Schema',
                                   @level0name = N'dbo',
                                   @level1type = N'Table',
                                   @level1name = N'conParametrosCorreoTbl',
                                   @level2type = N'Column',
                                   @level2name = N'macAddressAct';
Go

