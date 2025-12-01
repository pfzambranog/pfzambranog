Create Or Alter Procedure Spa_catGeneralesTbl
   (@PsTabla                   Sysname,
    @PsColumna                 Sysname,
    @PnValor                   Smallint,
    @PsDescripcion             Varchar(  60),
    @PnEstatus                 Integer       = 0   Output,
    @PsMensaje                 Varchar( 250) = ' ' Output)  
As

Declare
    @w_sql               Varchar(Max),
    @w_desc_error        Varchar( 250),
    @w_Error             Integer

Begin
/*
Objetivo: Procedimiento de Alta a la Tabla de Catálogos Generales.
Versión:  1

*/
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    On
   Set Ansi_Warnings On
   Set Ansi_Padding  On
   
   Select @PnEstatus  = 0,
          @PsMensaje  = Null

   If Exists (Select Top 1 1
                  From   catGeneralesTbl
                  Where  tabla   = @PsTabla
                  And    columna = @PsColumna
                  And    valor   = @PnValor)
      Begin
         Select @PnEstatus = 2,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)
         Set Xact_Abort Off
         Return
      End

   Begin Try
      Insert Into catGeneralesTbl
      Select @PsTabla, @PsColumna, @PnValor, @PsDescripcion
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

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Alta a la Tabla de Catálogos Generales.',
   @w_procedimiento  NVarchar(250) = 'Spa_catGeneralesTbl';

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