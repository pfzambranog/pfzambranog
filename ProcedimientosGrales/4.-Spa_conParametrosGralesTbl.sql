Create Or Alter Procedure Spa_conParametrosGralesTbl
  (@PsDescripcion        Varchar(  100), 
   @PnParametroNumber    Integer,
   @PsParametroChar      Varchar(  120),
   @PdParametroFecha     Datetime,
   @PnIdUsuarioAct       Integer,
   @PsIpAct              Varchar(   30),
   @PsMacAddressAct      Varchar(   30),
   @PnEstatus            Integer          = 0    Output,
   @PsMensaje            Varchar(  250)   = ' '  Output)
As

Declare
   @w_desc_error          Varchar( 250),
   @w_Error               Integer,
   @w_idParametroGral     Smallint,
   @w_fechaAct            Datetime

Begin
/*
Objetivo: Alta de Registros a la Tabla de Parametros Generales.
Versión:  1

*/
   Set Quoted_identifier Off
   Set Nocount            On
   Set Xact_Abort         On
   Set Ansi_Nulls         On
   Set Ansi_Warnings      On
   Set Ansi_Padding       On
   
   Select @PnEstatus      = 0,
          @PsMensaje      = Null,
          @w_fechaAct     = GetDate()

   If Exists ( Select Top 1 1
               From   conParametrosGralesTbl
               Where  descripcion = @PsDescripcion)
      Begin
         Select @PnEstatus = 2028,
                @PsMensaje = Dbo.Fn_Busca_MensajeError(@PnEstatus)
         Set Xact_Abort Off
         Return
      End

   Select @w_idParametroGral = Max(idParametroGral)
   From   conParametrosGralesTbl

   Set @w_idParametroGral = Isnull(@w_idParametroGral, 0) + 1

   Begin Try
      Insert Into  conParametrosGralesTbl
      (idParametroGral, descripcion,  parametroNumber, ParametroChar,
       parametroFecha,  idUsuarioAct, fechaAct,        ipAct,
       macAddressAct)
      Select @w_idParametroGral, @PsDescripcion,   @PnParametroNumber, @PsParametroChar,
             @PdParametroFecha,  @PnIdUsuarioAct,  @w_fechaAct,        @PsIpAct,
             @PsMacAddressAct

   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch
        
   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Char))) + ' ' + @w_desc_error
         Set Xact_Abort Off
         Return
      End

   Set Xact_Abort Off
   Return

End
Go 

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Alta a la Tabla de Parametros Generales.',
   @w_procedimiento  NVarchar(250) = 'Spa_conParametrosGralesTbl';

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