Use SCMBD
Go

/*
Declare
   @w_idProceso           Integer      = 0,
   @PnEstatus             Integer      = 0,
   @PsMensaje             Varchar(250) = Null;

Begin
   Select @w_idProceso = Max(idProceso)
   From   SMBDTI.dbo.logServiciosNotificaCorreosTbl

   Execute Spp_ValidaServicioCorreos @PnEstatus = @PnEstatus Output,
                                     @PsMensaje = @PsMensaje Output

   Select @PnEstatus, @PsMensaje

   Select *
   From   SMBDTI.dbo.logServiciosNotificaCorreosTbl
   Where  idProceso > Isnull(@w_idProceso, 0)

   Return

End
Go

*/

Create Or Alter Procedure Spp_ValidaServicioCorreos
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
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off
/*

Objetivo:    Proceso de Validación del Servicio de Correos.
Programador: Pedro Felipe Zambrano
Fecha:       06/05/2022

*/


--
-- Incializamos Variables
--

   Select @PnEstatus        = 0,
          @PsMensaje        = Null,
          @w_comilla        = Char(39),
          @w_minutos        = 10,
          @w_servidor       = @@ServerName;

   If Not Exists (Select Top 1 1
                  From   catControlProcesosTbl
                  Where  idProceso         = 15
                  And    idEstatus         = 1)
      Begin
         Set Xact_Abort    Off
         Return
      End

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

   Select @w_minutos = ParametroNumber
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 15

   Select @w_usuario = parametroChar
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 9

      Select @w_sql      = 'Select @o_cadena = idUsuarioAct
                            From Openquery(SCMBD, ''Select dbo.Fn_Desencripta_cadena(' + @w_usuario + ') idUsuarioAct '')',
             @w_param    = '@o_cadena Varchar(Max) Output '

   Execute Sp_ExecuteSQL @w_sql, @w_param, @o_cadena = @w_usuario Output

   Set @w_idUsuarioAct = Cast(@w_usuario As Integer)

   Begin Try
      Update dbo.catControlProcesosTbl
      Set    ultFechaEjecucion = Getdate()
      Where  idProceso         = 15;
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

   Create Table #TempMotivosCorreos
   (profile_id       Integer       Not Null,
    descripcion      NVarchar(510) Not Null,
    fechaProgramada  Datetime          Null)

   Insert Into #TempMotivosCorreos
   Select a.profile_id,
          b.description,
          Min(send_request_date)
   From   msdb.dbo.sysmail_allitems a
   Join   msdb.dbo.sysmail_profile b
   On     b.profile_id = a.profile_id
   Where  sent_status != 'sent'
   Group  By a.profile_id, b.description
   Having DateDiff(mi, Min(send_request_date), Getdate()) >= @w_minutos
   If @@Rowcount = 0
      Begin
         Set Xact_Abort    Off
         Return
      End

   Insert Into dbo.logServiciosNotificaCorreosTbl
   (servidor, idPerfilCorreo, descripcion, fechaInicio,  error, mensajeError)
   Select @w_servidor,   profile_id,  descripcion, fechaProgramada,
          profile_id,   'Problemas con Emisión de Correos'
   From   #TempMotivosCorreos a
   Where  Not Exists     ( Select Top 1 1
                           From   dbo.logServiciosNotificaCorreosTbl
                           Where  servidor                  = @w_servidor
                           And    idPerfilCorreo            = a.profile_id
                           And    descripcion               = a.descripcion
                           And    informado                 = 0
                           And    Cast(fechaInicio As Date) = Cast(a.fechaProgramada As Date)
                           And    DateDiff(mi, fechaTermino, Getdate()) > @w_minutos)

   Set @PsMensaje = Cast(@@Rowcount As Varchar) + ' Registros Nuevos'

   Set Xact_Abort    Off
   Return
End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Proceso de Validación Estatus del Servicio de Correos.',
   @w_procedimiento  Varchar( 100) = 'Spp_ValidaServicioCorreos'


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

