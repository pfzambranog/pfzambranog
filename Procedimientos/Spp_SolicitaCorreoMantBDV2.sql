Use SCMBD
Go


/*
Declare
   @PsIdProceso           Varchar(1000) = '11, 12, 14,15, 16',
   @PnEstatus             Integer       = 0,
   @PsMensaje             Varchar(250)  = Null;

Begin
   Execute Spp_SolicitaCorreoMantBDV2 @PsIdProceso    = @PsIdProceso,
                                      @PnEstatus      = @PnEstatus Output,
                                      @PsMensaje      = @PsMensaje Output

   Select @PnEstatus, @PsMensaje

   Return

End
Go

*/

Create  Or Alter Procedure Spp_SolicitaCorreoMantBDV2
  (@PsIdProceso           Varchar(1000),
   @PnEstatus             Integer        = 0     Output,
   @PsMensaje             Varchar(250)   = Null  Output)
As

Declare
   @w_error                 Integer,
   @w_desc_error            Varchar ( 250),
   @w_usuario               Varchar ( Max),
   @w_sql                   NVarchar(1500),
   @w_param                 Nvarchar( 750),
   @w_fechaAct              Datetime,
   @w_procedimiento         Sysname,
   @w_existe                Tinyint,
   @w_registros             Integer,
   @w_registros2            Integer,
   @w_linea                 Integer,
   @w_secuencia             Integer,
   @w_comilla               Char(1),
--
   @w_idProceso             Integer,
   @w_idError               Integer,
   @w_idUsuarioAct          Integer;

Begin
/*

Objetivo:    Genera la Solicitud de Notificación de Monitoreo de Base de Datos (link Server, Jobs).
Programador: Pedro Felipe Zambrano
Fecha:       02/08/2025

*/

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

--
-- Incializamos Variables
--

   Select @PnEstatus            = 0,
          @PsMensaje            = '',
          @w_registros          = 0,
          @w_registros2         = 0,
          @w_secuencia          = 0,
          @w_fechaAct           = Getdate(),
          @w_comilla            = Char(39);


--
-- Busqueda de Parámetros y Validación
--

   Select @w_usuario = parametroChar
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 8
   If @@Rowcount = 0
      Begin
         Set @w_usuario = dbo.Fn_Encripta_cadena(1)
      End

   Select @w_sql      = 'Select @o_cadena = dbo.Fn_Desencripta_cadena(' + @w_usuario + ')  ',
          @w_param    = '@o_cadena Varchar(Max) Output '

   Execute Sp_ExecuteSQL @w_sql, @w_param, @o_cadena = @w_usuario Output

   Set @w_idUsuarioAct = Cast(@w_usuario As Integer)

   Set @PnEstatus = dbo.Fn_ValidaUsuario (18)

   If @PnEstatus != 0
      Begin
         Set @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort Off
         Return

      End

--
-- Generación de Tabla Temporal
--


   Create Table #TempProcesos
   (secuencia     Integer       Not Null Identity(1, 1) Primary Key,
    procedimiento Sysname       Not Null)

--
-- Inicio de Proceso
--

   Set @w_sql = 'Select Procedimiento
                 From   dbo.catControlProcesosTbl
                 Where  idProceso In (' + @PsIdProceso + ')
                 And    idEstatus = 1';

   Begin Try
      Insert Into #TempProcesos
      (procedimiento)
     Execute(@w_sql)
     Set @w_registros2 = @@Rowcount
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230),
              @w_linea      = error_line()
   End   Catch

   If Isnull(@w_Error, 0)  <> 0
      Begin
         Select @PnEstatus  = @w_Error,
                @PsMensaje  = Concat('Error.: ', @w_Error, ' ', + @w_desc_error,
                                     ', en linea ', @w_linea);

         Set Xact_Abort Off
         Return
      End

   If @w_registros2 = 0
      Begin
         Select @PnEstatus = 3000,
                @PsMensaje = Dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort    Off
         Return
      End

   While @w_secuencia < @w_registros2
   Begin
      Set @w_secuencia = @w_secuencia + 1;

      Select @w_procedimiento        = procedimiento
      From   #TempProcesos
      Where  secuencia = @w_secuencia
      If @@Rowcount = 0
         Begin
            Break
         End

      Execute @w_procedimiento @PnEstatus =  @PnEstatus Output, @PsMensaje = @PsMensaje Output

      If @PnEstatus != 0
         Begin
            Select  @PnEstatus, @PsMensaje
         End

   End

   Set Xact_Abort Off
   Return

End
Go


--
-- Comentarios.
--

Declare
   @w_valor          Nvarchar(250) = 'Genera la Solicitud de Notificación de Monitoreo de Base de Datos (link Server, Jobs).',
   @w_procedimiento  NVarchar(250) = 'Spp_SolicitaCorreoMantBDV2';

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

