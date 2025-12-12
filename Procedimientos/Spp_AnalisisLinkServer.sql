Use SCMBD
Go


/*
Declare
   @PnEstatus      Integer      = Null,
   @PsMensaje      Varchar(250) = Null;

Begin

   Execute dbo.Spp_AnalisisLinkServer @PnEstatus = @PnEstatus Output,
                                      @PsMensaje = @PsMensaje Output;

   If @PnEstatus != 0
      Begin
         Select @PnEstatus As Estatus, @PsMensaje As Mensaje
      End

   Return
End
Go

*/

Create Or Alter Procedure dbo.Spp_AnalisisLinkServer
  (@PnEstatus               Integer      = Null Output,
   @PsMensaje               Varchar(250) = Null Output)
As

Declare
   @w_DbLink                Sysname,
   @w_baseDatos             Sysname,
   @w_sql                   Nvarchar(1500),
   @w_param                 Nvarchar( 750),
   @w_error                 Integer,
   @w_desc_error            Varchar(  250),
   @w_registros             Integer,
   @w_insert                Integer,
   @w_minutosEspera         Integer,
   @w_salida                Integer,
   @w_idProceso             Integer,
   @w_secuencia             Integer,
   @w_idMotivoCorreo        Integer,
   @w_idUsuarioAct          Integer,
   @w_linea                 Integer,
   @w_tabla                 Sysname,
   @w_tablaLog              Sysname,
   @w_dbname                Sysname,
   @w_instancia             Sysname,
   @w_base                  Sysname,
   @w_objeto                Sysname,
   @w_periodicidad          Varchar(   60),
   @w_server                Varchar(  100),
   @w_usuario               Varchar(  Max),
   @w_idAplicacion          Smallint,
   @w_idTipoNotificacion    Tinyint,
   @w_grupoCorreo           Varchar(   20),
   @w_ambiente              Varchar(  250),
   @w_incidencia            Varchar(  850),
   @w_parametros            Varchar(  Max),
   @w_proceso               Varchar(  100),
   @w_ip                    Varchar(   30),
   @w_query                 Varchar( 1000),
   @w_fechaAct              Datetime,
   @w_idEstatus             Tinyint;

Begin
/*

Objetivo:    Análiza y Valida los Link Server.
Programador: Pedro Felipe Zambrano
Fecha:       05/05/2025


*/

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    On

   Select @PnEstatus            = 0,
          @w_registros          = 0,
          @w_secuencia          = 0,
          @w_insert             = 0,
          @PsMensaje            = Null,
          @w_tabla              = 'sysobjects',
          @w_baseDatos          = 'tempdb',
          @w_server             = @@ServerName,
          @w_instancia          = @@servicename,
          @w_idMotivoCorreo     = 108,
          @w_idAplicacion       = 27,
          @w_tablaLog           = 'logAnalisisLSTbl',
          @w_fechaAct           = Getdate(),
          @w_dbname             = Db_name(),
          @w_ip                 = dbo.Fn_BuscaDireccionIP();

   Select @w_ip = Replace(@w_ip, '(', ''),
          @w_ip = Replace(@w_ip, ')', '');

   If @w_server like '%'+ Char(92) + '%'
      Begin
         Set @w_server = dbo.Fn_splitStringColumna(@w_server, Char(92), 1)
      End

--
-- Búsqueda de Parámetros.
--

   Select @w_ambiente = Upper(parametroChar)
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 24
   If @@Rowcount = 0
      Begin
         Set @w_ambiente = ''
      End

   Select @w_usuario = parametroChar
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 8

   Select @w_sql   = 'Select @o_usuario = dbo.Fn_Desencripta_cadena(' + @w_usuario + ') ',
          @w_param = '@o_usuario Varchar(Max) Output '

   Execute Sp_ExecuteSQL @w_sql, @w_param, @o_usuario = @w_usuario Output

   Set @w_idUsuarioAct = Cast(@w_usuario As Smallint)

   Select @w_minutosEspera = ParametroNumber
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 15

   Select @w_grupoCorreo        = codigoGrupoCorreo,
          @w_idTipoNotificacion = idTipoNotificacion,
          @w_tablalOG           = tablaLog,
          @w_proceso            = descripcion,
          @w_periodicidad       = dbo.Fn_splitStringColumna (Trim(periodicidad), Char(32), 1),
          @w_idEstatus          = idEstatus
   From   dbo.catControlProcesosTbl
   Where  idProceso = 11
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 3000,
                @PsMensaje = Dbo.Fn_Busca_MensajeError(@PnEstatus)

         Goto Salida
      End

   If @w_idEstatus != 1
      Begin
         Select @PnEstatus = 3006,
                @PsMensaje = Dbo.Fn_Busca_MensajeError(@PnEstatus)

         Goto Salida
      End

   If Isnumeric(@w_periodicidad) = 1
      Begin
         Set @w_minutosEspera = Isnull(@w_periodicidad, @w_minutosEspera);
      End

--
-- Creación de Tablas Temporales.
--

   Create Table #logAnalisisLSTbl
   (secuencia     Integer       Not Null   Identity(1, 1) Primary Key,
    servidor      Sysname       Not Null,
    linkServer    Sysname       Not Null,
    actividad     Varchar(Max)  Not Null,
    fechaInicio   DateTime      Not Null   Default Getdate(),
    fechaTermino  Datetime          Null,
    error         Integer       Not Null   Default 0,
    mensajeError  Varchar(250)  Not Null   Default '',
    informado     Bit           Not Null   Default 0)

