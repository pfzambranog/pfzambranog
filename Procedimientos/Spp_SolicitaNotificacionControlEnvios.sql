Use SCMBD
Go

/*

Declare
   @PdFechaProc       Date         = Null,
   @PnIdAccion        Tinyint      = 1,
   @PnTipoConsulta    Tinyint      = 1,
   @PnEstatus         Integer      = 0,
   @PsMensaje         Varchar(250) = Null
Begin
   Execute dbo.Spp_SolicitaNotificacionControlEnvios @PdFechaProc    = @PdFechaProc,
                                                     @PnIdAccion     = @PnIdAccion,
                                                     @PnTipoConsulta = @PnTipoConsulta,
                                                     @PnEstatus      = @PnEstatus    Output,
                                                     @PsMensaje      = @PsMensaje    Output;
  If @PnEstatus != 0
     Begin
        Select @PnEstatus, @PsMensaje
     End

  Return;
End
Go
*/

Create or Alter Procedure dbo.Spp_SolicitaNotificacionControlEnvios
  (@PdFechaProc       Date         = Null,
   @PnIdAccion        Tinyint      = 1,                -- 1 = Solicita Correo,    2 = Emite Reporte
   @PnTipoConsulta    Tinyint      = 1,                -- 1 = Consulta Acumulada, 2 = Consulta del Día
   @PnEstatus         Integer      = 0    Output,
   @PsMensaje         Varchar(250) = Null Output)
As

Declare
   @w_error             Integer,
   @w_desc_error        Varchar ( 250),
   @w_registros         Integer,
   @w_secuencia         Integer,
   @w_idAplicacion      Integer,
   @w_cantidad          Integer,
   @w_tope              Integer,
   @w_topeDiario        Integer,
   @w_fechaProc         Date,
   @w_fechaInicio       Date,
   @w_diaInicioCorte    Tinyint,
   @w_sql               Varchar(4000),
   @w_comilla           Char(1);

Declare
   @w_tablaResultado    Table
   (idAplicacion   Smallint     Not Null Primary Key,
    cantidad       Integer      Not Null);

Begin

/*

Objetivo:    Valida la cantidad de Correos enviados en el día y el período, solicita correo y emite reporte.
Programador: Pedro Felipe Zambrano
Fecha:       01/12/2022

*/

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

--
-- Incializamos Variables
--

   Select @PnEstatus        = 0,
          @PsMensaje        = Null,
          @w_secuencia      = 0,
          @w_comilla        = Char(39),
          @w_fechaProc      = Isnull(@PdFechaProc, Getdate());

--
-- Incializamos Validaciones
--

   If Not Exists ( Select Top 1 1
                   From   sys.databases a
                   Where  state_desc = 'ONLINE'
                   And    name       = 'SCMBD')
      Begin
         Set Xact_Abort    Off
         Return
      End

--
-- Búsqueda de Parámetros.
--

   Select @w_diaInicioCorte = parametroNumber
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral= 21;
   If @@Rowcount = 0
      Begin
         Set @w_diaInicioCorte = 1
      End

   Set @w_fechaInicio = Convert(Date, Concat(Format(@w_diaInicioCorte, '00'), Substring(Convert(Char(10), @w_fechaProc, 103), 3, 8)), 103)

   If @w_fechaInicio > @w_fechaProc
      Begin
         Set @w_fechaInicio = DateAdd(mm, -1, @w_fechaInicio)
      End

   Select @w_tope = parametroNumber
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 20

   Select @w_topeDiario = @w_tope * parametroNumber / 100
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 22

   Set @w_tope = @w_tope * 0.9

   Set @w_sql = 'Select a.idAplicacion, Count(1)
                 From   dbo.movEnvioCorreosTbl a
                 Join   dbo.conProcesosTbl b
                 On     b.idProceso = a.idProceso 
                 Where  1  = 1
                 And    Cast(fechaEnvio As Date)'
                
   If @PnTipoConsulta = 1
      Begin
         Set @w_sql = @w_sql + ' Between ' + @w_comilla + Cast(@w_fechaInicio As Varchar) + @w_comilla 
                             + ' And '     + @w_comilla + Cast(@w_fechaProc   As Varchar) + @w_comilla
      End 
   Else
      Begin
         Set @w_sql = @w_sql + ' = ' + @w_comilla + Cast(@w_fechaProc As Varchar) + @w_comilla
      End
      
   Set @w_sql = @w_sql + ' Group  By a.idAplicacion
                           Order  By 1'
  Begin Try
     Insert Into @w_tablaResultado
     (idAplicacion, cantidad)
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

   Select @w_cantidad = Sum(cantidad)
   From @w_tablaResultado

   If @w_cantidad >= @w_tope
      Begin
         Select a.idAplicacion, b.descripcion aplicacion, Sum(cantidad)
         From   @w_tablaResultado a
         Join   scsti.dbo.segAplicacionesTbl b
         On     b.idAplicacion = a.idAplicacion
         Group  By a.idAplicacion, b.descripcion
      End

   Set Xact_Abort Off
   Return

End
Go