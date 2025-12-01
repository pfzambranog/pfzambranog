Use SCMBD
Go

If Not Exists ( Select Top 1 1
                From   dbo.conProcedimientosCorreoTbl
                Where  idMotivoCorreo = 106)
   Begin
      Insert Into dbo.conProcedimientosCorreoTbl
      (idMotivoCorreo, idProcedimiento, codigoProcedimiento, procedimiento,
       idUsuarioAct,   fechaAct,        ipAct,               macAddressAct)
      Select 106,      1,               'enviaCorreoIncidencia',  'Spp_enviaCorreoIncidencia',
             18,       Getdate(),       dbo.Fn_BuscaDireccionIP(), dbo.Fn_Busca_DireccionMAC();

   End

If Not Exists ( Select Top 1 1
                From   dbo.conProcedimientosCorreoTbl
                Where  idMotivoCorreo = 110)
   Begin
      Insert Into dbo.conProcedimientosCorreoTbl
      (idMotivoCorreo, idProcedimiento, codigoProcedimiento, procedimiento,
       idUsuarioAct,   fechaAct,        ipAct,               macAddressAct)
      Select 110,      1,               'reportaIncTiempoProc',  'Spp_reportaIncTiempoProc',
             18,       Getdate(),       dbo.Fn_BuscaDireccionIP(), dbo.Fn_Busca_DireccionMAC();

   End
