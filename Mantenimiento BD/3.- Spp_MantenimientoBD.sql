Use SisArrendaCredito
Go

--Declare
--   @PsDbName              Varchar(250) = Db_name(),
--   @w_idProceso           Integer      = 0,
--   @PnEstatus             Integer      = 0,
--   @PsMensaje             Varchar(250) = Null;

--Begin
--   Select @w_idProceso = Max(idProceso)
--   From   SisArrendaCredito.dbo.logMantenimientoBDTbl

--   Execute Spp_MantenimientoBD @PsDbName  = @PsDbName,
--                               @PnEstatus = @PnEstatus Output,
--                               @PsMensaje = @PsMensaje Output

--   If @PnEstatus != 0
--      Begin
--         Select @PnEstatus, @PsMensaje
--      End

--   Select *
--   From   SisArrendaCredito.dbo.logMantenimientoBDTbl
--   Where  idProceso > @w_idProceso

--   Return

--End
--Go
--

-- Objetivo:    An�liza, Valida y ejecuta Mantenimiento a la BD.
-- Programador: Pedro Felipe Zambrano
-- Fecha:       21/11/2024
-- Versi�n:     1


Create Or Alter Procedure dbo.Spp_MantenimientoBD
  (@PsDbName              Varchar(250) = Null,
   @PnEstatus             Integer      = 0     Output,
   @PsMensaje             Varchar(250) = Null  Output)
As

Declare
   @w_error          Integer,
   @w_desc_error     Varchar(250),
   @w_tipoRecovery   Varchar(100),
   @w_dbFile         Sysname,
   @w_sql            Varchar(Max),
   @w_comilla        Char(1),
   @w_fechaInicio    Datetime,
   @w_servidor       Sysname,
   @w_database_id    Integer,
   @w_idProceso      Integer,
   @w_idProcesoF     Integer;

   Set @PsDbName = Isnull(@PsDbName, Db_name());

Declare
   C_base Cursor For
   Select database_id, recovery_model_desc
   From   sys.databases
   Where  name       = @PsDbName
   And    state_desc = 'ONLINE';

Begin

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

--
-- Incializamos Variables
--

   Select @PnEstatus        = 0,
          @PsMensaje        = Null,
          @w_comilla        = Char(39),
          @w_servidor       = @@ServerName;

   Open  C_Base
   While @@Fetch_status < 1
   Begin
      Fetch C_Base Into @w_database_id, @w_tipoRecovery
      If @@Fetch_status != 0
         Begin
            Break
         End

      Set @w_fechaInicio = Getdate()

      Begin Try
         Insert Into dbo.logMantenimientoBDTbl
         (servidor, baseDatos, actividad, fechaInicio)
         Select @w_servidor, @PsDbName, 'Comprobaci�n de la integridad l�gica y f�sica de la base de datos', @w_fechaInicio

         Set @w_idProceso = @@Identity
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 230)
      End   Catch

      If Isnull(@w_Error, 0)  <> 0
         Begin
            Select @PnEstatus  = @w_Error,
                   @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

            Set Xact_Abort Off
            Return
         End

--
-- Actualiza el tipo de recuperaci�n a Simple.
--

      If @w_tipoRecovery != 'SIMPLE'
         Begin
            Set @w_sql = 'Alter Database ' + @PsDbName + ' Set Recovery Simple';
         End

      Begin Try
         Execute (@w_sql)
      End   Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 230)
      End   Catch

      If Isnull(@w_Error, 0)  <> 0
         Begin
            Select @PnEstatus  = @w_Error,
                   @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

            Update  dbo.logMantenimientoBDTbl
            Set     fechaTermino = @w_fechaInicio,
                    Error        = @PnEstatus,
                    mensajeError = @PsMensaje
            Where   idProceso = @w_idProceso

            Break

         End

