/*

Procedimiento que lista los valores de la tabla de Catalogos Parámetros Generales.

Declare
   @PnIdParametroGral    Smallint         = Null,
   @PsDescripcion        Varchar( 250)    = Null,
   @PnParametroNumber    Integer          = Null,
   @PsParametroChar      Varchar(  120)   = Null,
   @PdParametroFecha     Date             = Null,
   @PnIdUsuarioAct       Integer          = 1,
   @PdFechaAct           Date             = Null,
   @PsIpAct              Varchar(30)      = Null,
   @PsMacAddressAct      Varchar(30)      = Null,
   @PnEstatus            Integer          = 0,
   @PsMensaje            Varchar( 250)    = Null;

Begin
   Execute  dbo.Spc_conParametrosGralesTbl @PnIdParametroGral  = @PnIdParametroGral,
                                           @PsDescripcion      = @PsDescripcion,
                                           @PnParametroNumber  = @PnParametroNumber,
                                           @PsParametroChar    = @PsParametroChar,
                                           @PdParametroFecha   = @PdParametroFecha,
                                           @PnIdUsuarioAct     = @PnIdUsuarioAct,
                                           @PdFechaAct         = @PdFechaAct,
                                           @PsIpAct            = @PsIpAct,
                                           @PsMacAddressAct    = @PsMacAddressAct,
                                           @PnEstatus          = @PnEstatus Output,
                                           @PsMensaje          = @PsMensaje Output;

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

   Return

End
Go

*/

Create Or Alter Procedure dbo.Spc_conParametrosGralesTbl
  (@PnIdParametroGral        Smallint         = Null,
   @PsDescripcion            Varchar(  100)   = Null,
   @PnParametroNumber        Integer          = Null,
   @PsParametroChar          Varchar( 1000)   = Null,
   @PdParametroFecha         Date             = Null,
   @PnIdUsuarioAct           Integer,
   @PdFechaAct               Date             = Null,
   @PsIpAct                  Varchar(   30)   = Null,
   @PsMacAddressAct          Varchar(   30)   = Null,
   @PnEstatus                Integer          = 0    Output,
   @PsMensaje                Varchar(  250)   = ' '  Output)
As

Declare
   @w_desc_error          Varchar( 250),
   @w_Error               Integer,
   @w_sql                 Varchar(Max),
   @w_comilla             Char(1),
   @w_primero             Bit,
   @w_idEstatus           Bit,
   @w_idTipoUsuario       Bit,
   @w_registros           Integer;

Begin
/*
Objetivo: lista los valores de la tabla de Catalogos Parámetros Generales.'
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
          @w_comilla      = Char(39),
          @w_primero      = 0

   Select @PnEstatus = dbo.Fn_ValidaUsuarioAdmin(@PnIdUsuarioAct)
   If @PnEstatus != 0
      Begin
         Set @PsMensaje = Dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort Off
         Return
      End

   Set @w_sql = 'Select a.idParametroGral,  a.descripcion,  a.parametroNumber, a.parametroChar,
                        a.parametroFecha,   a.idUsuarioAct, b.nombre usuario,
                        a.fechaAct,         a.ipAct,        a.macAddressAct
                 From   dbo.conParametrosGralesTbl a
                 Join   dbo.segUsuariosTbl b
                 On     b.idUsuario = a.idUsuarioAct
                 Where  1 = 1'

   If @PnIdParametroGral Is Not Null
      Begin
         Set @w_sql     = @w_sql + ' And a.idParametroGral = ' + Cast(@PnIdParametroGral As Varchar)
      End

   If @PsDescripcion Is Not Null
      Begin
         Set @w_sql = @w_sql + ' And a.descripcion like ' + @w_comilla + '%' + @PsDescripcion + '%' + @w_comilla

      End

   If @PnParametroNumber Is Not Null
      Begin
         Set @w_sql = @w_sql + ' And a.parametroNumber = ' + Cast(@PnParametroNumber As Varchar)

      End

   If @PsParametroChar Is Not Null
      Begin
         Set @w_sql = @w_sql + ' And a.parametroChar like ' + @w_comilla + '%' + @PsParametroChar + '%' + @w_comilla

      End

   If @PdParametroFecha Is Not Null
      Begin
         Set @w_sql = @w_sql + ' Cast(a.parametroFecha As Date) = ' + @w_comilla + Cast(@PdParametroFecha As Varchar) + @w_comilla

      End

   If @PdFechaAct Is Not Null
      Begin
         Set @w_sql = @w_sql + ' And  Cast(a.fechaAct As Date) = ' + @w_comilla + Cast(@PdFechaAct As Varchar) + @w_comilla

      End

   If @PsIpAct Is Not Null
      Begin
         Set @w_sql = @w_sql + 'And  a.ipAct like ' + @w_comilla + '%' + @PsIpAct + '%' + @w_comilla

      End

   If @PsMacAddressAct Is Not Null
      Begin

         Set @w_sql = @w_sql + ' And a.macAddressAct like ' + @w_comilla + '%' + @PsMacAddressAct + '%' + @w_comilla

      End

   Set @w_sql = @w_sql + ' Order By 1 '

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
                @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Char))) + ' ' + @w_desc_error
         Set Xact_Abort Off
         Return
      End

   If @w_registros  = 0
      Begin
         Select @PnEstatus  = 4,
                @PsMensaje  = dbo.Fn_Busca_MensajeError(@PnEstatus)

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
   @w_valor          Nvarchar(250) = 'Procedimiento que Consulta la tabla de Catálogos de Parámetros Generales.',
   @w_procedimiento  NVarchar(250) = 'Spc_conParametrosGralesTbl';

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