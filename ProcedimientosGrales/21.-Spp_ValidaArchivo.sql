/*
Declare
   @PsArchivo     Varchar(255) = 'RepTiempoProc_0C8C63A3C81148B2.txt',
   @PsRuta        Varchar(255) = 'C:\Sitios\ApiSeguridad\ApiSeguridad-QA\LogsDba\',
   @PsSalida      Integer      = 0,
   @PnEstatus     Integer      = 0,
   @PsMensaje     Varchar(250) = Null
Begin
   Execute dbo.Spp_ValidaArchivo @PsArchivo = @PsArchivo,
                                 @PsRuta    = @PsRuta,
                                 @PsSalida  = @PsSalida  Output,
                                 @PnEstatus = @PnEstatus Output,
                                 @PsMensaje = @PsMensaje Output;

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje, @PsSalida
      End
   Else
      Begin
         Select @PsSalida
      End

   Return

End
Go

*/

Create Or Alter Procedure dbo.Spp_ValidaArchivo
  (@PsArchivo           Varchar(255),
   @PsRuta              Varchar(255),
   @PsSalida            Integer      = 0    Output,
   @PnEstatus           Integer      = 0    Output,
   @PsMensaje           Varchar(250) = Null Output)
As

Declare
   @w_desc_error      Varchar( 250),  
   @w_Error           Integer,
   @w_existe          Integer,
   @w_secuencia       Integer,
   @w_rutaArchivo     Varchar(510)
 
Begin
 
/*
Objetivo: Valida la Existencia física de un archivo en el DD.
Versión: 1

*/

   Set Nocount       On  
   Set Xact_Abort    On  
   Set Ansi_Nulls    Off 
   Set Ansi_Warnings On  
   Set Ansi_Padding  On  

   Select @PnEstatus  = 0,
          @PsMensaje  = '',
          @PsSalida   = 0;

--
--
--

   Create table #TempDatosArch
  (secuencia         Integer Not Null Identity Primary Key,
   existeArchivo     Integer,
   esDirectorio      Integer,
   existeDirectorio  Integer)

   Set @w_rutaArchivo =  @PsRuta + @PsArchivo 

   Begin Try
      Insert into #TempDatosArch
      (existeArchivo, esDirectorio, existeDirectorio)
      Execute sys.xp_fileexist  @w_rutaArchivo
      Set @w_secuencia = @@Identity
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

   Select @PsSalida = existeArchivo 
   From   #TempDatosArch 
   Where  Secuencia = @w_secuencia

   Set Xact_Abort Off
   Return

End
Go 

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Consulta de la Existencia física de un archivo en el DD.',
   @w_procedimiento  NVarchar(250) = 'Spp_ValidaArchivo';

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