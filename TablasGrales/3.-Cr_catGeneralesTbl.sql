If Exists (Select Top 1 1 
           From   Sysobjects 
           Where  Uid = 1 
           And    Type = 'U'
           And    Name = 'catGeneralesTbl')
   Begin 
     Drop Table catGeneralesTbl
   End 
Go    

Create Table catGeneralesTbl
   (tabla       Sysname     Not Null,
    columna     Sysname     Not Null,
    valor       Smallint    Not Null,
    descripcion Varchar(60) Null,
Constraint catGeneralesPk
Primary Key (tabla, columna, valor))
Go 

--
-- Comentarios
--

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Nombre de la tabla a la cual se le van a referenciar las variables' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catGeneralesTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'tabla'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Columna a la cual se le van a referenciar las variables ' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catGeneralesTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'columna'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Valor de la variable' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catGeneralesTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'valor'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Descripción de la Variable' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catGeneralesTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'descripcion'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Tabla de Variables Generales Aplicables a Tablas Especificas.' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catGeneralesTbl'
Go
