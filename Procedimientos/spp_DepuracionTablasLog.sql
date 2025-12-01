
/*
Declare
   @PnEstatus                 Integer        = 0,
   @PsMensaje                 Varchar (250)  = ' '
Begin
   Execute dbo.spp_DepuracionTablasLog @PnEstatus = @PnEstatus Output,
                                       @PsMensaje = @PsMensaje Output;

   Select @PnEstatus, @PsMensaje
   Return

End

*/


Create Or Alter Procedure dbo.spp_DepuracionTablasLog
  (@PnEstatus                 Integer        = 0   Output,
   @PsMensaje                 Varchar (250)  = ' ' Output)
As

Declare
   @w_desc_error              Varchar( 250),
   @w_sql                     Varchar( Max),
   @w_fecha                   Date,
   @w_Error                   Integer,
   @w_dias                    Integer,
   @w_linea                   Integer,
   @w_tabla                   Sysname,
   @w_comilla                 Char(1);

Begin
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    On

   Select @PnEstatus         = 0,
          @PsMensaje         = '',
          @w_comilla         = Char(39);

   Select @w_dias = parametroNumber
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 17
   Set    @w_dias = Isnull(@w_dias, 90) * -1


   Set @w_fecha  =  DateAdd(dd, @w_dias, Getdate())


   If Exists (Select Top 1 1
              From   sysobjects
              Where  Uid  = 1
              And    Type = 'U'
              And    Name = 'movDatosAdicionalesCorreoTbl')
      Begin
         Begin Try
            Delete dbo.movDatosAdicionalesCorreoTbl
            Where  idProceso In (Select idProceso
                                 From   dbo.conProcesosTbl
                                 Where  Cast(fechaProgramada As Date) <  @w_fecha );

         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230),
                    @w_linea      = error_line();

         End   Catch

         If Isnull(@w_Error, 0) <> 0
            Begin
               Select @PnEstatus = @w_Error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ',  @w_desc_error, ' En Línea ', @w_linea);

               Insert Into dbo.tmpLogError
               (error, descripcion)
               Select @w_Error, Concat(@w_desc_error, ' Tabla: ', 'movDatosAdicionalesCorreoTbl', ' Línea ', @w_linea);

               Set Xact_Abort Off
               Return
            End
      End

    -- conEmisionNotificacionesTbl*

   If Exists (Select Top 1 1
              From   sysobjects
              Where  Uid  = 1
              And    Type = 'U'
              And    Name = 'conEmisionNotificacionesTbl')
      Begin
         Begin Try
            Delete dbo.conEmisionNotificacionesTbl
            Where  Cast(fechaEnvioNotificacion As Date) < @w_fecha
         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230),
                    @w_linea      = error_line();

          End   Catch

          If Isnull(@w_Error, 0) <> 0
             Begin
               Select @PnEstatus = @w_Error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ',  @w_desc_error, ' En Línea ', @w_linea);

               Insert Into dbo.tmpLogError
               (error, descripcion)
               Select @w_Error, Concat(@w_desc_error, ' Tabla: ', 'conEmisionNotificacionesTbl', ' Línea ', @w_linea);

               Set Xact_Abort Off
               Return
            End

       End

   -- movProcesosDetELTbl

   If Exists (Select Top 1 1
              From   sysobjects
              Where  Uid  = 1
              And    Type = 'U'
              And    Name = 'movProcesosDetELTbl')
      Begin
         Begin Try
            Delete dbo.movProcesosDetELTbl
            Where  Cast(fechaInicio As Date) < @w_fecha
         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230),
                    @w_linea      = error_line();

          End   Catch

          If Isnull(@w_Error, 0) <> 0
             Begin
               Select @PnEstatus = @w_Error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ',  @w_desc_error, ' En Línea ', @w_linea);

               Insert Into dbo.tmpLogError
               (error, descripcion)
               Select @w_Error, Concat(@w_desc_error, ' Tabla: ', 'movProcesosDetELTbl', ' Línea ', @w_linea);

               Set Xact_Abort Off
               Return
            End

       End

   -- conProcesosTbl*
   If Exists (Select Top 1 1
              From   sysobjects
              Where  Uid  = 1
              And    Type = 'U'
              And    Name = 'conProcesosTbl')
       Begin
          Begin Try
             Delete dbo.conProcesosTbl
             Where  Cast(fechaProgramada As Date) < @w_fecha
          End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230),
                    @w_linea      = error_line();

          End   Catch

          If Isnull(@w_Error, 0) <> 0
             Begin
               Select @PnEstatus = @w_Error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ',  @w_desc_error, ' En Línea ', @w_linea);

               Insert Into dbo.tmpLogError
               (error, descripcion)
               Select @w_Error, Concat(@w_desc_error, ' Tabla: ', 'conProcesosTbl', ' Línea ', @w_linea);

               Set Xact_Abort Off
               Return
            End
       End

   -- movProcesosELTbl

   If Exists (Select Top 1 1
              From   dbo.sysobjects
              Where  Uid   = 1
              And    Type  = 'U'
              And    name = 'movProcesosELTbl')
      Begin
         Begin Try
            Delete dbo.movProcesosELTbl
            Where  Cast(fechaInicio As Date) < @w_fecha
         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230),
                    @w_linea      = error_line();

          End   Catch

          If Isnull(@w_Error, 0) <> 0
             Begin
               Select @PnEstatus = @w_Error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ',  @w_desc_error, ' En Línea ', @w_linea);

               Insert Into dbo.tmpLogError
               (error, descripcion)
               Select @w_Error, Concat(@w_desc_error, ' Tabla: ', 'movProcesosELTbl', ' Línea ', @w_linea);

               Set Xact_Abort Off
               Return
            End
       End

   -- movEnvioCorreosTbl

   If Exists (Select Top 1 1
              From   sysobjects
              Where  Uid  = 1
              And    Type = 'U'
              And    Name = 'movEnvioCorreosTbl')
      Begin
         Begin Try
            Delete dbo.movEnvioCorreosTbl
            Where  Cast(fechaEnvio As Date) < @w_fecha
         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230),
                    @w_linea      = error_line();

          End   Catch

          If Isnull(@w_Error, 0) <> 0
             Begin
               Select @PnEstatus = @w_Error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ',  @w_desc_error, ' En Línea ', @w_linea);

               Insert Into dbo.tmpLogError
               (error, descripcion)
               Select @w_Error, Concat(@w_desc_error, ' Tabla: ', 'movEnvioCorreosTbl', ' Línea ', @w_linea);

               Set Xact_Abort Off
               Return
            End
       End


   -- movEntregaNotificacionesTb

   Set @w_tabla = 'movEntregaNotificacionesTb';

   If Exists (Select Top 1 1
              From   dbo.sysobjects
              Where  Uid   = 1
              And    Type  = 'U'
              And    name  = @w_tabla)
       Begin
          Set @w_sql = Concat('Delete dbo.', @w_tabla,
                             ' Where  Cast(fechaAct As Date)  < ', @w_comilla, @w_fecha, @w_comilla)
          Begin Try
             Execute (@w_sql)
          End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230),
                    @w_linea      = error_line();

          End   Catch

          If Isnull(@w_Error, 0) <> 0
             Begin
               Select @PnEstatus = @w_Error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ',  @w_desc_error, ' En Línea ', @w_linea);

               Insert Into dbo.tmpLogError
               (error, descripcion)
               Select @w_Error, Concat(@w_desc_error, ' Tabla: ', @w_tabla, ' Línea ', @w_linea);

               Set Xact_Abort Off
               Return
            End
       End

   -- MovRechazosCorreoTbl

   Set @w_tabla = 'movTempCorreosReportadosTbl'

   If Exists (Select Top 1 1
              From   dbo.sysobjects
              Where  Uid   = 1
              And    Type  = 'U'
              And    name  = @w_tabla)
       Begin
          Set @w_sql = Concat('Delete dbo.', @w_tabla,
                             ' Where  Cast(fechaAct As Date)  < ', @w_comilla, @w_fecha, @w_comilla)
          Begin Try
             Execute (@w_sql)
          End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230),
                    @w_linea      = error_line();

          End   Catch

          If Isnull(@w_Error, 0) <> 0
             Begin
               Select @PnEstatus = @w_Error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ',  @w_desc_error, ' En Línea ', @w_linea);

               Insert Into dbo.tmpLogError
               (error, descripcion)
               Select @w_Error, Concat(@w_desc_error, ' Tabla: ', @w_tabla, ' Línea ', @w_linea);

               Set Xact_Abort Off
               Return
            End
       End

   -- movTempCorreosReportadosTbl*

   Set @w_tabla = 'movTempCorreosReportadosTbl'

   If Exists (Select Top 1 1
              From   dbo.sysobjects
              Where  Uid   = 1
              And    Type  = 'U'
              And    name  = @w_tabla)
       Begin
          Set @w_sql = Concat('Delete dbo.', @w_tabla,
                             ' Where  Cast(fechaAct As Date)  < ', @w_comilla, @w_fecha, @w_comilla)
          Begin Try
             Execute (@w_sql)
          End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230),
                    @w_linea      = error_line();

          End   Catch

          If Isnull(@w_Error, 0) <> 0
             Begin
               Select @PnEstatus = @w_Error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ',  @w_desc_error, ' En Línea ', @w_linea);

               Insert Into dbo.tmpLogError
               (error, descripcion)
               Select @w_Error, Concat(@w_desc_error, ' Tabla: ', @w_tabla, ' Línea ', @w_linea);

               Set Xact_Abort Off
               Return
            End
       End

   Set @w_fecha  =  DateAdd(dd, 1, @w_fecha)

   Set @w_sql = Concat('msdb.dbo.sysmail_delete_mailitems_sp  @sent_before = ', @w_comilla, @w_fecha, @w_comilla)

   Begin Try
      Execute (@w_sql)
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230),
              @w_linea      = error_line();

    End   Catch

    If Isnull(@w_Error, 0) <> 0
       Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ',  @w_desc_error, ' En Línea ', @w_linea);

         Insert Into dbo.tmpLogError
         (error, descripcion)
         Select @w_Error, Concat(@w_desc_error, ' Proc: sysmail_delete_mailitems_sp. Línea ', @w_linea);

         Set Xact_Abort Off
         Return
      End

   Select @w_dias = parametroNumber
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 16;

   Set    @w_dias = Isnull(@w_dias, 30) * -1


   Set @w_fecha  =  DateAdd(dd, @w_dias, Getdate())

    -- movLogMonitoresPushTbl

   If Exists (Select Top 1 1
              From   dbo.sysobjects
              Where  Uid   = 1
              And    Type  = 'U'
              And    name = 'movLogMonitoresPushTbl')
       Begin
          Begin Try
             Delete dbo.movLogMonitoresPushTbl
             Where  Cast(fechaInicio As Date) < @w_fecha
          End Try

          Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230),
                    @w_linea      = error_line();

          End   Catch

          If Isnull(@w_Error, 0) <> 0
             Begin
               Select @PnEstatus = @w_Error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ',  @w_desc_error, ' En Línea ', @w_linea);

               Insert Into dbo.tmpLogError
               (error, descripcion)
               Select @w_Error, Concat(@w_desc_error, ' Tabla: movLogMonitoresPushTbl. Línea ', @w_linea);

               Set Xact_Abort Off
               Return
            End


       End

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Procedimiento que Depura tablas de movimientos y logs.',
   @w_procedimiento  Varchar( 100) = 'spp_DepuracionTablasLog'


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

