Create Or Alter Function dbo.Fn_BuscaNombreColonia
  (@PnIdPais       Smallint,
   @PnIdEstado     Smallint,
   @PnIdCiudad     Smallint,
   @PnIdMunicipio  Smallint,
   @PnIdColonia    SMallint,
   @PnOpcion       Tinyint)
Returns Varchar(100)
As

Begin
   Declare
      @o_salida           Varchar(100)

   Begin
      Select @o_salida = Case When @PnOpcion = 1
                              Then nombre
                              When @PnOpcion = 2
                              Then abreviatura
                              Else 'Opci�n de Consulta Fuera de Rango'
                         End
      From   dbo.catColoniasTbl
      Where  idPais              = @PnIdPais
      And    idEstado            = @PnIdEstado
      And    IsNull(idCiudad, 0) = Isnull(@PnIdCiudad, 0)
      And    idMunicipio         = @PnIdMunicipio
      And    idColonia           = @PnIdColonia
      If @@Rowcount = 0
         Begin
            Set @o_salida = ' '
         End
   End

   Set @o_salida = Isnull(@o_salida, ' ')

   Return(@o_salida)

End

Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Funci�n que Consulta en la entidad catColoniasTbl.',
   @w_procedimiento  NVarchar(250) = 'Fn_BuscaNombreColonia';

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
