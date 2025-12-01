/*

Declare
   @PnIdUsuario         Integer = 3
Begin
   Select dbo.Fn_ValidaUsuarioAdmin(@PnIdUsuario)
   Return
End

Go

*/

Create Or Alter Function dbo.Fn_ValidaUsuarioAdmin
  (@PnIdUsuario         Integer)
Returns Integer
As

Begin
/*
Objetivo: Valida existencia, Estatus de Usuario de Seguridad Corporativa y si es de tipo Administrativo
Versión:  1

*/
   Declare
      @w_idEstatus      Tinyint,
      @w_idTipoUsuario  Tinyint,
      @o_salida         Integer

   Begin
      Set @o_salida       = 0

      Select @w_idEstatus     = idEstatus,
             @w_idTipoUsuario = idTipoUsuario
      From   dbo.segUsuariosTbl
      Where  idUsuario    = @PnIdUsuario
      If @@Rowcount = 0
         Begin
            Set  @o_salida = 9999
            Goto Salida
         End

      If @w_idEstatus = 0
         Begin
            Set  @o_salida = 9998
            Goto Salida
         End

      If @w_idTipoUsuario != 1
         Begin
            Set  @o_salida =  9995
            Goto Salida
         End

--

      Select @w_idEstatus = idEstatus
      From   dbo.segUsuariosTbl
      Where  idUsuario    = @PnIdUsuario
      If @@Rowcount = 0
         Begin
            Set @o_salida = 9997
            Goto Salida
         End

      If @w_idEstatus = 0
         Begin
            Set  @o_salida = 9996
            Goto Salida
         End

   End

Salida:

   Set @o_salida = Isnull(@o_salida, ' ')

   Return(@o_salida)

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Función que Valida la Existencia y Estatus de Usuario de Seguridad Corporativa y si es de Tipo Administrativo.',
   @w_procedimiento  NVarchar(250) = 'Fn_ValidaUsuarioAdmin';

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
