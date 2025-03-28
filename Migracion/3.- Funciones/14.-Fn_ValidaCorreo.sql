Create Or Alter Function dbo.Fn_ValidaCorreo
   (@PsCorreo Varchar(300))
Returns Bit

As
Begin
   Declare
      @w_salida Bit,
      @w_aux    Varchar(150)  ;

   Set @w_salida = 0

   If @PsCorreo Like '[a-z,0-9,_,-,.,a-z]%@[a-z,0-9,_,-,.,a-z]%.[a-z][a-z]%'
      Begin
         Set @w_salida = 1
      End

   If CharIndex('@',@PsCorreo) <> 0
      Begin
         Set @w_aux = Substring(@PsCorreo, CharIndex('@', @PsCorreo) + 1, Len(@PsCorreo))
         If CharIndex('@', @w_aux) <> 0
            Begin
               Set @w_salida = 0
               Return @w_salida
            End
      End

   If CharIndex('.@', @PsCorreo) <> 0
      Begin
         Set @w_salida = 0
         Return @w_salida
      End

   If CharIndex('..', @PsCorreo) <> 0
      Begin
         Set @w_salida = 0
         Return @w_salida
      End

   If CharIndex(',', @PsCorreo) <> 0
      Begin
         Set @w_salida = 0
         Return @w_salida
      End

   If Right(@PsCorreo, 1) Not Between 'a' And 'z'
      Begin
         Set @w_salida = 0
         Return @w_salida
      End


   If Charindex('á', @PsCorreo Collate SQL_Latin1_General_CP850_CI_AS) <> 0
      Begin
         Set @w_salida = 0
         Return @w_salida
      End

   If Charindex('é', @PsCorreo Collate SQL_Latin1_General_CP850_CI_AS) <> 0
      Begin
         Set @w_salida = 0
         Return @w_salida
      End

   If Charindex('í', @PsCorreo Collate SQL_Latin1_General_CP850_CI_AS) <> 0
      Begin
         Set @w_salida = 0
         Return @w_salida
      End

   If Charindex('ó', @PsCorreo Collate SQL_Latin1_General_CP850_CI_AS) <> 0
      Begin
         Set @w_salida = 0
         Return @w_salida
      End

   If Charindex('ú', @PsCorreo Collate SQL_Latin1_General_CP850_CI_AS) <> 0
      Begin
         Set @w_salida = 0
         Return @w_salida
      End

   If Charindex('ñ', @PsCorreo Collate Modern_Spanish_CI_AI) <> 0
      Begin
         Set @w_salida = 0
         Return @w_salida
      End

   Return @w_salida;

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Función de Validación de dirección de correo.',
   @w_procedimiento  NVarchar(250) = 'Fn_ValidaCorreo';

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

