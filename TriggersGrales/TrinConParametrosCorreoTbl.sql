Use SCMBD
Go


Create Or Alter Trigger dbo.TrinConParametrosCorreoTbl
On     dbo.conParametrosCorreoTbl
   
After  Insert, Update
As

Declare
   @w_idAplicacion   Smallint,
   @w_idParametro    Smallint,
   @w_contrasenia    Varchar(250),
   @w_idUsuarioAct   Smallint,
   @w_idEstatus      Bit,
   @w_idTipoUsuario  Bit,
   @w_fechaAct       Datetime,
   @w_ipAct          Varchar(30),
   @w_macAddressAct  Varchar(30),
   @w_parametro      Varchar(1000);
Begin

   Select @w_idParametro   = idParametro,
          @w_idAplicacion  = idAplicacion,
          @w_contrasenia   = valorAlfa,
          @w_idUsuarioAct  = idUsuarioAct,
          @w_fechaAct      = fechaAct,
          @w_ipAct         = ipAct,
          @w_macAddressAct = macAddressAct,
          @w_parametro     = dbo.Fn_BuscaValorParametro(4, 1)
   From   inserted


   If @w_idParametro = 6
      Begin
         Update conParametrosCorreoTbl
         Set    valorAlfa     = dbo.Fn_Encripta_cadena (@w_contrasenia),
                fechaAct      = Isnull(fechaAct, Getdate()),
                ipAct         = Case When @w_ipAct Is Null
                                     Then dbo.Fn_BuscaDireccionIP()
                                     Else @w_ipAct
                                End,
                macAddressAct = Case When @w_macAddressAct Is Null
                                    Then dbo.Fn_Busca_DireccionMAC()
                                    Else @w_macAddressAct
                                End
         Where  idParametro  = @w_idParametro
         And    idAplicacion = @w_idAplicacion    
      End
   Else
      Begin
         If @w_ipAct          Is Null Or
            @w_macAddressAct  Is Null
            Begin
               Update conParametrosCorreoTbl
               Set    fechaAct      = Isnmull(@w_fechaAct, Getdate()),
                      ipAct         = Case When @w_ipAct Is Null
                                           Then dbo.Fn_BuscaDireccionIP()
                                          Else @w_ipAct
                                      End,
                      macAddressAct = Case When @w_macAddressAct Is Null
                                           Then dbo.Fn_Busca_DireccionMAC()
                                           Else @w_macAddressAct
                                      End
               Where  idParametro  = @w_idParametro
               And    idAplicacion = @w_idAplicacion    
            End
       End

   Return

End
Go