--
-- Inicio Proceso
--

   Insert Into #logAnalisisLSTbl
   (servidor, linkServer, actividad)
   Select  a.data_source, name, 'ANALISIS LINKED SERVERS:  ' + name
   From   sys.servers       a
   Join   sys.linked_logins b
   On     a.server_id  = b.server_id
   Where  a.server_id <> 0
   And    Provider  Like 'SQLNCLI%'
   Order by 1, 2;

   Set @w_registros = @@Identity

   If @w_registros = 0
      Begin
         Select @PnEstatus = 98,
                @PsMensaje = Dbo.Fn_Busca_MensajeError(@PnEstatus)

         Goto Salida
      End


   Select @w_idProceso = Max(idProceso)
   From   dbo.logAnalisisLSTbl;

   Set @w_idProceso = Isnull(@w_idProceso, 0) + 1;

   While @w_secuencia < @w_registros
   Begin
      Set @w_secuencia = IsNull(@w_secuencia, 0) + 1

      Select @w_DbLink = linkServer
      From   #logAnalisisLSTbl
      Where  secuencia = @w_secuencia;
      If @@Rowcount = 0
         Begin
            Break
        End

      Select @PnEstatus    = 0,
             @PsMensaje    = '',
             @w_Error      = 0,
             @w_desc_error = '';

      If Exists (Select Top 1 1
                 From   dbo.logAnalisisLSTbl
                 Where  servidor   = @w_server
                 And    linkServer = @w_DbLink
                 And    Datediff(mi, fechaTermino, @w_fechaAct) < @w_minutosEspera)
         Begin
            Goto Siguiente
         End

      Select @w_sql   = 'Select  @w_output = count(1) '    +
                        'From [' + Rtrim(Ltrim(@w_DbLink)) + '].' + Rtrim(Ltrim(@w_baseDatos)) + '.dbo.' + @w_tabla,
             @w_param = '@w_output Integer Output'

      Begin Try
         Execute SP_ExecuteSQL  @w_sql, @w_param, @w_output = @w_salida Output
      End   Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 230),
                 @w_linea      = error_line();

      End   Catch

      If IsNull(@w_Error, 0) <> 0
         Begin
            Select @PnEstatus = @w_Error,
                   @PsMensaje = Concat('Error.: ', @w_Error, '. ', @w_desc_error, ' En Línea: ', @w_linea);
         End

     If  Isnull(@w_salida, 0) = 0 Or
         @PnEstatus       != 0
         Begin
            Insert into dbo.logAnalisisLSTbl
            (idProceso, secuencia,   servidor,   linkServer,
             actividad, fechaInicio, error,      mensajeError)
            Select @w_idProceso, secuencia,   servidor,    linkServer,
                   actividad,    fechaInicio, @PnEstatus,  @PsMensaje
            From   #logAnalisisLSTbl
            Where  secuencia    = @w_secuencia;
            Set @w_insert = @w_insert + @@Rowcount;

        End

     Select @PnEstatus = 0,
            @PsMensaje = '';

Siguiente:

   End

   If @w_insert = 0
      Begin
         Goto Salida
      End

   Set @w_incidencia = 'INCIDENCIA CON LINKED SERVER ';

   Set @w_parametros = Concat(@w_grupoCorreo,  '|', @w_server,       '|',
                              @w_ip,           '|', @w_instancia,    '|',
                              @w_ambiente,     '|', @w_baseDatos,    '|',
                              @w_idAplicacion, '|', @w_incidencia,   '|',
                              @w_idProceso,    '|', @w_tablaLog,     '|',
                              @w_registros);

   Execute dbo.Spa_conProcesosTbl @PnIdMotivo           = @w_idMotivoCorreo,
                                  @PnIdTipoNotificacion = @w_idTipoNotificacion,
                                  @PsParametros         = @w_parametros,
                                  @PsURL                = '',
                                  @PdFechaProgramada    = @w_fechaAct,
                                  @PnIdUsuarioAct       = @w_idUsuarioAct,
                                  @PnEstatus            = @PnEstatus  Output,
                                  @PsMensaje            = @PsMensaje  Output

   If @PnEstatus = 0
      Begin
         Begin Try
            Update dbo.logAnalisisLSTbl
            Set    informado    = 1,
                   fechaTermino = Getdate()
            Where  idProceso = @w_idProceso;
         End Try

         Begin Catch
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230),
                    @w_linea      = error_line()

         End   Catch

         If IsNull(@w_Error, 0) <> 0
            Begin
               Select @PnEstatus = @w_Error,
                      @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' En Línea ', @w_linea);

            End

      End

   Begin Try
      Update dbo.catControlProcesosTbl
      Set    ultFechaEjecucion = Getdate()
      Where  idProceso         = 11;
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230),
              @w_linea      = error_line()

   End   Catch

   If IsNull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' En Línea ', @w_linea);

      End

Salida:

   Set Xact_Abort    Off
   Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Proceso de Análisis y Validación de Link Server.',
   @w_procedimiento  Varchar( 100) = 'Spp_AnalisisLinkServer'


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
