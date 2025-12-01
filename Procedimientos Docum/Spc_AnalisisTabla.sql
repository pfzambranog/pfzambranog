Use SCMBD
Go

/*

Procedimiento que lista los tamaños de las tablas.

Declare
   @PsTablas                    Varchar(Max)     = Null,
   @PnRegistrosMinimos          Integer          = 0,
   @PnOrden                     Tinyint          = 2,
   @PnIdUsuarioAct              Smallint         = 1,
   @PnEstatus                   Integer          = 0,
   @PsMensaje                   Varchar(  250)   = ' '

Begin
   Execute  dbo.Spc_AnalisisTabla @PsTablas           = @PsTablas,
                                  @PnRegistrosMinimos = @PnRegistrosMinimos,
                                  @PnOrden            = @PnOrden,
                                  @PnIdUsuarioAct     = @PnIdUsuarioAct,
                                  @PnEstatus          = @PnEstatus Output,
                                  @PsMensaje          = @PsMensaje Output

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

   Return

End
Go

*/

Create Or Alter Procedure dbo.Spc_AnalisisTabla
  (@PsTablas                    Varchar(Max)          = Null,  
   @PnRegistrosMinimos          Integer          = 0,  
   @PnOrden                     Tinyint          = 1,  
   @PnIdUsuarioAct              Integer,  
   @PnEstatus                   Integer          = 0   Output,  
   @PsMensaje                   Varchar(  250)   = ' ' Output)  
As  
  
Declare  
   @w_desc_error               Varchar( 250),  
   @w_Error                    Integer,  
   @w_idEstatus                Tinyint,  
   @w_idTipoUsuario            Tinyint,  
   @w_comilla                  Char(1),  
   @w_sql                      Varchar(Max),  
   @w_tablas                   Varchar(4000),  
   @w_tabla                    Sysname,  
   @w_existe                   Bit,  
   @w_pos                      Integer,  
   @w_len                      Integer  
  
