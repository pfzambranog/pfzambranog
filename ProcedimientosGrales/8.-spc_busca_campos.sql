/*
Declare
   @PsCampo    Varchar(  90) = 'tabla',
   @PnEstatus  Integer       = 0,
   @PsMensaje  Varchar( 250) = ''

Begin
   Execute spc_busca_campos @PsCampo   = @PsCampo,
                            @PnEstatus = @PnEstatus  Output,
                            @PsMensaje = @PsMensaje  Output

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

   Return

End;
Go


*/

Create Or Alter Procedure dbo.spc_busca_campos
  (@PsCampo    Varchar(  90),
   @PnEstatus  Integer       = 0  Output,
   @PsMensaje  Varchar( 250) = '' Output)
As

Declare
   @w_desc_error              Varchar( 250),
   @w_Error                   Integer

Begin
/*
Objetivo: Buscar un campo seleccionado en las tablas de la Base de Datos. 
Versión:  1
*/

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    On
   Set Ansi_Warnings On
   Set Ansi_Padding  On
   
   Select @PnEstatus  = 0,
          @PsMensaje  = Null


   Begin Try
      Select a.name, b.name, b.column_id  
      From   sys.tables a, sys.columns b  
      Where  a.object_id = b.object_id   
      And    b.name      Like '%' + rtrim(ltrim(@Pscampo)) + '%'  
      Order by 3, 1  
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error
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
   @w_valor          Nvarchar(250) = 'Procedimiento de Búsqueda de un campo seleccionado en las tablas de la Base de Datos.',
   @w_procedimiento  NVarchar(250) = 'Spc_busca_campos';

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