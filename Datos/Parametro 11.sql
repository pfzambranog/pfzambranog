Insert Into dbo.conParametrosGralesTbl
Select 11, 'Tiempo de Proceso Límite (Segundos)', Null, 240, Null, 1, Getdate(),
       dbo.Fn_BuscaDireccionIP(), dbo.Fn_Busca_DireccionMac()
Go
