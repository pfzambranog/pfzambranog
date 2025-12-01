/*

Declare
   @PsSever         NVarchar(128) = '127.0.0.1',
   @PsBaseDatos     Sysname       = 'SCMBD',
   @PsDbLink        Sysname       = 'SCMBD',
   @PsTabla         Sysname       = 'segUsuariosTbl',
   @PsUsuario       Varchar( 30)  = 'sa',
   @PsPassword      Varchar(250)  = 'Pedro',
   @PnEstatus       Integer       = 0,
   @PsMensaje       Varchar(250)  = ' '

Begin
   Execute Spa_Genera_dbLink @PsSever     = @PsSever,
                             @PsBaseDatos = @PsBaseDatos,
                             @PsDbLink    = @PsDbLink,
                             @PsTabla     = @PsTabla,
                             @PsUsuario   = @PsUsuario,
                             @PsPassword  = @PsPassword,
                             @PnEstatus   = @PnEstatus,
                             @PsMensaje   = @PsMensaje

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

   Return

End
Go

*/

Create Or Alter Procedure Spa_Genera_dbLink
  (@PsSever         Nvarchar(128),
   @PsBaseDatos     Sysname,
   @PsDbLink        Sysname,
   @PsTabla         Sysname,
   @PsUsuario       Varchar( 30),
   @PsPassword      Varchar(250),
   @PnEstatus       Integer       = 0     Output,
   @PsMensaje       Varchar(250)  = ' '   Output)
-- With Encryption
As

Declare 
   @w_sql              NVarchar(500),
   @w_param            NVarchar(500),
   @w_registros        Integer,
   @w_desc_error       Varchar( 250),
   @w_Error            Integer

   
Begin
/*

Objetivo: Dar de Alta Link Servers
Versión:  1
*/

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    On
   Set Ansi_Warnings On
   Set Ansi_Padding  On
   
   Select @PnEstatus  = 0,
          @PsMensaje  = Null 

   
   If Exists ( Select top 1 1
               From   sys.servers s 
               Where  s.server_id <> 0 
               And    s.name       = @PsDbLink)
      Begin
         Begin Try
            Execute  sys.sp_dropserver @server = @PsDbLink, @droplogins = 'droplogins'
         End   Try
         
         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230)
         End   Catch
         
            If Isnull(@w_Error, 0) <> 0
         Begin
            Select @PnEstatus = @w_Error,
                   @PsMensaje = 'Error.: Eliminando Db_Link. ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error
            Set Xact_Abort Off
            Return
         End
     
      End
  
    Begin Try
       Execute sys.sp_addlinkedserver @server = @PsDbLink, @srvproduct = '', @provider = 'SQLNCLI', @datasrc = @PsSever
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

    Begin Try
       Execute sp_addlinkedsrvlogin @rmtsrvname  = @PsDbLink,  @useself     = 'FALSE',     @locallogin  = null, 
                                    @rmtuser     = @PsUsuario, @rmtpassword = @PsPassword
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

    Select @w_sql   = 'Select @w_output = count(1) '    +
                      'From ' + Rtrim(Ltrim(@PsDbLink)) + '.' + Rtrim(Ltrim(@PsBaseDatos)) + '.dbo.' + @PsTabla,
           @w_param = '@w_output Integer Output'

    Begin Try
       Execute SP_ExecuteSQL  @w_sql, @w_param, @w_output = @w_registros Output
    End   Try

    Begin Catch
       Select  @w_Error      = @@Error,
               @w_desc_error = Substring (Error_Message(), 1, 230)
    End   Catch
         
    If Isnull(@w_Error, 0) <> 0
       Begin
          Select @PnEstatus = @w_Error,
                 @PsMensaje = 'Error.: Conectando. ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error
          Set Xact_Abort Off
          Return
       End

    Set @PsMensaje = 'Conexión Exitosa..'

    Set Xact_Abort Off
    Return
    
End
Go 

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Alta a Link Servers.',
   @w_procedimiento  NVarchar(250) = 'Spa_Genera_dbLink';

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