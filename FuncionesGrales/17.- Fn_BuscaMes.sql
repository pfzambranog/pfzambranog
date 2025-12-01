Create Or Alter Function dbo.Fn_BuscaMes
 (@w_Mes       Integer)
Returns Varchar(15)

As
Begin
    Declare
	   @w_salida   Varchar(15)
       Select @w_salida = Case @w_mes
                          When  1 Then 'Ene'
                          When  2 Then 'Feb'
                          When  3 Then 'Mar'
                          When  4 Then 'Abr'
                          When  5 Then 'May'
                          When  6 Then 'Jun'
                          When  7 Then 'Jul'
                          When  8 Then 'Ago'
                          When  9 Then 'Sep'
                          When 10 Then 'Oct'
                          When 11 Then 'Nov'
                          When 12 Then 'Dic'
          End

Return Isnull(@w_salida,'')

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Función que Consulta las iniciales de los meses Seleccionado.',
   @w_procedimiento  NVarchar(250) = 'Fn_BuscaMes';

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