--
-- Actualiza la Base de datos a Usuario �nico
--

      Set @w_sql = Concat('Alter Database ', @PsDbName, ' Set Single_User');
      Begin Try
         Execute (@w_sql)
      End   Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 230)
      End   Catch

      If Isnull(@w_Error, 0)  <> 0
         Begin
            Select @PnEstatus  = @w_Error,
                   @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

            Update  dbo.logMantenimientoBDTbl
            Set     fechaTermino = @w_fechaInicio,
                    Error        = @PnEstatus,
                    mensajeError = @PsMensaje
            Where   idProceso = @w_idProceso

            Break

         End

--
-- Chequeo de posibles inconsistencias en la Base de datos.
--

      Set @w_sql = Concat('Dbcc Checkdb (', @w_comilla, @PsDbName, @w_comilla, ', noindex) With No_infomsgs')

      Begin Try
         Execute (@w_sql)
      End   Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 230)
      End   Catch

      If Isnull(@w_Error, 0)  <> 0
         Begin
            Select @PnEstatus  = @w_Error,
                   @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

            Update  dbo.logMantenimientoBDTbl
            Set     fechaTermino = @w_fechaInicio,
                    Error        = @PnEstatus,
                    mensajeError = @PsMensaje
            Where   idProceso    = @w_idProceso

            Break

         End

      Set @w_fechaInicio = Getdate()

      Begin Try
         Update  dbo.logMantenimientoBDTbl
         Set     fechaTermino = @w_fechaInicio
         Where   idProceso = @w_idProceso
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 230)
      End   Catch

      If Isnull(@w_Error, 0)  <> 0
         Begin
            Select @PnEstatus  = @w_Error,
                   @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

            Update  dbo.logMantenimientoBDTbl
            Set     fechaTermino = @w_fechaInicio,
                    Error        = @PnEstatus,
                    mensajeError = @PsMensaje
            Where   idProceso = @w_idProceso

            Break
         End

--

      Begin Try
         Insert Into dbo.logMantenimientoBDTbl
         (servidor, baseDatos, actividad, fechaInicio)
         Select @w_servidor, @PsDbName, 'Compactaci�n Base de Datos', @w_fechaInicio

         Set @w_idProceso = @@Identity
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 230)
      End   Catch

      If Isnull(@w_Error, 0)  <> 0
         Begin
            Select @PnEstatus  = @w_Error,
                   @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

            Set Xact_Abort Off
            Return
         End

      Set @w_sql = Concat('Dbcc Shrinkdatabase (', @w_comilla, @PsDbName, @w_comilla, ', 10) With No_infomsgs')

      Begin Try
         Execute (@w_sql)
      End   Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 230)
      End   Catch

      If Isnull(@w_Error, 0)  <> 0
         Begin
            Select @PnEstatus  = @w_Error,
                   @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

            Update  dbo.logMantenimientoBDTbl
            Set     fechaTermino = @w_fechaInicio,
                    Error        = @PnEstatus,
                    mensajeError = @PsMensaje
            Where   idProceso = @w_idProceso

            Break

         End

      Set @w_fechaInicio = Getdate()

      Begin Try
         Update  dbo.logMantenimientoBDTbl
         Set     fechaTermino = @w_fechaInicio
         Where   idProceso = @w_idProceso
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 230)
      End   Catch

      If Isnull(@w_Error, 0)  <> 0
         Begin
            Select @PnEstatus  = @w_Error,
                   @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

            Update  dbo.logMantenimientoBDTbl
            Set     fechaTermino = @w_fechaInicio,
                    Error        = @PnEstatus,
                    mensajeError = @PsMensaje
            Where   idProceso = @w_idProceso

            Break
         End

