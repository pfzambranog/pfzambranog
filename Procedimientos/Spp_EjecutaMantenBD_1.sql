Use SCMBD
Go

/*
Declare
   @w_idProceso           Integer      = 0,
   @PnEstatus             Integer      = 0,  
   @PsMensaje             Varchar(250) = Null;

Begin
   Select @w_idProceso = Max(idProceso)
   From   SMBDTI.dbo.logMantenimientoBDTbl

   Execute Spp_EjecutaMantenBD_1 @PnEstatus = @PnEstatus Output,
                                 @PsMensaje = @PsMensaje Output

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

   Select *
   From   SMBDTI.dbo.logMantenimientoBDTbl
   Where  idProceso > @w_idProceso

   Return

End
Go 
                
*/

Create Or Alter Procedure Spp_EjecutaMantenBD_1
  (@PnEstatus             Integer      = 0     Output,  
   @PsMensaje             Varchar(250) = Null  Output)                
As

Declare
   @w_error          Integer,
   @w_desc_error     Varchar(250),
   @w_dbName         Sysname,
   @w_procedure      Sysname,
   @w_sql            NVarchar(1500),
   @w_param          NVarchar( 750),
   @w_Existe         Tinyint,
   @w_comilla        Char(1),
   @w_servidor       Sysname;
   
Declare
   C_BaseIni Cursor For
   Select name
   From   sys.databases
   Where  state_desc = 'ONLINE'
   And    name   Not In ('master', 'tempdb', 'model', 'msdb');

Begin
/*

Objetivo:    Análiza, Valida y ejecuta Mantenimiento a las BD online en la instancia.
Programador: Pedro Felipe Zambrano
Fecha:       06/05/2022

*/ 

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off  

--
-- Incializamos Variables
--
                         
   Select @PnEstatus        = 0,
          @PsMensaje        = Null,
          @w_comilla        = Char(39);

   Begin Try 
      Update catControlProcesosTbl
      Set    ultFechaEjecucion = Getdate()
      Where  idProceso         = 1;
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

   Open  C_BaseIni
   While @@Fetch_status < 1
   Begin
      Fetch C_BaseIni Into @w_dbName
      If @@Fetch_status != 0
         Begin
            Break
         End

      Select @w_sql    = 'Select @o_existe = Count(Distinct 1) 
                          From   ' + @w_dbName + '.dbo.Sysobjects 
                          Where  Uid  = 1 
                          And    Type = ' + @w_comilla + 'P' + @w_comilla + '
                          And    Name = ' + @w_comilla + 'Spp_MantenimientoBD_1' + @w_comilla,
             @w_param  = '@o_existe   Tinyint Output',
             @w_Existe = 0;

     Execute Sp_ExecuteSQL @w_sql, @w_param, @o_existe = @w_existe Output

     If Isnull(@w_existe, 0) = 1
        Begin
           Set @w_procedure = @w_dbName + '.dbo.Spp_MantenimientoBD_1 '
           Execute @w_procedure @PsDbName   = @w_dbName,
                                @PnEstatus  = @PnEstatus Output,
                                @PsMensaje  = @PsMensaje Output

           If @PnEstatus != 0
              Begin
                 Select @PnEstatus, @PsMensaje
              End

        End
 
   End

   Close      C_BaseIni
   Deallocate C_BaseIni

   Set Xact_Abort Off
   Return

End 
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Análiza, Valida y ejecuta Mantenimiento a las BD online en la instancia.',
   @w_procedimiento  Varchar( 100) = 'Spp_EjecutaMantenBD_1'


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
