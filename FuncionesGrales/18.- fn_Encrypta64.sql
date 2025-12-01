Use SCMBD
Go

--
-- Select dbo.fn_Encrypta64 ('Hello Base64')
--

Create Or Alter Function dbo.fn_Encrypta64
(@PsInput    Varchar(Max))
Returns varchar(max)
As
Begin
   Declare
      @o_salida    varchar(max),
      @w_Binary     Varbinary(Max);

   Begin
      Set @w_Binary = CONVERT(Varbinary(Max), @PsInput);

      Set @o_salida = cast('' as xml).value('xs:base64Binary(sql:variable("@w_Binary"))', 'varchar(max)') 

   End
   
   Return @o_salida
End;
Go


--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Encripta Cadena a Base 64.',
   @w_procedimiento  NVarchar(250) = 'fn_Encrypta64';

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