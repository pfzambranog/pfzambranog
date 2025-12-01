Use SCMBD
Go

If Exists (Select Top 1 1
           From   Information_schema.Tables
           Where  table_schema = 'dbo'
           And    table_name   = 'movLogControlCambiosTbl')
   Begin
      Drop Table dbo.movLogControlCambiosTbl
   End
Go

Create table dbo.movLogControlCambiosTbl
(secuencia             Integer         Not Null Identity (1, 1),
 idUsuario             Integer         Not Null,
 baseDatos             Sysname         Not Null,
 fecha                 Date            Not Null Default Getdate(),
 tipoActualizacion     Tinyint         Not Null Default 1, -- 1 = Back, 2 = API/Front
 cantidad              Integer         Not Null,
 cantidadErrores       Integer         Not Null Default 0,
 idError               Varchar( 10)        Null Default '',
 observaciones         Varchar(250)        Null Default '',
 informado             Tinyint             Not Null Default 0,
 Constraint movLogControlCambiosPk
 Primary Key (secuencia),
 Index movLogControlCambiosIdx01 (idUsuario, baseDatos, fecha),
 Constraint movLogControlCambiosChk01
 Check (tipoActualizacion In (1, 2)))
 Go

--
-- Comentarios
--

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla Log de Movimientos de Control de Cambio.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table',
                                @level1name = N'movLogControlCambiosTbl'
Go

Execute sp_addextendedproperty @name       = N'MS_Description',
                               @value      = N'Identificador Único del Movimiento de Control de Cambio.',
                               @level0type = 'Schema',
                               @level0name = N'dbo',
                               @level1type = 'Table',
                               @level1name = N'movLogControlCambiosTbl',
                               @level2type = 'Column',
                               @level2name = N'secuencia'
Go

Execute sp_addextendedproperty @name       = N'MS_Description',
                               @value      = N'Identificador del Usuario que solicita el Control de Cambio.',
                               @level0type = 'Schema',
                               @level0name = N'dbo',
                               @level1type = 'Table',
                               @level1name = N'movLogControlCambiosTbl',
                               @level2type = 'Column',
                               @level2name = N'idUsuario'
Go

Execute sp_addextendedproperty @name       = N'MS_Description',
                               @value      = N'Base de Datos donde se Solicita el Control de Cambio.',
                               @level0type = 'Schema',
                               @level0name = N'dbo',
                               @level1type = 'Table',
                               @level1name = N'movLogControlCambiosTbl',
                               @level2type = 'Column',
                               @level2name = N'baseDatos'
Go

Execute sp_addextendedproperty @name       = N'MS_Description',
                               @value      = N'Fecha en que se Solicita el Control de Cambio.',
                               @level0type = 'Schema',
                               @level0name = N'dbo',
                               @level1type = 'Table',
                               @level1name = N'movLogControlCambiosTbl',
                               @level2type = 'Column',
                               @level2name = N'fecha'
Go

Execute sp_addextendedproperty @name       = N'MS_Description',
                               @value      = N'Tipo de Actualización Solicitada en el Control de Cambio. 1 = Back, 2 = API/Front',
                               @level0type = 'Schema',
                               @level0name = N'dbo',
                               @level1type = 'Table',
                               @level1name = N'movLogControlCambiosTbl',
                               @level2type = 'Column',
                               @level2name = N'tipoActualizacion'
Go

Execute sp_addextendedproperty @name       = N'MS_Description',
                               @value      = N'Cantidad de Objetos del Control de Cambio.',
                               @level0type = 'Schema',
                               @level0name = N'dbo',
                               @level1type = 'Table',
                               @level1name = N'movLogControlCambiosTbl',
                               @level2type = 'Column',
                               @level2name = N'cantidad'
Go

Execute sp_addextendedproperty @name       = N'MS_Description',
                               @value      = N'Cantidad de Objetos con Errores en el Control de Cambio.',
                               @level0type = 'Schema',
                               @level0name = N'dbo',
                               @level1type = 'Table',
                               @level1name = N'movLogControlCambiosTbl',
                               @level2type = 'Column',
                               @level2name = N'cantidadErrores'
Go

Execute sp_addextendedproperty @name       = N'MS_Description',
                               @value      = N'Identificador del Error Principal en el Control de Cambio.',
                               @level0type = 'Schema',
                               @level0name = N'dbo',
                               @level1type = 'Table',
                               @level1name = N'movLogControlCambiosTbl',
                               @level2type = 'Column',
                               @level2name = N'idError'
Go

Execute sp_addextendedproperty @name       = N'MS_Description',
                               @value      = N'Observaciones en el Control de Cambio.',
                               @level0type = 'Schema',
                               @level0name = N'dbo',
                               @level1type = 'Table',
                               @level1name = N'movLogControlCambiosTbl',
                               @level2type = 'Column',
                               @level2name = N'observaciones'
Go

Execute sp_addextendedproperty @name       = N'MS_Description',
                               @value      = N'Indica si fue Informado el Resultado del Control de Cambio.',
                               @level0type = 'Schema',
                               @level0name = N'dbo',
                               @level1type = 'Table',
                               @level1name = N'movLogControlCambiosTbl',
                               @level2type = 'Column',
                               @level2name = N'informado'
Go
