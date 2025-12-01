/*

Procedimiento que lista los objetos de base y fecha de creacion y de modificacion.

Declare
   @PsProcedimiento      Varchar(4000)    = Null,
   @PnIdUsuarioAct       Smallint         = 1,
   @PnEstatus            Integer          = 0,
   @PsMensaje            Varchar(  250)   = ' '

Begin
   Execute  Spc_AnalisisObjetosBD @PsProcedimiento     = @PsProcedimiento,
                                  @PnIdUsuarioAct      = @PnIdUsuarioAct,
                                  @PnEstatus           = @PnEstatus Output,
                                  @PsMensaje           = @PsMensaje Output

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

   Return

End
Go

*/

Create Or Alter Procedure Spc_AnalisisObjetosBD
  (@PsProcedimiento             Sysname    = Null,
   @PnIdUsuarioAct              Integer,
   @PnEstatus                   Integer          = 0   Output,
   @PsMensaje                   Varchar(  250)   = ' ' Output)
As

Declare
   @w_desc_error              Varchar( 250),
   @w_Error                   Integer,
   @w_idEstatus               Tinyint,
   @w_idTipoUsuario           Tinyint,
   @w_comilla                 Char(1),
   @w_sql                     Varchar(Max),
   @w_tablas                  Varchar(4000),
   @w_tabla                   Sysname,
   @w_existe                  Bit,
   @w_pos                     Integer,
   @w_len                     Integer,
   @w_esquema                 Varchar(   30)

Begin
/*

Objetivo: listar los objetos de base y fecha de creacion y de modificacion.
Versión:  1
*/

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    On
   Set Ansi_Warnings On
   Set Ansi_Padding  On
   
   Select @PnEstatus       = 0,
          @PsMensaje       = ' ',
          @w_esquema       = Concat(current_User, '.'),
          @w_comilla       = Char(39);

   Select @w_idEstatus     = idEstatus
   From   dbo.segUsuariosTbl
   Where  idUsuario    = @PnIdUsuarioAct
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 9999,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort Off
         Return
      End

   If @w_idEstatus = 0
      Begin
         Select @PnEstatus = 9998,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort Off
         Return
      End

   If @w_idTipoUsuario != 1
      Begin
         Select @PnEstatus = 9995,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort Off
         Return
      End
   
   Select @w_idEstatus = idEstatus
   From   segUsuariosTbl
   Where  idUsuario    = @PnIdUsuarioAct
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 9997,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort Off
         Return
      End

   If @w_idEstatus = 0
      Begin
         Select @PnEstatus = 9996,
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)
         Set Xact_Abort Off
         Return
      End

   Set @w_tabla = Rtrim('segDimObjetos_' + 
                  Substring(Replace(Cast(Newid() As Varchar(Max)), '-', ''), 1, 12))


   Set @w_sql   = 'Create  Table    dbo.' + @w_tabla    + ' ' +
                  '(tipo                 Char(2)      Not Null,
                    name                 Sysname      Not Null, 
                    fechaCreacion        Datetime     Not Null,
                    fechaModificacion    Datetime     Not Null,
                    Primary Key (tipo, name)) '

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

   Set @w_sql =  'Insert into dbo.' + @w_tabla + '
                  (tipo, name, fechaCreacion, fechaModificacion)
                  Select a.type, a.name,  a.create_date, a.modify_date                    
                  From   sys.all_objects  a
                  Join   sysObjects b
                  On     b.id     = a.object_id
                  Where  b.uid    = 1'
                  
   If @PsProcedimiento Is Not Null
      Begin
         Set @w_sql = @w_sql + ' And    b.name = ' + @w_comilla + @PsProcedimiento + @w_comilla
      End
   
   Set @w_sql = @w_sql + ' And    b.name  != '  + @w_comilla + @w_tabla + @w_comilla + '
                           And    a.type  In (' + @w_comilla + 'P' + @w_comilla + ', ' + @w_comilla + 'FN' + @w_comilla + ', ' + 
                                                  @w_comilla + 'V' + @w_comilla + ', ' + @w_comilla + 'U'  + @w_comilla + ') 
                           ORDER  By 1, 2 '    
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

  Set @w_sql = 'Select tipo, name, fechaCreacion, fechaModificacion ' +
               'From   dbo.' + @w_tabla

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

  Set @w_sql = 'Drop Table dbo.' + @w_tabla
  Execute (@w_sql)
  
  Set Xact_Abort Off
  Return

End
Go 

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento que lista los objetos de base y fecha de creacion y de modificacion.',
   @w_procedimiento  NVarchar(250) = 'Spc_AnalisisObjetosBD';

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