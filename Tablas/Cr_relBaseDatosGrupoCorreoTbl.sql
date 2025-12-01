Use SMBDTI
Go

If Exists (Select Top 1 1
           From   Sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'relBaseDatosGrupoCorreoTbl')
   Begin
      Drop Table relBaseDatosGrupoCorreoTbl
   End
Go

Create Table relBaseDatosGrupoCorreoTbl
(idRelacion          Integer       Not Null Identity(1, 1),
 baseDatos           Sysname       Not Null,
 codigoGrupoCorreo   Varchar(20)   Not Null,
 idEstatus           Bit           Not Null Default 1,
 fechaAlta           Datetime      Not Null Default Getdate(),
 fechaAct            Datetime      Not Null Default Getdate(),
Constraint relBaseDatosGrupoCorreoPk
Primary Key (idRelacion))
Go

Create Unique Index relBaseDatosGrupoCorreoIdex01 On relBaseDatosGrupoCorreoTbl (baseDatos, codigoGrupoCorreo);

--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Tabla de Relación de Base de Datos - Grupo de Correo.' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'relBaseDatosGrupoCorreoTbl'

Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador de Relación de Base de Datos - Grupo de Correo' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'relBaseDatosGrupoCorreoTbl', 
                                @level2type = 'Column',
                                @level2name = 'idRelacion'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador de la Base de Datos' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'relBaseDatosGrupoCorreoTbl', 
                                @level2type = 'Column',
                                @level2name = 'baseDatos'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Código de Grupo de Correo al que se le envíara el correo de ejecuciones' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'relBaseDatosGrupoCorreoTbl', 
                                @level2type = 'Column',
                                @level2name = 'codigoGrupoCorreo'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Estatus del Registro' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'relBaseDatosGrupoCorreoTbl', 
                                @level2type = 'Column',
                                @level2name = 'idEstatus'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Fecha de Alta del Registro' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'relBaseDatosGrupoCorreoTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaAlta'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Última Fecha de Actualización del Registro' , 
                                @level0type = 'Schema',
                                @level0name = 'dbo', 
                                @level1type = 'Table',
                                @level1name = 'relBaseDatosGrupoCorreoTbl', 
                                @level2type = 'Column',
                                @level2name = 'fechaAct'
Go