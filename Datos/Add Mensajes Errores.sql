Use SCMBD
Go

Declare
   @w_idError         Smallint,
   @w_idUsuarioAct    Integer,
   @w_fechaAct        Datetime,
   @w_mensaje         Varchar(100),
   @w_ipAct           Varchar( 30),
   @w_macAddressAct   Varchar( 30);

Begin
   Select @w_idError        = 557,
          @w_mensaje        = 'No Existe un Grupo Receptor Correo Relacionado a la Base Selecionada.',
          @w_idUsuarioAct   = 1,
          @w_fechaAct       = Getdate(),
          @w_ipAct          = dbo.Fn_BuscaDireccionIP(),
          @w_macAddressAct  = dbo.Fn_Busca_DireccionMAC();

   If Not Exists ( Select Top 1 1
                   From   dbo.catMensajesErroresTbl
                   Where  idError = @w_idError)
      Begin
         Insert Into dbo.catMensajesErroresTbl
         (idError, mensaje, idUsuarioAct, fechaAct,
          ipAct,   macAddressAct)
         Select @w_idError, @w_mensaje,       @w_idUsuarioAct, @w_fechaAct,
                @w_ipAct,   @w_macAddressAct
      End

    Return
End
Go
