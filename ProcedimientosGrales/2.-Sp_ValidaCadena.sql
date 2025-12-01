/*

Procedimiento que Consulta la cantidad de tipos de caracteres incluiddos en una Cadena


Declare
   @PsCadena            Varchar(1000)   = 'DOCUMENTO DE PRUEBA_3.xml',
   @PnConsulta           Numeric(2, 0)  = 3,
   @PnEstatus            Integer        = 0,
   @PsMensaje            Varchar(250)

Begin 
   Execute Sp_ValidaCadena @PsCadena,  @PnConsulta, @PnEstatus   Output,         @PsMensaje        Output

   Select @PnEstatus,  @PsMensaje
End
Go

*/


Create Procedure Sp_ValidaCadena
  (@PsCadena             Varchar(1000),
   @PnConsulta           Numeric(2, 0),  -- 1 = Caracteres Númericos, 2 = Caracteres Alfa, 3 = Caracteres Especiales.
   @PnEstatus            Integer        = 0    Output,
   @PsMensaje            Varchar(250)   = ' '  Output)
As

Declare
   @w_posicion           Numeric(4, 0),
   @w_len                Numeric(4, 0),
   @w_char               Numeric(4, 0),
   @w_number             Numeric(4, 0),
   @w_especial           Numeric(4, 0)

Begin
   Select @w_posicion = 0,
          @PnEstatus  = 0,
          @w_len      = Len(@PsCadena),
          @w_char     = 0,
          @w_number   = 0,
          @w_especial = 0
          
   While @w_posicion   < @w_len
   Begin
      Set @w_posicion = @w_posicion + 1
      If  Substring(@PsCadena, @w_posicion, 1) Between '0' And '9'
          Begin
             Set @w_number = @w_number + 1
          End
      Else
         Begin
            If Ascii(Substring(@PsCadena, @w_posicion, 1)) Between 97 And 122 Or
               Ascii(Substring(@PsCadena, @w_posicion, 1)) Between 65 And 90  Or
               Ascii(Substring(@PsCadena, @w_posicion, 1))       = 32
               Begin
                  Set @w_char = @w_char + 1
               End
            Else
               Begin
                  If Not Exists ( Select top 1 1
                                  From   catCaracterEspecTbl  -- Caracteres Válidos 
                                  Where  Ascii(Substring(@PsCadena, @w_posicion, 1)) = ChrAscii)
                           Begin
                       Set @w_especial = @w_especial + 1
                  End
               End
         End
   End
   
   Select @PnEstatus = Case When @PnConsulta = 1
                            Then @w_number
                            When @PnConsulta = 2
                            Then @w_char
                            Else @w_especial
                       End
   If @PnConsulta > 2 And
      @PnEstatus  > 0
      Begin
         Set @PsMensaje = 'Cadena Contiene ' + Cast(@PnEstatus As Varchar) + 
                          Case When @PnEstatus  = 1
                               Then ' Carácter Especial'
                               Else ' Caracteres Especiales'
                          End
      End


   Set Xact_Abort    Off
   Return
End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Validación de una cadena de caracteres determinados.',
   @w_procedimiento  NVarchar(250) = 'Sp_validaCadena';

If Not Exists (Select Top 1 1
               From   sys.extended_properties a
               Join   sysobjects  b
               On     b.xtype   = 'P'
               And    b.name    = @w_procedimiento
               And    b.id      = a.major_id)
   Begin
      Execute  sp_addextendedproperty @name       = N'MS_Description',
                                      @value      = @w_valor,
                                      @level0type = 'Schema',
                                      @level0name = N'dbo',
                                      @level1type = 'Procedure', 
                                      @level1name = @w_procedimiento

   End
Else
   Begin
      Execute sp_updateextendedproperty @name       = 'MS_Description',
                                        @value      = @w_valor,
                                        @level0type = 'Schema',
                                        @level0name = N'dbo',
                                        @level1type = 'Procedure', 
                                        @level1name = @w_procedimiento
   End
Go