If Exists (Select Top 1 1 
           From   Sysobjects
           Where  Uid = 1
           And    Type = 'U'
           And    Name = 'catCriteriosTbl')
   Begin
     Drop Table catCriteriosTbl   
   End 
Go    

Create Table catCriteriosTbl
   (criterio       Char     (25) Not Null,
    valor          Smallint      Not Null,
    descripcion    Varchar  (60) Null,
    valorAdicional Varchar (250) Null,
Constraint catCriteriosTblPk
Primary Key (criterio, valor))
Go 

--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Criterio de Búsqueda de Valor' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catCriteriosTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'criterio'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Valor del Criterio de Búsqueda' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catCriteriosTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'valor'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Descripción del Criterio de Búsqueda' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catCriteriosTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'descripcion'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Valor Adicional al Criterio' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catCriteriosTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'valorAdicional'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'CatáloGo de Criterios de Búsquedas.' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catCriteriosTbl'
Go