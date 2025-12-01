/*
  Procedimiento de Consulta que nos valida si existe una tabla 

Declare
   @PsNombreTabla            Sysname        = 'catgeneralestbl',
   @PnIdUsuarioAct           Smallint       = 1,
   @PnEstatus                Integer        = 0,  
   @PsMensaje                Varchar( 250)  = ' '
   

Begin
   Execute Spc_validaTabla  @PsNombreTabla  =  @PsNombreTabla     ,
                            @PnIdUsuarioAct =  @PnIdUsuarioAct    ,
                            @PnEstatus      =  @PnEstatus  Output ,   
                            @PsMensaje      =  @PsMensaje  Output    
   
   If @PnEstatus > 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

End
Go
*/

Create Or Alter Procedure [dbo].[Spc_validaTabla]
  (@PsNombreTabla            Sysname,
   @PnIdUsuarioAct           Integer,
   @PnEstatus                Integer        = 0   Output,
   @PsMensaje                Varchar( 250)  = ' ' Output)  
As

Declare
   @w_desc_error              Varchar( 250),
   @w_Error                   Integer,
   @w_idEstatus               Tinyint,
   @w_sql                     Varchar(Max),
   @w_comilla                 Char(1)

Begin
/*
Objetivo: Validar la Existencia de una Tabla en la Base de Datos en el esquema dbo.
Versión: 1

*/
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off
   Set Ansi_Warnings On
   Set Ansi_Padding  On
   
   Select @PnEstatus       = 0,
          @PsMensaje       = ' ',
          @w_comilla       = Char(39)

   Select @PnEstatus = dbo.Fn_ValidaUsuario(@PnIdUsuarioAct)
   If @PnEstatus != 0
      Begin
         Set @PsMensaje = Dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort Off
         Return
      End

   Set @w_sql = 'Select Count(1) existe '                                         +
                'From   Sysobjects '                                              +
                'Where  Uid  = 1 '                                                +
                'And    Type = ' + @w_comilla + 'U'            + @w_comilla + ' ' +
                'And    Name = ' + @w_comilla + @PsNombreTabla + @w_comilla
                
   Begin Try
      Execute (@w_sql)
   End   Try
    
   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar(10)))) + ' ' + @w_desc_error

         Set Xact_Abort    Off
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
   @w_valor          Nvarchar(250) = 'Procedimiento que Valida la Existencia de una Tabla en la Base de Datos en el esquema dbo.',
   @w_procedimiento  NVarchar(250) = 'Spc_validaTabla';

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