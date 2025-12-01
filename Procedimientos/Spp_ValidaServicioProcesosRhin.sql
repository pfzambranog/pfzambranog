Use SCMBD
Go

/*
Declare
   @PnEstatus      Integer      = Null,
   @PsMensaje      Varchar(250) = Null,
   @w_idProceso    Integer      = 0;

Begin
   Select @w_idProceso = Max(idProceso)
   From   dbo.logProcesosRhinTbl

   Execute dbo.Spp_ValidaServicioProcesosRhin @PnEstatus = @PnEstatus Output,
                                              @PsMensaje = @PsMensaje Output;

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

   Select *
   From   dbo.logProcesosRhinTbl
   Where  idProceso > Isnull(@w_idProceso, 0);

   Return
End
Go


*/

Create or Alter Procedure dbo.Spp_ValidaServicioProcesosRhin
  (@PdFechaProceso Date         = Null,
   @PnEstatus      Integer      = Null Output,
   @PsMensaje      Varchar(250) = Null Output)
As

Declare
   @w_error             Integer,
   @w_desc_error        Varchar(  250),
   @w_fechaAct          Datetime,
   @w_fechaInicio       Datetime,
   @w_fecha             Integer,
   @w_registros         Integer,
   @w_idEstatus         Tinyint,
   @w_minutos           Tinyint,
   @w_secuencia         Integer,
   @w_idProceso         Integer,
   @w_idProcesoRhin     Integer,
   @w_reg               Integer;

Begin
/*
Objetivo: Procedimiento de Validación de los Monitores de Rhin.

Programador: Pedro Felipe Zambrano
Fecha:       06/05/2022

*/
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off  

