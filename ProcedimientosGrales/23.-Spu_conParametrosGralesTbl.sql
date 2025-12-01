/*
Declare
   @PnIdParametroGral    Smallint         = 4,
   @PsDescripcion        Varchar(  100)   = 'Llave Simetrica',
   @PnParametroNumber    Numeric(24, 6)   = Null,
   @PsParametroChar      Varchar(  150)   = 'LlaveSimetrica',
   @PdParametroFecha     Datetime         = Null,
   @PnIdUsuarioAct       Integer          = 1,
   @PsIpAct              Varchar(   30)   = Null,
   @PsMacAddressAct      Varchar(   30)   = Null,
   @PnEstatus            Integer          = 0,
   @PsMensaje            Varchar(  250)   = ' ';

Begin
   Execute dbo.Spu_conParametrosGralesTbl @PnIdParametroGral = @PnIdParametroGral,
                                          @PsDescripcion     = @PsDescripcion,
                                          @PnParametroNumber = @PnParametroNumber,
                                          @PsParametroChar   = @PsParametroChar,
                                          @PdParametroFecha  = @PdParametroFecha,
                                          @PnIdUsuarioAct    = @PnIdUsuarioAct,
                                          @PsIpAct           = @PsIpAct,
                                          @PsMacAddressAct   = @PsMacAddressAct,
                                          @PnEstatus         = @PnEstatus     Output,
                                          @PsMensaje         = @PsMensaje     Output;



   Select @PnEstatus Error, @PsMensaje Mensaje

   Return

End
Go
*/

Create Or Alter Procedure dbo.Spu_conParametrosGralesTbl
  (@PnIdParametroGral    Smallint,
   @PsDescripcion        Varchar(  100),
   @PnParametroNumber    Numeric(24, 6),
   @PsParametroChar      Varchar(  150),
   @PdParametroFecha     Datetime,
   @PnIdUsuarioAct       Integer,
   @PsIpAct              Varchar(   30)   = Null,
   @PsMacAddressAct      Varchar(   30)   = Null,
   @PnEstatus            Integer          = 0    Output,
   @PsMensaje            Varchar(  250)   = ' '  Output)
As

Declare
   @w_desc_error          Varchar( 250),
   @w_Error               Integer,
   @w_fechaAct            Datetime,
   @w_sql                 Varchar(Max),
   @w_ipAct               Varchar(   30),
   @w_macAddressAct       Varchar(   30),
   @w_comilla             Char(1);

Begin
/*
Objetivo: Actualización de Registros de la tabla de Parámetros generales.
Versión:  1
*/

   Set Quoted_identifier Off
   Set Nocount            On
   Set Xact_Abort         On
   Set Ansi_Nulls        Off

   Select @PnEstatus       = 0,
          @PsMensaje       = Char(32),
          @w_fechaAct      = GetDate(),
          @w_comilla       = Char(39),
          @w_ipAct         = Isnull(@PsIpAct,         dbo.Fn_BuscaDireccionIP()),
          @w_macAddressAct = Isnull(@PsMacAddressAct, dbo.Fn_Busca_DireccionMac());


   If Not Exists ( Select Top 1 1
                   From   conParametrosGralesTbl
                   Where  idParametroGral = @PnIdParametroGral)
      Begin
         Select @PnEstatus = 2026,
                @PsMensaje = Dbo.Fn_Busca_MensajeError(@PnEstatus)
         Set Xact_Abort Off
         Return
      End

   Set @w_sql = Concat('Update dbo.conParametrosGralesTbl ',
                       'Set idUsuarioAct      = ', @PnIdUsuarioAct, ', ',
                           'fechaAct          = ', @w_comilla, @w_fechaAct,      @w_comilla,  ', ',
                           'ipAct             = ', @w_comilla, @w_ipAct,         @w_comilla, ', ',
                           'macAddressAct     = ', @w_comilla, @w_macAddressAct, @w_comilla);

   If @PsDescripcion Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ', descripcion = ', @w_comilla,  @PsDescripcion, @w_comilla);
      End

   If @PnParametroNumber Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ',  parametroNumber = ',@PnParametroNumber);
      End

   If @PsParametroChar Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ', parametroChar = ', @w_comilla, @PsParametroChar, @w_comilla);
      End

   If @PdParametroFecha Is Not Null
      Begin
         Set @w_sql = Concat(@w_sql, ',  parametroFecha = ', @w_comilla, @PdParametroFecha, @w_comilla);
      End

   Set @w_sql = Concat(@w_sql, 'Where  idParametroGral  = ', @PnIdParametroGral)

   Begin Try

      Execute (@w_sql)

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

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Actualización de Registros de la tabla de parámetros generales.',
   @w_procedimiento  NVarchar(250) = 'Spu_conParametrosGralesTbl';

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