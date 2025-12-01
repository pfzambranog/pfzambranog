-- Use SMBDTI  -- Aplicar en todas las BD de la instancia
-- Go

/*

Declare
   @PsDbName              Varchar(250) = 'SMBDTI',
   @w_idProceso           Integer      = 0,
   @PnEstatus             Integer      = 0,  
   @PsMensaje             Varchar(250) = Null;

Begin
   Select @w_idProceso = Max(idProceso)
   From   SMBDTI.dbo.logMantenimientoBDTbl

   Execute Spp_MantenimientoBD_1 @PsDbName  = @PsDbName,
                                 @PnEstatus = @PnEstatus Output,
                                 @PsMensaje = @PsMensaje Output

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

   Select *
   From   SMBDTI.dbo.logMantenimientoBDTbl
   Where  idProceso > @w_idProceso

   Return

End
Go 
                
*/

Create   Procedure Spp_MantenimientoBD_1
  (@PsDbName              Varchar(250),
   @PnEstatus             Integer      = 0     Output,  
   @PsMensaje             Varchar(250) = Null  Output)                
As

Declare
   @w_error          Integer,
   @w_desc_error     Varchar(250),
   @w_dbName         Sysname,
   @w_tipoRecovery   Varchar(100),
   @w_dbFile         Sysname,
   @w_sql            Varchar(Max),
   @w_comilla        Char(1),
   @w_fechaInicio    Datetime,
   @w_servidor       Sysname,
   @w_database_id    Integer,
   @w_idProceso      Integer,
   @w_idProcesoF     Integer;

Declare
   C_base Cursor For
   Select database_id, name, recovery_model_desc
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
      Fetch C_Base Into @w_database_id, @w_dbName, @w_tipoRecovery
      If @@Fetch_status != 0
         Begin
            Break
         End

      Set @w_fechaInicio = Getdate()

      Begin Try
         Insert Into SMBDTI.dbo.logMantenimientoBDTbl
         (servidor, baseDatos, actividad, fechaInicio)
         Select @w_servidor, @w_dbName, 'Compruebación de la integridad lógica y física de la base de datos.', @w_fechaInicio

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

      If @w_tipoRecovery != 'SIMPLE'
         Begin
            Set @w_sql = 'Alter Database ' + @w_dbName + ' Set Recovery Simple';
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

            Update  SMBDTI.dbo.logMantenimientoBDTbl
            Set     fechaTermino = @w_fechaInicio,
                    Error        = @PnEstatus,
                    mensajeError = @PsMensaje
            Where   idProceso = @w_idProceso
            
            Break

         End
		 
      Set @w_sql = Concat('Dbcc Checkdb (', @w_comilla, @w_dbName, @w_comilla, ', noindex) With No_infomsgs') 

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

            Update  SMBDTI.dbo.logMantenimientoBDTbl
            Set     fechaTermino = @w_fechaInicio,
                    Error        = @PnEstatus,
                    mensajeError = @PsMensaje
            Where   idProceso = @w_idProceso

            Break

         End

      Set @w_fechaInicio = Getdate()

      Begin Try
         Update  SMBDTI.dbo.logMantenimientoBDTbl
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

            Update  SMBDTI.dbo.logMantenimientoBDTbl
            Set     fechaTermino = @w_fechaInicio,
                    Error        = @PnEstatus,
                    mensajeError = @PsMensaje
            Where   idProceso = @w_idProceso

            Break
         End

--

      Begin Try
         Insert Into SMBDTI.dbo.logMantenimientoBDTbl
         (servidor, baseDatos, actividad, fechaInicio)
         Select @w_servidor, @w_dbName, 'Compactación Base de Datos', @w_fechaInicio

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

      Set @w_sql = Concat('Dbcc Shrinkdatabase (', @w_comilla, @w_dbName, @w_comilla, ', 10) With No_infomsgs') 

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

            Update  SMBDTI.dbo.logMantenimientoBDTbl
            Set     fechaTermino = @w_fechaInicio,
                    Error        = @PnEstatus,
                    mensajeError = @PsMensaje
            Where   idProceso = @w_idProceso

            Break

         End

      Set @w_fechaInicio = Getdate()

      Begin Try
         Update  SMBDTI.dbo.logMantenimientoBDTbl
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

            Update  SMBDTI.dbo.logMantenimientoBDTbl
            Set     fechaTermino = @w_fechaInicio,
  Error        = @PnEstatus,
                    mensajeError = @PsMensaje
            Where   idProceso = @w_idProceso

            Break
         End

      Declare
      C_Files Cursor For
      Select a.name
      From   sys.master_files a
      Join   sys.databases b
      On     b.database_id = a.database_id
      Where  b.database_id = @w_database_id
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
            Insert Into SMBDTI.dbo.logMantenimientoBDTbl
            (servidor, baseDatos, actividad, fechaInicio)
            Select @w_servidor, @w_dbName, Concat('Compactación Archivo Log.: ', @w_dbFile), @w_fechaInicio

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

               Update  SMBDTI.dbo.logMantenimientoBDTbl
               Set     fechaTermino = @w_fechaInicio,
                       Error        = @PnEstatus,
                       mensajeError = @PsMensaje
               Where   idProceso = @w_idProcesoF

               Break

            End

         Set @w_sql = Concat('Dbcc Shrinkfile (', @w_comilla, @w_dbFile, @w_comilla , ', Truncateonly) With No_infomsgs');

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

               Update  SMBDTI.dbo.logMantenimientoBDTbl
               Set     fechaTermino = @w_fechaInicio,
                       Error        = @PnEstatus,
                       mensajeError = @PsMensaje
               Where   idProceso = @w_idProcesoF

               Break
            End

         Set @w_fechaInicio = Getdate()

         Begin Try
            Update  SMBDTI.dbo.logMantenimientoBDTbl
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

      If @w_tipoRecovery != 'SIMPLE'
         Begin
            Set @w_sql = 'Alter Database ' + @w_dbName + ' Set Recovery ' + @w_tipoRecovery;

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

               Update  SMBDTI.dbo.logMantenimientoBDTbl
               Set     fechaTermino = @w_fechaInicio,
                       Error        = @PnEstatus,
                       mensajeError = @PsMensaje
               Where   idProceso = @w_idProceso

               Break

            End

         End

   End

   Close      C_Base
   Deallocate C_Base

   Set Xact_Abort Off
   Return

End 
 
Go
