Use SCMBD
Go

/*
Declare
   @w_idProceso           Integer      = 0,
   @PnEstatus             Integer      = 0,  
   @PsMensaje             Varchar(250) = Null;

Begin
   Select @w_idProceso = Max(idProceso)
   From   SMBDTI.dbo.logServiciosNotificacionesPushTbl

   Execute Spp_ValidaServicioNotPush @PnEstatus = @PnEstatus Output,
                                     @PsMensaje = @PsMensaje Output

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

   Select *
   From   SMBDTI.dbo.logServiciosNotificacionesPushTbl
   Where  idProceso > Isnull(@w_idProceso, 0)

   Return

End
Go 
                
*/

Create Or Alter Procedure Spp_ValidaServicioNotPush
  (@PnEstatus             Integer      = 0     Output,  
   @PsMensaje             Varchar(250) = Null  Output)                
As

Declare
   @w_error             Integer,
   @w_desc_error        Varchar(250),
   @w_usuario           Varchar(Max),
   @w_baseDatos         Sysname,
   @w_sql               NVarchar(1500),
   @w_param             NVarchar( 750),
   @w_comilla           Char(1),
   @w_fechaInicio       Datetime,
   @w_fechaComp         Date,
   @w_servidor          Sysname,
   @w_minutos           Integer,
   @w_registros         Integer,
   @w_idProceso         Integer,
   @w_idUsuarioAct      Integer,
   @w_idEstatus         Tinyint;

Begin
/*

Objetivo:    Proceso de Validación del Servicio de Notificaciones Push.
Programador: Pedro Felipe Zambrano
Fecha:       06/10/2025

*/
                   
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

   Select @w_idEstatus = state
   From   sys.databases
   Where  name       = 'SCMBD'
   If @@Rowcount = 0
      Begin
         Set Xact_Abort    Off
         Return
      End

   If @w_idEstatus != 0
      Begin
         Set Xact_Abort    Off
         Return
      End

   If Not Exists (Select Top 1 1 
                  From   dbo.catControlProcesosTbl
                  Where  idProceso         = 16
                  And    idEstatus         = 1)
      Begin
         Set Xact_Abort    Off
         Return
      End

   Select @w_minutos = ParametroNumber
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 15
   
   Select @w_usuario = parametroChar        
   From   dbo.conParametrosGralesTbl        
   Where  idParametroGral = 9       
   
   Select @w_sql   = 'Select @o_usuario = dbo.Fn_Desencripta_cadena(' + @w_usuario + ') ',        
          @w_param = '@o_usuario Varchar(Max) Output '        
   
   Execute Sp_ExecuteSQL @w_sql, @w_param, @o_usuario = @w_usuario Output        
   
   Set @w_idUsuarioAct = Cast(@w_usuario As Integer) 

   Begin Try 
      Update dbo.catControlProcesosTbl
      Set    ultFechaEjecucion = Getdate()
      Where  idProceso         = 16;
   End Try

   Begin Catch    
      Select  @w_Error      = @@Error,    
              @w_desc_error = Substring (Error_Message(), 1, 230)
  
   End   Catch    
 
   If IsNull(@w_Error, 0) <> 0    
      Begin    
         Select @PnEstatus = @w_Error,    
                @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error  

      End

   Select @w_idEstatus = state
   From   sys.databases
   Where  name       = Db_name()
   If @@Rowcount = 0
      Begin
         Set Xact_Abort    Off
         Return
      End

   If @w_idEstatus != 0
      Begin
         Set Xact_Abort    Off
         Return
      End

   Create Table #TempMotivosCorreos
   (idAplicacion     Integer      Not Null,
    idMotivoCorreo   Integer      Not Null,
    fechaProgramada  Datetime         Null,
    actividad        Varchar(100)     Null
    Primary Key (idAplicacion, idMotivoCorreo))
    
   Insert Into #TempMotivosCorreos
   Select a.idAplicacion, a.idMotivoCorreo, Min(fechaProgramada),
          Concat('Análisis de Notificaciones Push Aplicación',    Char(32), a.idAplicacion, 
                                       Char(32), 'Motivo Correo', Char(32), a.idMotivoCorreo)
   From   dbo.conEmisionNotificacionesTbl a
   Join   dbo.conProcesosTbl b
   On     b.idSession           = a.idSession
   And    b.idTipoNotificacion != 1
   Where  a.idEstatus          In (1, 2)
   Group  By a.idAplicacion, a.idMotivoCorreo
   Having DateDiff(mi, min(fechaProgramada), Getdate()) >= @w_minutos
   If @@Rowcount = 0
      Begin 
         Set Xact_Abort    Off
         Return
      End

   Insert Into dbo.logServiciosNotificacionesPushTbl
   (servidor, idMonitor, actividad, fechaInicio, 
    error,    mensajeError)
   Select @w_servidor,    idMonitor,  actividad,  fechaProgramada,  
          a.idAplicacion, actividad
   From   #TempMotivosCorreos a
   Join   dbo.catRelMonitorPushAplicacionTbl b 
   On     b.idAplicacion = a.idAplicacion
   Where  Not Exists     ( Select Top 1 1
                           From   dbo.logServiciosNotificacionesPushTbl
                           Where  servidor                  = @w_servidor
                           And    idMonitor                 = b.idMonitor
                           And    DateDiff(mi, fechaTermino, Getdate()) <= @w_minutos
                           And    actividad                 = a.actividad)

   Set Xact_Abort    Off
   Return
End 
Go

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Validación del Servicio de Notificaciones Push.',
   @w_procedimiento  NVarchar(250) = 'Spp_ValidaServicioNotPush';

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

  
