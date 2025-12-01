/*
  Procedimiento de Bajas de Registros en la tabla de catalogos generales.

Declare
   @PsTabla                  Sysname,
   @PsColumna                Sysname,
   @PnValor                  Integer,
   @PnIdUsuarioAct           Integer        = 1,
   @PnEstatus                Integer        = 0,  
   @PsMensaje                Varchar( 250)  = ' '
   

Begin
   Execute dbo.Spd_catGeneralesTbl  @PsTabla        = @PsTabla,
                                    @PsColumna      = @PsColumna,
                                    @PnValor        = @PnValor,
                                    @PnIdUsuarioAct = @PnIdUsuarioAct,
                                    @PnEstatus      = @PnEstatus  Output ,   
                                    @PsMensaje      = @PsMensaje  Output    
   
   If @PnEstatus > 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

End
Go
*/

Create Or Alter Procedure dbo.Spd_catGeneralesTbl
   (@PsTabla                   Sysname,
    @PsColumna                 Sysname,
    @PnValor                   Integer,
    @PnIdUsuarioAct            Integer,
    @PnEstatus                 Integer       = 0   Output,
    @PsMensaje                 Varchar( 250) = ' ' Output)  

As
Declare
    @w_sql               Varchar(Max),
    @w_desc_error        Varchar( 250),
    @w_Error             Integer

Begin

/*
Objetivo: Procesar la Baja de Registros en la tabla de catalogos generales.
Versión:  1
*/

   Set Nocount       On
   Set Xact_Abort    Off
   Set Ansi_Nulls    On
   Set Ansi_Warnings On
   Set Ansi_Padding  On
   
   Select @PnEstatus  = dbo.Fn_ValidaUsuario(@PnIdUsuarioAct),
          @PsMensaje  = ''

   If @PnEstatus != 0
      Begin
         Set @PsMensaje = Dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort On
         Return
      End

   If Not Exists (Select Top 1 1
                  From   catGeneralesTbl
                  Where  tabla   = @PsTabla
                  And    columna = @PsColumna
                  And    valor   = @PnValor)
      Begin
         Select @PnEstatus = 3,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort On
         Return
      End

   Begin Try
      Delete catGeneralesTbl
      Where  tabla   = @PsTabla
      And    columna = @PsColumna
      And    valor   = @PnValor
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
   @w_valor          Nvarchar(250) = 'Procedimiento que procesa la Baja de Registros en la tabla de catalogos generales.',
   @w_procedimiento  NVarchar(250) = 'Spd_catGeneralesTbl';

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