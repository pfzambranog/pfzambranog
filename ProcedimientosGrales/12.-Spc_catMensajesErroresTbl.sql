/*

Procedimiento que lista los valores de la tabla de Catalogos Generales.

Declare
   @PnIdError            Varchar(  90)   = Null,
   @PsMensaje            Varchar( 250)   = Null,
   @PnIdUsuarioAct       Integer         = 1,
   @PdFechaAct           Date            = Null,
   @PsIpAct              Varchar(30)     = Null,
   @PsMacAddressAct      Varchar(30)     = Null,
   @PnEstatus            Integer         = 0,
   @PsMensajeR           Varchar( 250)   = ' '

Begin
   Execute  dbo.Spc_catMensajesErroresTbl @PnIdError       = @PnIdError,
                                          @PsMensaje       = @PsMensaje,
                                          @PnIdUsuarioAct  = @PnIdUsuarioAct,
                                          @PdFechaAct      = @PdFechaAct,
                                          @PsIpAct         = @PsIpAct,
                                          @PsMacAddressAct = @PsMacAddressAct,
                                          @PnEstatus       = @PnEstatus Output,
                                          @PsMensajeR      = @PsMensajeR Output

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensajeR
      End

   Return

End
Go

*/

Create Or Alter Procedure dbo.Spc_catMensajesErroresTbl
    (@PnIdError       Smallint      = Null,
     @PsMensaje       Varchar( 250) = Null,
     @PnIdUsuarioAct  Integer,
     @PdFechaAct      Date          = Null,
     @PsIpAct         Varchar(30)   = Null,
     @PsMacAddressAct Varchar(30)   = Null,
     @PnEstatus       Integer       = 0   Output,
     @PsMensajeR      Varchar( 250) = ' ' Output)
As
Declare
    @w_sql               Varchar(Max),
    @w_desc_error        Varchar( 250),
    @w_Error             Integer,
    @w_primero           Bit,
    @w_comilla           Char(1),
    @w_registros         Integer

Begin
/*
Objetivo: Consulta el Catálogo de Errores.
Version:  1
*/

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    On
   Set Ansi_Warnings On
   Set Ansi_Padding  On

   Select @PnEstatus   = 0,
          @PsMensajeR  = Null,
          @w_primero   = 0,
          @w_comilla   = Char(39)


--

   Set @PnEstatus = dbo.Fn_ValidaUsuario(@PnIdUsuarioAct)

   If @PnEstatus <> 0
      Begin
         Set @PsMensajeR =  dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort Off
         Return
      End
--

   Set @w_sql = 'Select a.idError,   a.mensaje,  a.idUsuarioAct,   b.nombre usuario,
                        a.fechaAct,   a.ipAct,    a.macAddressAct
                From    dbo.catMensajesErroresTbl a
                Join    dbo.segUsuariosTbl b
                On      b.idUsuario = a.idUsuarioAct
                Where   1 = 1 '

   If @PnIdError Is Not Null
      Begin
         Set @w_sql = @w_sql + ' And a.idError = ' + Cast(@PnIdError As Varchar)
      End

   If @PsMensaje Is Not Null
      Begin
         Set @w_sql = @w_sql + ' And a.mensaje Like ' + @w_comilla + '%' + @PsMensaje + '%' + @w_comilla
      End

   If @PdFechaAct Is Not Null
      Begin
         Set @w_sql = @w_sql + ' And Cast(a.fechaAct As Date) = ' + @w_comilla + Cast(@PdFechaAct As Varchar) + @w_comilla

      End

   If @PsIpAct Is Not Null
      Begin

         Set @w_sql = @w_sql + ' And a.ipAct Like ' + @w_comilla + '%' + @PsipAct + '%' + @w_comilla

      End

   If @PsMacAddressAct Is Not Null
      Begin
         Set @w_sql = @w_sql + ' And a.macAddressAct Like ' + @w_comilla + '%' + @PsMacAddressAct + '%' + @w_comilla

      End

   Set  @w_sql = @w_sql + ' Order by 1'

   Begin Try
      Execute (@w_sql)
      Set  @w_registros = @@Rowcount
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus  = @w_Error,
                @PsMensajeR = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error
         Set Xact_Abort Off
         Return
      End

   If @w_registros  = 0
      Begin
         Select @PnEstatus  = 4,
                @PsMensajeR = dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort Off
         Return
      End

   Set Xact_Abort Off
   Return
End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento que Consulta la tabla de Catálogos de Errores.',
   @w_procedimiento  NVarchar(250) = 'Spc_catMensajesErroresTbl';

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