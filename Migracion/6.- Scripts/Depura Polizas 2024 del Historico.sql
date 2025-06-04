Use DB_Siccorp_DES
Go

Declare
   @w_Error                   Integer,
   @w_desc_error              Varchar(Max),
   @w_linea                   Integer,
   @w_regMov                  Integer,
   @w_regPol                  Integer;
   
Begin
   Set Nocount       On
   Set Xact_Abort    On

   Select @w_Error     = 0,
          @w_regMov    = 0,
          @w_linea     = 0;

   Begin Transaction
      Begin Try
         Delete dbo.movimientosHist
         Where  ejercicio = 2024;
         Set @w_regMov = @@Rowcount;

         Delete dbo.PolizaHist
         Where  ejercicio = 2024;
         Set @w_regPol = @@Rowcount;

      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_linea      = Error_line(),
                 @w_desc_error = Concat(Substring (Error_Message(), 1, 200), ' En Línea ', @w_linea);

      End   Catch

      If @w_error != 0
         Begin
            Select @w_error error, @w_desc_error "Mensaje Error";

            RollBack Transaction

            Goto Salida
         End

   Commit Transaction

   Select Concat('Pólizas Eliminadas ',      Format(@w_regPol, "###,###,###")) Salida
   Union
   Select Concat('MOvimientos Eliminados ',  Format(@w_regMov, "###,###,###"));

Salida:

End
Go
