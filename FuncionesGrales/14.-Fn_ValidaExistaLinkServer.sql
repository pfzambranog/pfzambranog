/*

Declare
   @PsLinkServer Varchar(300) = 'BI'
Begin
   Select dbo.Fn_ValidaExistaLinkServer(@PsLinkServer)
   Return
End

Go

*/

Create Or Alter Function Fn_ValidaExistaLinkServer
  (@PsLinkServer     Varchar(250))
Returns Int
As

Begin
/*
Objetivo: Valida existencia de Link Server
Versión:  1

*/
   Declare
      @o_salida           int

   Begin
      If @PsLinkServer Is Not Null
         Begin
            Select @o_salida = count(1)
            From   sys.servers s 
            Where  s.server_id <> 0 
            And    s.name       = @PsLinkServer
         End

      Set @o_salida = Isnull(@o_salida, '0')

   End

   Return(@o_salida)

End
Go 

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Función que Valida la Existencia de Link Server.',
   @w_procedimiento  NVarchar(250) = 'Fn_ValidaExistaLinkServer';

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

