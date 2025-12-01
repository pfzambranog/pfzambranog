Use SCMBD
Go

If ((Select Count(1)
     From   fn_listextendedproperty('MS_Description', Null, Null,  Null,
                                                      Null, Null, Null)) > 0) 
   Begin
      Execute sp_updateextendedproperty @name  = 'MS_Description',
                                        @value = N'Base de datos de Monitoreo de Procesos Base de Datos'
   End
Else
   Begin
      Execute sp_addextendedproperty @name  = 'MS_Description',
                                     @value = 'Base de datos de Monitoreo de Procesos Base de Datos'
   End
GO