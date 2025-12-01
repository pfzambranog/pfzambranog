/*
Declare
   @PsCaracter       Char(1)         = Null,
   @PnChrAscii       Smallint        = Null,
   @PnEstatus        Integer         = 0,
   @PsMensaje        Varchar(  250)  = ' ';
Begin
   Execute dbo.Spc_catCaracterEspecTbl @PsCaracter      = @PsCaracter,
                                       @PnChrAscii      = @PnChrAscii,
                                       @PnEstatus       = @PnEstatus      Output,
                                       @PsMensaje       = @PsMensaje      Output;

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

   Return

End
Go
*/

Create or Alter Procedure dbo.Spc_catCaracterEspecTbl
  (@PsCaracter       Char(1)         = Null,
   @PnChrAscii       Smallint        = Null,
   @PnEstatus        Integer         = 0   Output,
   @PsMensaje        Varchar(  250)  = ' ' Output)
As
Declare
   @w_desc_error        Varchar( 250),
   @w_Error             Integer,
   @w_sql               Varchar(Max),
   @w_primero           Bit,
   @w_registros         Integer,
   @w_comilla           Char(1)

Begin
/*
Objetivo: Consulta los datos de La tabla de Caracteres Especiales.
Versión:  1
*/

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    On
   Set Ansi_Warnings On
   Set Ansi_Padding  On
   
   Select @PnEstatus  = 0,
          @PsMensaje  = ' ',
          @w_primero  = 0,
          @w_comilla  = Char(39)

    Set @w_sql = 'Select a.caracter,                         a.chrAscii
                  From dbo.catCaracterEspecTbl a ' 

   If @PsCaracter Is Not Null
      Begin
         If @w_primero = 0
            Begin
               Select @w_primero = 1,
                      @w_sql = @w_sql + ' Where '
            End
         Else
            Begin
               Set @w_sql = @w_sql + ' And '
            End

         Set @w_sql = @w_sql + ' a.caracter Like ' + @w_comilla + '%' + @PsCaracter + '%' + @w_comilla
      End

   If @PnChrAscii Is Not Null
      Begin
         If @w_primero = 0
            Begin
               Select @w_primero = 1,
                      @w_sql = @w_sql + ' Where '
            End
         Else
            Begin
               Set @w_sql = @w_sql + ' And '
            End

         Set @w_sql = @w_sql + ' a.chrAscii = ' + Cast(@PnChrAscii As Varchar)
      End
      
      
   Begin Try
      Execute (@w_sql)
      Set @w_registros = @@Rowcount
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

   If @w_registros = 0
      Begin
         Select @PnEstatus = 4, 
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)
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
   @w_valor          Nvarchar(250) = 'Procedimiento de Consulta los datos de La tabla de Caracteres Especiales.',
   @w_procedimiento  NVarchar(250) = 'Spc_catCaracterEspecTbl';

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