Begin  
/*  
Objetivo: lista los tamaños de las tablas  
Versión:  1  
  
*/  
  
   Set Nocount       On  
   Set Xact_Abort    On  
   Set Ansi_Nulls    Off  
   Set Ansi_Warnings On  
   Set Ansi_Padding  On  
  
   Select @PnEstatus       = 0,  
          @PsMensaje       = ' ',  
          @w_comilla       = Char(39);  
  
   Set @w_tabla = Rtrim('segDimTablas_' +  
                  Substring(Replace(Cast(Newid() As Varchar(Max)), '-', ''), 1, 12))  
  
   Set @w_existe = dbo.Fn_existe_tabla(@w_tabla)  
  
   If @w_existe = 1  
      Begin  
         Set @w_sql = 'Drop Table Dbo.' + @w_tabla  
  
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
                      @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error  
  
               Set Xact_Abort Off  
               Return  
            End  
  
      End  
  
   Set @w_sql   = 'Create     Table dbo.' + @w_tabla    + ' ' +  
                  '(tabla               Sysname      Not Null, '    +  
                   'registros           Integer      Not Null, '    +  
                   'espacioInicialMB    Varchar(18)  Not Null, '    +  
                   'espacioDatosMB      Varchar(18)  Not Null, '    +  
                   'espacioIndicesMB    Varchar(18)  Not Null, '    +  
                   'disponibleMB        Varchar(18)  Not Null, '    +  
                   'Primary Key (tabla)) '  
  
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
                @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error  
  
         Set Xact_Abort Off  
         Return  
      End  
  
   If Isnull(@w_Error, 0) <> 0  
      Begin  
         Select @PnEstatus = @w_Error,  
   @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error  
  
         Set Xact_Abort Off  
         Return  
      End  
  
  
   Set @w_sql = 'Insert into dbo.' + @w_tabla + ' ' +  
                'Execute sp_msForEachTable '     + @w_comilla +  
                         'Execute sp_spaceused ' + @w_comilla + @w_comilla + '?' + @w_comilla + @w_comilla + @w_comilla  
  
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
                @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error  
  
         Set Xact_Abort Off  
         Return  
      End  
  
  Set @w_sql = 'Update ' + @w_tabla + '  
                Set   espacioInicialMB = Replace(espacioInicialMB, ' + @w_comilla + 'KB' + + @w_comilla + ', Char(32)),  
                      espacioDatosMB   = Replace(espacioDatosMB, '   + @w_comilla + 'KB' + + @w_comilla + ', Char(32)),  
                      espacioIndicesMB = Replace(espacioIndicesMB, ' + @w_comilla + 'KB' + + @w_comilla + ', Char(32)),  
                      disponibleMB     = Replace(disponibleMB, '     + @w_comilla + 'KB' + + @w_comilla + ', Char(32))'  
  
  Execute (@w_sql)  
  
  Set @w_sql = 'Update ' + @w_tabla + '  
                Set   espacioInicialMB = Cast(espacioInicialMB As Integer) / 1024,  
                      espacioDatosMB   = Cast(espacioDatosMB   As Integer) / 1024,  
                      espacioIndicesMB = Cast(espacioIndicesMB As Integer) / 1024,  
                      disponibleMB     = Cast(disponibleMB     As Integer) / 1024'  
  
  Execute (@w_sql)  
  
  Set @w_sql = 'Select tabla, registros,  Cast(espacioInicialMB As Integer) espacioInicialMB,  
                                          Cast(espacioDatosMB   As Integer) espacioDatosMB,  
                                          Cast(espacioIndicesMB As Integer) espacioIndicesMB,  
                                          Cast(disponibleMB     As Integer) disponibleMB  
                From   ' + @w_tabla  
  
  If @PsTablas Is Not Null  
     Begin  
        Select @w_len    = len(@PsTablas),  
               @w_pos    = 0,  
               @w_tablas = ''  
  
        While @w_pos < @w_len  
        Begin  
           Set @w_pos = @w_pos + 1  
  
           If Substring(@PsTablas, @w_pos, 1) = ','  
              Begin  
                 Set @w_tablas = Ltrim(Rtrim(@w_tablas)) + @w_comilla + ', ' + @w_comilla  
              End  
           Else  
              Begin  
                 Set @w_tablas = Ltrim(Rtrim(@w_tablas)) + Substring(@PsTablas, @w_pos, 1)  
              End  
        End  
  
        Set @w_sql = @w_sql + ' Where tabla In (' + @w_comilla + @w_tablas + @w_comilla + ')'  
  
     End  
  Else  
     Begin  
        Set @w_sql = @w_sql + ' Where registros >= ' + Cast(@PnRegistrosMinimos As Varchar)  
     End  
  
  If @PnOrden = 1  
     Begin  
        Set @w_sql = @w_sql + ' Order By Registros Desc'  
     End  
  
  If @PnOrden = 2  
     Begin  
        Set @w_sql = @w_sql + ' Order By espacioInicialMB Desc'  
     End  
  
  If @PnOrden = 3  
     Begin  
        Set @w_sql = @w_sql + ' Order By espacioDatosMB Desc'  
     End  
  
  If @PnOrden = 4  
     Begin  
        Set @w_sql = @w_sql + ' Order By disponibleMB Desc'  
     End  
  
  
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
                @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error  
  
         Set Xact_Abort Off  
         Return  
      End  
  
   Set @w_existe = dbo.Fn_existe_tabla(@w_tabla)  
  
   If @w_existe = 1  
      Begin  
         Set @w_sql = 'Drop Table Dbo.' + @w_tabla  
  
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
                      @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error  
  
               Set Xact_Abort Off  
               Return  
            End  
  
      End  
  
  Set Xact_Abort Off  
  Return  
  
End 
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento que Consulta las tablas de la base de datos.',
   @w_procedimiento  NVarchar(250) = 'Spc_AnalisisTabla';

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


