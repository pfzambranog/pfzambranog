Use SCMBD
Go

/*
Declare
   @w_idProceso           Integer      = 0,
   @PnEstatus             Integer      = 0,  
   @PsMensaje             Varchar(250) = Null;

Begin
   Select @w_idProceso = Max(idProceso)
   From   SMBDTI.dbo.logMantenimientoDepTablaTbl

   Execute Spp_MantenimientoDepuraTablas @PnEstatus = @PnEstatus Output,
                                         @PsMensaje = @PsMensaje Output

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

   Select *
   From   SMBDTI.dbo.logMantenimientoDepTablaTbl
   Where  idProceso > Isnull(@w_idProceso, 0)

   Return

End
Go 

*/

Create Or Alter Procedure dbo.Spp_MantenimientoDepuraTablas
  (@PnEstatus             Integer      = 0     Output,  
   @PsMensaje             Varchar(250) = Null  Output)
As

Declare
   @w_error             Integer,
   @w_desc_error        Varchar(250),
   @w_usuario           Varchar(Max),
   @w_baseDatos         Sysname,
   @w_tabla             Sysname,
   @w_campo             Sysname,
   @w_procedimiento     Sysname,
   @w_sql               NVarchar(1500),
   @w_param             NVarchar( 750),
   @w_comilla           Char(1),
   @w_fechaInicio       Datetime,
   @w_fechaComp         Date,
   @w_servidor          Sysname,
   @w_dias              Integer,
   @w_registros         Integer,
   @w_idProceso         Integer,
   @w_idProcesoLog      Integer,
   @w_idUsuarioAct      Integer;

Declare
   C_DepPaso1 Cursor For
   Select idProceso, baseDatos, tabla, campo, dias
   From   dbo.catMantenimentoTablasTbl a
   Where  servidor  = @@ServerName
   And    idTipoDep = 1
   And    idEstatus = 1
   And    Exists    ( Select Top 1 1
                      From   sys.databases
                      Where  state_desc = 'ONLINE'
                      And    name       = a.baseDatos);

Declare
   C_DepPaso2 Cursor For
   Select idProceso, baseDatos, tabla, Concat(a.baseDatos, '.dbo.', a.procedimiento), dias
   From   dbo.catMantenimentoTablasTbl a
   Where  servidor  = @@ServerName
   And    idTipoDep = 2
   And    idEstatus = 1
   And    Exists    ( Select Top 1 1
                      From   sys.databases
                      Where  state_desc = 'ONLINE'
                      And    name       = a.baseDatos);

