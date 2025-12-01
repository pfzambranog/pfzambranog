Create Or Alter Function Fn_Busca_MensajeError
 (@PnIdError         Smallint)
Returns Varchar(250)
As

Begin
   Declare
      @o_salida     Varchar( 250)
   Begin

      Select @o_salida = mensaje
      From   dbo.catMensajesErroresTbl
      Where  idError      = @PnIdError
      If @@Rowcount = 0
         Begin
            Set @o_salida = 'Error.: ' + Cast(@PnIdError As Varchar) +  '.    Mensaje No Definido'
         End

   End

   Return(@o_salida)

End
Go

--
-- COmentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Función que Busca la Descripción del Mensaje de Error.',
   @w_procedimiento  NVarchar(250) = 'Fn_Busca_MensajeError';

If Not Exists (Select Top 1 1
               From   sys.extended_properties a
               Join   sysobjects  b
               On     b.xtype   = 'Fn'
               And    b.name    = @w_procedimiento
               And    b.id      = a.major_id)
   Begin
      Execute  sp_addextendedproperty @name       = N'MS_Description',
                                      @value      = @w_valor,
                                      @level0type = 'Schema',
                                      @level0name = N'dbo',
                                      @level1type = 'Function', 
                                      @level1name = @w_procedimiento

   End
Else
   Begin
      Execute sp_updateextendedproperty @name       = 'MS_Description',
                                        @value      = @w_valor,
                                        @level0type = 'Schema',
                                        @level0name = N'dbo',
                                        @level1type = 'Function', 
                                        @level1name = @w_procedimiento
   End
Go 