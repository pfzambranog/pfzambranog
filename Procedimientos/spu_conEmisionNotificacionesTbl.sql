/*
Declare
   @PnIdMonitor      Smallint  = 4,
   @PnIdOrigen      Smallint  = 2,
   @PnEstatus      Integer  = 0,
   @PsMensaje      Varchar( 250) = ' '
Begin
   Execute dbo.spu_conEmisionNotificacionesTbl @PnIdMonitor = @PnIdMonitor,
              @PnIdOrigen = @PnIdOrigen,
              @PnEstatus = @PnEstatus  Output,
              @PsMensaje = @PsMensaje  Output

   Select @PnEstatus, @PsMensaje

   Return
End
Go

*/

Create Or Alter Procedure dbo.spu_conEmisionNotificacionesTbl
  (@PnIdMonitor      Smallint,
   @PnIdOrigen       Smallint,
   @PnIdEstatus      Tinyint  = 1,
   @PnEstatus        Integer  = 0   Output,
   @PsMensaje        Varchar( 250) = ' ' Output)
As

Declare
   @w_desc_error        Varchar( 250),
   @w_fechaProc         Datetime,
   @w_idEntrega         Bigint,
   @w_idEstatus         Tinyint,
   @w_idMovimiento      Bigint,
   @w_secuencia         Integer,
   @w_notificaciones    Integer,
   @w_registros         Integer,
   @w_Error             Integer,
   @w_linea             Integer,
   @w_minutossDelay     Integer;

Begin
   Set Nocount   On
   Set Xact_Abort  On
   Set Ansi_Nulls  On

   Select @PnEstatus      = 0,
          @PsMensaje      = Char(32),
          @w_fechaProc    = Getdate(),
          @w_secuencia    = 0,
          @w_registros    = 0;

   Select @w_minutossDelay = parametroNumber
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 13;
   If @@Rowcount = 0
      Begin
         Set @w_minutossDelay = 2
      End

   If @PnIdOrigen In (6, 7)
      Begin
         Set Xact_Abort    Off
         Return
      End

   If Not Exists ( Select Top 1 1
                   From   dbo.conEmisionNotificacionesTbl  a With (Nolock)
                   Join   dbo.catRelMonitorPushAplicacionTbl b With (Nolock)
                   On     a.idAplicacion = b.idAplicacion
                   And    a.idOrigen     = @PnIdOrigen
                   And    b.idMonitor    = @PnIdMonitor
                   And   Datediff(mi, a.fechaEnvioNotificacion, Getdate())  >= @w_minutossDelay
                   Where  a.idEstatus  In (2, 3))
   Begin
      Set Xact_Abort    Off
      Return
   End

   Begin Try
      Update dbo.conEmisionNotificacionesTbl
      Set    idEstatus    = 1,
             Observaciones   = 'Registro Reversado',
             fechaEnvioNotificacion = Null
      From   dbo.conEmisionNotificacionesTbl a
      Join   dbo.catRelMonitorPushAplicacionTbl b
      On     b.idAplicacion    = a.idAplicacion
      And    b.idMonitor       = @PnIdMonitor
      Where  a.idEstatus      In (2, 3)
      And    a.idOrigen       = @PnIdOrigen
      And    Datediff(mi, fechaEnvioNotificacion, Getdate())  >= @w_minutossDelay;

      Set @w_registros = @@Rowcount

   End Try

   Begin Catch
      Select @w_error       = Error_Number(),
             @w_desc_error  = Substring(Error_Message(), 1, 220),
             @w_linea       = error_line();
   End Catch

   If IsNull(@w_error, 0) <> 0
      Begin
         Select @PnEstatus = @w_error,
                @PsMensaje = Concat('Error: ', @w_error, ' ', @w_desc_error, ' En Linea ', @w_linea);

         Set Xact_Abort   Off
         Return
      End

   Begin Try
   Insert Into dbo.movLogMonitoresPushTbl
   (idMonitor, idOrigen, fechaInicio, registros,
    error,   comentarios)
   Select @PnIdMonitor, @PnIdOrigen, Getdate(), @w_registros,
    0 error,    'Registros Reversados'
   End Try

   Begin Catch
  Select @w_error = Error_Number(),
   @w_desc_error  = Error_Message()
   End Catch

   If IsNull(@w_error, 0) <> 0
      Begin
         Select @PnEstatus = @w_error,
                @PsMensaje = @w_desc_error,
                @w_linea   = error_line();

      End

   Set Xact_Abort  Off
   Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Procedimiento que Actualiza la tabla conEmisionNotificacionesTbl.',
   @w_procedimiento  Varchar( 100) = 'spu_conEmisionNotificacionesTbl'


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