Begin
/*

Objetivo:    Procedimiento de Depuración de datos en tablas incluidas en la entidad catMantenimentoTablasTbl.
Programador: Pedro Felipe Zambrano
Fecha:       06/05/2025

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

   Begin Try 
      Update dbo.catControlProcesosTbl
      Set    ultFechaEjecucion = Getdate()
      Where  idProceso         = 13;
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

   Select @w_usuario = parametroChar        
   From   dbo.conParametrosGralesTbl      
   Where  idParametroGral = 8
   
   Select @w_sql   = 'Select @o_usuario = dbo.Fn_Desencripta_cadena(' + @w_usuario + ') ',        
          @w_param = '@o_usuario Varchar(Max) Output '        
   
   Execute Sp_ExecuteSQL @w_sql, @w_param, @o_usuario = @w_usuario Output        
   
   Set @w_idUsuarioAct = Cast(@w_usuario As Integer) 

   Open  C_DepPaso1
   While @@Fetch_status < 1
   Begin
      Fetch C_DepPaso1 Into @w_idProceso, @w_baseDatos, @w_tabla, @w_campo, @w_dias
      If @@Fetch_status != 0
         Begin
            Break
         End

      Select @w_fechaInicio = Getdate(),
             @PnEstatus     = 0,
             @PsMensaje     = '',
             @w_registros   = 0;

      Begin Try
         Insert Into dbo.logMantenimientoDepTablaTbl
         (servidor, baseDatos, tabla)
         Select @w_servidor, @w_baseDatos, @w_tabla

         Set @w_idProcesoLog = @@Identity
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,    
                 @w_desc_error = Substring (Error_Message(), 1, 230)
      End   Catch
                     
      If Isnull(@w_Error, 0)  <> 0
         Begin                  
            Select @PnEstatus  = @w_Error,    
                   @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

            Goto Siguiente
         End
         
      Select @w_dias      = @w_dias * -1,
             @w_fechaComp = DateAdd(dd, @w_dias, Cast(@w_fechaInicio As Date))


      Set @w_sql = 'Delete ' + @w_baseDatos + '.dbo.' + @w_tabla + '
                    Where  Cast(' + @w_campo  + ' As Date) <= ' + @w_comilla + Cast(@w_fechaComp As Varchar) + @w_comilla 

      Begin Try
         Execute(@w_sql)
         Set @w_registros = @@Rowcount
      End   Try

      Begin Catch
         Select  @w_Error      = @@Error,    
                 @w_desc_error = Substring (Error_Message(), 1, 230)
      End   Catch
                     
      If Isnull(@w_Error, 0)  <> 0
         Begin                  
            Select @PnEstatus  = @w_Error,
                   @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error;
         End

Siguiente:

      Update dbo.logMantenimientoDepTablaTbl
      Set    registros    = Isnull(@w_registros, 0),
             fechaTermino = Getdate(),
             error        = @PnEstatus,
             mensajeError = @PsMensaje
      Where  idProceso = @w_idProcesoLog

      Update dbo.catMantenimentoTablasTbl
      Set    ultFechaProceso = Getdate()
      Where  idProceso = @w_idProceso


   End

   Close      C_DepPaso1
   Deallocate C_DepPaso1

   Open  C_DepPaso2
   While @@Fetch_status < 1
   Begin
      Fetch C_DepPaso2 Into @w_idProceso, @w_baseDatos, @w_tabla, @w_procedimiento, @w_dias
      If @@Fetch_status != 0
         Begin
            Break
         End

      Select @w_fechaInicio = Getdate(),
             @PnEstatus     = 0,
             @PsMensaje     = '',
             @w_registros   = 0;

      Begin Try
         Insert Into dbo.logMantenimientoDepTablaTbl
         (servidor, baseDatos, tabla)
         Select @w_servidor, @w_baseDatos, @w_tabla

         Set @w_idProcesoLog = @@Identity
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,    
                 @w_desc_error = Substring (Error_Message(), 1, 230)
      End   Catch
                     
      If Isnull(@w_Error, 0)  <> 0
         Begin                  
            Select @PnEstatus  = @w_Error,    
                   @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error

            Goto SiguienteProc
         End

      Select @w_dias      = @w_dias * -1,
             @w_fechaComp = DateAdd(dd, @w_dias, Cast(@w_fechaInicio As Date))


     Execute @w_procedimiento @PdFechaBase    = @w_fechaComp,
                              @PnIdUsuarioAct = @w_idUsuarioAct,
                              @PnEstatus      = @PnEstatus  Output,
                              @PsMensaje      = @PsMensaje  Output;

     If Isnumeric(@PsMensaje) = 1
        Begin
           Select @w_registros = Cast(@PsMensaje As Integer),
                  @PsMensaje   = ''
        End

SiguienteProc:

      Update dbo.logMantenimientoDepTablaTbl
      Set    registros    = Isnull(@w_registros, 0),
             fechaTermino = Getdate(),
             error        = @PnEstatus,
             mensajeError = @PsMensaje
      Where  idProceso = @w_idProcesoLog

      Update dbo.catMantenimentoTablasTbl
      Set    ultFechaProceso = Getdate()
      Where  idProceso = @w_idProceso


   End

   Close      C_DepPaso2
   Deallocate C_DepPaso2


   Set Xact_Abort Off
   Return

End 
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Depuración de datos en tablas incluidas en la entidad catMantenimentoTablasTbl.',
   @w_procedimiento  NVarchar(250) = 'Spp_MantenimientoDepuraTablas';

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

  

