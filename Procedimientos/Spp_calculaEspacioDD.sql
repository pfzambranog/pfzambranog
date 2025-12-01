USE [SCMBD]
GO

/*
Declare
   @PnEstatus               Integer      = 0,
   @PsMensaje               Varchar(250) = Null

Begin
   Execute dbo.Spp_calculaEspacioDD @PnEstatus = @PnEstatus     Output,
                                    @PsMensaje = @PsMensaje     Output;

   Select @PnEstatus, @PsMensaje

   Return

End
Go
*/

Create or Alter Procedure dbo.Spp_calculaEspacioDD
  (@PnEstatus               Integer      = 0    Output,
   @PsMensaje               Varchar(250) = Null Output)
As

Declare
   @w_error                 Integer,
   @w_desc_error            Varchar(  250),
   @w_indice                Varchar(  100),
   @w_server                Varchar(  100),
   @w_usuario               Varchar(  Max),
   @w_idMotivoCorreo        Smallint,
   @w_idAplicacion          Smallint,
   @w_idTipoNotificacion    Tinyint,
   @w_idEstatus             Tinyint,
   @w_tiempo                Integer,
   @w_idUsuarioAct          Integer,
   @w_grupoCorreo           Varchar(   20),
   @w_ambiente              Varchar(  250),
   @w_incidencia            Varchar(  850),
   @w_parametros            Varchar(  Max),
   @w_proceso               Varchar(  100),
   @w_ip                    Varchar(   20),
   @w_query                 Varchar( 1000),
   @w_sql                   NVarchar(4000),
   @w_param                 NVarchar( 750),
   @w_servidor              Sysname,
   @w_tablaLog              Sysname,
   @w_dbname                Sysname,
   @w_instancia             Sysname,
   @w_base                  Sysname,
   @w_objeto                Sysname,
   @w_fechaAct              Datetime,
   @w_idProceso             Integer,
   @w_secuencia             Integer,
   @w_minimoDispo           Decimal(18, 2),
   @w_totaldisponible       Varchar(20),
   @w_porcentajeLibre       Varchar(20),
   @w_minutosEspera         Integer;

Declare
   @w_tabla          Table
   (totalEspacio     Decimal(18, 2),
    totaldisponible  Decimal(18, 2),
    porcentajeLibre  Decimal(18, 2) Default 0)

Begin
/*

Objetivo:    Validación espacio disponible en disco duro.
Programador: Pedro Felipe Zambrano
Fecha:       08/09/2025
Versión:     1

*/

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off

--
-- Inicializamos Variables
--

   Select @PnEstatus            = 0,
          @PsMensaje            = '',
          @w_server             = @@ServerName,
          @w_servidor           = @@ServerName,
          @w_instancia          = @@servicename,
          @w_idMotivoCorreo     = 110,
          @w_idAplicacion       = 27,
          @w_secuencia          = 0,
          @w_fechaAct           = Getdate(),
          @w_dbname             = Db_name(),
          @w_ip                 = dbo.Fn_buscaDireccionIP(),
          @w_indice             = Substring('IDX_' + Replace(Cast(newid() As Varchar(100)), '-', ''), 1, 30);


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

   Select @w_minimoDispo = parametroNumber
   From   dbo.conParametrosGralesTbl
   Where  idParametroGral = 18
   If @@Rowcount = 0
      Begin
         Set @w_minimoDispo = 10.00
      End

   Select @w_grupoCorreo        = codigoGrupoCorreo,
          @w_idTipoNotificacion = idTipoNotificacion,
          @w_tablalOG           = tablaLog,
          @w_proceso            = descripcion,
          @w_idEstatus          = idEstatus
   From   dbo.catControlProcesosTbl
   Where  idProceso = 17
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
--
-- Inicio Proceso
--

   Update dbo.catControlProcesosTbl
   Set    ultFechaEjecucion = Getdate()
   Where  idProceso = 17

   Insert Into @w_tabla
   (totalEspacio, totaldisponible)
   Select Top 1 Round(((total_bytes /1048576.0) / 1024), 2) totalEspaciodd,
          Round(((available_bytes /1048576.0) / 1024), 2) available_bytes
   From   sys.master_files f
   Cross  Apply sys.dm_os_volume_stats(f.database_id, f.file_id);

   Update @w_tabla
   Set    porcentajeLibre = (totaldisponible / totalEspacio) * 100.00


   If Exists ( Select Top 1 1
               From   @w_tabla
               Where  porcentajeLibre > @w_minimoDispo)
      Begin
         Goto Salida
      End

   Select @w_porcentajeLibre = Concat(Format(porcentajeLibre, 'N', 'en-us'), '%'), 
          @w_totaldisponible = Concat(Format(totaldisponible, 'N', 'en-us'), 'GB')
   From   @w_tabla;

   Select @PnEstatus = 97,
          @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus),
          @w_objeto  = Concat('Espacio Disponible ', totaldisponible, ' GB')
   From   @w_tabla;

   Insert Into dbo.logProcesosEspacioDDTbl
   (servidor,             fechaInicio, totalEspacio, totaldisponible,
    porcentajeDisponible, error,       mensajeError)
   Select @w_servidor,         @w_fechaAct, totalEspacio, totaldisponible,
          porcentajeLibre,     @PnEstatus,        @PsMensaje
   From   @w_tabla a
   Where  Not Exists (Select Top 1 1
                      From   dbo.logProcesosEspacioDDTbl
                      Where  servidor                                = @w_servidor
                      And    Datediff(mi, fechaTermino, @w_fechaAct) < @w_minutosEspera);
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 0,
                @PsMensaje = '';

         Goto Salida
      End

   Set @w_idProceso = @@Identity

   Select @PnEstatus = 0,
          @PsMensaje = '';
   Set @w_incidencia = Concat('Espacio en Disco Duro Requiere Atención en ', @w_server);

   Set @w_parametros = Concat(@w_grupoCorreo,   '|', @w_server,          '|',
                              @w_ip,            '|', @w_instancia,       '|',
                              @w_ambiente,      '|', @w_idAplicacion,    '|',
                              @w_incidencia,    '|', @w_idProceso,       '|',
                              @w_tablaLog,      '|', @w_totaldisponible, '|',
                              @w_porcentajeLibre);

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
         Update dbo.logProcesosEspacioDDTbl
         Set    fechaTermino   = Getdate(),
                informado      = 1
         From   dbo.logProcesosEspacioDDTbl a
         Where  a.idProceso    = @w_idProceso;
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
   @w_valor          Varchar(1500) = 'Consulta el Espacio de DD en el servidor de BD.',
   @w_procedimiento  Varchar( 100) = 'Spp_calculaEspacioDD'


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