--
-- Compactaci�n de los Archivos Logs que tenga relacionado la Base de datos.
--

      Declare
      C_Files Cursor For
      Select a.name
      From   sys.master_files a
      Join   sys.databases b
      On     b.database_id = a.database_id
      Where  b.database_id = @w_database_id
      And    b.name        = @PsDbName
      And    a.type        = 1
      And    a.state_desc  = 'ONLINE';

      Open C_Files
      While @@Fetch_status < 1
      Begin
         Fetch C_Files Into @w_dbFile
         If @@Fetch_status != 0
            Begin
               Break
            End

         Begin Try
            Insert Into dbo.logMantenimientoBDTbl
            (servidor, baseDatos, actividad, fechaInicio)
            Select @w_servidor, @PsDbName, Concat('Compactaci�n Archivo Log.: ', @w_dbFile), @w_fechaInicio

            Set @w_idProcesoF = @@Identity

         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230)
         End   Catch

         If Isnull(@w_Error, 0)  <> 0
            Begin
               Select @PnEstatus  = @w_Error,
                      @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

               Update  dbo.logMantenimientoBDTbl
               Set     fechaTermino = @w_fechaInicio,
                       Error        = @PnEstatus,
                       mensajeError = @PsMensaje
               Where   idProceso = @w_idProcesoF

               Break

            End

         Set @w_sql = Concat('Use ', @PsDbName, '; Dbcc Shrinkfile (', @w_comilla, @w_dbFile, @w_comilla , ', Truncateonly) With No_infomsgs');

         Begin Try
            Execute (@w_sql)
         End   Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230)
         End   Catch

         If Isnull(@w_Error, 0)  <> 0
            Begin
               Select @PnEstatus  = @w_Error,
                      @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

               Update  dbo.logMantenimientoBDTbl
               Set     fechaTermino = @w_fechaInicio,
                       Error        = @PnEstatus,
                       mensajeError = @PsMensaje
               Where   idProceso = @w_idProcesoF

               Break
            End

         Set @w_fechaInicio = Getdate()

         Begin Try
            Update  dbo.logMantenimientoBDTbl
            Set     fechaTermino = @w_fechaInicio
            Where   idProceso = @w_idProcesoF
         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230)
         End   Catch

         If Isnull(@w_Error, 0)  <> 0
            Begin
               Select @PnEstatus  = @w_Error,
                      @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

               Set Xact_Abort Off
               Return
            End

      End
      Close      C_Files
      Deallocate C_Files

      If @PnEstatus != 0
         Begin
            Break
         End

--
-- Actualiza el tipo de recuperaci�n a Inicial.
--

      If @w_tipoRecovery != 'SIMPLE'
         Begin
            Set @w_sql = 'Alter Database ' + @PsDbName + ' Set Recovery ' + @w_tipoRecovery;

            Begin Try
               Execute (@w_sql)
            End   Try

            Begin Catch
               Select  @w_Error      = @@Error,
                       @w_desc_error = Substring (Error_Message(), 1, 230)
            End   Catch

            If Isnull(@w_Error, 0)  <> 0
               Begin
                  Select @PnEstatus  = @w_Error,
                         @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

               Update  dbo.logMantenimientoBDTbl
               Set     fechaTermino = @w_fechaInicio,
                       Error        = @PnEstatus,
                       mensajeError = @PsMensaje
               Where   idProceso = @w_idProceso

               Break

            End

         End

--
-- Actualiza la Base de datos a Multi Usuario.
--

      Set @w_sql = Concat('Alter Database ', @PsDbName, ' Set Multi_User');
      Begin Try
         Execute (@w_sql)
      End   Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 230)
      End   Catch

      If Isnull(@w_Error, 0)  <> 0
         Begin
            Select @PnEstatus  = @w_Error,
                   @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

            Update  dbo.logMantenimientoBDTbl
            Set     fechaTermino = @w_fechaInicio,
                    Error        = @PnEstatus,
                    mensajeError = @PsMensaje
            Where   idProceso = @w_idProceso

            Break

         End

--
--
--

   End

   Close      C_Base
   Deallocate C_Base

   Set Xact_Abort Off
   Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'An�liza, Valida y compacta la Base de Datos.',
   @w_procedimiento  Varchar( 100) = 'Spp_MantenimientoBD'


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
                                      @level0name = N'Dbo',
                                      @level1type = 'Procedure',
                                      @level1name = @w_procedimiento;

   End
Else
   Begin
      Execute sp_updateextendedproperty @name       = 'MS_Description',
                                        @value      = @w_valor,
                                        @level0type = 'Schema',
                                        @level0name = N'Dbo',
                                        @level1type = 'Procedure',
                                        @level1name = @w_procedimiento
   End
Go