--
-- Inicializamos Variables
--

   Select @PnEstatus        = 0,    
          @PsMensaje        = Null,
          @w_minutos        = 10,
          @w_secuencia      = 0,
          @w_idProceso      = 0,
          @w_fechaAct       = Getdate(),
          @PdFechaProceso   = Isnull(@PdFechaProceso, @w_fechaAct),
          @w_fecha          = Cast(Convert(Char(10), @PdFechaProceso, 112) As Integer);

   If Not Exists (Select Top 1 1 
                  From   dbo.catControlProcesosTbl
                  Where  idProceso         = 14
                  And    idEstatus         = 1)
      Begin
         Set Xact_Abort    Off
         Return
      End

   Select @w_idEstatus = state
   From   sys.databases
   Where  name       = 'RHIN'
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
   
   Begin Try 
      Update dbo.catControlProcesosTbl
      Set    ultFechaEjecucion = Getdate()
      Where  idProceso         = 14;
   End Try

   Begin Catch    
      Select  @w_Error      = @@Error,    
              @w_desc_error = Substring (Error_Message(), 1, 230)
  
   End   Catch    
 
   If IsNull(@w_Error, 0) <> 0    
      Begin    
         Select @PnEstatus = @w_Error,    
                @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error  

         Set Xact_Abort Off
         Return
      End

   Select @w_idEstatus = state
   From   sys.databases
   Where  name       = 'RHIN'
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

   Create table #TmpProcesosRhin
   (secuencia          Integer   Not Null Identity (1, 1) Primary Key,
    tabla              Sysname   Not Null,
    idProceso          Integer   Not Null,
    idEstatus          Tinyint   Not Null  Default 1,
    fechaInicioProceso Datetime  Not Null  Default Getdate(),
    informar           Bit       Not Null  Default 0)

   Insert Into #TmpProcesosRhin
   (tabla, idProceso)
   Select 'nomProcesosTbl', idProceso
   From   rhin.dbo.nomProcesosTbl
   Where  idEstatus = 1

   Set  @w_registros = @@Rowcount

   Insert Into #TmpProcesosRhin
   (tabla, idProceso, idEstatus, fechaInicioProceso)
   Select 'nomProcesosTbl', idProceso, idEstatus, fechaInicio 
   From   rhin.dbo.nomProcesosTbl
   Where  idEstatus = 2
   Set  @w_registros = @w_registros + @@Rowcount

   If @w_registros = 0
      Begin
         Select @PnEstatus = 0,
                @PsMensaje = ''

         Set Xact_Abort    Off
         Return
      End

   While @w_secuencia < @w_registros 
   Begin
      Set @w_secuencia = @w_secuencia + 1

      Select @w_fechaInicio     = fechaInicioProceso,
             @w_idProcesoRhin   = idProceso,
             @w_idEstatus       = idEstatus
      From   #TmpProcesosRhin
      Where  secuencia = @w_secuencia
      If @@Rowcount = 0
         Begin
            Break
         End

      If @w_idEstatus = 2
         Begin
            If DateDiff(mi, @w_fechaInicio, Getdate()) >= @w_minutos
               Begin
                  Update #TmpProcesosRhin
                  Set    informar  = 1
                  Where  secuencia = @w_secuencia
               End
         End
      Else
         Begin
            Select @w_fechaInicio = fechaInicio
            From   dbo.logProcesosRhinDetTbl
            Where  idProcesoRhin = @w_idProcesoRhin
            Set @w_reg = @@Rowcount

            If @w_reg != 0
               Begin
                  If DateDiff(mi, @w_fechaInicio, Getdate()) >= @w_minutos
                     Begin
                        Update #TmpProcesosRhin
                        Set    informar  = 1
                        Where  secuencia = @w_secuencia
                     End
               End

            If @w_reg = 0
               Begin
                  If @w_idProceso = 0
                     Begin
                        Insert Into logProcesosRhinTbl
                        (actividad, error, mensajeError)
                        Select 'VALIDACIÓN DE PROCESOS RHIN', 1, 'HAY CALCULOS EN ESPERA'
                     End

                  Set @w_idProceso = @@Identity

                  Insert Into logProcesosRhinDetTbl
                  (idProceso, idProcesoRhin, error, mensajeError)
                  Select @w_idProceso, @w_idProcesoRhin, 1, 'CALCULO EN ESTATUS DE ESPERA.'
               End
         End
   End

   If Exists ( Select Top 1 1
               From   #TmpProcesosRhin
               Where  informar  = 1)
      Begin
         Update #TmpProcesosRhin
         Set    informar        = 0
         From   dbo.logProcesosRhinDetTbl a
         Join   #TmpProcesosRhin      b 
         On     a.idProcesoRhin = b.idProceso
         And    b.informar      = 1
     End

   If Exists ( Select Top 1 1
               From   #TmpProcesosRhin
               Where  informar  = 1)
      Begin
         If @w_idProceso = 0
            Begin
               Begin Try
                  Insert Into dbo.logProcesosRhinTbl
                  (actividad, error, mensajeError)
                  Select 'VALIDACIÓN DE PROCESOS RHIN', 1, 'HAY CALCULOS EN ESPERA'
                  Set @w_idProceso = @@Identity
               End Try

               Begin Catch                            
                  Select  @w_Error      = @@Error,
                          @w_desc_error = Substring (Error_Message(), 1, 230)                            
               End Catch                            
                               
               If Isnull(@w_Error, 0)  <> 0                            
                  Begin                   
                     Select @PnEstatus  = @w_Error,
                            @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error          
                      
                     Set Xact_Abort Off                                
                     Return          
                  End   

            End

         Begin Try
            Insert Into dbo.logProcesosRhinDetTbl
            (idProceso, idProcesoRhin, error, mensajeError)
            Select @w_idProceso, idProceso, 2, 'CALCULO EN ESTATUS 2 SIN TERMINAR'
            From   #TmpProcesosRhin
            Where  informar  = 1
        
         End Try

         Begin Catch                            
            Select  @w_Error      = @@Error,
                    @w_desc_error = Substring (Error_Message(), 1, 230)                            
         End Catch                            
                         
         If Isnull(@w_Error, 0)  <> 0                            
            Begin                   
               Select @PnEstatus  = @w_Error,
                      @PsMensaje  = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error          
                
               Set Xact_Abort Off                                
               Return          
            End   

      End

   Set Xact_Abort    Off
   Return

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Validación de los Monitores de Rhin.',
   @w_procedimiento  NVarchar(250) = 'Spp_ValidaServicioProcesosRhin';

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
