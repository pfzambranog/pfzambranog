--
-- Comentarios
--

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Areas y Regi�n',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Area_o_Region'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Auxiliares',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Auxiliar'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Cuentas Contables',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Catalogo'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Cuentas Auxiliares Contables',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'CatalogoAuxiliar'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Cuentas Auxiliares de Cierre',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'CatalogoAuxiliarCierreTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Cuentas Auxiliares de Cierre por Per�odo',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'CatalogoAuxiliarCierre'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Cuentas al Cierre por Per�odo',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'CatalogocierreTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Cuentas Contables Consolidadas',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'CatalogoConsolidado'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Cuentas Contables de Externos',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'CatAuxExterno'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Rechazo de P�lizas Contables',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catCausasRechazoTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo SEPOMEX de Ciudades',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catCiudadesTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo SEPOMEX de C�digos Postales',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catCodigosPostalesTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo SEPOMEX de Colonias',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catColoniasTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo SEPOMEX de Estados',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catEstadosTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo SEPOMEX de Municipios',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catMunicipiosTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo SEPOMEX de Paises',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catPaisesTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo SAT de Paises',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catPaisesSATTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo SAT de Estados',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catEstadosSATTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo SAT de C�digos AGrupadores',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'CodigoAgrupadorSAT'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de descripci�n de criterios de selecc�n',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catCriteriosTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Descripci�n de Catalogos Generales',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'catGeneralesTbl'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Contadores',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Contadores'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de control de Auxiliares de CC',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'ControlAuxiliarCC'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Cuentas Predeterminadas',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Cuentas_predeterminadas'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Departamento y Sucursal',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Departamento_o_Sucursal'
Go


Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de control de Ejercicios contables.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Ejercicios'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de control de Ejercicios contables.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Ejercicios_Presupuesto'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Monedas.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Moneda'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Grupos Area y Regi�n',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Grupo_Area_o_Region'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Detalle de Grupos Area y Regi�n',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Grupo_Area_o_Region_detalle'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Grupos de Usuarios.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Grupos'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Grupos de Empresas.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Grupos_Empresas'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Mayores por Sectores.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Mayor_Sector'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Mapeo de C�digos de Agrupadores Contables.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'MapeoCodigoAgrupador'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Detalle de la P�liza Diaria.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'MovDia'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Detalle de la P�liza Diaria por Per�odo.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Movimientos'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Detalle de la P�liza Diaria Hist�rica por Per�odo.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'MovimientosHist'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Detalle de la P�liza Diaria Capturada por Per�odo.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'MovimientosCaptura'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Detalle de la P�liza de cierre por Per�odo.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'MovimientosCierre'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Detalle de la P�liza con Errores.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'MovimientosErrores'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de la Naturaleaz de la cuenta contable',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Naturaleza_Cuentas'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Encabezado de la P�liza Diaria.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'PolDia'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Encabezado de la P�liza Diaria por Per�odo.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Poliza'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Encabezado de la P�liza Diaria Hist�rica por Per�odo.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'PolizaHist'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Encabezado de la P�liza Diaria Capturada por Per�odo.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'PolizaCaptura'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de Encabezado de la P�liza de cierre por Per�odo.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'PolizaCierre'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Par�metros.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Parametros'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Tabla de promedios de cifras contables.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Promedios'
Go


Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Sectores.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Sector'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Tipo de Cambios.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'TipoDeCambio'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Tipo de P�liza contable.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'TipoPol'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Tipo de Reexpresi�n Contable.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'TipoReex'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de la tasa de Reexpresi�n Contable.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'TasaReex'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Mayores de Sectorizaci�n.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Sectorizacion'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Rangos Contables.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Rangos'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de SubRangos Contables.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'SubRangos'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de SubRangos Contables por Departamento.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'RelSubRangos_DepartamentosTbl'
Go


Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Usuarios.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Usuarios'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Formatos Contables ER.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Formato_ER'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Formatos de Reportes.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Formatos'
Go

Execute  sp_addextendedproperty @name       = N'MS_Description',
                                @value      = N'Cat�logo de Formatos de Reportes por Empresa.',
                                @level0type = 'Schema',
                                @level0name = N'dbo',
                                @level1type = 'Table', 
                                @level1name = 'Formatos_Empresas'
Go



