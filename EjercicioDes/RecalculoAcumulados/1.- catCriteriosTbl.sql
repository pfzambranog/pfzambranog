Use Ejercicio_des
Go

--
-- obetivo:     Script de Generaci�n del cat�logo de Criterios.
-- fecha:       12/11/2024.
-- Programador: Pedro Zambrano
-- Versi�n:     1
--

If Exists (Select Top 1 1
           From   sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'catCriteriosTbl')
   Begin
      Drop table dbo.catCriteriosTbl
   End
Go

Create Table dbo.catCriteriosTbl (
    criterio         Char(25)     Not Null,
    valor            Tinyint      Not Null,
    descripcion      Varchar(60)  Not Null,
    valorAdicional   Varchar(20)      Null,
    idEstatus        Bit          Not Null Default 1,
    fechaAct         Datetime     Not Null Default Getdate(),
    ipAct            Varchar(30)      Null,
    macAddressAct    Varchar(30)      Null,
COnstraint catCriteriosPk
Primary Key (criterio, valor));
Go

--
-- Comentarios
--

Execute sys.sp_addextendedproperty @name       = 'MS_Description',
                                   @value      = 'Cat�logo de Criterios de Filtros' ,
                                   @level0type = 'Schema',
                                   @level0name = 'dbo',
                                   @level1type = 'Table',
                                   @level1name = 'catCriteriosTbl';
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description',
                                   @value      = 'Criterio del Fltro' ,
                                   @level0type = 'Schema',
                                   @level0name = 'dbo',
                                   @level1type = 'Table',
                                   @level1name = 'catCriteriosTbl',
                                   @level2type = 'Column',
                                   @level2name = 'criterio';
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description',
                                   @value      = 'Valor del Criterio para el Fltro' ,
                                   @level0type = 'Schema',
                                   @level0name = 'dbo',
                                   @level1type = 'Table',
                                   @level1name = 'catCriteriosTbl',
                                   @level2type = 'Column',
                                   @level2name = 'valor';
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description',
                                   @value      = 'Decripci�n del Valor del Criterio para el Fltro' ,
                                   @level0type = 'Schema',
                                   @level0name = 'dbo',
                                   @level1type = 'Table',
                                   @level1name = 'catCriteriosTbl',
                                   @level2type = 'Column',
                                   @level2name = 'descripcion';
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description',
                                   @value      = 'Decripci�n del Valor Adicional del Criterio para el Fltro' ,
                                   @level0type = 'Schema',
                                   @level0name = 'dbo',
                                   @level1type = 'Table',
                                   @level1name = 'catCriteriosTbl',
                                   @level2type = 'Column',
                                   @level2name = 'valorAdicional';
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description',
                                   @value      = 'Identificador del estatus del registro, 0 = Inhabilitado, 1 = Habilitado' ,
                                   @level0type = 'Schema',
                                   @level0name = 'dbo',
                                   @level1type = 'Table',
                                   @level1name = 'catCriteriosTbl',
                                   @level2type = 'Column',
                                   @level2name = 'idEstatus';
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description',
                                   @value      = '�ltima Fecha de Actualizaci�n del Registro' ,
                                   @level0type = 'Schema',
                                   @level0name = 'dbo',
                                   @level1type = 'Table',
                                   @level1name = 'catCriteriosTbl',
                                   @level2type = 'Column',
                                   @level2name = 'fechaAct';
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description',
                                   @value      = '�ltima Direcci�n IP desde donde se Actualiz� el Registro' ,
                                   @level0type = 'Schema',
                                   @level0name = 'dbo',
                                   @level1type = 'Table',
                                   @level1name = 'catCriteriosTbl',
                                   @level2type = 'Column',
                                   @level2name = 'ipAct';
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description',
                                   @value      = '�ltima Direcci�n MAC desde donde se Actualiz� el Registro' ,
                                   @level0type = 'Schema',
                                   @level0name = 'dbo',
                                   @level1type = 'Table',
                                   @level1name = 'catCriteriosTbl',
                                   @level2type = 'Column',
                                   @level2name = 'macAddressAct';
Go
