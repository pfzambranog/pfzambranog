/*
  Procedimiento que procesa la baja de registros de la tabla de Parámetros Generales.

Declare
   @PnIdParametroGral        Smallint       = 88,
   @PnIdUsuarioAct           Integer        = 1,
   @PnEstatus                Integer        = 0,  
   @PsMensaje                Varchar( 250)  = ' '

Begin
   Execute dbo.Spd_conParametrosGralesTbl  @PnIdParametroGral  =  @PnIdParametroGral,
                                           @PnIdUsuarioAct     =  @PnIdUsuarioAct,
                                           @PnEstatus          =  @PnEstatus  Output,
                                           @PsMensaje          =  @PsMensaje  Output
   
   If @PnEstatus > 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

End
Go
*/

Create Or Alter Procedure Spd_conParametrosGralesTbl
  (@PnIdParametroGral    Smallint,
   @PnIdUsuarioAct       Integer,
   @PnEstatus            Integer          = 0    Output,
   @PsMensaje            Varchar(  250)   = ' '  Output)
As

Declare
   @w_desc_error          Varchar( 250),
   @w_Error               Integer,
   @w_idEstatus           Bit,
   @w_idTipoUsuario       Bit

Begin
/*
Objetivo: Procesa la baja de registros de la tabla de Parámetros Generales.
Versión: 1

*/
   Set Nocount            On
   Set Xact_Abort         On
   Set Ansi_Nulls         Off
   Set Ansi_Warnings      On
   Set Ansi_Padding       On
   
   Select @PnEstatus      = dbo.Fn_ValidaUsuarioAdmin(@PnIdUsuarioAct),
          @PsMensaje      = Null

  If @PnEstatus != 0
      Begin
         Set @PsMensaje = Dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort Off
         Return
      End

   If Not Exists ( Select Top 1 1
                   From   conParametrosGralesTbl
                   Where  idParametroGral = @PnIdParametroGral)
      Begin
         Select @PnEstatus = 2026,
                @PsMensaje = Dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort Off
         Return
      End
   
 
   Begin Try
      Delete conParametrosGralesTbl
      Where  idParametroGral = @PnIdParametroGral
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch
        
   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Case When @PnEstatus = 547
                                  Then dbo.Fn_Busca_MensajeError(@PnEstatus)
                                  Else 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error
                             End

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
   @w_valor          Nvarchar(250) = 'Procedimiento que procesa la baja de registros de la tabla de Parámetros Generales..',
   @w_procedimiento  NVarchar(250) = 'Spd_conParametrosGralesTbl';

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