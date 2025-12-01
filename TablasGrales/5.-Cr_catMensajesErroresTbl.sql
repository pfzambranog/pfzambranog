If Exists (Select Top 1 1 
           From   Sysobjects 
           Where  Uid = 1
           And    Type = 'U'
           And    Name = 'catMensajesErroresTbl')
   Begin 
     Drop Table catMensajesErroresTbl
   End    
Go    

Create Table catMensajesErroresTbl
   (idError       smallint      Not Null,
    mensaje       varchar (250) Null,
    idUsuarioAct  smallint      Not Null,
    fechaAct      datetime      Null,
    ipAct         varchar (30)  Null,
    macAddressAct varchar (30)  Null,
Constraint catMensajesErroresPk
Primary Key (idError),
 Constraint catMensajesErroresFk01
 Foreign Key (idUsuarioAct)
 References segUsuariosTbl);

--
-- Comentarios
--


Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Código de Error' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catMensajesErroresTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'idError'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Identificador del Usuario que Actualizó el Registro' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catMensajesErroresTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'idUsuarioAct'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Última Fecha de  Actualización del Registro' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catMensajesErroresTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'fechaAct'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Dirección IP desde donde se Actualizó el Registro' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catMensajesErroresTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'ipAct'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Dirección Mac desde donde se Actualizó el Registro' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catMensajesErroresTbl', 
                                @level2type = 'COLUMN',
                                @level2name = 'macAddressAct'
Go
Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'CátaloGo Generales' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catMensajesErroresTbl'
Go

Exec sys.sp_addextendedproperty @name       = 'MS_Description', 
                                @value      = 'Llave Foránea de Usuario que Actualizo los datos de la tabla' , 
                                @level0type = 'SCHEMA',
                                @level0name = 'dbo', 
                                @level1type = 'TABLE',
                                @level1name = 'catMensajesErroresTbl', 
                                @level2type = 'CONSTRAINT',
                                @level2name = 'catMensajesErroresFk01'
Go