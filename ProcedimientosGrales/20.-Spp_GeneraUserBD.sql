Use SCMBD

/*
  Procedimiento de Generación de Usuarios de BS.

Declare
   @PsIdUsuarioBD            Sysname        = 'Test01',
   @PsPasswordBD             Sysname        = 'Test01',
   @PsBaseDatos              Sysname        = 'SCMBD',
   @PnEstatus                Integer        = 0,  
   @PsMensaje                Varchar( 250)  = ' '
   

Begin
   Execute dbo.Spp_GeneraUserBD   @PsIdUsuarioBD = @PsIdUsuarioBD,
                                  @PsPasswordBD  = @PsPasswordBD, 
                                  @PsBaseDatos   = @PsBaseDatos,  
                                  @PnEstatus     = @PnEstatus   Output, 
                                  @PsMensaje     = @PsMensaje   Output;
  
   
   If @PnEstatus > 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

End
Go
*/

Create Or Alter Procedure dbo.Spp_GeneraUserBD
  (@PsIdUsuarioBD           Sysname,
   @PsPasswordBD            Sysname,
   @PsBaseDatos             Sysname,
   @PnEstatus               Integer        = 0     Output,
   @PsMensaje               Varchar( 250)  = Null  Output)
As

Declare
    @w_desc_error              Varchar( 250),  
    @w_Error                   Integer,  
    @w_IdEstatus               Tinyint,  
    @w_sql                     NVarchar(1500),
    @w_param                   NVarchar( 750),
    @w_comilla                 Char(1),
    @w_registros               Smallint

Begin  
/*
Objetivo: Generar usuario de Base de Datos.
Vsersión: 1
*/

   Set Nocount       On  
   Set Xact_Abort    On  
   Set Ansi_Nulls    Off 
   Set Ansi_Warnings On  
   Set Ansi_Padding  On  

   Select @PnEstatus  = 0,
          @PsMensaje  = '',
          @w_comilla = Char(39)

   Select @w_idEstatus = is_disabled
   From   master.sys.sql_logins
   Where  type = 'S'
   And    name = @PsIdUsuarioBD
   If @@Rowcount = 0
      Begin
         Set @w_sql = 'Create Login ' + @PsIdUsuarioBD + ' With  Password = ' + @w_comilla + @PsIdUsuarioBD + @w_comilla + ', ' +
                      'Default_database = ' + @PsBaseDatos                                                               + ', ' +  
                      'Default_Language = English '                                                                      + ', ' +
                      'Check_Expiration = Off '                                                                          + ', ' +
                      'Check_Policy     = Off'
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
                      @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

               Set Xact_Abort Off
               Return
            End
      End

   Select @w_sql   = 'Select @o_idEstatus = Count(1) '                           +
                     'From   ' + @PsBaseDatos + '.sys.sysusers '                 +
                     'Where  name = ' + @w_comilla + @PsIdUsuarioBD + @w_comilla,
          @w_param = '@o_idEstatus  Tinyint Output'

   Begin Try
      Execute Sp_executeSQL @w_sql, @w_param, @o_idEstatus = @w_IdEstatus Output
   End   Try

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


   If Isnull(@w_IdEstatus, 0) = 0
      Begin
         Set @w_sql = 'Use '         + @PsBaseDatos   + '; ' + Char(13) +
                      'Create User ' + @PsIdUsuarioBD + ' For Login ' + @PsIdUsuarioBD + ' ' +
                      'With Default_schema = ' + @PsIdUsuarioBD
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
                      @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error
               Set Xact_Abort Off
               Return
            End
      End

   Set @w_sql =  'Use '         + @PsBaseDatos   + '; ' + Char(13) +
                'Execute sp_addrolemember ' + @w_comilla + 'db_datareader'  + @w_comilla + ', '              + 
                                              @w_comilla + @PsIdUsuarioBD   + @w_comilla + '; ' + Char(13)   + 
                'Execute sp_addrolemember ' + @w_comilla + 'db_datawriter'  + @w_comilla + ', '              + 
                                              @w_comilla + @PsIdUsuarioBD   + @w_comilla +'; '  + Char(13)   +
                'Execute sp_addrolemember ' + @w_comilla + 'db_accessadmin' + @w_comilla + ', '              + 
                                              @w_comilla + @PsIdUsuarioBD   + @w_comilla +';'
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
                @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error
         Set Xact_Abort Off
         Return
      End

   Set Xact_Abort Off
   Return

End
Go

Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento que Genera nuevos Usuarios en la Base de Datos.',
   @w_procedimiento  NVarchar(250) = 'Spp_GeneraUserBD';

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