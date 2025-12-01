Alter Procedure dbo.Spa_conProcesosTbl        
  (@PnIdMotivo                Integer,      
   @PnIdTipoNotificacion      Tinyint        = 0,      
   @PsParametros              Varchar (8000) = '',      
   @PsURL                     Varchar (2000) = '',      
   @PdFechaProgramada         Datetime       = Null,      
   @PnIdUsuarioAct            Smallint,      
   @PsXML                     Varchar(Max)            = Null,      
   @PsHTML                    NVarchar( Max) = Null,      
   @PsTipo                    NVarchar(  20) = Null,      
   @PsRuta                    Varchar ( 250) = Null,      
   @PsNombreArchivo           Varchar ( 250) = Null,      
   @PnEstatus                 Integer        = 0   Output,      
   @PsMensaje                 Varchar (250)  = ' ' Output)      
As          
          
Declare          
   @w_desc_error              Varchar( 250),          
   @w_Error                   Integer,          
   @w_fechaAct                Datetime,          
   @w_idEstatus               Bit,          
   @w_idProceso               Integer,          
   @w_fechaProgramada         Datetime,          
   @w_idSession               Varchar(60)      
          
Begin          
   Set Nocount       On          
   Set Xact_Abort    On          
   Set Ansi_Nulls    On          
   Set Ansi_Warnings On          
   Set Ansi_Padding  On          
          
   Select @PnEstatus         = 0,          
          @w_idEstatus       = 1,          
          @PsMensaje         = Null,          
          @w_fechaAct        = Getdate(),          
          @w_idSession       = Substring(Replace(Cast(newid() As Varchar(100)), '-', ''), 1, 30),          
          @w_fechaProgramada = Case When @PdFechaProgramada Is Null          
                                    Then @w_fechaAct          
                                    Else @PdFechaProgramada          
                               End          
--          
      
   Select @PnEstatus = dbo.Fn_ValidaUsuario(@PnIdUsuarioAct)      
   If @PnEstatus != 0          
      Begin          
         Set @PsMensaje = Dbo.Fn_Busca_MensajeError(@PnEstatus)      
          
         Set Xact_Abort Off          
         Return          
      End          
          
   If Not Exists ( Select Top 1 1          
                   From   dbo.conMotivosCorreoTbl          
                   Where  idMotivo = @PnIdMotivo)      
      Begin          
         Select @PnEstatus = 2007,          
                @PsMensaje = Dbo.Fn_Busca_MensajeError(@PnEstatus)      
          
         Set Xact_Abort Off          
         Return          
      End          
          
   If Not Exists ( Select Top 1 1          
                   From   dbo.catCriteriosTbl          
                   Where  criterio = 'idTipoNotificacion'          
                   And    valor    = @PnIdTipoNotificacion)        
      Begin          
         Select @PnEstatus = 6202,          
                @PsMensaje = Dbo.Fn_Busca_MensajeError(@PnEstatus)      
      
         Set Xact_Abort Off      
         Return      
      End      
      
      Select @PnIdMotivo,   @PnIdTipoNotificacion, @PnIdUsuarioAct,          
             @PsParametros,  @w_fechaProgramada, @PsURL,                @PnIdUsuarioAct,          
             @w_fechaAct,    @w_idSession      
  
   Begin Try      
      Insert Into dbo.conProcesosTbl      
      (idMotivoCorreo,  idTipoNotificacion, idUsuario,      
       parametros,      fechaProgramada,    urlArchivoSalida,   idUsuarioAct,          
       fechaAct,        idSession)      
      Select @PnIdMotivo,   @PnIdTipoNotificacion, @PnIdUsuarioAct,          
             @PsParametros,  @w_fechaProgramada, @PsURL,                @PnIdUsuarioAct,          
             @w_fechaAct,    @w_idSession      
      Set @w_idProceso = @@Identity      
   End Try          
          
   Begin Catch          
      Select  @w_Error      = @@Error,          
              @w_desc_error = Substring (Error_Message(), 1, 230)      
   End   Catch          
      
   If Isnull(@w_Error, 0) <> 0      
      Begin          
         Select @PnEstatus = @w_Error,          
                @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar(10)))) + ' ' + @w_desc_error       
      
         Set Xact_Abort Off          
         Return            
      End        
      
    
   If @PsXML           Is Not Null Or      
      @PsHTML          Is Not Null Or      
      @PsTipo          Is Not Null Or      
      @PsRuta          Is Not Null Or      
      @PsNombreArchivo Is Not Null      
      Begin       
         Begin Try       
            Insert Into dbo.movDatosAdicionalesCorreoTbl      
            (idProceso, XML,        HTML, tipo,       
             ruta,      nombreArchivo)      
            Select @w_idProceso, @PsXML,            @PsHTML, @PsTipo,      
                   @PsRuta,      @PsNombreArchivo      
         End Try          
      
         Begin Catch          
            Select  @w_Error      = @@Error,      
                    @w_desc_error = Substring (Error_Message(), 1, 230)      
         End   Catch          
      
         If Isnull(@w_Error, 0) <> 0          
            Begin          
               Select @PnEstatus = @w_Error,          
                      @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar(10)))) + ' ' + @w_desc_error       
      
               Set Xact_Abort Off          
               Return      
            End      
      
      End      
      
   Select @PsMensaje = Cast(@w_idProceso As Varchar)       
      
   Set Xact_Abort Off      
   Return      
      
End 
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Análiza, Valida y ejecuta Mantenimiento a la BD.',
   @w_procedimiento  Varchar( 100) = 'Spp_MantenimientoBD_1'


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
